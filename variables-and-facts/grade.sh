#!/bin/bash
#
# RHCE Killer - Variables and Facts Grading Script
# Magic Variables, Facts & Conditionals Mastery
#

EXAM_NAME="Variables and Facts: Magic Variables, Facts & Conditionals"
TOTAL_POINTS=200
PASSING_SCORE=140

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
SCORE=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Working directory
WORK_DIR="/home/student/ansible"

# Helper function to check tasks
check() {
    local description="$1"
    local points="$2"
    local command="$3"
    
    echo -ne "  ${CYAN}▶${NC} ${description}... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓${NC} (+${points} pts)"
        SCORE=$((SCORE + points))
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} (0 pts)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

clear

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}RHCE Killer${NC} — Variables and Facts Grading               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}Magic Variables, Facts & Conditionals${NC}                    ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if working directory exists
if [ ! -d "$WORK_DIR" ]; then
    echo -e "${RED}❌ Working directory $WORK_DIR not found!${NC}"
    exit 1
fi

cd "$WORK_DIR" || exit 1

echo -e "${BLUE}📊 Grading Tasks...${NC}"
echo ""

# ============================================================================
# Task 01 — Facts Discovery (10 pts)
# ============================================================================
echo -e "${YELLOW}Task 01 — Facts Discovery (10 pts)${NC}"

check "Playbook facts-discovery.yml exists" 2 \
    "test -f facts-discovery.yml"

check "Playbook has gather_facts enabled" 2 \
    "grep -q 'gather_facts.*true' facts-discovery.yml || ! grep -q 'gather_facts.*false' facts-discovery.yml"

check "Playbook displays ansible_distribution" 1 \
    "grep -q 'ansible_distribution' facts-discovery.yml"

check "Playbook displays ansible_memtotal_mb" 1 \
    "grep -q 'ansible_memtotal_mb' facts-discovery.yml"

check "Playbook displays ansible_processor_vcpus" 1 \
    "grep -q 'ansible_processor_vcpus' facts-discovery.yml"

check "Playbook displays ansible_default_ipv4" 1 \
    "grep -q 'ansible_default_ipv4' facts-discovery.yml"

check "Playbook displays ansible_hostname" 1 \
    "grep -q 'ansible_hostname' facts-discovery.yml"

check "Playbook runs without errors" 1 \
    "ansible-playbook facts-discovery.yml --syntax-check 2>/dev/null"

echo ""

# ============================================================================
# Task 02 — Conditional Package Installation (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 02 — Conditional Package Installation (15 pts)${NC}"

check "Playbook conditional-packages.yml exists" 3 \
    "test -f conditional-packages.yml"

check "Playbook uses ansible_memtotal_mb fact" 3 \
    "grep -q 'ansible_memtotal_mb' conditional-packages.yml"

check "Playbook has when condition for httpd" 3 \
    "grep -A2 'name.*httpd' conditional-packages.yml | grep -q 'when'"

check "Playbook has when condition for nginx" 3 \
    "grep -A2 'name.*nginx' conditional-packages.yml | grep -q 'when'"

check "Playbook runs without errors" 3 \
    "ansible-playbook conditional-packages.yml --syntax-check 2>/dev/null"

echo ""

# ============================================================================
# Task 03 — OS-Specific Configuration (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 03 — OS-Specific Configuration (15 pts)${NC}"

check "Playbook os-specific.yml exists" 3 \
    "test -f os-specific.yml"

check "Playbook uses ansible_distribution fact" 3 \
    "grep -q 'ansible_distribution' os-specific.yml"

check "Playbook has when conditions" 3 \
    "grep -q 'when:' os-specific.yml"

check "File /etc/system-info.txt exists on node1" 3 \
    "ansible node1.example.com -m command -a 'test -f /etc/system-info.txt' -i inventory 2>/dev/null"

check "File contains correct content for Rocky" 3 \
    "ansible node1.example.com -m command -a 'cat /etc/system-info.txt' -i inventory 2>/dev/null | grep -q 'Rocky'"

echo ""

# ============================================================================
# Task 04 — Magic Variables - Inventory Information (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 04 — Magic Variables - Inventory (15 pts)${NC}"

