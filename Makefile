.PHONY: up tf-apply wait-bootstrap bootstrap-status sync-exams \
        ssh ssh-student destroy verify status help debug ip-fix unlock

# ─── Configuration ──────────────────────────────────────────────
TF_DIR    := terraform
KEY_FILE  := rhce-killer.pem
LAB_UP    := bash scripts/lab-up.sh

# Lazy IP detection: only resolves when actually used
MY_IP      = $(shell curl -s ifconfig.me)/32

# Common SSH options for one-shot helpers (debug, ssh, etc.)
SSH_OPTS  := -i $(KEY_FILE) -o StrictHostKeyChecking=no -o ServerAliveInterval=60

# ────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "  RHCE Killer — EX294 Lab"
	@echo ""
	@echo "  make up               full pipeline: provision → bootstrap → sync (one command)"
	@echo "  make ssh-student      SSH into control as student"
	@echo "  make ssh              SSH into control as rocky"
	@echo "  make sync-exams       re-push exam files (after editing locally)"
	@echo "  make destroy          tear down lab and stop billing (with progress bar + verify)"
	@echo "  make verify           list any AWS resources Terraform still tracks"
	@echo "  make status           show Terraform outputs (IPs)"
	@echo "  make debug            tail bootstrap log on control node"
	@echo "  make ip-fix           update SG when your public IP changes"
	@echo "  make bootstrap-status one-shot bootstrap check (no polling)"
	@echo "  make wait-bootstrap   block until bootstrap finishes (with progress bar)"
	@echo "  make unlock           force-release a stale Terraform state lock"
	@echo ""
	@echo "  Logs from each phase live under .lab-logs/"
	@echo "  Tail any phase live in another terminal: tail -f .lab-logs/01-tf-apply.log"
	@echo ""

# ─── One-command pipeline (delegates to scripts/lab-up.sh) ──────
up:
	@$(LAB_UP) up

tf-apply:
	@$(LAB_UP) tf-apply

wait-bootstrap:
	@$(LAB_UP) wait-bootstrap

sync-exams:
	@$(LAB_UP) sync-exams

# ─── Single-shot bootstrap check (no polling) ───────────────────
bootstrap-status:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip 2>/dev/null); \
	if [ -z "$$CONTROL_IP" ]; then \
	  echo "  Lab not running. Run 'make up' first."; exit 1; \
	fi; \
	if ssh $(SSH_OPTS) -o BatchMode=yes -o ConnectTimeout=5 \
	     rocky@$$CONTROL_IP \
	     "sudo grep -q 'Bootstrap complete' /var/log/rhce-bootstrap.log 2>/dev/null" \
	     2>/dev/null; then \
	  echo "  ✓ Bootstrap complete"; \
	else \
	  echo "  ⏳ Bootstrap still running — try 'make wait-bootstrap' for live progress"; \
	fi

# ─── Convenience helpers ────────────────────────────────────────
ssh:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh $(SSH_OPTS) rocky@$$CONTROL_IP

ssh-student:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh $(SSH_OPTS) student@$$CONTROL_IP

debug:
	@CONTROL_IP=$$(cd $(TF_DIR) && terraform output -raw control_public_ip); \
	ssh $(SSH_OPTS) rocky@$$CONTROL_IP \
	    "sudo tail -50 /var/log/rhce-bootstrap.log"

status:
	@cd $(TF_DIR) && terraform output

destroy:
	@echo ""
	@echo "  WARNING — this will destroy all AWS resources for the lab:"
	@echo "    • 3 EC2 instances (control + node1 + node2)"
	@echo "    • 1 NAT Gateway + 1 Elastic IP  (the silent billers)"
	@echo "    • VPC, subnets, route tables, security groups, key pair"
	@echo ""
	@read -p "  Type 'yes' to confirm: " C; \
	if [ "$$C" != "yes" ]; then \
	  echo "  Cancelled."; \
	  exit 0; \
	fi; \
	$(LAB_UP) destroy

# Sanity-check: list any resources Terraform still tracks (run after destroy
# to confirm nothing leaked, or any time to inspect lab state).
verify:
	@$(LAB_UP) verify

ip-fix:
	@echo "  Updating SG to allow your IP: $(MY_IP)"
	@cd $(TF_DIR) && terraform apply -var="my_ip=$(MY_IP)" \
	  -target=aws_security_group.control -auto-approve

# Recover from a stale Terraform state lock (e.g. after a crashed apply).
unlock:
	@LOCK_ID=$$(cd $(TF_DIR) && terraform plan -no-color 2>&1 \
	            | awk '/^\s*ID:[[:space:]]+/ {print $$2; exit}'); \
	if [ -z "$$LOCK_ID" ]; then \
	  echo "  No state lock detected. Nothing to unlock."; \
	  exit 0; \
	fi; \
	echo "  Found stale lock: $$LOCK_ID"; \
	read -p "  Force-unlock? [y/N] " C; \
	if [ "$$C" = "y" ] || [ "$$C" = "Y" ]; then \
	  cd $(TF_DIR) && terraform force-unlock -force "$$LOCK_ID" \
	    && echo "  ✓ Unlocked. Run 'make up' to retry."; \
	else \
	  echo "  Cancelled."; \
	fi
