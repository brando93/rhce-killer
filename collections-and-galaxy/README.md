# RHCE Killer — Collections and Galaxy
## EX294: Mastering Ansible Galaxy and Collections

---

> **Intermediate Exam: Galaxy and Collections**
> This exam teaches you how to use Ansible Galaxy and Collections.
> Master installing, creating, and using collections and roles from Galaxy.
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

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- Use ansible-galaxy commands
- Install collections and roles as needed
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** roles-basics, playbooks-fundamentals

You should know:
- How to write playbooks
- Basic role structure
- How to use modules
- Command line basics

---

## Tasks

### Task 01 — Install Role from Galaxy (12 pts)

Install the role `geerlingguy.apache` from Ansible Galaxy:
- Use `ansible-galaxy install`
- Install to default location
- Verify installation

**Requirements:**
- Use ansible-galaxy command
- Role installed successfully
- Can be used in playbooks
- Verify with `ansible-galaxy list`

---

### Task 02 — Install Specific Role Version (15 pts)

Install role `geerlingguy.mysql` version `4.3.0`:
- Use version specification
- Install specific version
- Verify correct version installed

**Requirements:**
- Specify version in command
- Correct version installed
- Use `ansible-galaxy install role,version`

---

### Task 03 — Install Role to Custom Path (15 pts)

Install role `geerlingguy.nginx` to `/home/student/ansible/custom-roles/`:
- Use `-p` or `--roles-path` option
- Install to custom directory
- Verify in custom location

**Requirements:**
- Custom path specified
- Role in correct location
- Can be used from there

---

### Task 04 — Create requirements.yml for Roles (18 pts)

Create `/home/student/ansible/requirements.yml` that lists:
- `geerlingguy.apache` version `3.1.4`
- `geerlingguy.mysql` version `4.3.0`
- `geerlingguy.nginx` version `2.8.0`

Install all roles using requirements file.

**Requirements:**
- Create requirements.yml
- Proper YAML format
- Install with `-r` option
- All roles installed

---

### Task 05 — Install Collection from Galaxy (15 pts)

Install collection `community.general`:
- Use `ansible-galaxy collection install`
- Install to default location
- Verify installation

**Requirements:**
- Use collection install command
- Collection installed
- Can use modules from it
- Verify with `ansible-galaxy collection list`

---

### Task 06 — Install Specific Collection Version (15 pts)

Install `ansible.posix` collection version `1.4.0`:
- Specify version
- Install specific version
- Verify correct version

**Requirements:**
- Version specified
- Correct version installed
- Use `ansible-galaxy collection install name:version`

---

### Task 07 — Install Collection to Custom Path (15 pts)

Install `community.docker` to `/home/student/ansible/custom-collections/`:
- Use `-p` or `--collections-path` option
- Install to custom directory
- Verify in custom location

**Requirements:**
- Custom path specified
- Collection in correct location
- Configure ansible.cfg if needed

---

### Task 08 — Create requirements.yml for Collections (18 pts)

Create requirements.yml that includes collections:
- `community.general` version `5.5.0`
- `ansible.posix` version `1.4.0`
- `community.docker` version `3.0.0`

Install all collections using requirements file.

**Requirements:**
- Collections section in requirements.yml
- Proper format
- Install with `-r` option
- All collections installed

---

### Task 09 — Use Module from Collection (15 pts)

Create playbook `use-collection.yml` that:
- Uses module from `community.general` collection
- Uses FQCN (Fully Qualified Collection Name)
- Example: `community.general.timezone`

**Requirements:**
- Use FQCN format
- Module from collection
- Playbook runs successfully
- Proper syntax

---

### Task 10 — List Installed Roles (10 pts)

Use ansible-galaxy to:
- List all installed roles
- Show role information
- Verify installations

**Requirements:**
- Use `ansible-galaxy list`
- Shows installed roles
- Correct output

---

### Task 11 — List Installed Collections (10 pts)

Use ansible-galaxy to:
- List all installed collections
- Show collection information
- Verify installations

**Requirements:**
- Use `ansible-galaxy collection list`
- Shows installed collections
- Correct output

