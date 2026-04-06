# RHCE Killer — Ansible Vault
## EX294: Mastering Secrets Management

---

> **Intermediate Exam: Vault Security**
> This exam teaches you how to secure sensitive data with Ansible Vault.
> Master encryption, decryption, and vault password management.
> Time limit: **2.5 hours**. Start the timer with: `bash START.sh`

---

## Environment

| Host | IP | Role |
|------|----|------|
| control.example.com | 10.0.1.10 | Control node (you work here) |
| node1.example.com | 10.0.2.11 | Managed node (Rocky Linux 9) |
| node2.example.com | 10.0.2.12 | Managed node (Rocky Linux 9) |

Your working directory: `/home/student/ansible/`
Your inventory file: `/home/student/ansible/inventory`
Your config file: `/home/student/ansible/ansible.cfg`
Your vault password file: `/home/student/ansible/.vault_pass`

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks must be created under `/home/student/ansible/`
- Use vault password: `ansible123` (stored in `.vault_pass`)
- Playbooks must run without errors
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, variables-and-facts

You should know:
- How to write playbooks
- How to use variables
- Basic file operations
- How to run playbooks

---

## Tasks

### Task 01 — Create Vault Password File (10 pts)

Create a vault password file `/home/student/ansible/.vault_pass` that:
- Contains the password: `ansible123`
- Has permissions `0600`
- Is used automatically by ansible.cfg

**Requirements:**
- Create file with correct password
- Set proper permissions
- Verify ansible.cfg references it

---

### Task 02 — Encrypt a String (12 pts)

Create a playbook `/home/student/ansible/vault-string.yml` that:
- Runs on **all managed nodes**
- Defines an encrypted variable `db_password` with value `SecretPass123`
- Uses `ansible-vault encrypt_string` to encrypt it
- Displays the password (decrypted) using debug
- Uses `become: true`

**Requirements:**
- Use `ansible-vault encrypt_string`
- Embed encrypted string in playbook
- Variable name: `db_password`
- Playbook runs successfully

---

### Task 03 — Create Encrypted File (15 pts)

Create an encrypted file `/home/student/ansible/secrets.yml` that:
- Contains variables:
  ```yaml
  api_key: "ABC123XYZ"
  db_password: "MySecretDB"
  admin_password: "AdminPass456"
  ```
- Is encrypted with ansible-vault
- Uses vault password from `.vault_pass`

**Requirements:**
- Use `ansible-vault create`
- File must be encrypted
- Contains all three variables
- Can be decrypted with vault password

---

### Task 04 — Use Encrypted Variables (15 pts)

Create a playbook `/home/student/ansible/vault-use.yml` that:
- Runs on **all managed nodes**
- Loads variables from `secrets.yml`
- Creates file `/tmp/api-config.txt` with content: `API Key: {{ api_key }}`
- Uses encrypted variables

**Requirements:**
- Use `vars_files` to load secrets.yml
- Access encrypted variables
- Deploy to managed nodes
- Playbook runs with vault password

---

### Task 05 — Encrypt Existing File (12 pts)

Create a plain file `/home/student/ansible/credentials.yml` with:
```yaml
username: admin
password: PlainPassword
```

Then encrypt it using `ansible-vault encrypt`.

**Requirements:**
- Create plain file first
- Use `ansible-vault encrypt`
- File becomes encrypted
- Original content preserved

---

### Task 06 — Decrypt File (10 pts)

Decrypt the file `credentials.yml` from Task 05 using `ansible-vault decrypt`.

**Requirements:**
- Use `ansible-vault decrypt`
- File becomes plain text
- Content readable
- Can be re-encrypted

---

### Task 07 — View Encrypted File (10 pts)

View the contents of `secrets.yml` without decrypting it permanently using `ansible-vault view`.

**Requirements:**
- Use `ansible-vault view`
- Display contents
- File remains encrypted
- No permanent changes

---

### Task 08 — Edit Encrypted File (15 pts)

