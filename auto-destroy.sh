#!/usr/bin/env bash
#
# Auto-destroy RHCE Killer lab after a configurable period of inactivity.
#
# Born after the author left the lab running overnight and got billed for it.
#
# Subcommands:
#   start    Run as daemon (default if no arg given)
#   stop     Stop a running daemon
#   status   Show daemon state (running/stopped/last activity)
#   run      Run in foreground (for debugging)
#
# Environment overrides:
#   INACTIVITY_TIMEOUT_SEC  default 3600 (1h)
#   CHECK_INTERVAL_SEC      default 300  (5min)
#
# Activity is defined as: at least one SSH session connected to the control
# node (`who | wc -l > 0`). When the lab has been idle for longer than
# INACTIVITY_TIMEOUT_SEC, the daemon runs `bash scripts/lab-up.sh destroy`
# (same robust destroy used by `make destroy`).

set -uo pipefail

INACTIVITY_TIMEOUT_SEC="${INACTIVITY_TIMEOUT_SEC:-3600}"
CHECK_INTERVAL_SEC="${CHECK_INTERVAL_SEC:-300}"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="${REPO_DIR}/.auto-destroy.pid"
LOG_FILE="${REPO_DIR}/.auto-destroy.log"
ACTIVITY_FILE="${REPO_DIR}/.auto-destroy.activity"

KEY_FILE="${REPO_DIR}/rhce-killer.pem"

# ───── styling (only when stdout is a TTY) ────────────────────────────
if [[ -t 1 ]]; then
    NC=$'\e[0m'; G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; C=$'\e[36m'
else
    NC=""; G=""; R=""; Y=""; C=""
fi

log() {
    local msg="$*"
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$ts] $msg"
    echo "[$ts] $msg" >> "$LOG_FILE"
}

get_control_ip() {
    (cd "${REPO_DIR}/terraform" \
        && terraform output -raw control_public_ip 2>/dev/null)
}

# Returns 0 if at least one SSH session is currently connected to the
# control node, 1 otherwise.
check_activity() {
    local ip
    ip="$(get_control_ip)"
    [[ -z "$ip" ]] && return 2  # lab not up

    local n
    n=$(ssh -i "$KEY_FILE" \
            -o StrictHostKeyChecking=no \
            -o BatchMode=yes \
            -o ConnectTimeout=5 \
            "rocky@$ip" "who | wc -l" 2>/dev/null | tr -d ' ')
    [[ -z "$n" || ! "$n" =~ ^[0-9]+$ ]] && return 1
    (( n > 0 ))
}

# Run the same destroy that `make destroy` uses (with progress + verify).
trigger_destroy() {
    log "${R}⚠  Inactivity threshold reached — triggering destroy${NC}"
    cd "$REPO_DIR" || exit 1
    if bash scripts/lab-up.sh destroy >> "$LOG_FILE" 2>&1; then
        log "${G}✓ Lab destroyed. Saved \$\$\$ on idle EC2/NAT GW.${NC}"
    else
        log "${R}✗ Destroy failed. See $LOG_FILE${NC}"
    fi
    rm -f "$ACTIVITY_FILE" "$PID_FILE"
}

