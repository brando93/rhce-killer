.PHONY: up ssh destroy reset status help bootstrap-status sync-exams

MY_IP    := $(shell curl -s ifconfig.me)/32
TF_DIR   := terraform
KEY_FILE := rhce-killer.pem

help:
	@echo ""
	@echo "  RHCE Killer — EX294 Lab (21 Exams Available)"
	@echo ""
	@echo "  make up               — spin up 3 EC2 instances (detects your IP)"
	@echo "  make bootstrap-status — check if bootstrap is complete"
	@echo "  make sync-exams       — sync all 21 exam files to control node"
	@echo "  make ssh              — SSH into control node as rocky"
	@echo "  make ssh-student      — SSH into control node as student"
	@echo "  make destroy          — destroy all resources (stop billing)"
	@echo "  make status           — show IPs"
	@echo "  make debug            — tail bootstrap log on control node"
	@echo "  make ip-fix           — update SG if your IP changed"
	@echo ""
	@echo "  📚 Two Learning Paths:"
	@echo "     Path A: 5 complete exams (real exam simulation)"
	@echo "     Path B: 16 thematic exams (deep learning by topic)"
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
	@echo "💡 Tip: Run 'make bootstrap-status' in 2-3 minutes"
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
	echo "   → Complete exams (exam-01 to exam-05)"; \
	scp -i $(KEY_FILE) -o StrictHostKeyChecking=no -r exam-01 exam-02 exam-03 exam-04 exam-05 rocky@$$CONTROL_IP:/tmp/ 2>/dev/null; \
	echo "   → Thematic exams (16 topic-focused exams)"; \
	scp -i $(KEY_FILE) -o StrictHostKeyChecking=no -r \
		inventory-basics playbooks-fundamentals variables-and-facts \
		conditionals-and-when loops-and-iteration blocks-and-error-handling \
		jinja2-basics jinja2-advanced ansible-vault ssh-and-privilege \
		roles-basics roles-advanced collections-and-galaxy \
		debugging-and-troubleshooting performance-optimization system-administration \
		rocky@$$CONTROL_IP:/tmp/ 2>/dev/null; \
	echo "📥 Installing exam files..."; \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
		"sudo rm -rf /home/student/exams/* && \
		 sudo mkdir -p /home/student/exams/complete /home/student/exams/thematic && \
		 sudo cp -r /tmp/exam-* /home/student/exams/complete/ && \
		 sudo cp -r /tmp/inventory-* /tmp/playbooks-* /tmp/variables-* \
		           /tmp/conditionals-* /tmp/loops-* /tmp/blocks-* \
		           /tmp/jinja2-* /tmp/ansible-vault /tmp/ssh-* \
		           /tmp/roles-* /tmp/collections-* \
		           /tmp/debugging-* /tmp/performance-* /tmp/system-* \
		           /home/student/exams/thematic/ 2>/dev/null; \
		 sudo chown -R student:student /home/student/exams/ && \
		 sudo chmod +x /home/student/exams/*/*.sh /home/student/exams/*/*/*.sh && \
		 sudo rm -rf /tmp/exam-* /tmp/inventory-* /tmp/playbooks-* /tmp/variables-* \
		            /tmp/conditionals-* /tmp/loops-* /tmp/blocks-* \
		            /tmp/jinja2-* /tmp/ansible-vault /tmp/ssh-* \
		            /tmp/roles-* /tmp/collections-* \
		            /tmp/debugging-* /tmp/performance-* /tmp/system-*" 2>/dev/null; \
	echo ""; \
	echo "✅ All 21 exam files synced successfully!"; \
	echo ""; \
	echo "╔════════════════════════════════════════════════════════════╗"; \
	echo "║  🎯 Ready to Start! Two Learning Paths Available:         ║"; \
	echo "╚════════════════════════════════════════════════════════════╝"; \
	echo ""; \
	echo "📚 PATH A: Complete Exams (Real Exam Simulation)"; \
	echo "   Location: ~/exams/complete/"; \
	echo "   • exam-01 (⭐ Basic - 100 pts, 4h)"; \
	echo "   • exam-02 (⭐⭐ Intermediate - 120 pts, 4h)"; \
	echo "   • exam-03 (⭐⭐⭐ Roles & Collections - 120 pts, 4h)"; \
	echo "   • exam-04 (⭐⭐⭐ Linux Admin - 120 pts, 4h)"; \
	echo "   • exam-05 (⭐⭐⭐⭐ Troubleshooting - 150 pts, 4h)"; \
	echo ""; \
	echo "🎓 PATH B: Thematic Exams (Deep Learning by Topic)"; \
	echo "   Location: ~/exams/thematic/"; \
	echo "   Fundamentals:"; \
	echo "   • inventory-basics (120 pts, 2h)"; \
	echo "   • playbooks-fundamentals (155 pts, 2.5h)"; \
	echo "   • variables-and-facts (200 pts, 3h)"; \
	echo "   Logic & Control:"; \
	echo "   • conditionals-and-when (187 pts, 2.5h)"; \
	echo "   • loops-and-iteration (207 pts, 2.5h)"; \
	echo "   • blocks-and-error-handling (215 pts, 2.5h)"; \
	echo "   Templates:"; \
	echo "   • jinja2-basics (286 pts, 3h)"; \
	echo "   • jinja2-advanced (366 pts, 3.5h)"; \
	echo "   Security:"; \
	echo "   • ansible-vault (213 pts, 2.5h)"; \
	echo "   • ssh-and-privilege (215 pts, 2.5h)"; \
	echo "   Roles:"; \
	echo "   • roles-basics (263 pts, 3h)"; \
	echo "   • roles-advanced (436 pts, 3.5h)"; \
	echo "   • collections-and-galaxy (214 pts, 2.5h)"; \
	echo "   Optimization:"; \
	echo "   • debugging-and-troubleshooting (240 pts, 2.5h)"; \
	echo "   • performance-optimization (244 pts, 2.5h)"; \
	echo "   • system-administration (289 pts, 3h)"; \
	echo ""; \
	echo "🚀 Quick Start:"; \
	echo "   1. SSH: make ssh-student"; \
	echo "   2. List: ls ~/exams/complete/ ~/exams/thematic/"; \
	echo "   3. Start: bash ~/exams/complete/exam-01/START.sh"; \
	echo "   4. Grade: bash ~/exams/complete/exam-01/grade.sh"; \
	echo ""; \
	echo "💡 Recommendation:"; \
	echo "   • New to Ansible? Start with Path B (thematic)"; \
	echo "   • Preparing for exam? Use Path A (complete)"; \
	echo "   • Need practice on specific topics? Use Path B"; \
	echo ""; \
	echo "📚 Your workspace: ~/ansible/"; \
	echo "🚀 Remember: make destroy when done to stop billing"; \
	echo ""
