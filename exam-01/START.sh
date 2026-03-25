#!/bin/bash
# ─────────────────────────────────────────────
# RHCE Killer — Exam Timer
# Simulates the real EX294 exam experience
# ─────────────────────────────────────────────

EXAM_DURATION=$((4 * 60 * 60))  # 4 hours in seconds
START_TIME=$(date +%s)
END_TIME=$((START_TIME + EXAM_DURATION))
LOG_FILE="/home/student/.exam_start_time"

# Save start time for reference
echo "$START_TIME" > "$LOG_FILE"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           RHCE KILLER — EX294 Exam 01 Starting              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  Duration : 4 hours                                          ║"
echo "║  Start    : $(date '+%H:%M:%S %Z')                                    ║"
echo "║  End      : $(date -d "@$END_TIME" '+%H:%M:%S %Z' 2>/dev/null || date -r "$END_TIME" '+%H:%M:%S %Z')                                    ║"
echo "║                                                              ║"
echo "║  Working directory: /home/student/ansible/                   ║"
echo "║                                                              ║"
echo "║  Read the exam at: ~/exams/exam-01/README.md                 ║"
echo "║  Grade yourself  : bash ~/exams/exam-01/grade.sh             ║"
echo "║                                                              ║"
echo "║  Press Ctrl+C to exit timer (exam continues)                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Show countdown in background via tmux status bar or standalone
while true; do
  NOW=$(date +%s)
  REMAINING=$((END_TIME - NOW))

  if [ "$REMAINING" -le 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║           ⏰  TIME IS UP!                 ║"
    echo "║   Run: bash ~/exams/exam-01/grade.sh     ║"
    echo "╚══════════════════════════════════════════╝"
    break
  fi

  HH=$((REMAINING / 3600))
  MM=$(( (REMAINING % 3600) / 60 ))
  SS=$((REMAINING % 60))

  # Warning colors
  if [ "$REMAINING" -le 300 ]; then      # last 5 min
    COLOR="\033[0;31m"   # red
  elif [ "$REMAINING" -le 900 ]; then    # last 15 min
    COLOR="\033[1;33m"   # yellow
  else
    COLOR="\033[0;36m"   # cyan
  fi

  printf "\r  ${COLOR}Time remaining: %02d:%02d:%02d\033[0m   " "$HH" "$MM" "$SS"

  # Alerts
  if [ "$REMAINING" -eq 3600 ]; then
    echo -e "\n\n  ⚠️  ONE HOUR REMAINING — prioritize incomplete tasks!\n"
  elif [ "$REMAINING" -eq 900 ]; then
    echo -e "\n\n  ⚠️  15 MINUTES LEFT — wrap up and verify!\n"
  elif [ "$REMAINING" -eq 300 ]; then
    echo -e "\n\n  🚨 5 MINUTES LEFT — stop and grade now!\n"
  fi

  sleep 1
done