Edit `secrets.yml` to add a new variable `smtp_password: EmailPass789` using `ansible-vault edit`.

**Requirements:**
- Use `ansible-vault edit`
- Add new variable
- File remains encrypted
- Changes saved

---

### Task 09 — Rekey Encrypted File (15 pts)

Change the vault password for `secrets.yml` from `ansible123` to `newpass456` using `ansible-vault rekey`.

**Requirements:**
- Use `ansible-vault rekey`
- Old password: `ansible123`
- New password: `newpass456`
- File remains encrypted
- Accessible with new password

---

### Task 10 — Multiple Vault IDs (18 pts)

Create two encrypted files with different vault IDs:
- `/home/student/ansible/dev-secrets.yml` with vault ID `dev`
- `/home/student/ansible/prod-secrets.yml` with vault ID `prod`

Each contains:
```yaml
environment: dev  # or prod
db_host: localhost
```

**Requirements:**
- Use `--vault-id` option
- Two different vault IDs
- Both files encrypted
- Can be used separately

---

### Task 11 — Playbook with Multiple Vaults (20 pts)

Create a playbook `/home/student/ansible/vault-multi.yml` that:
- Runs on **all managed nodes**
- Loads both `dev-secrets.yml` and `prod-secrets.yml`
- Uses `--vault-id` to specify passwords
- Displays both environment values

**Requirements:**
- Use multiple vault files
- Specify vault IDs when running
- Access variables from both
- Playbook runs successfully

---

### Task 12 — Encrypt Specific Variables (15 pts)

Create a playbook `/home/student/ansible/vault-mixed.yml` that:
- Has both plain and encrypted variables:
  ```yaml
  vars:
    app_name: myapp  # plain
    app_port: 8080   # plain
    api_secret: !vault |  # encrypted
      $ANSIBLE_VAULT;1.1;AES256
      ...
  ```
- Runs on **all managed nodes**
- Uses mixed variables

**Requirements:**
- Mix plain and encrypted variables
- Use `!vault` tag
- Encrypt only sensitive data
- Playbook runs successfully

---

### Task 13 — Vault in Group Variables (18 pts)

Create encrypted group variables file `/home/student/ansible/group_vars/all/vault.yml` that:
- Contains:
  ```yaml
  vault_db_password: "GroupSecret123"
  vault_api_key: "GroupAPI456"
  ```
- Is encrypted with ansible-vault
- Is loaded automatically by playbooks

**Requirements:**
- Create in group_vars/all/
- File name: vault.yml
- Encrypted with vault
- Variables available to all hosts

---

### Task 14 — Vault in Host Variables (18 pts)

Create encrypted host variables file `/home/student/ansible/host_vars/node1.example.com/vault.yml` that:
- Contains:
  ```yaml
  vault_node_secret: "Node1Secret"
  ```
- Is encrypted with ansible-vault
- Is loaded automatically for node1

**Requirements:**
- Create in host_vars/node1.example.com/
- File name: vault.yml
- Encrypted with vault
- Variable available only to node1

---

### Task 15 — Vault Password Script (20 pts)

Create a vault password script `/home/student/ansible/vault-pass.sh` that:
- Is executable
- Outputs the vault password when run
- Can be used with `--vault-password-file`
- Contains: `#!/bin/bash` and `echo "ansible123"`

**Requirements:**
- Create executable script
- Outputs password to stdout
- Works with ansible-vault
- Permissions: 0700

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Create Vault Password File | 10 |
| 02 | Encrypt a String | 12 |
| 03 | Create Encrypted File | 15 |
| 04 | Use Encrypted Variables | 15 |
| 05 | Encrypt Existing File | 12 |
| 06 | Decrypt File | 10 |
| 07 | View Encrypted File | 10 |
| 08 | Edit Encrypted File | 15 |
| 09 | Rekey Encrypted File | 15 |
| 10 | Multiple Vault IDs | 18 |
| 11 | Playbook with Multiple Vaults | 20 |
| 12 | Encrypt Specific Variables | 15 |
| 13 | Vault in Group Variables | 18 |
| 14 | Vault in Host Variables | 18 |
| 15 | Vault Password Script | 20 |
| **Total** | | **213** |

