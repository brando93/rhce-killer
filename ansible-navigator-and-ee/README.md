# RHCE Killer — Ansible-Navigator & Execution Environments
## EX294 (v9.x): The modern way to run Ansible

---

> **Intermediate Exam: Modern Ansible CLI**
> Since RHEL 9 / EX294 v9, the exam expects you to use **`ansible-navigator`**
> instead of `ansible-playbook` directly. Navigator wraps Ansible in a
> container (Execution Environment) and provides a richer TUI plus
> reproducible runs. This exam drills the navigator commands and EE setup
> Red Hat actually tests.
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

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks must be created under `/home/student/ansible/`
- Some tasks require Podman (already installed on the control node)
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, roles-basics

You should know:
- How to write playbooks
- Basic role structure
- Module documentation lookup

---

## Tasks

### Task 01 — Install ansible-navigator (5 pts)

Install the `ansible-navigator` package on the control node.

**Verification:**
```bash
which ansible-navigator
ansible-navigator --version
```

---

### Task 02 — Configure ansible-navigator.yml (15 pts)

Create `/home/student/ansible/ansible-navigator.yml` with the following
required settings:

- `ansible-navigator.ansible.inventory.entries: [/home/student/ansible/inventory]`
- `ansible-navigator.execution-environment.image: ee-supported-rhel9:latest`
- `ansible-navigator.execution-environment.container-engine: podman`
- `ansible-navigator.execution-environment.pull.policy: missing`
- `ansible-navigator.mode: stdout`
- `ansible-navigator.playbook-artifact.enable: true`
- `ansible-navigator.playbook-artifact.save-as: /home/student/ansible/artifacts/{playbook_name}-{ts_utc}.json`

The file must be valid YAML. Navigator will use this config automatically
when run from `/home/student/ansible/`.

**Verification:**
```bash
ansible-navigator settings --effective | grep -E "image|inventory|stdout"
```

---

### Task 03 — List inventory with navigator (10 pts)

Without editing your inventory file, use `ansible-navigator` to dump the
full inventory contents as JSON and save it to `/tmp/inventory-dump.json`.
The exact command must be saved to `/home/student/ansible/inv-dump.sh`.

**Verification:**
```bash
bash /home/student/ansible/inv-dump.sh
cat /tmp/inventory-dump.json | head
```

---

### Task 04 — List installed collections (10 pts)

Use `ansible-navigator` (NOT `ansible-galaxy`) to list collections
available in the configured execution environment. Capture the output to
`/home/student/ansible/collections-list.txt`.

The output must include at least these collections: `ansible.builtin`,
`ansible.posix`, `community.general`.

---

### Task 05 — Look up a module from inside navigator (10 pts)

Use `ansible-navigator doc` to write the full documentation for
`ansible.builtin.copy` to `/home/student/ansible/copy-doc.txt`.

The file must include sections for `OPTIONS`, `EXAMPLES`, and `RETURN VALUES`.

---

### Task 06 — Run a playbook via navigator (stdout mode) (15 pts)

Create a playbook `/home/student/ansible/hello.yml` that simply prints a
debug message on every managed node:

```yaml
---
- name: Hello via navigator
  hosts: all
  gather_facts: false
  tasks:
    - name: Say hi
      ansible.builtin.debug:
        msg: "Hello from {{ inventory_hostname }} via navigator"
```

Run it with `ansible-navigator run hello.yml --mode stdout`. The full
console output must be saved to `/home/student/ansible/hello-output.txt`
(use `tee` or shell redirection).

---

### Task 07 — Configure a custom EE image (18 pts)

Edit `ansible-navigator.yml` to use a non-default execution environment.
Add a *secondary* registry entry that overrides only when the role
`production` is set:

- Default image stays as `ee-supported-rhel9:latest`
- Add an entry under `ansible-navigator.execution-environment.environment-variables`:
  - `pass: [ANSIBLE_FORCE_COLOR, ANSIBLE_HOST_KEY_CHECKING]`
  - `set: { ANSIBLE_STDOUT_CALLBACK: yaml }`

