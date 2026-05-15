#!/usr/bin/env bash
# scripts/lib/grade-helpers.sh
#
# Shared validation helpers for all 21 exam grade.sh scripts.
# Each grade.sh sources this file and gets:
#   - canonical check() signature: check DESC PTS CMD [HINT]
#   - ansible_check() for module-based checks
#   - existence helpers: file_exists / dir_exists / user_exists / group_exists
#   - service helpers: service_active / service_enabled
#   - color codes (RED/GREEN/YELLOW/CYAN/NC/BOLD/BLUE)
#   - scoring state (PASS/FAIL/TOTAL/FAILED_TASKS)
#   - print_summary() final renderer
#
# Usage in a grade.sh:
#
#   #!/bin/bash
#   ANSIBLE_DIR="/home/student/ansible"
#   EXAM_NAME="my-exam"
#   EXAM_TITLE="My Exam"
#   cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }
#
#   source "$(dirname "$0")/../lib/grade-helpers.sh"
#
#   echo -e "${BOLD}Task 01 — Foo (10 pts)${NC}"
#   check "foo.yml exists" 5 \
#       "test -f $ANSIBLE_DIR/foo.yml" \
#       "Create playbook: foo.yml"
#
#   print_summary

set -u

# ───── color codes ─────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m';   GREEN='\033[0;32m';   YELLOW='\033[1;33m'
    BLUE='\033[0;34m';  CYAN='\033[0;36m';    NC='\033[0m'
    BOLD='\033[1m'
else
    RED='';  GREEN=''; YELLOW=''; BLUE=''; CYAN=''; NC=''; BOLD=''
fi

# ───── scoring state ───────────────────────────────────────────────────
PASS=0
FAIL=0
TOTAL=0
RESULTS=()
FAILED_TASKS=()

# ───── core check helper ───────────────────────────────────────────────
# Signature: check DESC PTS CMD [HINT]
# - DESC: short description shown in the output
# - PTS:  integer point value awarded on success
# - CMD:  shell expression evaluated; success = exit 0
# - HINT: optional remediation hint shown on failure
#
# In addition to PASS/FAIL/TOTAL (used by print_summary), this also bumps
# TOTAL_POINTS / TASKS_PASSED / TASKS_FAILED so legacy summaries that
# predate this lib keep working unchanged.
check() {
    local DESC="$1"
    local PTS="$2"
    local CMD="$3"
    local HINT="${4:-}"
    TOTAL=$((TOTAL + PTS))

    if eval "$CMD" &>/dev/null; then
        echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
        PASS=$((PASS + PTS))
        TOTAL_POINTS=$((${TOTAL_POINTS:-0} + PTS))
        TASKS_PASSED=$((${TASKS_PASSED:-0} + 1))
        RESULTS+=("PASS|$PTS|$DESC")
    else
        echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
        if [[ -n "$HINT" ]]; then
            echo -e "    ${YELLOW}→ Hint:${NC} $HINT"
        fi
        FAIL=$((FAIL + PTS))
        TASKS_FAILED=$((${TASKS_FAILED:-0} + 1))
        RESULTS+=("FAIL|0|$DESC")
        FAILED_TASKS+=("$DESC|$HINT")
    fi
}

# ───── ansible module check ───────────────────────────────────────────
# Signature: ansible_check DESC PTS HOST MODULE ARGS GREP_PATTERN [HINT]
# Runs `ansible HOST -m MODULE -a ARGS` and PASSes if output matches GREP_PATTERN.
ansible_check() {
    local DESC="$1"
    local PTS="$2"
    local HOST="$3"
    local MODULE="$4"
    local ARGS="$5"
    local GREP_PATTERN="$6"
    local HINT="${7:-}"

    TOTAL=$((TOTAL + PTS))
    local OUTPUT
    OUTPUT=$(ansible "$HOST" -m "$MODULE" -a "$ARGS" 2>/dev/null)

    if echo "$OUTPUT" | grep -qE "$GREP_PATTERN"; then
        echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
        PASS=$((PASS + PTS))
        TOTAL_POINTS=$((${TOTAL_POINTS:-0} + PTS))
        TASKS_PASSED=$((${TASKS_PASSED:-0} + 1))
        RESULTS+=("PASS|$PTS|$DESC")
    else
        echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
        if [[ -n "$HINT" ]]; then
            echo -e "    ${YELLOW}→ Hint:${NC} $HINT"
        fi
        FAIL=$((FAIL + PTS))
        TASKS_FAILED=$((${TASKS_FAILED:-0} + 1))
        RESULTS+=("FAIL|0|$DESC")
        FAILED_TASKS+=("$DESC|$HINT")
    fi
}

# ───── small existence helpers ────────────────────────────────────────
file_exists()    { [[ -f "$1" ]]; }
dir_exists()     { [[ -d "$1" ]]; }
user_exists()    { id "$1" &>/dev/null; }
group_exists()   { getent group "$1" &>/dev/null; }

# Service helpers run against all managed hosts via ansible.
# Returns 0 if the service is in the desired state on EVERY host.
service_active() {
    ansible all -m shell -a "systemctl is-active $1" 2>/dev/null \
        | grep -q "active"
}
service_enabled() {
    ansible all -m shell -a "systemctl is-enabled $1" 2>/dev/null \
        | grep -q "enabled"
}

# ───── final summary ──────────────────────────────────────────────────
# Renders the standard PASS/FAIL summary. Each grade.sh calls this at the end.
# Args (optional):
#   $1 = exam title (defaults to ${EXAM_TITLE:-this exam})
#   $2 = next-exam suggestion (printed if score >= 70%)
print_summary() {
    local title="${1:-${EXAM_TITLE:-this exam}}"
    local next_exam="${2:-}"
    local pct=0
    (( TOTAL > 0 )) && pct=$(( PASS * 100 / TOTAL ))

    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}   ${title} — Final Score${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""

    if (( pct >= 70 )); then
        echo -e "${BOLD}${GREEN}  RESULT: PASS ✓${NC}"
    else
        echo -e "${BOLD}${RED}  RESULT: FAIL ✗${NC}"
    fi
    echo ""
    echo -e "${BOLD}  Score: ${PASS}/${TOTAL} points (${pct}%)${NC}"
    echo -e "  Passing threshold: 70%"
    echo -e "  Points earned: ${GREEN}${PASS}${NC} | Points lost: ${RED}${FAIL}${NC}"
    echo ""

    if (( ${#FAILED_TASKS[@]} > 0 )); then
        echo -e "${BOLD}${YELLOW}📋 Failed tasks (${#FAILED_TASKS[@]}):${NC}"
        echo ""
        local i=1
        for entry in "${FAILED_TASKS[@]}"; do
            local desc hint
            desc="${entry%%|*}"
            hint="${entry#*|}"
            echo -e "  ${RED}${i}.${NC} ${BOLD}${desc}${NC}"
            [[ -n "$hint" && "$hint" != "$desc" ]] && \
                echo -e "     ${BLUE}💡${NC} ${hint}"
            i=$((i+1))
        done
        echo ""
    fi

    if (( pct >= 70 )) && [[ -n "$next_exam" ]]; then
        echo -e "${CYAN}Next step:${NC} ${next_exam}"
        echo ""
    fi
}
