.PHONY: up ssh destroy reset status help

MY_IP    := $(shell curl -s ifconfig.me)/32
TF_DIR   := terraform
KEY_FILE := rhce-killer.pem

help:
	@echo ""
	@echo "  RHCE Killer — EX294 Lab"
	@echo ""
	@echo "  make up       — spin up 3 EC2 instances (detects your IP)"
	@echo "  make ssh      — SSH into control node as rocky"
	@echo "  make destroy  — destroy all resources (stop billing)"
	@echo "  make status   — show IPs"
	@echo "  make debug    — tail bootstrap log on control node"
	@echo "  make ip-fix   — update SG if your IP changed"
	@echo ""

up:
	@echo "Your IP: $(MY_IP)"
	@cd $(TF_DIR) && terraform init -upgrade
	@cd $(TF_DIR) && terraform apply -var="my_ip=$(MY_IP)" -auto-approve
	@echo ""
	@echo "Wait ~3 min for bootstrap, then: make ssh"
	@echo "Watch bootstrap: make debug"

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