check "Playbook inventory-info.yml exists" 3 \
    "test -f inventory-info.yml"

check "Playbook uses groups magic variable" 3 \
    "grep -q 'groups' inventory-info.yml"

check "Playbook runs on node1" 3 \
    "grep -q 'node1' inventory-info.yml"

check "File /tmp/inventory-report.txt exists on node1" 3 \
    "ansible node1.example.com -m command -a 'test -f /tmp/inventory-report.txt' -i inventory 2>/dev/null"

check "File contains host information" 3 \
    "ansible node1.example.com -m command -a 'cat /tmp/inventory-report.txt' -i inventory 2>/dev/null | grep -q 'node'"

echo ""

# ============================================================================
# Task 05 — Conditional Tasks Based on Hostname (10 pts)
# ============================================================================
echo -e "${YELLOW}Task 05 — Hostname Conditionals (10 pts)${NC}"

check "Playbook hostname-conditional.yml exists" 2 \
    "test -f hostname-conditional.yml"

check "Playbook uses inventory_hostname or ansible_hostname" 2 \
    "grep -q 'inventory_hostname\|ansible_hostname' hostname-conditional.yml"

check "Directory /opt/node1-data exists on node1" 2 \
    "ansible node1.example.com -m command -a 'test -d /opt/node1-data' -i inventory 2>/dev/null"

check "Directory /opt/node2-data exists on node2" 2 \
    "ansible node2.example.com -m command -a 'test -d /opt/node2-data' -i inventory 2>/dev/null"

check "Directories have correct permissions" 2 \
    "ansible node1.example.com -m command -a 'stat -c %a /opt/node1-data' -i inventory 2>/dev/null | grep -q '755'"

echo ""

# ============================================================================
# Task 06 — Network Facts and Conditionals (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 06 — Network Facts (15 pts)${NC}"

check "Playbook network-check.yml exists" 3 \
    "test -f network-check.yml"

check "Playbook uses ansible_default_ipv4 fact" 3 \
    "grep -q 'ansible_default_ipv4' network-check.yml"

check "Playbook has network conditionals" 3 \
    "grep -q 'when:' network-check.yml"

check "File /etc/network-zone.conf exists on nodes" 3 \
    "ansible managed -m command -a 'test -f /etc/network-zone.conf' -i inventory 2>/dev/null"

check "File contains zone configuration" 3 \
    "ansible managed -m command -a 'cat /etc/network-zone.conf' -i inventory 2>/dev/null | grep -q 'zone='"

echo ""

# ============================================================================
# Task 07 — Custom Facts (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 07 — Custom Facts (15 pts)${NC}"

check "Playbook custom-facts.yml exists" 3 \
    "test -f custom-facts.yml"

check "Custom fact file exists on node1" 3 \
    "ansible node1.example.com -m command -a 'test -f /etc/ansible/facts.d/app.fact' -i inventory 2>/dev/null"

check "Custom fact has correct format" 3 \
    "ansible node1.example.com -m command -a 'cat /etc/ansible/facts.d/app.fact' -i inventory 2>/dev/null | grep -q '\[application\]'"

check "Playbook uses ansible_local" 2 \
    "grep -q 'ansible_local' custom-facts.yml"

check "File /tmp/app-info.txt exists" 2 \
    "ansible node1.example.com -m command -a 'test -f /tmp/app-info.txt' -i inventory 2>/dev/null"

check "App info file has correct content" 2 \
    "ansible node1.example.com -m command -a 'cat /tmp/app-info.txt' -i inventory 2>/dev/null | grep -q 'webapp'"

echo ""

# ============================================================================
# Task 08 — Multiple Conditions (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 08 — Multiple Conditions (15 pts)${NC}"

check "Playbook multi-conditions.yml exists" 3 \
    "test -f multi-conditions.yml"

check "Playbook uses ansible_processor_vcpus" 3 \
    "grep -q 'ansible_processor_vcpus' multi-conditions.yml"

check "Playbook uses ansible_memtotal_mb" 3 \
    "grep -q 'ansible_memtotal_mb' multi-conditions.yml"

check "Playbook has multiple when conditions" 3 \
    "grep -A1 'when:' multi-conditions.yml | grep -q 'ansible_processor_vcpus\|ansible_memtotal_mb'"

