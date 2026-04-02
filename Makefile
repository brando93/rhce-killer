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
	@echo "Your IP: $(MY_IP)"
	@cd $(TF_DIR) && terraform init -upgrade
	@cd $(TF_DIR) && terraform apply -var="my_ip=$(MY_IP)" -auto-approve
	@echo ""
	@echo "Wait ~3 min for bootstrap, then: make ssh"
	@echo "Watch bootstrap: make debug"

bootstrap-status:
	@echo "Checking bootstrap status..."
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip 2>/dev/null); \
	if [ -z "$$CONTROL_IP" ]; then \
		echo "❌ Lab not running. Run 'make up' first."; \
		exit 1; \
	fi; \
	if ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no -o ConnectTimeout=5 rocky@$$CONTROL_IP \
		"sudo grep -q 'Bootstrap complete' /var/log/rhce-bootstrap.log 2>/dev/null" 2>/dev/null; then \
		echo "✅ Bootstrap complete! You can now run 'make ssh'"; \
		echo ""; \
		ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
			"sudo tail -3 /var/log/rhce-bootstrap.log"; \
	else \
		echo "⏳ Bootstrap still running... (this takes ~3 minutes)"; \
		echo ""; \
		echo "Watch progress with: make debug"; \
		echo "Or try again in 30 seconds: make bootstrap-status"; \
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
	@echo "Syncing exam files to control node..."
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip 2>/dev/null); \
	if [ -z "$$CONTROL_IP" ]; then \
		echo "❌ Lab not running. Run 'make up' first."; \
		exit 1; \
	fi; \
	echo "Copying exam files to control node..."; \
	scp -i $(KEY_FILE) -o StrictHostKeyChecking=no -r exam-01 exam-02 exam-03 exam-04 exam-05 rocky@$$CONTROL_IP:/tmp/; \
	echo "Installing exam files..."; \
	ssh -i $(KEY_FILE) -o StrictHostKeyChecking=no rocky@$$CONTROL_IP \
		"sudo rm -rf /home/student/exams/* && \
		 sudo cp -r /tmp/exam-* /home/student/exams/ && \
		 sudo chown -R student:student /home/student/exams/ && \
		 sudo chmod +x /home/student/exams/*/*.sh && \
		 sudo rm -rf /tmp/exam-*"; \
	echo "✅ All exam files synced successfully!"; \
	echo ""; \
	echo "You can now:"; \
	echo "  1. SSH to control: make ssh-student"; \
	echo "  2. View exams: ls ~/exams/"; \
	echo "  3. Start exam: bash ~/exams/exam-01/START.sh"