---

### Task 12 — Remove Installed Role (12 pts)

Remove a previously installed role:
- Use `ansible-galaxy remove`
- Remove specific role
- Verify removal

**Requirements:**
- Use remove command
- Role removed
- Verify with list command

---

### Task 13 — Search Galaxy for Roles (12 pts)

Search Ansible Galaxy for roles:
- Use `ansible-galaxy search`
- Search for specific keyword
- View results

**Requirements:**
- Use search command
- Specify search term
- Results displayed

---

### Task 14 — View Role Information (12 pts)

View detailed information about a role:
- Use `ansible-galaxy info`
- Display role details
- Show metadata

**Requirements:**
- Use info command
- Role information displayed
- Includes description, author, etc.

---

### Task 15 — Combined requirements.yml (20 pts)

Create comprehensive requirements.yml with:
- Multiple roles with versions
- Multiple collections with versions
- Both in same file

Install everything with single command.

**Requirements:**
- Both roles and collections
- Proper YAML structure
- Single install command
- All installed successfully

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Install Role from Galaxy | 12 |
| 02 | Install Specific Role Version | 15 |
| 03 | Install Role to Custom Path | 15 |
| 04 | requirements.yml for Roles | 18 |
| 05 | Install Collection | 15 |
| 06 | Install Specific Collection Version | 15 |
| 07 | Install Collection to Custom Path | 15 |
| 08 | requirements.yml for Collections | 18 |
| 09 | Use Module from Collection | 15 |
| 10 | List Installed Roles | 10 |
| 11 | List Installed Collections | 10 |
| 12 | Remove Installed Role | 12 |
| 13 | Search Galaxy | 12 |
| 14 | View Role Information | 12 |
| 15 | Combined requirements.yml | 20 |
| **Total** | | **214** |

**Passing score: 70% (150/214 points)**

---

## When you finish

```bash
bash /home/student/exams/collections-and-galaxy/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Install Role from Galaxy

```bash
# Install role from Galaxy
ansible-galaxy install geerlingguy.apache

# Verify installation
ansible-galaxy list
```

**Expected output:**
```
- geerlingguy.apache, (version)
```

**Default location:**
- `~/.ansible/roles/`
- Or path specified in ansible.cfg

**Explanation:**
- `ansible-galaxy install` downloads from Galaxy
- Role name format: `author.role_name`
- Installed to default roles path
- Ready to use in playbooks

---

## Solution 02 — Install Specific Role Version

```bash
# Install specific version
ansible-galaxy install geerlingguy.mysql,4.3.0

# Verify version
ansible-galaxy list | grep mysql
```

**Alternative syntax:**
```bash
ansible-galaxy install geerlingguy.mysql:4.3.0
```

**Explanation:**
- Comma or colon separates name and version
- Installs exact version specified
- Useful for reproducibility
- Version must exist on Galaxy

---

## Solution 03 — Install Role to Custom Path

```bash
# Create custom directory
mkdir -p /home/student/ansible/custom-roles

# Install to custom path
ansible-galaxy install geerlingguy.nginx -p /home/student/ansible/custom-roles/

# Verify
ls -la /home/student/ansible/custom-roles/
```

**Use in playbook:**
```yaml
---
- name: Use role from custom path
  hosts: all
  
  roles:
    - role: geerlingguy.nginx
```

**Configure ansible.cfg:**
```ini
[defaults]
roles_path = /home/student/ansible/custom-roles:~/.ansible/roles
```

---

## Solution 04 — Create requirements.yml for Roles

**File: requirements.yml**
```yaml
---
roles:
  - name: geerlingguy.apache
    version: 3.1.4
  
  - name: geerlingguy.mysql
    version: 4.3.0
  
  - name: geerlingguy.nginx
    version: 2.8.0
```

**Install:**
```bash
ansible-galaxy install -r requirements.yml
```

**Force reinstall:**
```bash
ansible-galaxy install -r requirements.yml --force
```

**Explanation:**
- YAML file lists all roles
- Specifies versions for each
- Single command installs all
- Reproducible deployments

---

## Solution 05 — Install Collection from Galaxy

```bash
# Install collection
ansible-galaxy collection install community.general

