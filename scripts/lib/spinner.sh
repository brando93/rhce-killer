#!/usr/bin/env bash
# scripts/lib/spinner.sh
#
# Phased progress-bar UI primitives.
# Used by scripts/lab-up.sh and any future tooling that wants a clean,
# spinner+bar status line instead of dumping raw command output.
#
# Public API:
#   format_duration <seconds>            -> "Xs" or "XmYYs"
#   make_bar <pct>                       -> "█████··············" (BAR_WIDTH chars)
#   render_line <marker> <label> <pct> <elapsed> <color>
#   finalize_line ok|fail <label> <start_ts>
#   hide_cursor / show_cursor            -> TTY-only
#   dump_log_tail <logfile> [n]          -> last N lines on failure
#   run_phase <label> <logfile> <cmd...> -> bg + spinner, fixed pct (no progress)
#   spin_at_pct <start> <pct> <label> <color> <cmd...>
#                                        -> bg + spinner at a fixed pct
#
# Expected environment (set by caller before sourcing or before calling):
#   BAR_WIDTH      (default 20)
#   LABEL_WIDTH    (default 36)
#
# Color variables NC, B, DIM, G, R, Y, C and IS_TTY are exported by this lib.

set -u

# ───── styling ─────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    NC=$'\e[0m'; B=$'\e[1m'; DIM=$'\e[2m'
    G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; C=$'\e[36m'
    IS_TTY=1
else
    NC=""; B=""; DIM=""; G=""; R=""; Y=""; C=""
    IS_TTY=0
fi

SPIN_CHARS=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

: "${BAR_WIDTH:=20}"
: "${LABEL_WIDTH:=36}"

# ───── small utilities ────────────────────────────────────────────────

format_duration() {
    local s=$1
    if (( s < 60 )); then
        printf "%ds" "$s"
    else
        printf "%dm%02ds" $((s / 60)) $((s % 60))
    fi
}

# Build a bar of width $BAR_WIDTH filled to a given percentage (0..100).
make_bar() {
    local pct="$1"
    (( pct > 100 )) && pct=100
    (( pct < 0   )) && pct=0
    local filled=$(( pct * BAR_WIDTH / 100 ))
    local empty=$(( BAR_WIDTH - filled ))
    local bar="" i
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="·"; done
    printf '%s' "$bar"
}

# Render a status line. Args: marker label pct elapsed_s color
render_line() {
    local marker="$1" label="$2" pct="$3" elapsed="$4" color="$5"
    if (( IS_TTY )); then
        printf "\r      ${color}%s${NC} %-*s [${color}%s${NC}] ${DIM}%s${NC}\e[K" \
            "$marker" "$LABEL_WIDTH" "$label" \
            "$(make_bar "$pct")" "$(format_duration "$elapsed")"
    else
        printf "      %s %s [%s] %s\n" \
            "$marker" "$label" "$(make_bar "$pct")" "$(format_duration "$elapsed")"
    fi
}

# Finalize a phase line: write a final ✓/✗ at 100% and newline.
# Args: ok|fail label start_ts
finalize_line() {
    local status="$1" label="$2" start="$3"
    local elapsed=$(( $(date +%s) - start ))
    if [[ "$status" == "ok" ]]; then
        render_line "✓" "$label" 100 "$elapsed" "$G"
    else
        render_line "✗" "$label" 0 "$elapsed" "$R"
    fi
    (( IS_TTY )) && printf '\n'
}

hide_cursor() { (( IS_TTY )) && printf '\e[?25l'; }
show_cursor() { (( IS_TTY )) && printf '\e[?25h'; }

# Dump last N lines of a log on failure.
dump_log_tail() {
    local logfile="$1" n="${2:-30}"
    echo
    echo "      ${DIM}─── last $n lines of $logfile ───${NC}"
    tail -n "$n" "$logfile" 2>/dev/null | sed 's|^|      |'
}

# ───── background-command spinners ────────────────────────────────────

# Run a command in the background while showing a spinner at a fixed pct.
# Args: start_ts pct label color cmd...
spin_at_pct() {
    local start="$1"; shift
    local pct="$1";   shift
    local label="$1"; shift
    local color="$1"; shift

    "$@" &
    local pid=$!
    hide_cursor
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        local elapsed=$(( $(date +%s) - start ))
        render_line "${SPIN_CHARS[i]}" "$label" "$pct" "$elapsed" "$color"
        i=$(( (i + 1) % ${#SPIN_CHARS[@]} ))
        sleep 0.1
    done
    local rc=0
    wait "$pid" || rc=$?
    show_cursor
    return $rc
}