check "Playbook runs without errors" 3 \
    "ansible-playbook multi-conditions.yml --syntax-check 2>/dev/null"

echo ""

# ============================================================================
# Task 09 — Hostvars (20 pts)
# ============================================================================
echo -e "${YELLOW}Task 09 — Hostvars (20 pts)${NC}"

check "Playbook hostvars-demo.yml exists" 4 \
    "test -f hostvars-demo.yml"

check "Playbook uses hostvars magic variable" 4 \
    "grep -q 'hostvars' hostvars-demo.yml"

check "Playbook runs on node1" 4 \
    "grep -q 'node1' hostvars-demo.yml"

check "File /tmp/cluster-info.txt exists on node1" 4 \
    "ansible node1.example.com -m command -a 'test -f /tmp/cluster-info.txt' -i inventory 2>/dev/null"

check "File contains both node IPs" 4 \
    "ansible node1.example.com -m command -a 'cat /tmp/cluster-info.txt' -i inventory 2>/dev/null | grep -q '10.0.2'"

echo ""

# ============================================================================
# Task 10 — Fact Gathering (10 pts)
# ============================================================================
echo -e "${YELLOW}Task 10 — Fact Gathering (10 pts)${NC}"

check "Playbook fact-gathering.yml exists" 2 \
    "test -f fact-gathering.yml"

check "Playbook disables automatic fact gathering" 2 \
    "grep -q 'gather_facts.*false' fact-gathering.yml"

check "Playbook uses setup module with filter" 2 \
    "grep -q 'setup:' fact-gathering.yml && grep -q 'filter' fact-gathering.yml"

check "File /tmp/ip-only.txt exists" 2 \
    "ansible managed -m command -a 'test -f /tmp/ip-only.txt' -i inventory 2>/dev/null"

check "File contains IP address" 2 \
    "ansible node1.example.com -m command -a 'cat /tmp/ip-only.txt' -i inventory 2>/dev/null | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'"

echo ""

# ============================================================================
# Task 11 — Register + When (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 11 — Register + When (15 pts)${NC}"

check "Playbook register-conditional.yml exists" 3 \
    "test -f register-conditional.yml"

check "Playbook uses register keyword" 3 \
    "grep -q 'register:' register-conditional.yml"

check "Playbook uses when with register" 3 \
    "grep -q 'when:' register-conditional.yml"

check "Playbook checks for httpd package" 3 \
    "grep -q 'httpd' register-conditional.yml"

check "Playbook runs without errors" 3 \
    "ansible-playbook register-conditional.yml --syntax-check 2>/dev/null"

echo ""

# ============================================================================
# Task 12 — Loop with Conditionals (20 pts)
# ============================================================================
echo -e "${YELLOW}Task 12 — Loop + Conditionals (20 pts)${NC}"

check "Playbook loop-conditionals.yml exists" 4 \
    "test -f loop-conditionals.yml"

check "Playbook defines packages variable" 4 \
    "grep -q 'packages:' loop-conditionals.yml"

check "Playbook uses loop" 4 \
    "grep -q 'loop:' loop-conditionals.yml"

check "Playbook uses when with loop" 4 \
    "grep -A2 'loop:' loop-conditionals.yml | grep -q 'when:'"

check "Playbook uses ansible_memtotal_mb in condition" 4 \
    "grep -q 'ansible_memtotal_mb' loop-conditionals.yml"

echo ""

# ============================================================================
# Task 13 — Group Membership (10 pts)
# ============================================================================
echo -e "${YELLOW}Task 13 — Group Membership (10 pts)${NC}"

check "Playbook group-conditional.yml exists" 2 \
    "test -f group-conditional.yml"

check "Playbook uses group_names magic variable" 2 \
    "grep -q 'group_names' group-conditional.yml"

check "Playbook has group membership conditions" 2 \
    "grep -q 'in group_names' group-conditional.yml"

check "File /etc/node-type.conf exists on nodes" 2 \
    "ansible managed -m command -a 'test -f /etc/node-type.conf' -i inventory 2>/dev/null"