The change must NOT break the configuration: re-run `ansible-navigator
settings --effective` to confirm it parses.

---

### Task 08 — Pull and inspect the EE (15 pts)

Use `ansible-navigator images` (or `--mode stdout` equivalent) to:

1. List all images known to the configured container engine
2. Save the output to `/home/student/ansible/ee-images.txt`

Then, on the command line, use `podman` to print the size and creation
date of the `ee-supported-rhel9` image, saving the result to
`/home/student/ansible/ee-supported-rhel9-info.txt`.

**Hint:** `podman inspect ee-supported-rhel9 --format '{{.Size}} {{.Created}}'`

---

### Task 09 — Pass extra-vars to navigator (10 pts)

Modify `hello.yml` to also print the value of a variable `greeting` if
defined. Run the playbook via navigator passing `greeting=hola` as an
extra-var. The console output must contain the string `hola from`.

Save the exact command line to `/home/student/ansible/extra-vars.sh`.

---

### Task 10 — Inspect a saved artifact (15 pts)

After Task 06 / Task 09, navigator should have written JSON artifacts to
`/home/student/ansible/artifacts/`. List the files there to a file
`/home/student/ansible/artifact-list.txt`. Then use `jq` (already
installed) to extract the `status` field of the most recent artifact and
write it to `/home/student/ansible/last-status.txt`. Expected value:
`successful`.

---

### Task 11 — Replay a recorded run (12 pts)

Pick any artifact from `/home/student/ansible/artifacts/` and replay it
with `ansible-navigator replay <artifact> --mode stdout`. Redirect the
output to `/home/student/ansible/replay-output.txt`.

Replay is the navigator-equivalent of debugging a previous playbook
execution. The replayed output must contain the same hosts as the
original run.

---

### Task 12 — Use a non-default inventory (10 pts)

Create an alternative inventory at `/home/student/ansible/inventory-dev`
that only lists `node1.example.com` under a group `[dev]`.

Run `ansible-navigator inventory --list --mode stdout --inventory
/home/student/ansible/inventory-dev` and save the output to
`/home/student/ansible/inv-dev.txt`. The file must contain `node1` but
NOT `node2`.

---

### Task 13 — Migrate ansible-playbook to ansible-navigator (20 pts)

You have an existing playbook `/home/student/ansible/legacy.yml` (the same
content as `hello.yml` from Task 06 is fine). The legacy way you used to
run it was:

```bash
ansible-playbook -i inventory --become legacy.yml --extra-vars "env=prod"
```

Write a wrapper script `/home/student/ansible/run-legacy.sh` that uses
`ansible-navigator run` to do the exact same thing — same playbook, same
inventory, same become semantics, same extra-var — but with the navigator
configuration sourced from `ansible-navigator.yml`. The script must:

- Exit with non-zero status if the playbook fails
- Save the run artifact (navigator does this automatically when configured)
- Use `--mode stdout`

**Verification:**
```bash
bash /home/student/ansible/run-legacy.sh
ls -t /home/student/ansible/artifacts/ | head -1   # new artifact present
```

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Install ansible-navigator | 5 |
| 02 | ansible-navigator.yml config | 15 |
| 03 | List inventory | 10 |
| 04 | List collections | 10 |
| 05 | Module doc lookup | 10 |
| 06 | Run playbook (stdout) | 15 |
| 07 | EE config + env vars | 18 |
| 08 | Pull and inspect EE | 15 |
| 09 | Extra-vars | 10 |
| 10 | Inspect saved artifact | 15 |
| 11 | Replay artifact | 12 |
| 12 | Non-default inventory | 10 |
| 13 | Migrate playbook command | 20 |
| **Total** | | **165** |

**Passing score: 70% (116/165 points)**

---

## When you finish

