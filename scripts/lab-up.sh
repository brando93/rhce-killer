#!/usr/bin/env bash
# scripts/lab-up.sh
# Clean orchestrator for the RHCE Killer lab lifecycle.
# Subcommands: tf-apply | wait-bootstrap | sync-exams | up | ready
#
# Each phase shows a single status line: spinner + progress bar + elapsed time.
# Underlying tool output (terraform/ssh/scp) is captured to .lab-logs/.
# On failure the last 30 lines of the relevant log are dumped automatically.

set -uo pipefail

# ───── config ──────────────────────────────────────────────────────────
TF_DIR="${TF_DIR:-terraform}"
KEY_FILE="${KEY_FILE:-rhce-killer.pem}"
BOOTSTRAP_TIMEOUT_SEC="${BOOTSTRAP_TIMEOUT_SEC:-600}"
BOOTSTRAP_POLL_SEC="${BOOTSTRAP_POLL_SEC:-5}"
LOG_DIR="${LOG_DIR:-.lab-logs}"
BAR_WIDTH="${BAR_WIDTH:-20}"
LABEL_WIDTH="${LABEL_WIDTH:-36}"

# ───── load UI helpers from shared lib ────────────────────────────────
# Set widths BEFORE sourcing so the lib uses them.
BAR_WIDTH=20
LABEL_WIDTH=36
# shellcheck source=scripts/lib/spinner.sh
source "$(dirname "$0")/lib/spinner.sh"

SSH_OPTS=(-i "$KEY_FILE"
          -o StrictHostKeyChecking=no
          -o BatchMode=yes
          -o ConnectTimeout=5
          -o ServerAliveInterval=60
          -o LogLevel=ERROR)

restore_cursor() { (( IS_TTY )) && printf '\e[?25h'; }
trap restore_cursor EXIT INT TERM

mkdir -p "$LOG_DIR"

# ───── tiny helpers (only those lab-up.sh-specific) ───────────────────

# Bytes-aware portable size getter.
file_size_local() {
    local f="$1"
    stat -c %s "$f" 2>/dev/null || stat -f %z "$f" 2>/dev/null || echo 0
}

# If the failure mentions a resource that no longer exists in AWS
# (someone destroyed it from the console out of band), suggest a
# `terraform refresh` to sync state before retrying.
# Args: $1 logfile
suggest_refresh_recovery() {
    local logfile="$1"
    if grep -qiE "no longer exists|does not exist|InvalidInstanceID.NotFound|InvalidGroup.NotFound|InvalidVpcID.NotFound|InvalidSubnetID.NotFound" \
         "$logfile" 2>/dev/null; then
        echo
        echo "      ${Y}⚠  Terraform state references a resource that no longer exists in AWS.${NC}"
        echo "      The resource was probably deleted from the AWS console out of band."
        echo "      Refresh the state to sync, then retry:"
        echo "        ${C}cd $TF_DIR && terraform apply -refresh-only -auto-approve -var=my_ip=0.0.0.0/0 && cd ..${NC}"
        echo "        ${C}make destroy${NC}"
        echo
    fi
}

# If the failure was a stale Terraform state lock, surface the recovery
# command to the user instead of leaving them to read the log.
# Args: $1 logfile
suggest_lock_recovery() {
    local logfile="$1"
    if grep -q "Error acquiring the state lock" "$logfile" 2>/dev/null; then
        local lock_id
        lock_id=$(grep -m1 -E '^\s*ID:\s+' "$logfile" | awk '{print $2}')
        echo
        echo "      ${Y}⚠  Stale Terraform state lock detected.${NC}"
        if [[ -n "$lock_id" ]]; then
            echo "      Recover with:"
            echo "        ${C}cd $TF_DIR && terraform force-unlock $lock_id && cd ..${NC}"
            echo "        ${C}make up${NC}"
        else
            echo "      Recover with: ${C}cd $TF_DIR && terraform force-unlock <ID>${NC}"
        fi
        echo
    fi
}