check "File contains type configuration" 2 \
    "ansible managed -m command -a 'cat /etc/node-type.conf' -i inventory 2>/dev/null | grep -q 'type='"

echo ""

# ============================================================================
# Task 14 — Ansible Environment (10 pts)
# ============================================================================
echo -e "${YELLOW}Task 14 — Ansible Environment (10 pts)${NC}"

check "Playbook ansible-env.yml exists" 2 \
    "test -f ansible-env.yml"

check "Playbook runs on localhost" 2 \
    "grep -q 'localhost' ansible-env.yml"

check "Playbook uses ansible_version" 2 \
    "grep -q 'ansible_version' ansible-env.yml"

check "Playbook uses ansible_python_version" 2 \
    "grep -q 'ansible_python_version' ansible-env.yml"

check "File /tmp/ansible-info.txt exists" 2 \
    "test -f /tmp/ansible-info.txt"

echo ""

# ============================================================================
# Task 15 — Failed_when and Changed_when (15 pts)
# ============================================================================
echo -e "${YELLOW}Task 15 — Failed/Changed When (15 pts)${NC}"

check "Playbook custom-status.yml exists" 3 \
    "test -f custom-status.yml"

check "Playbook uses failed_when" 3 \
    "grep -q 'failed_when:' custom-status.yml"

check "Playbook uses changed_when" 3 \
    "grep -q 'changed_when:' custom-status.yml"

check "Playbook uses register" 3 \
    "grep -q 'register:' custom-status.yml"

check "Playbook runs without errors" 3 \
    "ansible-playbook custom-status.yml --syntax-check 2>/dev/null"

echo ""

# ============================================================================
# Final Results
# ============================================================================
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📊 Final Results${NC}"
echo ""
echo -e "  Total Score: ${YELLOW}${SCORE}${NC}/${TOTAL_POINTS} points"

PERCENTAGE=$((SCORE * 100 / TOTAL_POINTS))
echo -e "  Percentage: ${YELLOW}${PERCENTAGE}%${NC}"
echo ""
echo -e "  Checks Passed: ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "  Checks Failed: ${RED}${CHECKS_FAILED}${NC}"
echo ""

if [ $SCORE -ge $PASSING_SCORE ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${GREEN}✅ CONGRATULATIONS! YOU PASSED!${NC}                          ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🎉 Excellent work on mastering Ansible facts and conditionals!${NC}"
    echo ""
    echo -e "${YELLOW}📚 Key Concepts Mastered:${NC}"
    echo -e "   • Ansible Facts Discovery & Usage"
    echo -e "   • Magic Variables (inventory_hostname, groups, hostvars)"
    echo -e "   • Conditional Logic (when, failed_when, changed_when)"
    echo -e "   • Custom Facts Creation"
    echo -e "   • OS-Specific Configurations"
    echo -e "   • Loop + Conditional Combinations"
    echo ""
    echo -e "${GREEN}🚀 You're well-prepared for the RHCE exam!${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}  ${RED}❌ NOT PASSED${NC} (Need ${PASSING_SCORE}+ points)                      ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📚 Review these topics:${NC}"
    echo ""
    
    if [ $SCORE -lt 50 ]; then
        echo -e "   • Review Ansible facts basics"
        echo -e "   • Practice using ansible -m setup"
        echo -e "   • Study conditional syntax (when:)"
    elif [ $SCORE -lt 100 ]; then
        echo -e "   • Practice magic variables (groups, hostvars)"
        echo -e "   • Review custom facts creation"
        echo -e "   • Study loop + conditional combinations"
    else
        echo -e "   • Review advanced conditionals"
        echo -e "   • Practice hostvars usage"
        echo -e "   • Study failed_when and changed_when"
    fi
    
    echo ""
    echo -e "${CYAN}💡 Tips:${NC}"
    echo -e "   • Use ${GREEN}ansible hostname -m setup${NC} to explore facts"
    echo -e "   • Test conditionals with ${GREEN}debug${NC} module first"
    echo -e "   • Review solutions in ${GREEN}~/exams/variables-and-facts/README.md${NC}"
    echo -e "   • Practice each task individually"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# Clean up timer if exam is complete
rm -f "$HOME/.variables_and_facts_timer" 2>/dev/null

# Made with Bob