```bash
bash /home/student/exams/thematic/ansible-navigator-and-ee/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Install ansible-navigator

```bash
sudo dnf install -y ansible-navigator
ansible-navigator --version
```

`ansible-navigator` ships in the **AppStream** repo on RHEL/Rocky 9. On
some lab images it's already installed.

---

## Solution 02 — Configure ansible-navigator.yml

**File:** `/home/student/ansible/ansible-navigator.yml`
```yaml
---
ansible-navigator:
  ansible:
    inventory:
      entries:
        - /home/student/ansible/inventory
  execution-environment:
    image: ee-supported-rhel9:latest
    container-engine: podman
    pull:
      policy: missing
  mode: stdout
  playbook-artifact:
    enable: true
    save-as: /home/student/ansible/artifacts/{playbook_name}-{ts_utc}.json
```

**Explanation:**
- `mode: stdout` makes navigator default to the legacy ansible-playbook-style
  output. The interactive TUI is the alternative (`--mode interactive`).
- `pull.policy: missing` means "only pull the image if it's not already
  local" — avoids a network round trip on every run.
- `playbook-artifact` writes a JSON record of each run, which Task 10/11
  read back.

Verify:
```bash
cd /home/student/ansible
ansible-navigator settings --effective | grep -E "image|inventory|stdout"
```

---

## Solution 03 — List inventory with navigator

**File:** `inv-dump.sh`
```bash
#!/bin/bash
ansible-navigator inventory --list --mode stdout > /tmp/inventory-dump.json
```

`ansible-navigator inventory` mirrors `ansible-inventory`. The `--list`
flag emits the full JSON tree of groups + vars.

---

## Solution 04 — List installed collections

```bash
ansible-navigator collections --mode stdout > collections-list.txt
```

In `--mode stdout`, navigator prints a table of all collections shipped
inside the configured execution environment. `ee-supported-rhel9` bundles
the `community.general`, `ansible.posix`, and `ansible.builtin` namespaces
among others.

---

## Solution 05 — Look up a module from inside navigator

```bash
ansible-navigator doc ansible.builtin.copy --mode stdout > copy-doc.txt
```

`navigator doc` is the navigator-equivalent of `ansible-doc`. Inside the
EE container so the output matches whatever module versions ship with the
image.

---

## Solution 06 — Run a playbook via navigator

**File:** `hello.yml` (see task description)

**Run and capture:**
```bash
cd /home/student/ansible
ansible-navigator run hello.yml --mode stdout 2>&1 | tee hello-output.txt
```

Note `--mode stdout` (or just relying on the config set in Task 02). The
`tee` captures stdout/stderr to a file while also showing it on screen.

---

## Solution 07 — Configure a custom EE image

**Update `ansible-navigator.yml`:**
```yaml
---
ansible-navigator:
  ansible:
    inventory:
      entries:
        - /home/student/ansible/inventory
  execution-environment:
    image: ee-supported-rhel9:latest
    container-engine: podman
    pull:
      policy: missing
    environment-variables:
      pass:
        - ANSIBLE_FORCE_COLOR
        - ANSIBLE_HOST_KEY_CHECKING
      set:
        ANSIBLE_STDOUT_CALLBACK: yaml
  mode: stdout
  playbook-artifact:
    enable: true
    save-as: /home/student/ansible/artifacts/{playbook_name}-{ts_utc}.json
```

**Explanation:**
- `environment-variables.pass` forwards listed vars from the host into the EE
- `environment-variables.set` defines fixed values inside the EE
- Changing `ANSIBLE_STDOUT_CALLBACK` to `yaml` makes navigator's output
  human-friendlier (vs default `default`)

Confirm parse:
```bash
ansible-navigator settings --effective | grep -A 5 environment-variables
```

---

## Solution 08 — Pull and inspect the EE

```bash
ansible-navigator images --mode stdout > ee-images.txt
podman inspect ee-supported-rhel9 \
  --format '{{.Size}} bytes  created {{.Created}}' \
  > ee-supported-rhel9-info.txt