**Passing score: 70% (149/213 points)**

---

## When you finish

```bash
bash /home/student/exams/ansible-vault/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Create Vault Password File

```bash
# Create vault password file
echo "ansible123" > /home/student/ansible/.vault_pass

# Set permissions
chmod 0600 /home/student/ansible/.vault_pass

# Verify ansible.cfg references it
grep vault_password_file /home/student/ansible/ansible.cfg
```

**Expected in ansible.cfg:**
```ini
[defaults]
vault_password_file = /home/student/ansible/.vault_pass
```

**Explanation:**
- Vault password file stores password
- Permissions 0600 = owner read/write only
- ansible.cfg references it automatically
- No need to type password each time

**Verification:**
```bash
ls -la /home/student/ansible/.vault_pass
cat /home/student/ansible/.vault_pass
```

---

## Solution 02 — Encrypt a String

```bash
# Encrypt string
ansible-vault encrypt_string 'SecretPass123' --name 'db_password'
```

**Playbook: vault-string.yml**
```yaml
---
- name: Use encrypted string
  hosts: all
  become: true
  
  vars:
    db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653236336462626566653063336164663966303231363934653561363338373838316566
          3136626431626536303530376637343637346536356635620a653638643939666333613936636331
          63373764616538303034323538323661306231326635633630343137316333666133343530383630
          3438626666666137650a316638313963326662633630343761303764323566363532363361663034
          3833
  
  tasks:
    - name: Display encrypted password
      ansible.builtin.debug:
        msg: "Database password is: {{ db_password }}"
```

**Explanation:**
- `encrypt_string` encrypts single value
- `--name` specifies variable name
- `!vault |` tag marks encrypted data
- Playbook decrypts automatically

**Run:**
```bash
ansible-playbook vault-string.yml
```

---

## Solution 03 — Create Encrypted File

```bash
# Create encrypted file
ansible-vault create secrets.yml
```

**Content to enter:**
```yaml
api_key: "ABC123XYZ"
db_password: "MySecretDB"
admin_password: "AdminPass456"
```

**Explanation:**
- `create` opens editor for new encrypted file
- Enter content in editor
- Save and exit
- File encrypted automatically
- Uses vault password from .vault_pass

**Verification:**
```bash
# View encrypted content
cat secrets.yml

# View decrypted content
ansible-vault view secrets.yml
```

---

## Solution 04 — Use Encrypted Variables

**Playbook: vault-use.yml**
```yaml
---
- name: Use encrypted variables
  hosts: all
  
  vars_files:
    - secrets.yml
  
  tasks:
    - name: Create API config file
      ansible.builtin.copy:
        content: "API Key: {{ api_key }}\n"
        dest: /tmp/api-config.txt
        mode: '0644'
```

**Explanation:**
- `vars_files` loads encrypted file
- Variables decrypted automatically
- Access like normal variables
- Vault password from .vault_pass

**Run:**
```bash
ansible-playbook vault-use.yml
```

**Verification:**
```bash
ansible all -m command -a "cat /tmp/api-config.txt"
```

---

## Solution 05 — Encrypt Existing File

```bash
# Create plain file
cat > credentials.yml << EOF
username: admin
password: PlainPassword
EOF

# Encrypt the file
ansible-vault encrypt credentials.yml
```

**Explanation:**
- Create plain YAML file first
- `encrypt` converts to encrypted
- Original content preserved
- File now encrypted

**Verification:**
```bash
# View encrypted
cat credentials.yml

