#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Ansible-Navigator & EE Exam Grader
# 13 tasks · 165 points · 70% passing (116)
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
EXAM_NAME="ansible-navigator-and-ee"
EXAM_TITLE="Ansible-Navigator & Execution Environments"

cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   ${EXAM_TITLE}${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Install ansible-navigator (5 pts)${NC}"
# ─────────────────────────────────────────────
check "ansible-navigator binary in PATH" 3 \
    "command -v ansible-navigator" \
    "Install with: sudo dnf install -y ansible-navigator"
check "ansible-navigator --version succeeds" 2 \
    "ansible-navigator --version" \
    "Make sure ansible-navigator runs without errors"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Configure ansible-navigator.yml (15 pts)${NC}"
# ─────────────────────────────────────────────
check "ansible-navigator.yml exists" 2 \
    "test -f $ANSIBLE_DIR/ansible-navigator.yml" \
    "Create $ANSIBLE_DIR/ansible-navigator.yml"
check "Config sets EE image" 3 \
    "grep -qE 'image:[[:space:]]+ee-supported-rhel9' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Set ansible-navigator.execution-environment.image: ee-supported-rhel9:latest"
check "Config sets container-engine: podman" 2 \
    "grep -qE 'container-engine:[[:space:]]+podman' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Set container-engine: podman"
check "Config sets inventory entry" 2 \
    "grep -qE '/home/student/ansible/inventory' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Set ansible.inventory.entries to your inventory path"
check "Config sets mode: stdout" 2 \
    "grep -qE 'mode:[[:space:]]+stdout' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Set top-level mode: stdout"
check "Config enables playbook-artifact" 2 \
    "grep -A2 'playbook-artifact:' $ANSIBLE_DIR/ansible-navigator.yml | grep -qE 'enable:[[:space:]]+true'" \
    "Set playbook-artifact.enable: true"
check "Config YAML is valid (settings --effective parses)" 2 \
    "ansible-navigator settings --effective &>/dev/null" \
    "Run: ansible-navigator settings --effective to debug parse errors"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — List inventory with navigator (10 pts)${NC}"
# ─────────────────────────────────────────────
check "inv-dump.sh exists" 2 \
    "test -f $ANSIBLE_DIR/inv-dump.sh" \
    "Create inv-dump.sh that runs ansible-navigator inventory --list"
check "Script invokes ansible-navigator inventory" 3 \
    "grep -qE 'ansible-navigator[[:space:]]+inventory' $ANSIBLE_DIR/inv-dump.sh" \
    "Use ansible-navigator inventory (NOT ansible-inventory)"
check "/tmp/inventory-dump.json exists" 3 \
    "test -f /tmp/inventory-dump.json" \
    "Run bash inv-dump.sh to create the file"
check "Dumped JSON includes node1" 2 \
    "grep -q 'node1' /tmp/inventory-dump.json" \
    "The inventory must contain node1 — check inventory file"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — List installed collections (10 pts)${NC}"
# ─────────────────────────────────────────────
check "collections-list.txt exists" 3 \
    "test -f $ANSIBLE_DIR/collections-list.txt" \
    "Run: ansible-navigator collections --mode stdout > collections-list.txt"
check "Output lists ansible.builtin" 3 \
    "grep -q 'ansible.builtin' $ANSIBLE_DIR/collections-list.txt" \
    "Output should include ansible.builtin collection"
check "Output lists ansible.posix" 2 \
    "grep -q 'ansible.posix' $ANSIBLE_DIR/collections-list.txt" \
    "Output should include ansible.posix collection"
check "Output lists community.general" 2 \
    "grep -q 'community.general' $ANSIBLE_DIR/collections-list.txt" \
    "Output should include community.general collection"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Module documentation lookup (10 pts)${NC}"
# ─────────────────────────────────────────────
check "copy-doc.txt exists" 3 \
    "test -f $ANSIBLE_DIR/copy-doc.txt" \
    "Run: ansible-navigator doc ansible.builtin.copy --mode stdout > copy-doc.txt"
check "Documentation has OPTIONS section" 3 \
    "grep -q 'OPTIONS' $ANSIBLE_DIR/copy-doc.txt" \
    "Make sure full doc was captured (not truncated)"
check "Documentation has EXAMPLES section" 2 \
    "grep -q 'EXAMPLES' $ANSIBLE_DIR/copy-doc.txt" \
    "Output should include EXAMPLES"
check "Documentation has RETURN VALUES section" 2 \
    "grep -q 'RETURN' $ANSIBLE_DIR/copy-doc.txt" \
    "Output should include RETURN VALUES section"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Run playbook in stdout mode (15 pts)${NC}"
# ─────────────────────────────────────────────
check "hello.yml exists" 3 \
    "test -f $ANSIBLE_DIR/hello.yml" \
    "Create hello.yml playbook"
check "hello.yml uses ansible.builtin.debug" 3 \
    "grep -qE 'ansible.builtin.debug|^[[:space:]]+debug:' $ANSIBLE_DIR/hello.yml" \
    "Use debug module with msg: parameter"
check "hello-output.txt exists" 4 \
    "test -f $ANSIBLE_DIR/hello-output.txt" \
    "Capture run output with tee or > redirection"
check "Output contains Hello / via navigator" 5 \
    "grep -qE 'Hello.*from|via navigator' $ANSIBLE_DIR/hello-output.txt" \
    "Output must contain the debug message"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Custom EE environment variables (18 pts)${NC}"
# ─────────────────────────────────────────────
check "environment-variables block defined" 5 \
    "grep -q 'environment-variables:' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Add environment-variables: under execution-environment:"
check "ANSIBLE_FORCE_COLOR is passed through" 4 \
    "grep -A6 'environment-variables:' $ANSIBLE_DIR/ansible-navigator.yml | grep -q 'ANSIBLE_FORCE_COLOR'" \
    "Add ANSIBLE_FORCE_COLOR to the pass: list"
check "ANSIBLE_HOST_KEY_CHECKING is passed through" 4 \
    "grep -A6 'environment-variables:' $ANSIBLE_DIR/ansible-navigator.yml | grep -q 'ANSIBLE_HOST_KEY_CHECKING'" \
    "Add ANSIBLE_HOST_KEY_CHECKING to the pass: list"
check "ANSIBLE_STDOUT_CALLBACK is set inside EE" 3 \
    "grep -q 'ANSIBLE_STDOUT_CALLBACK' $ANSIBLE_DIR/ansible-navigator.yml" \
    "Add ANSIBLE_STDOUT_CALLBACK: yaml under set:"
check "Config still parses with settings --effective" 2 \
    "ansible-navigator settings --effective &>/dev/null" \
    "Run settings --effective; fix any YAML errors"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Pull and inspect EE (15 pts)${NC}"
# ─────────────────────────────────────────────
check "ee-images.txt exists" 4 \
    "test -f $ANSIBLE_DIR/ee-images.txt" \
    "Run: ansible-navigator images --mode stdout > ee-images.txt"
check "Output mentions ee-supported-rhel9" 4 \
    "grep -q 'ee-supported-rhel9' $ANSIBLE_DIR/ee-images.txt" \
    "The configured EE image should appear in the images list"
check "ee-supported-rhel9-info.txt exists" 4 \
    "test -f $ANSIBLE_DIR/ee-supported-rhel9-info.txt" \
    "Run: podman inspect ee-supported-rhel9 --format '...' > ee-supported-rhel9-info.txt"
check "Info file has size or created field" 3 \
    "grep -qE '[0-9]+' $ANSIBLE_DIR/ee-supported-rhel9-info.txt" \
    "Output should contain numeric size in bytes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Extra-vars to navigator (10 pts)${NC}"
# ─────────────────────────────────────────────
check "extra-vars.sh exists" 3 \
    "test -f $ANSIBLE_DIR/extra-vars.sh" \
    "Create extra-vars.sh"
check "Script uses --extra-vars" 3 \
    "grep -qE '\-\-extra-vars' $ANSIBLE_DIR/extra-vars.sh" \
    "Pass --extra-vars 'greeting=hola' to ansible-navigator run"
check "Script invokes ansible-navigator run" 2 \
    "grep -qE 'ansible-navigator[[:space:]]+run' $ANSIBLE_DIR/extra-vars.sh" \
    "Use ansible-navigator run (not ansible-playbook)"
check "Playbook supports a greeting variable" 2 \
    "grep -q 'greeting' $ANSIBLE_DIR/hello.yml" \
    "Use {{ greeting | default('Hello') }} in the debug message"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Inspect saved artifact (15 pts)${NC}"
# ─────────────────────────────────────────────
check "artifacts/ directory exists" 3 \
    "test -d $ANSIBLE_DIR/artifacts" \
    "Run a playbook with playbook-artifact enabled to create artifacts/"
check "At least one artifact JSON file exists" 4 \
    "ls $ANSIBLE_DIR/artifacts/*.json 2>/dev/null | head -1 | xargs test -f" \
    "Run a navigator playbook (Task 06 or 09) to generate an artifact"
check "artifact-list.txt exists" 3 \
    "test -f $ANSIBLE_DIR/artifact-list.txt" \
    "Run: ls artifacts/ > artifact-list.txt"
check "last-status.txt exists" 2 \
    "test -f $ANSIBLE_DIR/last-status.txt" \
    "Use jq to extract .status from the latest artifact"
check "last-status.txt says 'successful'" 3 \
    "grep -q 'successful' $ANSIBLE_DIR/last-status.txt" \
    "Status should be 'successful' if the playbook ran cleanly"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Replay artifact (12 pts)${NC}"
# ─────────────────────────────────────────────
check "replay-output.txt exists" 4 \
    "test -f $ANSIBLE_DIR/replay-output.txt" \
    "Run: ansible-navigator replay <artifact> --mode stdout > replay-output.txt"
check "Replay output mentions PLAY or TASK" 4 \
    "grep -qE 'PLAY|TASK' $ANSIBLE_DIR/replay-output.txt" \
    "The replay should reproduce the ansible-playbook output format"
check "Replay output mentions an inventory host" 4 \
    "grep -qE 'node1|node2|control' $ANSIBLE_DIR/replay-output.txt" \
    "Replay should show the same hosts as the original run"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Non-default inventory (10 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-dev exists" 3 \
    "test -f $ANSIBLE_DIR/inventory-dev" \
    "Create inventory-dev with only node1 under [dev]"
check "inventory-dev defines [dev] group" 2 \
    "grep -q '\\[dev\\]' $ANSIBLE_DIR/inventory-dev" \
    "Add a [dev] group header"
check "inv-dev.txt exists" 3 \
    "test -f $ANSIBLE_DIR/inv-dev.txt" \
    "Run: ansible-navigator inventory --list --inventory inventory-dev > inv-dev.txt"
check "Output mentions node1 but NOT node2" 2 \
    "grep -q 'node1' $ANSIBLE_DIR/inv-dev.txt && ! grep -q 'node2' $ANSIBLE_DIR/inv-dev.txt" \
    "Make sure inventory-dev only contains node1"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Migrate ansible-playbook to navigator (20 pts)${NC}"
# ─────────────────────────────────────────────
check "legacy.yml exists" 3 \
    "test -f $ANSIBLE_DIR/legacy.yml" \
    "Create legacy.yml (same content as hello.yml works)"
check "run-legacy.sh exists" 3 \
    "test -f $ANSIBLE_DIR/run-legacy.sh" \
    "Create run-legacy.sh wrapper script"
check "Script invokes ansible-navigator run" 4 \
    "grep -qE 'ansible-navigator[[:space:]]+run' $ANSIBLE_DIR/run-legacy.sh" \
    "Use ansible-navigator run (NOT ansible-playbook)"
check "Script uses --become" 3 \
    "grep -qE '\-\-become' $ANSIBLE_DIR/run-legacy.sh" \
    "Pass --become for sudo escalation"
check "Script uses --extra-vars" 3 \
    "grep -qE '\-\-extra-vars' $ANSIBLE_DIR/run-legacy.sh" \
    "Pass --extra-vars 'env=prod'"
check "Script uses --mode stdout" 2 \
    "grep -qE 'mode[[:space:]]+stdout' $ANSIBLE_DIR/run-legacy.sh" \
    "Pass --mode stdout to get classic output"
check "Script has set -e or pipefail" 2 \
    "grep -qE 'set -[ueo]+' $ANSIBLE_DIR/run-legacy.sh" \
    "set -euo pipefail makes the script fail on any error"

print_summary "Ansible-Navigator & EE" \
    "bash ~/exams/thematic/system-administration/START.sh"