# Verify installation
ansible-galaxy collection list
```

**Expected output:**
```
Collection        Version
----------------- -------
community.general 5.x.x
```

**Default location:**
- `~/.ansible/collections/ansible_collections/`

**Explanation:**
- Collections contain modules, plugins, roles
- Namespace.collection format
- Installed to collections path
- Use with FQCN in playbooks

---

## Solution 06 — Install Specific Collection Version

```bash
# Install specific version
ansible-galaxy collection install ansible.posix:1.4.0

# Verify version
ansible-galaxy collection list | grep posix
```

**Explanation:**
- Colon separates name and version
- Installs exact version
- Important for compatibility
- Version must exist on Galaxy

---

## Solution 07 — Install Collection to Custom Path

```bash
# Create custom directory
mkdir -p /home/student/ansible/custom-collections

# Install to custom path
ansible-galaxy collection install community.docker -p /home/student/ansible/custom-collections/

# Verify
ls -la /home/student/ansible/custom-collections/ansible_collections/
```

**Configure ansible.cfg:**
```ini
[defaults]
collections_path = /home/student/ansible/custom-collections:~/.ansible/collections
```

**Explanation:**
- `-p` specifies custom path
- Collections stored in `ansible_collections/` subdirectory
- Configure path in ansible.cfg
- Multiple paths supported

---

## Solution 08 — Create requirements.yml for Collections

**File: requirements.yml**
```yaml
---
collections:
  - name: community.general
    version: 5.5.0
  
  - name: ansible.posix
    version: 1.4.0
  
  - name: community.docker
    version: 3.0.0
```

**Install:**
```bash
ansible-galaxy collection install -r requirements.yml
```

**Explanation:**
- `collections:` section for collections
- Each collection with name and version
- Single command installs all
- Reproducible environment

---

## Solution 09 — Use Module from Collection

**Playbook: use-collection.yml**
```yaml
---
- name: Use collection module
  hosts: all
  become: true
  
  tasks:
    - name: Set timezone using community.general
      community.general.timezone:
        name: America/New_York
    
    - name: Manage firewall using ansible.posix
      ansible.posix.firewalld:
        service: http
        permanent: true
        state: enabled
    
    - name: Use another community.general module
      community.general.nmcli:
        conn_name: eth0
        type: ethernet
        state: present
```

**Explanation:**
- FQCN format: `namespace.collection.module`
- Explicit and clear
- No ambiguity about module source
- Required for collections

**Run:**
```bash
ansible-playbook use-collection.yml
```

---

## Solution 10 — List Installed Roles

```bash
# List all roles
ansible-galaxy list

# List roles in specific path
ansible-galaxy list -p /path/to/roles

# Verbose output
ansible-galaxy list -v
```

**Example output:**
```
# /home/student/.ansible/roles
- geerlingguy.apache, 3.1.4
- geerlingguy.mysql, 4.3.0
- geerlingguy.nginx, 2.8.0
```

**Explanation:**
- Shows all installed roles
- Displays versions
- Shows installation path
- Useful for verification

---

## Solution 11 — List Installed Collections

```bash
# List all collections
ansible-galaxy collection list

# List collections in specific path
ansible-galaxy collection list -p /path/to/collections

# Show specific collection
ansible-galaxy collection list community.general
```

**Example output:**
```
Collection        Version
----------------- -------
ansible.posix     1.4.0
community.docker  3.0.0
community.general 5.5.0
```

**Explanation:**
- Shows all installed collections
- Displays versions
- Shows namespace and name
- Useful for verification

---

## Solution 12 — Remove Installed Role

```bash
# Remove role
ansible-galaxy remove geerlingguy.apache

# Remove from specific path
ansible-galaxy remove geerlingguy.apache -p /path/to/roles

# Verify removal
ansible-galaxy list
```

**Explanation:**
- Removes role from system
- Specify path if not default
- Verify with list command
- Cannot be undone (reinstall if needed)

---

## Solution 13 — Search Galaxy for Roles

```bash
# Search for roles
ansible-galaxy search apache