# View decrypted
ansible-vault view credentials.yml
```

---

## Solution 06 — Decrypt File

```bash
# Decrypt the file
ansible-vault decrypt credentials.yml
```

**Explanation:**
- `decrypt` converts to plain text
- File becomes readable
- Can edit with normal editor
- Can re-encrypt later

**Verification:**
```bash
cat credentials.yml
```

**Re-encrypt if needed:**
```bash
ansible-vault encrypt credentials.yml
```

---

## Solution 07 — View Encrypted File

```bash
# View without decrypting
ansible-vault view secrets.yml
```

**Explanation:**
- `view` displays decrypted content
- File remains encrypted
- No permanent changes
- Safe for viewing secrets

**Verification:**
```bash
# File still encrypted
cat secrets.yml
```

---

## Solution 08 — Edit Encrypted File

```bash
# Edit encrypted file
ansible-vault edit secrets.yml
```

**Add this line:**
```yaml
smtp_password: EmailPass789
```

**Explanation:**
- `edit` opens decrypted in editor
- Make changes
- Save and exit
- File re-encrypted automatically

**Verification:**
```bash
ansible-vault view secrets.yml | grep smtp_password
```

---

## Solution 09 — Rekey Encrypted File

```bash
# Change vault password
ansible-vault rekey secrets.yml
```

**Prompts:**
- Old password: `ansible123`
- New password: `newpass456`
- Confirm: `newpass456`

**Explanation:**
- `rekey` changes encryption password
- File remains encrypted
- Must know old password
- Use new password going forward

**Verification:**
```bash
# Try with old password (fails)
ansible-vault view secrets.yml --vault-password-file=<(echo "ansible123")

# Try with new password (works)
ansible-vault view secrets.yml --vault-password-file=<(echo "newpass456")
```

---

## Solution 10 — Multiple Vault IDs

```bash
# Create dev secrets with vault ID
ansible-vault create dev-secrets.yml --vault-id dev@prompt
```

**Content:**
```yaml
environment: dev
db_host: localhost
```

```bash
# Create prod secrets with vault ID
ansible-vault create prod-secrets.yml --vault-id prod@prompt
```

**Content:**
```yaml
environment: prod
db_host: localhost
```

**Explanation:**
- `--vault-id` assigns identifier
- `@prompt` asks for password
- Different passwords for different files
- Better security separation

**Verification:**
```bash
ansible-vault view dev-secrets.yml --vault-id dev@prompt
ansible-vault view prod-secrets.yml --vault-id prod@prompt
```

---

## Solution 11 — Playbook with Multiple Vaults

**Playbook: vault-multi.yml**
```yaml
---
- name: Use multiple vault files
  hosts: all
  
  vars_files:
    - dev-secrets.yml
    - prod-secrets.yml
  
  tasks:
    - name: Display environments
      ansible.builtin.debug:
        msg: "Dev: {{ environment }}, Prod DB: {{ db_host }}"
```

**Run:**
```bash
ansible-playbook vault-multi.yml --vault-id dev@prompt --vault-id prod@prompt
```

**Explanation:**
- Load multiple encrypted files
- Specify multiple vault IDs
- Each file decrypted with its password
- Variables from both available

---

## Solution 12 — Encrypt Specific Variables

```bash
# Encrypt the secret value
ansible-vault encrypt_string 'MyAPISecret123' --name 'api_secret'
```

**Playbook: vault-mixed.yml**
```yaml
---
- name: Mixed plain and encrypted variables
  hosts: all
  
  vars:
    app_name: myapp
    app_port: 8080
    api_secret: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36623965383739393466353738643561653739323334653937393866653739653739323334653937
          3839666537396537393233346539373938666537396537390a653739323334653937393866653739
          65373932333465393739386665373965373932333465393739386665373965373932333465393739
          3866653739653739320a373932333465393739386665373965373932333465393739386665373965
          3739
  
  tasks:
    - name: Display configuration
      ansible.builtin.debug:
        msg: "App: {{ app_name }}, Port: {{ app_port }}, Secret: {{ api_secret }}"