# ───── core monitoring loop ───────────────────────────────────────────
monitor_loop() {
    log "Auto-destroy daemon started (pid $$, timeout ${INACTIVITY_TIMEOUT_SEC}s, check every ${CHECK_INTERVAL_SEC}s)"
    date +%s > "$ACTIVITY_FILE"

    while true; do
        local now last inactive remaining
        now=$(date +%s)
        last=$(cat "$ACTIVITY_FILE" 2>/dev/null || echo "$now")
        inactive=$((now - last))
        remaining=$((INACTIVITY_TIMEOUT_SEC - inactive))

        check_activity
        local rc=$?
        case $rc in
            0)
                # SSH session detected — refresh activity timestamp
                date +%s > "$ACTIVITY_FILE"
                local min=$(( INACTIVITY_TIMEOUT_SEC / 60 ))
                log "${G}● active SSH session — countdown reset (next destroy in ≥${min}min)${NC}"
                ;;
            1)
                # No active sessions
                if (( inactive >= INACTIVITY_TIMEOUT_SEC )); then
                    trigger_destroy
                    exit 0
                fi
                log "${Y}○ idle ${inactive}s — destroy in $((remaining / 60))min ${remaining}s${NC}"
                ;;
            2)
                # Lab not up — nothing to monitor; exit cleanly
                log "Lab is not running (terraform has no control_public_ip). Exiting."
                rm -f "$ACTIVITY_FILE" "$PID_FILE"
                exit 0
                ;;
        esac
        sleep "$CHECK_INTERVAL_SEC"
    done
}

# ───── subcommand handlers ────────────────────────────────────────────

cmd_start() {
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "${Y}Auto-destroy is already running (pid $(cat "$PID_FILE")).${NC}"
        echo "Stop it first with: $0 stop"
        exit 1
    fi
    : > "$LOG_FILE"
    nohup bash "$0" run </dev/null >>"$LOG_FILE" 2>&1 &
    local pid=$!
    # Detach from controlling terminal so closing the shell doesn't kill us
    disown 2>/dev/null || true
    echo "$pid" > "$PID_FILE"
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo "${G}✓ Auto-destroy daemon started${NC} (pid $pid)"
        echo
        echo "  Timeout:   ${INACTIVITY_TIMEOUT_SEC}s ($((INACTIVITY_TIMEOUT_SEC / 60))min)"
        echo "  Check:     every ${CHECK_INTERVAL_SEC}s"
        echo "  Log:       $LOG_FILE"
        echo "  Stop:      $0 stop  (or: make auto-destroy-stop)"
        echo "  Status:    $0 status"
    else
        echo "${R}✗ Daemon failed to start. Check $LOG_FILE${NC}"
        rm -f "$PID_FILE"
        exit 1
    fi
}

cmd_stop() {
    if [[ ! -f "$PID_FILE" ]]; then
        echo "${Y}Auto-destroy is not running.${NC}"
        return 0
    fi
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null
        sleep 1
        kill -KILL "$pid" 2>/dev/null || true
        echo "${G}✓ Stopped auto-destroy daemon${NC} (pid $pid)"
    else
        echo "${Y}Stale pidfile (pid $pid no longer running). Cleaning up.${NC}"
    fi
    rm -f "$PID_FILE" "$ACTIVITY_FILE"
}

cmd_status() {
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        local pid
        pid=$(cat "$PID_FILE")
        echo "${G}● Running${NC} (pid $pid)"
        if [[ -f "$ACTIVITY_FILE" ]]; then
            local last now inactive
            last=$(cat "$ACTIVITY_FILE")
            now=$(date +%s)
            inactive=$((now - last))
            echo "  Last activity: $((inactive / 60))min ${inactive}s ago"
            echo "  Will destroy:  in $(( (INACTIVITY_TIMEOUT_SEC - inactive) / 60 ))min if no SSH"
        fi
        echo "  Recent log:"
        tail -n 5 "$LOG_FILE" 2>/dev/null | sed 's|^|    |'
    else
        echo "${Y}○ Not running${NC}"
        [[ -f "$LOG_FILE" ]] && {
            echo "  Last 5 log lines:"
            tail -n 5 "$LOG_FILE" | sed 's|^|    |'
        }
    fi
}

# ───── main ───────────────────────────────────────────────────────────
case "${1:-start}" in
    start)  cmd_start  ;;
    stop)   cmd_stop   ;;
    status) cmd_status ;;
    run)    monitor_loop ;;     # internal: invoked by `start` under nohup
    *)
        echo "Usage: $0 [start|stop|status|run]"
        exit 2
        ;;
esac
