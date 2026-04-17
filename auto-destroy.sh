#!/bin/bash
#
# Auto-destroy RHCE Killer lab after 1 hour of inactivity
# This script monitors SSH connections and destroys the environment if inactive
#

INACTIVITY_TIMEOUT=3600  # 1 hour in seconds
CHECK_INTERVAL=300       # Check every 5 minutes
LAST_ACTIVITY_FILE="/tmp/rhce-last-activity"
CONTROL_IP=$(cd terraform && terraform output -raw control_public_ip 2>/dev/null)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  RHCE Killer - Auto-Destroy Monitor                       ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚙️  Configuration:${NC}"
echo -e "   • Inactivity timeout: ${GREEN}1 hour${NC}"
echo -e "   • Check interval: ${GREEN}5 minutes${NC}"
echo -e "   • Control node IP: ${GREEN}${CONTROL_IP}${NC}"
echo ""
echo -e "${YELLOW}📊 Monitoring started...${NC}"
echo -e "   Press Ctrl+C to stop monitoring"
echo ""

# Initialize last activity timestamp
date +%s > "$LAST_ACTIVITY_FILE"

# Function to check if there are active SSH connections
check_activity() {
    if [ -z "$CONTROL_IP" ]; then
        echo -e "${RED}❌ Cannot get control node IP. Is Terraform initialized?${NC}"
        return 1
    fi
    
    # Check if we can connect to the control node
    if ssh -i rhce-killer.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
        student@${CONTROL_IP} "who" &>/dev/null; then
        
        # Check for active SSH sessions
        ACTIVE_USERS=$(ssh -i rhce-killer.pem -o StrictHostKeyChecking=no \
            student@${CONTROL_IP} "who | wc -l" 2>/dev/null)
        
        if [ "$ACTIVE_USERS" -gt 0 ]; then
            # Update last activity timestamp
            date +%s > "$LAST_ACTIVITY_FILE"
            return 0
        fi
    fi
    
    return 1
}

# Function to destroy the environment
destroy_environment() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}  ⚠️  INACTIVITY DETECTED - AUTO-DESTROYING ENVIRONMENT    ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}🔥 Destroying Terraform infrastructure...${NC}"
    echo ""
    
    cd terraform
    terraform destroy -auto-approve
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Environment successfully destroyed!${NC}"
        echo -e "${GREEN}💰 AWS resources have been cleaned up to save costs.${NC}"
        echo ""
        echo -e "${YELLOW}To recreate the environment:${NC}"
        echo -e "   ${GREEN}make up${NC}"
        echo ""
    else
        echo ""
        echo -e "${RED}❌ Failed to destroy environment. Please run manually:${NC}"
        echo -e "   ${GREEN}cd terraform && terraform destroy${NC}"
        echo ""
    fi
    
    # Clean up
    rm -f "$LAST_ACTIVITY_FILE"
    exit 0
}

# Trap Ctrl+C
trap 'echo ""; echo -e "${YELLOW}⚠️  Monitoring stopped by user${NC}"; rm -f "$LAST_ACTIVITY_FILE"; exit 0' INT

# Main monitoring loop
while true; do
    CURRENT_TIME=$(date +%s)
    LAST_ACTIVITY=$(cat "$LAST_ACTIVITY_FILE" 2>/dev/null || echo "$CURRENT_TIME")
    INACTIVE_TIME=$((CURRENT_TIME - LAST_ACTIVITY))
    REMAINING_TIME=$((INACTIVITY_TIMEOUT - INACTIVE_TIME))
    
    if check_activity; then
        MINUTES_REMAINING=$((REMAINING_TIME / 60))
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${GREEN}✓${NC} Active users detected. Auto-destroy in: ${GREEN}${MINUTES_REMAINING}+ minutes${NC}"
    else
        if [ $INACTIVE_TIME -ge $INACTIVITY_TIMEOUT ]; then
            destroy_environment
        else
            MINUTES_REMAINING=$((REMAINING_TIME / 60))
            echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${YELLOW}⚠${NC}  No activity. Auto-destroy in: ${YELLOW}${MINUTES_REMAINING} minutes${NC}"
        fi
    fi
    
    sleep $CHECK_INTERVAL
done

# Made with Bob
