.PHONY: up ssh destroy reset status help bootstrap-status sync-exams

MY_IP    := $(shell curl -s ifconfig.me)/32
TF_DIR   := terraform
KEY_FILE := rhce-killer.pem

help:
	@echo ""
	@echo "  RHCE Killer — EX294 Lab"
	@echo ""
	@echo "  make up               — spin up 3 EC2 instances (detects your IP)"
	@echo "  make bootstrap-status — check if bootstrap is complete"
	@echo "  make sync-exams       — sync all exam files to control node"
	@echo "  make ssh              — SSH into control node as rocky"
	@echo "  make ssh-student      — SSH into control node as student"
	@echo "  make destroy          — destroy all resources (stop billing)"
	@echo "  make status           — show IPs"
	@echo "  make debug            — tail bootstrap log on control node"
	@echo "  make ip-fix           — update SG if your IP changed"
	@echo ""

up:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  RHCE Killer - Deploying Lab Infrastructure                ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Your IP: $(MY_IP)"
	@echo ""
	@cd $(TF_DIR) && terraform init -upgrade
	@cd $(TF_DIR) && terraform apply -var="my_ip=$(MY_IP)" -auto-approve
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  Infrastructure Deployed! Bootstrap in Progress...         ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "⏳ Bootstrap is running (takes ~3 minutes)"
	@echo ""
	@echo "📋 Available commands while waiting:"
	@echo ""
	@echo "  make debug"
	@echo "    → Watch bootstrap progress in real-time"
	@echo "    → Shows last 50 lines of bootstrap log"
	@echo ""
	@echo "  make bootstrap-status"
	@echo "    → Check if bootstrap is complete"
	@echo "    → Shows ✅ when ready"
	@echo ""
	@echo "🎯 Next steps (after bootstrap completes):"
	@echo ""
	@echo "  1. Run: make sync-exams"
	@echo "     → Syncs all 5 exam files to the lab"
	@echo ""
	@echo "  2. Run: make ssh-student"
	@echo "     → SSH into the lab as student user"
	@echo ""
	@echo "  3. Start practicing:"
	@echo "     → bash ~/exams/exam-01/START.sh"
	@echo ""
	@echo "💡 Tip: Run 'rhce bootstrap-status' in 2-3 minutes"
	@echo ""

bootstrap-status:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  Checking Bootstrap Status...                              ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip 2>/dev/null); \
	if [ -z "$$CONTROL_IP" ]; then \
		echo "❌ Lab not running. Run 'rhce up' first."; \
		exit 1; \
	fi; \
	if ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no -o ConnectTimeout=5 rocky@$$CONTROL_IP \
		"sudo grep -q 'Bootstrap complete' /var/log/rhce-bootstrap.log 2>/dev/null" 2>/dev/null; then \
		echo "✅ Bootstrap Complete!"; \
		echo ""; \
		ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
			"sudo tail -3 /var/log/rhce-bootstrap.log"; \
		echo ""; \
		echo "╔════════════════════════════════════════════════════════════╗"; \
		echo "║  🎉 Lab is Ready! Next Steps:                              ║"; \
		echo "╚════════════════════════════════════════════════════════════╝"; \
		echo ""; \
		echo "1️⃣  Sync exam files:"; \
		echo "    make sync-exams"; \
		echo ""; \
		echo "2️⃣  SSH into the lab:"; \
		echo "    make ssh-student"; \
		echo ""; \
		echo "3️⃣  View available exams:"; \
		echo "    ls ~/exams/"; \
		echo ""; \
		echo "4️⃣  Start your first exam:"; \
		echo "    bash ~/exams/exam-01/START.sh"; \
		echo ""; \
		echo "5️⃣  Grade your work:"; \
		echo "    bash ~/exams/exam-01/grade.sh"; \
		echo ""; \
		echo "📚 Read exam instructions:"; \
		echo "    cat ~/exams/exam-01/README.md | less"; \
		echo ""; \
		echo "💡 Tip: Start with exam-01 (Basic) and progress to exam-05 (Expert)"; \
		echo ""; \
	else \
		echo "⏳ Bootstrap still running... (takes ~3 minutes)"; \
		echo ""; \
		echo "📋 What you can do:"; \
		echo ""; \
		echo "  make debug"; \
		echo "    → Watch bootstrap progress in real-time"; \
		echo ""; \
		echo "  make bootstrap-status"; \
		echo "    → Check again (try in 30 seconds)"; \
		echo ""; \
		echo "💡 Tip: Bootstrap installs Ansible, configures SSH, and sets up the lab"; \
		echo ""; \
	fi