# Search with author
ansible-galaxy search apache --author geerlingguy

# Search with platforms
ansible-galaxy search nginx --platforms EL

# Limit results
ansible-galaxy search mysql --limit 5
```

**Example output:**
```
Found 150 roles matching your search:

Name                           Description
----                           -----------
geerlingguy.apache            Apache 2.x for Linux
geerlingguy.apache-php-fpm    Apache with PHP-FPM
...
```

**Explanation:**
- Searches Ansible Galaxy
- Returns matching roles
- Can filter by author, platform
- Shows role descriptions

---

## Solution 14 — View Role Information

```bash
# View role info
ansible-galaxy info geerlingguy.apache

# View specific version info
ansible-galaxy info geerlingguy.apache,3.1.4
```

**Example output:**
```
Role: geerlingguy.apache
    description: Apache 2.x for Linux
    active: True
    commit: abc123
    company: Midwestern Mac, LLC
    created: 2013-12-05T20:15:00.000000Z
    download_count: 1234567
    forks_count: 123
    github_branch: master
    github_repo: ansible-role-apache
    github_user: geerlingguy
    id: 123
    imported: 2023-01-15T10:30:00.000000Z
    is_valid: True
    license: MIT
    min_ansible_version: 2.4
    modified: 2023-01-15T10:30:00.000000Z
    path: ('/home/user/.ansible/roles', 'geerlingguy.apache')
    role_type: ANS
    stargazers_count: 456
```

**Explanation:**
- Shows detailed role information
- Includes metadata
- Shows statistics
- Useful before installing

---

## Solution 15 — Combined requirements.yml

**File: requirements.yml**
```yaml
---
# Roles from Galaxy
roles:
  - name: geerlingguy.apache
    version: 3.1.4
  
  - name: geerlingguy.mysql
    version: 4.3.0
  
  - name: geerlingguy.nginx
    version: 2.8.0
  
  - src: https://github.com/user/custom-role.git
    name: custom_role
    version: main

# Collections from Galaxy
collections:
  - name: community.general
    version: 5.5.0
  
  - name: ansible.posix
    version: 1.4.0
  
  - name: community.docker
    version: 3.0.0
  
  - name: community.mysql
    version: 3.5.0
```

**Install everything:**
```bash
# Install roles
ansible-galaxy install -r requirements.yml

# Install collections
ansible-galaxy collection install -r requirements.yml

# Or install both (Ansible 2.10+)
ansible-galaxy install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
```

**Explanation:**
- Single file for all dependencies
- Both roles and collections
- Versions specified
- Can include Git repos
- Reproducible environment

---

## Quick Reference: ansible-galaxy Commands

### Roles

```bash
# Install role
ansible-galaxy install author.role

# Install specific version
ansible-galaxy install author.role,version

# Install to custom path
ansible-galaxy install author.role -p /path

# Install from requirements
ansible-galaxy install -r requirements.yml

# List roles
ansible-galaxy list

# Remove role
ansible-galaxy remove author.role

# Search roles
ansible-galaxy search keyword

# Role info
ansible-galaxy info author.role
```

### Collections

```bash
# Install collection
ansible-galaxy collection install namespace.collection

# Install specific version
ansible-galaxy collection install namespace.collection:version

# Install to custom path
ansible-galaxy collection install namespace.collection -p /path

# Install from requirements
ansible-galaxy collection install -r requirements.yml

# List collections
ansible-galaxy collection list

# Collection info
ansible-galaxy collection list namespace.collection
```

---

## Quick Reference: requirements.yml Format

### Roles Only
```yaml
---
roles:
  - name: author.role
    version: 1.0.0
  
  - src: https://github.com/user/repo.git
    name: custom_role
    version: main
```

### Collections Only
```yaml
---
collections:
  - name: namespace.collection
    version: 1.0.0
  
  - name: namespace.collection2
    source: https://galaxy.ansible.com
```

### Combined
```yaml
---
roles:
  - name: author.role
    version: 1.0.0