# ───── exam discovery ─────────────────────────────────────────────────
discover_exams() {
    COMPLETE_EXAMS=()
    THEMATIC_EXAMS=()
    local d name
    while IFS= read -r d; do
        [[ -n "$d" ]] || continue
        name=$(basename "$d")
        if [[ $name =~ ^exam-[0-9]+$ ]]; then
            COMPLETE_EXAMS+=("$name")
        else
            THEMATIC_EXAMS+=("$name")
        fi
    done < <(find . -maxdepth 2 -name grade.sh 2>/dev/null \
             | sed -e 's|/grade.sh$||' -e 's|^\./||' \
             | sort -u)
}

get_control_ip() {
    (cd "$TF_DIR" && terraform output -raw control_public_ip 2>/dev/null)
}

# ───── phase 1: terraform (init → plan → apply) ───────────────────────

# Watch a terraform apply running in the background. Drives the bar from
# `start_pct` to `end_pct` based on (resources created)/(resources planned).
# Args: pid logfile start_ts label_prefix planned_count start_pct end_pct
watch_tf_apply() {
    local pid="$1" logfile="$2" start="$3" prefix="$4"
    local planned="$5" start_pct="$6" end_pct="$7"

    hide_cursor
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        # Count completed resources. We avoid `grep -c | echo 0` because
        # `grep -c` exits 1 with no matches, so `|| echo 0` would APPEND
        # a second "0" → "0\n0" → arithmetic syntax error. `wc -l` always
        # emits exactly one number and exits 0.
        local done_count
        done_count=$(grep -E 'Creation complete|Modification complete|Destruction complete' "$logfile" 2>/dev/null | wc -l | tr -d ' ')
        [[ -z "$done_count" ]] && done_count=0
        local span=$(( end_pct - start_pct ))
        local pct=$start_pct
        if (( planned > 0 )); then
            pct=$(( start_pct + done_count * span / planned ))
        fi
        (( pct > end_pct - 1 )) && pct=$(( end_pct - 1 ))
        local elapsed=$(( $(date +%s) - start ))
        local label="${prefix} (${done_count}/${planned})"
        render_line "${SPIN_CHARS[i]}" "$label" "$pct" "$elapsed" "$C"
        i=$(( (i + 1) % ${#SPIN_CHARS[@]} ))
        sleep 0.2
    done
    local rc=0
    wait "$pid" || rc=$?
    show_cursor
    return $rc
}

do_tf_apply() {
    local logfile="$LOG_DIR/01-tf-apply.log"
    : > "$logfile"

    local start
    start=$(date +%s)

    # Detect public IP first (separate from the bar).
    local my_ip
    my_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || true)
    if [[ -z "$my_ip" ]]; then
        echo "      ${R}✗${NC} could not detect public IP via curl ifconfig.me"
        return 1
    fi
    my_ip="${my_ip}/32"
    local label_prefix="Terraform apply (${my_ip})"

    # Sub-step 1 (0–10%): init
    spin_at_pct "$start" 5 "Terraform init" "$C" \
        bash -c "cd '$TF_DIR' && terraform init -upgrade -input=false >>'$PWD/$logfile' 2>&1"
    local rc=$?
    if (( rc != 0 )); then
        finalize_line fail "Terraform init" "$start"
        dump_log_tail "$logfile"
        suggest_lock_recovery "$logfile"
        return $rc
    fi

    # Sub-step 2 (10–20%): plan
    # `-lock-timeout=120s` lets transient locks clear instead of failing fast.
    local planfile="${TF_DIR}/.lab-up.tfplan"
    spin_at_pct "$start" 15 "Terraform plan" "$C" \
        bash -c "cd '$TF_DIR' && terraform plan -lock-timeout=120s -out=.lab-up.tfplan -var=\"my_ip=$my_ip\" -input=false -no-color >>'$PWD/$logfile' 2>&1"
    rc=$?
    if (( rc != 0 )); then
        finalize_line fail "Terraform plan" "$start"
        dump_log_tail "$logfile"
        suggest_lock_recovery "$logfile"
        return $rc
    fi

    # Parse expected resource count from the log: lines like
    #   "Plan: 7 to add, 0 to change, 0 to destroy."
    # If the plan is a no-op we still want a bar that completes promptly.
    local planned
    planned=$(grep -E '^Plan: ' "$logfile" \
              | tail -1 \
              | sed -E 's/^Plan: ([0-9]+) to add.*/\1/')
    [[ -z "$planned" || ! "$planned" =~ ^[0-9]+$ ]] && planned=0

    if (( planned == 0 )); then
        # Nothing to do — still call apply to be safe (idempotent).
        spin_at_pct "$start" 95 "Terraform apply (no changes)" "$C" \
            bash -c "cd '$TF_DIR' && terraform apply -lock-timeout=120s -auto-approve -input=false -no-color .lab-up.tfplan >>'$PWD/$logfile' 2>&1"
        rc=$?
        if (( rc != 0 )); then
            finalize_line fail "$label_prefix" "$start"
            dump_log_tail "$logfile"
            suggest_lock_recovery "$logfile"
            return $rc
        fi
        finalize_line ok "$label_prefix (no changes)" "$start"
        return 0
    fi

    # Sub-step 3 (20–100%): apply with real-time resource counting
    ( cd "$TF_DIR" && terraform apply -lock-timeout=120s -auto-approve -input=false -no-color .lab-up.tfplan ) \
        >>"$logfile" 2>&1 &
    local apply_pid=$!
    watch_tf_apply "$apply_pid" "$logfile" "$start" "$label_prefix" "$planned" 20 100
    rc=$?

    if (( rc != 0 )); then
        finalize_line fail "$label_prefix" "$start"
        dump_log_tail "$logfile"
        suggest_lock_recovery "$logfile"
        return $rc
    fi
    finalize_line ok "$label_prefix (${planned}/${planned})" "$start"
}

# ───── phase 2: bootstrap polling with progress bar ───────────────────

do_wait_bootstrap() {
    local logfile="$LOG_DIR/02-bootstrap.log"
    : > "$logfile"

    local control_ip
    control_ip=$(get_control_ip)
    if [[ -z "$control_ip" ]]; then
        echo "      ${R}✗${NC} terraform did not produce control_public_ip — is the lab up?"
        return 1
    fi

    local label="polling control node"
    local start last_probe=0 i=0 elapsed=0
    start=$(date +%s)

    hide_cursor
    while true; do
        local now
        now=$(date +%s)
        elapsed=$(( now - start ))

        if (( now - last_probe >= BOOTSTRAP_POLL_SEC )); then
            last_probe=$now
            if ssh "${SSH_OPTS[@]}" "rocky@$control_ip" \
                 "sudo grep -q 'Bootstrap complete' /var/log/rhce-bootstrap.log 2>/dev/null" \
                 >>"$logfile" 2>&1; then
                # SUCCESS: force the bar to 100%
                show_cursor
                finalize_line ok "$label" "$start"
                return 0
            fi
        fi

        if (( elapsed >= BOOTSTRAP_TIMEOUT_SEC )); then
            show_cursor
            finalize_line fail "$label" "$start"
            dump_log_tail "$logfile"
            echo
            echo "      Run ${C}make debug${NC} to inspect /var/log/rhce-bootstrap.log on the host."
            return 1
        fi

        local pct=$(( elapsed * 100 / BOOTSTRAP_TIMEOUT_SEC ))
        render_line "${SPIN_CHARS[i]}" "$label" "$pct" "$elapsed" "$C"
        i=$(( (i + 1) % ${#SPIN_CHARS[@]} ))
        sleep 0.2
    done
}

# ───── phase 3: sync (pack → upload → install) ────────────────────────

# Watch an scp running in the background. Polls the remote tarball size
# every 1s and renders the bar between start_pct and end_pct.
# Args: scp_pid local_size remote_path remote_host overall_start label start_pct end_pct
watch_upload() {
    local pid="$1" local_size="$2" remote_path="$3" remote_host="$4"
    local start="$5" label="$6" start_pct="$7" end_pct="$8"

    hide_cursor
    local i=0 last_probe=0 remote_size=0
    while kill -0 "$pid" 2>/dev/null; do
        local now
        now=$(date +%s)
        if (( now - last_probe >= 1 )); then
            last_probe=$now
            local rs
            rs=$(ssh "${SSH_OPTS[@]}" "$remote_host" \
                "stat -c %s '$remote_path' 2>/dev/null || echo 0" 2>/dev/null)
            [[ -n "$rs" && "$rs" =~ ^[0-9]+$ ]] && remote_size=$rs
        fi

        local span=$(( end_pct - start_pct ))
        local pct=$start_pct
        if (( local_size > 0 )); then
            pct=$(( start_pct + remote_size * span / local_size ))
        fi
        (( pct > end_pct - 1 )) && pct=$(( end_pct - 1 ))
        local elapsed=$(( $(date +%s) - start ))
        render_line "${SPIN_CHARS[i]}" "$label" "$pct" "$elapsed" "$C"
        i=$(( (i + 1) % ${#SPIN_CHARS[@]} ))
        sleep 0.1
    done
    local rc=0
    wait "$pid" || rc=$?
    show_cursor
    return $rc
}

do_sync_exams() {
    discover_exams
    local logfile="$LOG_DIR/03-sync.log"
    : > "$logfile"

    local control_ip
    control_ip=$(get_control_ip)
    if [[ -z "$control_ip" ]]; then
        echo "      ${R}✗${NC} terraform did not produce control_public_ip — is the lab up?"
        return 1
    fi

    local n_complete=${#COMPLETE_EXAMS[@]}
    local n_thematic=${#THEMATIC_EXAMS[@]}
    local n_total=$(( n_complete + n_thematic ))
    local label_full
    label_full=$(printf "Sync exams: %d dirs (%d + %d)" "$n_total" "$n_complete" "$n_thematic")

    local complete_list="${COMPLETE_EXAMS[*]}"
    local thematic_list="${THEMATIC_EXAMS[*]}"
    local remote_user_host="rocky@$control_ip"
    local remote_tgz="/tmp/rhce-exams.tgz"

    local start
    start=$(date +%s)

    local tarball
    tarball=$(mktemp -t rhce-exams.XXXXXX.tgz 2>/dev/null \
             || mktemp /tmp/rhce-exams.XXXXXX.tgz)

    # Step 1 (0–25%): pack tarball locally — exam dirs + the shared lib that
    # all grade.sh files source.
    spin_at_pct "$start" 12 "$label_full — packing" "$C" \
        bash -c "tar czf '$tarball' $complete_list $thematic_list scripts/lib >>'$logfile' 2>&1"
    local rc=$?
    if (( rc != 0 )); then
        finalize_line fail "$label_full — pack" "$start"
        dump_log_tail "$logfile"
        rm -f "$tarball"; return $rc
    fi

    local local_size
    local_size=$(file_size_local "$tarball")

    # Step 2 (25–90%): upload with byte-poll progress
    scp "${SSH_OPTS[@]}" "$tarball" "$remote_user_host:$remote_tgz" \
        >>"$logfile" 2>&1 &
    local scp_pid=$!
    watch_upload "$scp_pid" "$local_size" "$remote_tgz" "$remote_user_host" \
        "$start" "$label_full — uploading" 25 90
    rc=$?
    if (( rc != 0 )); then
        finalize_line fail "$label_full — upload" "$start"
        dump_log_tail "$logfile"
        rm -f "$tarball"; return $rc
    fi

    # Step 3 (90–100%): extract + install on the control node.
    # scripts/lib/ goes to /home/student/exams/lib so grade.sh files can
    # source it via $(dirname "$0")/../lib/grade-helpers.sh
    spin_at_pct "$start" 95 "$label_full — installing" "$C" \
        ssh "${SSH_OPTS[@]}" "$remote_user_host" "
            set -e
            sudo rm -rf /home/student/exams
            sudo mkdir -p /home/student/exams/complete /home/student/exams/thematic
            TMP=\$(mktemp -d)
            tar xzf $remote_tgz -C \$TMP
            for d in $complete_list; do sudo mv \$TMP/\$d /home/student/exams/complete/; done
            for d in $thematic_list; do sudo mv \$TMP/\$d /home/student/exams/thematic/; done
            sudo mv \$TMP/scripts/lib /home/student/exams/lib
            sudo chown -R student:student /home/student/exams/
            sudo find /home/student/exams/ -name '*.sh' -exec chmod +x {} +
            rm -rf \$TMP $remote_tgz
        " >>"$logfile" 2>&1
    rc=$?
    rm -f "$tarball"

    if (( rc != 0 )); then
        finalize_line fail "$label_full — install" "$start"
        dump_log_tail "$logfile"
        return $rc
    fi
    finalize_line ok "$label_full" "$start"
}

# ───── phase: destroy ─────────────────────────────────────────────────

# Verify nothing is left in terraform state. Returns 0 if state is empty
# (ignoring local-only resources and data sources), 1 otherwise.
verify_destruction() {
    local state_resources
    state_resources=$( (cd "$TF_DIR" && terraform state list 2>/dev/null) \
                      | grep -v '^data\.' \
                      | grep -v '^tls_private_key\.' \
                      | grep -v '^local_file\.' \
                      | wc -l | tr -d ' ')
    [[ -z "$state_resources" ]] && state_resources=0
    echo "$state_resources"
}

do_destroy() {
    local logfile="$LOG_DIR/04-destroy.log"
    : > "$logfile"

    local start
    start=$(date +%s)

    # Sub-step 1 (0–10%): plan -destroy to count resources
    # We pass a dummy my_ip because terraform requires the var even for
    # destroy. It's safe — destroy plans only emit Destruction actions and
    # ignore non-destroy diffs from variable changes.
    spin_at_pct "$start" 5 "Terraform plan -destroy" "$C" \
        bash -c "cd '$TF_DIR' && terraform plan -destroy -lock-timeout=120s -var='my_ip=0.0.0.0/0' -input=false -no-color -out=.lab-up.tfplan.destroy >>'$PWD/$logfile' 2>&1"
    local rc=$?
    if (( rc != 0 )); then
        finalize_line fail "Terraform plan -destroy" "$start"
        dump_log_tail "$logfile"
        suggest_lock_recovery "$logfile"
        suggest_refresh_recovery "$logfile"
        # On failure, KEEP .lab-logs/ for forensics — don't auto-clean.
        echo "      ${DIM}Logs preserved at $LOG_DIR/ for inspection.${NC}"
        return $rc
    fi

    # Parse destruction count: "Plan: 0 to add, 0 to change, N to destroy."
    local planned
    planned=$(grep -E '^Plan: ' "$logfile" \
              | tail -1 \
              | sed -E 's/.*([0-9]+) to destroy.*/\1/')
    [[ -z "$planned" || ! "$planned" =~ ^[0-9]+$ ]] && planned=0

    if (( planned == 0 )); then
        finalize_line ok "Nothing to destroy (state already empty)" "$start"
        # Still clean local artifacts.
        do_destroy_cleanup "$start"
        return 0
    fi

    # Sub-step 2 (10–90%): destroy with real-time counting via watch_tf_apply
    # (which counts Destruction lines too).
    ( cd "$TF_DIR" && terraform apply -lock-timeout=120s -auto-approve -input=false -no-color .lab-up.tfplan.destroy ) \
        >>"$logfile" 2>&1 &
    local destroy_pid=$!
    watch_tf_apply "$destroy_pid" "$logfile" "$start" "Destroying" "$planned" 10 90
    rc=$?

    if (( rc != 0 )); then
        finalize_line fail "Destroying ($planned resources)" "$start"
        dump_log_tail "$logfile"
        suggest_lock_recovery "$logfile"
        suggest_refresh_recovery "$logfile"
        echo
        echo "      ${Y}⚠  Some resources may still exist in AWS. Re-run 'make destroy'.${NC}"
        echo "      ${DIM}Logs preserved at $LOG_DIR/ for inspection.${NC}"
        echo
        return $rc
    fi
    finalize_line ok "Destroyed ${planned}/${planned} resources" "$start"

    # Sub-step 3 (90–95%): verify state is empty
    local v_start
    v_start=$(date +%s)
    spin_at_pct "$v_start" 92 "Verifying AWS state" "$C" \
        bash -c "sleep 0.5"
    local leftover
    leftover=$(verify_destruction)
    if (( leftover > 0 )); then
        finalize_line fail "Verification: $leftover resources still in state" "$v_start"
        echo "      ${Y}⚠  Run 'cd $TF_DIR && terraform state list' to inspect.${NC}"
        echo "      ${Y}    Then re-run 'make destroy'.${NC}"
        echo "      ${DIM}Logs preserved at $LOG_DIR/ for inspection.${NC}"
        return 1
    fi
    finalize_line ok "Verification: state is empty" "$v_start"

    # Sub-step 4: cleanup local artifacts
    do_destroy_cleanup "$start"
}

do_destroy_cleanup() {
    local cleanup_start
    cleanup_start=$(date +%s)
    spin_at_pct "$cleanup_start" 50 "Cleaning local artifacts" "$C" \
        bash -c "
            rm -f '$KEY_FILE'
            rm -f '$TF_DIR/.lab-up.tfplan' '$TF_DIR/.lab-up.tfplan.destroy'
            rm -rf '$LOG_DIR'
            true
        "
    finalize_line ok "Cleaned local artifacts" "$cleanup_start"
}

# ───── final ready banner ─────────────────────────────────────────────
print_header() {
    echo
    echo "  ${B}RHCE Killer — Lab setup${NC}"
    echo
}

print_destroy_header() {
    echo
    echo "  ${B}RHCE Killer — Lab teardown${NC}"
    echo
}

print_destroyed() {
    echo
    echo "  ${G}${B}✓ Lab destroyed${NC}"
    echo
    echo "    ${DIM}All AWS resources tracked by Terraform are gone.${NC}"
    echo "    ${DIM}Local files removed: ${KEY_FILE}, ${LOG_DIR}/, plan caches.${NC}"
    echo
    echo "    ${DIM}Bring it back any time with:${NC} ${C}make up${NC}"
    echo
}

print_ready() {
    discover_exams
    local control_ip
    control_ip=$(get_control_ip)
    echo
    echo "  ${G}${B}✓ Lab ready${NC}"
    echo
    printf "    ${DIM}%-15s${NC} %s\n"            "Control node"  "${control_ip:-(unknown)}"
    printf "    ${DIM}%-15s${NC} %d complete · %d thematic\n" \
        "Exams"  "${#COMPLETE_EXAMS[@]}"  "${#THEMATIC_EXAMS[@]}"
    echo
    printf "    ${DIM}%-15s${NC} ${C}%s${NC}\n"   "Login"         "make ssh-student"
    printf "    ${DIM}%-15s${NC} ${C}%s${NC}\n"   "Start exam-01" "bash ~/exams/complete/exam-01/START.sh"
    printf "    ${DIM}%-15s${NC} ${C}%s${NC}\n"   "Tear down"     "make destroy"
    echo
}

# ───── main dispatcher ────────────────────────────────────────────────
cmd="${1:-up}"

case "$cmd" in
    up)
        print_header
        echo "  ${B}[1/3]${NC} Provisioning"
        do_tf_apply || exit $?
        echo
        echo "  ${B}[2/3]${NC} Bootstrap"
        do_wait_bootstrap || exit $?
        echo
        echo "  ${B}[3/3]${NC} Sync"
        do_sync_exams || exit $?
        print_ready
        ;;
    tf-apply)        do_tf_apply ;;
    wait-bootstrap)  do_wait_bootstrap ;;
    sync-exams)      do_sync_exams ;;
    ready)           print_ready ;;
    destroy)
        print_destroy_header
        do_destroy || exit $?
        print_destroyed
        ;;
    verify)
        # Sanity-check AWS state without destroying anything.
        leftover=$(verify_destruction)
        if (( leftover > 0 )); then
            echo "  ${Y}⚠  $leftover resources still tracked in Terraform state:${NC}"
            (cd "$TF_DIR" && terraform state list 2>/dev/null) \
                | grep -v '^data\.' | grep -v '^tls_private_key\.' | grep -v '^local_file\.' \
                | sed 's|^|    |'
        else
            echo "  ${G}✓ Terraform state is empty (no AWS resources tracked).${NC}"
        fi
        ;;
    *)
        echo "Usage: $0 [up|tf-apply|wait-bootstrap|sync-exams|ready|destroy|verify]"
        exit 2
        ;;
esac