```

**Explanation:**
- Mix plain and encrypted in same file
- Only encrypt sensitive data
- `!vault |` marks encrypted values
- More flexible than encrypting entire file

---

## Solution 13 — Vault in Group Variables

```bash
# Create directory
mkdir -p /home/student/ansible/group_vars/all

# Create encrypted file
ansible-vault create /home/student/ansible/group_vars/all/vault.yml
```

**Content:**
```yaml
vault_db_password: "GroupSecret123"
vault_api_key: "GroupAPI456"
```

**Explanation:**
- Group variables in `group_vars/`
- `all` group applies to all hosts
- File name `vault.yml` by convention
- Loaded automatically
- No need to specify in playbook

**Test playbook:**
```yaml
---
- name: Test group vault
  hosts: all
  tasks:
    - debug:
        msg: "DB Password: {{ vault_db_password }}"
```

---

## Solution 14 — Vault in Host Variables

```bash
# Create directory
mkdir -p /home/student/ansible/host_vars/node1.example.com

# Create encrypted file
ansible-vault create /home/student/ansible/host_vars/node1.example.com/vault.yml
```

**Content:**
```yaml
vault_node_secret: "Node1Secret"
```

**Explanation:**
- Host variables in `host_vars/hostname/`
- Specific to one host
- File name `vault.yml` by convention
- Loaded automatically for that host
- Other hosts don't see it

**Test playbook:**
```yaml
---
- name: Test host vault
  hosts: node1.example.com
  tasks:
    - debug:
        msg: "Node Secret: {{ vault_node_secret }}"
```

---

## Solution 15 — Vault Password Script

```bash
# Create script
cat > /home/student/ansible/vault-pass.sh << 'EOF'
#!/bin/bash
echo "ansible123"
EOF

# Make executable
chmod 0700 /home/student/ansible/vault-pass.sh
```

**Explanation:**
- Script outputs password to stdout
- Must be executable
- Can be used instead of password file
- More flexible (can fetch from secret manager)

**Usage:**
```bash
# With ansible-vault
ansible-vault view secrets.yml --vault-password-file=./vault-pass.sh

# With ansible-playbook
ansible-playbook playbook.yml --vault-password-file=./vault-pass.sh
```

**Verification:**
```bash
./vault-pass.sh
ls -la vault-pass.sh
```

---

## Quick Reference: Ansible Vault Commands

### Create Encrypted File
```bash
ansible-vault create filename.yml
ansible-vault create filename.yml --vault-id label@prompt
```

### Encrypt Existing File
```bash
ansible-vault encrypt filename.yml
ansible-vault encrypt filename.yml --vault-id label@prompt
```

### Decrypt File
```bash
ansible-vault decrypt filename.yml
```

### View Encrypted File
```bash
ansible-vault view filename.yml
ansible-vault view filename.yml --vault-id label@prompt
```

### Edit Encrypted File
```bash
ansible-vault edit filename.yml
ansible-vault edit filename.yml --vault-id label@prompt
```

### Rekey (Change Password)
```bash
ansible-vault rekey filename.yml
ansible-vault rekey filename.yml --new-vault-id new@prompt
```

### Encrypt String
```bash
ansible-vault encrypt_string 'secret_value' --name 'variable_name'
ansible-vault encrypt_string 'secret_value' --name 'variable_name' --vault-id label@prompt
```

---

## Quick Reference: Using Vault in Playbooks

### Load Encrypted File
```yaml
vars_files:
  - secrets.yml
```

### Inline Encrypted Variable
```yaml
vars:
  password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    ...encrypted data...
```

### Run with Vault Password
```bash
# From file
ansible-playbook playbook.yml --vault-password-file=.vault_pass

# From script
ansible-playbook playbook.yml --vault-password-file=./vault-pass.sh

# Prompt
ansible-playbook playbook.yml --ask-vault-pass