collections:
  - name: namespace.collection
    version: 1.0.0
```

---

## Quick Reference: Collection Structure

```
namespace/
└── collection_name/
    ├── docs/
    ├── galaxy.yml          # Collection metadata
    ├── plugins/
    │   ├── modules/        # Modules
    │   ├── inventory/      # Inventory plugins
    │   ├── lookup/         # Lookup plugins
    │   └── filter/         # Filter plugins
    ├── roles/              # Roles
    ├── playbooks/          # Playbooks
    └── tests/              # Tests
```

---

## Quick Reference: Using Collections

### In Playbook
```yaml
---
- name: Use collection
  hosts: all
  
  collections:
    - community.general
    - ansible.posix
  
  tasks:
    - timezone:           # Short name (from collections list)
        name: UTC
    
    - community.general.timezone:  # FQCN (always works)
        name: UTC
```

### In ansible.cfg
```ini
[defaults]
collections_path = ~/.ansible/collections:/usr/share/ansible/collections
```

---

## Best Practices

1. **Always specify versions:**
   ```yaml
   - name: geerlingguy.apache
     version: 3.1.4
   ```

2. **Use requirements.yml:**
   - Version control
   - Reproducible
   - Easy to share

3. **Use FQCN in playbooks:**
   ```yaml
   community.general.timezone:
   ```

4. **Configure paths in ansible.cfg:**
   ```ini
   [defaults]
   roles_path = ./roles:~/.ansible/roles
   collections_path = ./collections:~/.ansible/collections
   ```

5. **Test before production:**
   ```bash
   ansible-galaxy install -r requirements.yml --force
   ansible-playbook test.yml --check
   ```

6. **Document dependencies:**
   - README.md
   - requirements.yml
   - Comments in playbooks

---

## Common Patterns

### Development Environment
```yaml
---
roles:
  - name: geerlingguy.docker
  - name: geerlingguy.nodejs

collections:
  - name: community.general
  - name: community.docker
```

### Web Server Stack
```yaml
---
roles:
  - name: geerlingguy.apache
    version: 3.1.4
  - name: geerlingguy.php
    version: 4.8.0
  - name: geerlingguy.mysql
    version: 4.3.0

collections:
  - name: community.mysql
  - name: ansible.posix
```

### Container Platform
```yaml
---
roles:
  - name: geerlingguy.docker
  - name: geerlingguy.kubernetes

collections:
  - name: community.docker
  - name: community.kubernetes
  - name: kubernetes.core
```

---

## Tips for RHCE Exam

1. **Know the commands:**
   ```bash
   ansible-galaxy install
   ansible-galaxy collection install
   ansible-galaxy list
   ansible-galaxy collection list
   ```

2. **Create requirements.yml:**
   - Faster than individual installs
   - Shows understanding

3. **Use FQCN:**
   ```yaml
   community.general.timezone:
   ```

4. **Verify installations:**
   ```bash
   ansible-galaxy list
   ansible-galaxy collection list
   ```

5. **Common mistakes:**
   - Wrong syntax in requirements.yml
   - Forgetting to install collections
   - Not using FQCN
   - Wrong path configuration

6. **Test quickly:**
   ```bash
   ansible-galaxy install -r requirements.yml --force
   ansible-playbook test.yml --syntax-check
   ```

---

## Troubleshooting

### Error: "Role not found"
```bash
# Check installation
ansible-galaxy list

# Check roles_path
ansible-config dump | grep roles_path

# Reinstall
ansible-galaxy install role_name --force
```

### Error: "Collection not found"
```bash
# Check installation
ansible-galaxy collection list

# Check collections_path
ansible-config dump | grep collections_path

# Reinstall
ansible-galaxy collection install namespace.collection --force
```

### Error: "Module not found"
```bash
# Use FQCN
community.general.module_name:

# Verify collection installed
ansible-galaxy collection list | grep community.general
```

---

Good luck with your RHCE exam preparation! 🚀

Master Ansible Galaxy and Collections - they're essential for leveraging community content and organizing your automation.