ssh:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no -o ServerAliveInterval=60 rocky@$$CONTROL_IP

ssh-student:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no student@$$CONTROL_IP

debug:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
	  "sudo tail -50 /var/log/rhce-bootstrap.log"

status:
	@cd $(TF_DIR) && terraform output

destroy:
	@echo "WARNING: destroys all lab resources."
	@read -p "Type 'yes' to confirm: " C; \
	[ "$$C" = "yes" ] && \
	  cd $(TF_DIR) && terraform destroy -var="my_ip=$(MY_IP)" -auto-approve && \
	  cd .. && rm -f $(KEY_FILE) || echo "Cancelled."

ip-fix:
	@echo "Updating your IP to: $(MY_IP)"
	@cd $(TF_DIR) && terraform apply -var="my_ip=$(MY_IP)" \
	  -target=aws_security_group.control -auto-approve

sync-exams:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  Syncing Exam Files to Lab...                              ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip 2>/dev/null); \
	if [ -z "$$CONTROL_IP" ]; then \
		echo "❌ Lab not running. Run 'rhce up' first."; \
		exit 1; \
	fi; \
	echo "📦 Copying exam files to control node..."; \
	scp -i $(KEY_FILE) -o StrictHostKeyChecking=no -r exam-01 exam-02 exam-03 exam-04 exam-05 rocky@$$CONTROL_IP:/tmp/ 2>/dev/null; \
	echo "📥 Installing exam files..."; \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
		"sudo rm -rf /home/student/exams/* && \
		 sudo cp -r /tmp/exam-* /home/student/exams/ && \
		 sudo chown -R student:student /home/student/exams/ && \
		 sudo chmod +x /home/student/exams/*/*.sh && \
		 sudo rm -rf /tmp/exam-*" 2>/dev/null; \
	echo ""; \
	echo "✅ All exam files synced successfully!"; \
	echo ""; \
	echo "╔════════════════════════════════════════════════════════════╗"; \
	echo "║  🎯 Ready to Start! Here's What to Do:                     ║"; \
	echo "╚════════════════════════════════════════════════════════════╝"; \
	echo ""; \
	echo "1️⃣  SSH into the lab:"; \
	echo "    make ssh-student"; \
	echo ""; \
	echo "2️⃣  View available exams:"; \
	echo "    ls ~/exams/"; \
	echo ""; \
	echo "    You'll see:"; \
	echo "    • exam-01 (⭐ Basic - 100 pts)"; \
	echo "    • exam-02 (⭐⭐ Intermediate - 120 pts)"; \
	echo "    • exam-03 (⭐⭐⭐ Roles & Collections - 120 pts)"; \
	echo "    • exam-04 (⭐⭐⭐ Linux Admin - 120 pts)"; \
	echo "    • exam-05 (⭐⭐⭐⭐ Troubleshooting - 150 pts)"; \
	echo ""; \
	echo "3️⃣  Read exam instructions:"; \
	echo "    cat ~/exams/exam-01/README.md | less"; \
	echo ""; \
	echo "4️⃣  Start the exam (4-hour timer):"; \
	echo "    bash ~/exams/exam-01/START.sh"; \
	echo ""; \
	echo "5️⃣  Grade your work:"; \
	echo "    bash ~/exams/exam-01/grade.sh"; \
	echo ""; \
	echo "💡 Tips:"; \
	echo "   • Start with exam-01 if you're new to Ansible"; \
	echo "   • Each exam has complete solutions in the README"; \
	echo "   • Use 'ansible-doc <module>' for help"; \
	echo "   • The grading script gives specific hints"; \
	echo ""; \
	echo "📚 Your workspace: ~/ansible/"; \
	echo ""; \
	echo "🚀 Good luck! Remember: rhce destroy when done to stop billing"; \
	echo ""