# Multiple vault IDs
ansible-playbook playbook.yml --vault-id dev@prompt --vault-id prod@prompt
```

---

## Quick Reference: Vault Password File

### In ansible.cfg
```ini
[defaults]
vault_password_file = /path/to/.vault_pass
```

### File Format
```
ansible123
```

### Permissions
```bash
chmod 0600 .vault_pass
```

---

## Quick Reference: Vault IDs

### Create with Vault ID
```bash
ansible-vault create secrets.yml --vault-id prod@prompt
```

### View with Vault ID
```bash
ansible-vault view secrets.yml --vault-id prod@prompt
```

### Use in Playbook
```bash
ansible-playbook playbook.yml --vault-id prod@prompt --vault-id dev@prompt
```

### Vault ID Sources
```bash
--vault-id label@prompt          # Interactive prompt
--vault-id label@/path/to/file   # From file
--vault-id label@/path/to/script # From script
```

---

## Best Practices

1. **Never commit vault passwords:**
   ```bash
   echo ".vault_pass" >> .gitignore
   ```

2. **Use descriptive vault IDs:**
   ```bash
   --vault-id production@prompt
   --vault-id staging@prompt
   ```

3. **Encrypt only sensitive data:**
   ```yaml
   # Good: Mix plain and encrypted
   vars:
     app_name: myapp        # plain
     db_password: !vault |  # encrypted
   ```

4. **Use group_vars for shared secrets:**
   ```
   group_vars/
     all/
       vault.yml  # Encrypted secrets
       vars.yml   # Plain variables
   ```

5. **Use host_vars for host-specific secrets:**
   ```
   host_vars/
     hostname/
       vault.yml  # Encrypted secrets
       vars.yml   # Plain variables
   ```

6. **Rotate vault passwords regularly:**
   ```bash
   ansible-vault rekey secrets.yml
   ```

7. **Use vault password scripts for automation:**
   ```bash
   #!/bin/bash
   # Fetch from secret manager
   aws secretsmanager get-secret-value --secret-id ansible-vault
   ```

---

## Common Patterns

### Encrypted Database Credentials
```yaml
# group_vars/databases/vault.yml
vault_db_root_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  ...

vault_db_app_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  ...
```

### Encrypted API Keys
```yaml
# group_vars/all/vault.yml
vault_api_keys:
  github: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    ...
  aws: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    ...
```

### Encrypted SSH Keys
```yaml
# host_vars/jumphost/vault.yml
vault_ssh_private_key: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  ...
```

---

## Tips for RHCE Exam

1. **Set up vault password file early:**
   ```bash
   echo "ansible123" > .vault_pass
   chmod 0600 .vault_pass
   ```

2. **Verify ansible.cfg:**
   ```bash
   grep vault_password_file ansible.cfg
   ```

3. **Test vault commands:**
   ```bash
   ansible-vault create test.yml
   ansible-vault view test.yml
   ansible-vault edit test.yml
   ```

4. **Common mistakes:**
   - Wrong file permissions on .vault_pass
   - Forgetting to encrypt file
   - Using wrong vault password
   - Not specifying vault-id when needed

5. **Verify encrypted files:**
   ```bash
   # Should show encrypted content
   cat secrets.yml
   
   # Should show decrypted content
   ansible-vault view secrets.yml
   ```

6. **Test playbooks with vault:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ansible-playbook playbook.yml --check
   ansible-playbook playbook.yml
   ```

---

## Troubleshooting

### Error: "Decryption failed"
```bash
# Check vault password
cat .vault_pass

# Try with explicit password file
ansible-vault view secrets.yml --vault-password-file=.vault_pass
```

### Error: "Vault password file not found"
```bash
# Check ansible.cfg
grep vault_password_file ansible.cfg

# Check file exists
ls -la .vault_pass
```

### Error: "Permission denied"
```bash
# Fix permissions
chmod 0600 .vault_pass
```

### Error: "Could not match supplied vault ID"
```bash
# Specify correct vault ID
ansible-playbook playbook.yml --vault-id correct_id@prompt
```

---

Good luck with your RHCE exam preparation! 🚀

Master Ansible Vault - it's essential for securing sensitive data in production environments.