#!/bin/bash
#
# RHCE Killer - Exam 06 Timer
# Magic Variables, Facts & Conditionals Mastery
#

EXAM_NAME="Exam 06: Magic Variables, Facts & Conditionals"
EXAM_DURATION=180  # 3 hours in minutes
EXAM_DIR="$HOME/exams/exam-06"
TIMER_FILE="$HOME/.exam06_timer"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

clear

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}RHCE Killer${NC} — Practice Exam 06                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}Magic Variables, Facts & Conditionals Mastery${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if timer already exists
if [ -f "$TIMER_FILE" ]; then
    START_TIME=$(cat "$TIMER_FILE")
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    ELAPSED_MIN=$((ELAPSED / 60))
    REMAINING=$((EXAM_DURATION - ELAPSED_MIN))
    
    if [ $REMAINING -le 0 ]; then
        echo -e "${RED}⏰ Time's up! Your exam time has expired.${NC}"
        echo ""
        echo -e "${YELLOW}📊 Grade your work:${NC}"
        echo -e "   ${GREEN}bash ~/exams/exam-06/grade.sh${NC}"
        echo ""
        rm -f "$TIMER_FILE"
        exit 0
    fi
    
    echo -e "${YELLOW}⚠️  Exam already in progress!${NC}"
    echo ""
    echo -e "   Started: $(date -r $START_TIME '+%Y-%m-%d %H:%M:%S')"
    echo -e "   Elapsed: ${ELAPSED_MIN} minutes"
    echo -e "   Remaining: ${GREEN}${REMAINING} minutes${NC}"
    echo ""
    echo -e "${CYAN}💡 Commands:${NC}"
    echo -e "   ${GREEN}cat ~/exams/exam-06/README.md | less${NC}  → View instructions"
    echo -e "   ${GREEN}bash ~/exams/exam-06/grade.sh${NC}         → Grade your work"
    echo ""
    exit 0
fi

# Display exam information
echo -e "${BLUE}📋 Exam Information:${NC}"
echo -e "   • ${YELLOW}Duration:${NC} 3 hours (180 minutes)"
echo -e "   • ${YELLOW}Tasks:${NC} 15 exercises"
echo -e "   • ${YELLOW}Total Points:${NC} 200"
echo -e "   • ${YELLOW}Passing Score:${NC} 140/200 (70%)"
echo -e "   • ${YELLOW}Focus:${NC} Ansible Facts, Magic Variables, Conditionals"
echo ""

echo -e "${BLUE}🎯 Topics Covered:${NC}"
echo -e "   • Ansible Facts Discovery & Usage"
echo -e "   • Magic Variables (inventory_hostname, groups, hostvars)"
echo -e "   • Conditional Logic (when, failed_when, changed_when)"
echo -e "   • Custom Facts Creation"
echo -e "   • OS-Specific Configurations"
echo -e "   • Network & Hardware Facts"
echo -e "   • Loop + Conditional Combinations"
echo -e "   • Register & Conditional Execution"
echo ""

echo -e "${BLUE}📁 Working Directory:${NC}"
echo -e "   ${GREEN}cd ~/ansible/${NC}"
echo ""

echo -e "${BLUE}📖 View Instructions:${NC}"
echo -e "   ${GREEN}cat ~/exams/exam-06/README.md | less${NC}"
echo ""

echo -e "${BLUE}📊 Grade Your Work:${NC}"
echo -e "   ${GREEN}bash ~/exams/exam-06/grade.sh${NC}"
echo ""

echo -e "${YELLOW}⚠️  Important Rules:${NC}"
echo -e "   • Work as user ${GREEN}student${NC} on ${GREEN}control.example.com${NC}"
echo -e "   • All files must be in ${GREEN}/home/student/ansible/${NC}"
echo -e "   • Do NOT modify ${GREEN}/etc/ansible/ansible.cfg${NC}"
echo -e "   • Playbooks must run without errors"
echo -e "   • No partial credit — tasks are all-or-nothing"
echo ""

echo -e "${MAGENTA}💡 Pro Tips:${NC}"
echo -e "   • Use ${GREEN}ansible hostname -m setup${NC} to explore facts"
echo -e "   • Use ${GREEN}ansible hostname -m setup -a 'filter=ansible_*'${NC} for specific facts"
echo -e "   • Test conditionals with ${GREEN}debug${NC} module first"
echo -e "   • Remember: ${GREEN}ansible_local${NC} for custom facts"
echo -e "   • Check ${GREEN}ansible-doc${NC} for module syntax"
echo ""

# Confirmation
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
read -p "$(echo -e ${YELLOW}Ready to start the 3-hour timer? [y/N]:${NC} )" -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${RED}❌ Exam cancelled.${NC}"
    echo ""
    exit 0
fi

# Start timer
START_TIME=$(date +%s)
echo "$START_TIME" > "$TIMER_FILE"

clear

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${YELLOW}✅ EXAM STARTED!${NC}                                          ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}⏰ Timer Started:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${CYAN}⏰ Exam Ends:${NC} $(date -d "+${EXAM_DURATION} minutes" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v+${EXAM_DURATION}M '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
echo ""
echo -e "${YELLOW}📋 Quick Start:${NC}"
echo -e "   1. ${GREEN}cd ~/ansible/${NC}"
echo -e "   2. ${GREEN}cat ~/exams/exam-06/README.md | less${NC}"
echo -e "   3. Start with Task 01 and work through sequentially"
echo -e "   4. ${GREEN}bash ~/exams/exam-06/grade.sh${NC} when done"
echo ""
echo -e "${MAGENTA}💡 Remember:${NC}"
echo -e "   • ${GREEN}ansible node1.example.com -m setup${NC} → See all facts"
echo -e "   • ${GREEN}ansible node1.example.com -m setup -a 'filter=ansible_mem*'${NC} → Filter facts"
echo -e "   • Test your playbooks frequently!"
echo -e "   • Use ${GREEN}--check${NC} mode to test without changes"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Good luck! 🚀${NC}"
echo ""

# Change to working directory
cd ~/ansible/ 2>/dev/null || cd ~

# Create a reminder script
cat > /tmp/exam06_reminder.sh << 'EOF'
#!/bin/bash
TIMER_FILE="$HOME/.exam06_timer"
if [ -f "$TIMER_FILE" ]; then
    START_TIME=$(cat "$TIMER_FILE")
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    ELAPSED_MIN=$((ELAPSED / 60))
    REMAINING=$((180 - ELAPSED_MIN))
    
    if [ $REMAINING -le 0 ]; then
        echo "⏰ EXAM TIME EXPIRED! Grade your work: bash ~/exams/exam-06/grade.sh"
        rm -f "$TIMER_FILE"
    else
        HOURS=$((REMAINING / 60))
        MINS=$((REMAINING % 60))
        echo "⏰ Exam 06 - Time remaining: ${HOURS}h ${MINS}m"
    fi
fi
EOF
chmod +x /tmp/exam06_reminder.sh

# Show initial time remaining
/tmp/exam06_reminder.sh

# Made with Bob