```

If `images` reports the image is missing, navigator pulls it on first
playbook run (because of `pull.policy: missing`). To force a pull:
```bash
podman pull registry.redhat.io/ansible-automation-platform-23/ee-supported-rhel9
```

---

## Solution 09 — Pass extra-vars to navigator

**Update `hello.yml`:**
```yaml
---
- name: Hello via navigator
  hosts: all
  gather_facts: false
  tasks:
    - name: Say hi
      ansible.builtin.debug:
        msg: "{{ greeting | default('Hello') }} from {{ inventory_hostname }}"
```

**File:** `extra-vars.sh`
```bash
#!/bin/bash
ansible-navigator run hello.yml --mode stdout --extra-vars "greeting=hola"
```

Run it:
```bash
bash extra-vars.sh | grep "hola from"
```

The `--extra-vars` flag is **identical** to `ansible-playbook`'s, since
navigator just shells out to it inside the EE.

---

## Solution 10 — Inspect a saved artifact

```bash
ls /home/student/ansible/artifacts/ > artifact-list.txt
LATEST=$(ls -t /home/student/ansible/artifacts/*.json | head -1)
jq -r '.status' "$LATEST" > last-status.txt
```

The `playbook-artifact.save-as` template uses `{playbook_name}` and
`{ts_utc}` placeholders, so each run gets a unique filename. The JSON
contains the full play recap plus per-task results.

---

## Solution 11 — Replay a recorded run

```bash
LATEST=$(ls -t /home/student/ansible/artifacts/*.json | head -1)
ansible-navigator replay "$LATEST" --mode stdout > replay-output.txt
```

`navigator replay` re-renders the captured run without executing anything
on the managed nodes — useful for sharing a failed run with a teammate
or going back and looking at output you missed.

---

## Solution 12 — Use a non-default inventory

**File:** `inventory-dev`
```ini
[dev]
node1.example.com
```

```bash
ansible-navigator inventory --list --mode stdout \
    --inventory /home/student/ansible/inventory-dev \
    > inv-dev.txt
```

The `--inventory` (or `-i`) flag is identical to `ansible-playbook`'s.
Useful for running a one-off play against a subset of hosts without
editing the main inventory.

---

## Solution 13 — Migrate ansible-playbook to ansible-navigator

**File:** `run-legacy.sh`
```bash
#!/bin/bash
set -euo pipefail
cd /home/student/ansible
ansible-navigator run legacy.yml \
    --mode stdout \
    --become \
    --extra-vars "env=prod"
```

**Mapping (legacy → navigator):**

| ansible-playbook flag | ansible-navigator equivalent |
|---|---|
| `playbook.yml` | `run playbook.yml` |
| `-i inventory` | from `ansible-navigator.yml` or `--inventory` |
| `--become` | identical: `--become` |
| `--extra-vars "k=v"` | identical: `--extra-vars "k=v"` |
| `--tags foo` | identical: `--tags foo` |
| `--check` | identical: `--check` |
| `--limit node1` | identical: `--limit node1` |
| `-vvv` | identical: `-vvv` |

The mental model is: navigator is a **wrapper** that runs ansible-playbook
inside an EE container. Almost every flag is passed through unchanged.

---

## Tips for the real EX294

1. **Run from your working directory.** Navigator looks for
   `ansible-navigator.yml` in `$PWD`, then `~/.config/ansible-navigator/`,
   then `/etc/ansible-navigator/`.
2. **`--mode stdout` for everything** unless you specifically want the
   TUI. The TUI is nice for browsing but slows you down on a timed exam.
3. **Pull the EE image FIRST.** Don't let the timer eat 90 seconds
   waiting for a pull. Run `podman pull <image>` early in the exam.
4. **Artifacts ARE the audit trail.** If a grader asks "did your playbook
   succeed?", point them at the artifact JSON.
5. **`ansible-navigator doc` is your friend.** It works without internet
   (everything is in the EE), so it's faster than `ansible-doc` for module
   spec lookups on the exam.

---

Good luck! 🚀
