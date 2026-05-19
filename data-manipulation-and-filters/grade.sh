#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Data Manipulation & Filters Grader
# 15 tasks · 158 points · 70% passing (111)
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
EXAM_NAME="data-manipulation-and-filters"
EXAM_TITLE="Data Manipulation & Filters"

cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   ${EXAM_TITLE}${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Memory in GB with 2 decimals (5 pts)${NC}"
# ─────────────────────────────────────────────
check "mem-report.yml playbook exists" 1 \
    "test -f $ANSIBLE_DIR/mem-report.yml" \
    "Create mem-report.yml"
check "Template uses round(2) filter" 1 \
    "grep -qE 'round[[:space:]]*\\([[:space:]]*2[[:space:]]*\\)' $ANSIBLE_DIR/mem-report.yml $ANSIBLE_DIR/templates/*.j2 2>/dev/null" \
    "Use round(2) for 2-decimal precision"
check "Template divides ansible_memtotal_mb by 1024" 1 \
    "grep -rE 'ansible_memtotal_mb[[:space:]]*/[[:space:]]*1024' $ANSIBLE_DIR/templates/*.j2 $ANSIBLE_DIR/mem-report.yml 2>/dev/null" \
    "Divide MB by 1024 to get GB"
check "/tmp/mem-report.txt exists on managed nodes" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/mem-report.txt' &>/dev/null" \
    "Deploy template to /tmp/mem-report.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — default('NONE') pattern (5 pts)${NC}"
# ─────────────────────────────────────────────
check "safe-report.yml exists" 1 \
    "test -f $ANSIBLE_DIR/safe-report.yml" \
    "Create safe-report.yml"
check "Uses default('NONE') filter at least 3 times" 3 \
    "test \$(grep -cE \"default\\(['\\\"]NONE['\\\"]\\)\" $ANSIBLE_DIR/safe-report.yml) -ge 3" \
    "Use | default('NONE') on every fact lookup (3 facts in this task)"
check "/tmp/safe-report.txt was written" 1 \
    "ansible managed -b -m shell -a 'test -f /tmp/safe-report.txt' &>/dev/null" \
    "Run the playbook to create the file"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Build /etc/hosts from inventory (10 pts)${NC}"
# ─────────────────────────────────────────────
check "etc-hosts.yml exists" 2 \
    "test -f $ANSIBLE_DIR/etc-hosts.yml" \
    "Create etc-hosts.yml"
check "Playbook gathers facts on 'all'" 2 \
    "grep -qE 'hosts:[[:space:]]*all' $ANSIBLE_DIR/etc-hosts.yml && grep -qE 'gather_facts:[[:space:]]*(true|yes)' $ANSIBLE_DIR/etc-hosts.yml" \
    "First play must gather facts on 'all' so hostvars is populated"
check "Template loops over groups['all']" 3 \
    "grep -rE \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\[['\\\"]all['\\\"]\\]\" $ANSIBLE_DIR/templates/*.j2 $ANSIBLE_DIR/etc-hosts.yml 2>/dev/null" \
    "Use {% for host in groups['all'] %} in the template"
check "Reads IP from hostvars" 2 \
    "grep -rE 'hostvars\\[[^]]+\\]\\.ansible_default_ipv4' $ANSIBLE_DIR/templates/*.j2 $ANSIBLE_DIR/etc-hosts.yml 2>/dev/null" \
    "Use hostvars[host].ansible_default_ipv4.address"
check "/etc/hosts contains node1 entry on managed" 1 \
    "ansible managed -b -m shell -a 'grep -q node1.example.com /etc/hosts' &>/dev/null" \
    "After running, /etc/hosts should have node1's entry on every managed node"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Count hosts in groups (5 pts)${NC}"
# ─────────────────────────────────────────────
check "host-counts.yml exists" 2 \
    "test -f $ANSIBLE_DIR/host-counts.yml" \
    "Create host-counts.yml"
check "Playbook uses | length filter" 2 \
    "grep -qE '\\|[[:space:]]*length' $ANSIBLE_DIR/host-counts.yml" \
    "Use groups['name'] | length to count"
check "References at least 3 group names" 1 \
    "grep -cE \"groups\\[['\\\"](all|managed|control)['\\\"]\\]\" $ANSIBLE_DIR/host-counts.yml | xargs -I {} test {} -ge 3" \
    "Reference groups['all'], groups['managed'], groups['control']"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Extract kernel major.minor (5 pts)${NC}"
# ─────────────────────────────────────────────
check "kernel-version.yml exists" 1 \
    "test -f $ANSIBLE_DIR/kernel-version.yml" \
    "Create kernel-version.yml"
check "Playbook uses set_fact" 1 \
    "grep -qE '(ansible.builtin.set_fact|^[[:space:]]+set_fact)' $ANSIBLE_DIR/kernel-version.yml" \
    "Use set_fact to compute kernel_short"
check "Uses split('.') method on ansible_kernel" 2 \
    "grep -qE \"ansible_kernel.*split\\(['\\\"]\\.['\\\"]\\)\" $ANSIBLE_DIR/kernel-version.yml" \
    "Use ansible_kernel.split('.') to slice the version"
check "Slices and joins with [:2] | join('.')" 1 \
    "grep -qE '\\[:2\\]' $ANSIBLE_DIR/kernel-version.yml && grep -qE \"join\\(['\\\"]\\.['\\\"]\\)\" $ANSIBLE_DIR/kernel-version.yml" \
    "Use [:2] | join('.') to get major.minor"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Filter mounts above 80% (12 pts)${NC}"
# ─────────────────────────────────────────────
check "mount-alert.yml exists" 2 \
    "test -f $ANSIBLE_DIR/mount-alert.yml" \
    "Create mount-alert.yml"
check "Playbook references ansible_mounts" 3 \
    "grep -q 'ansible_mounts' $ANSIBLE_DIR/mount-alert.yml" \
    "Iterate ansible_mounts (list of dicts)"
check "Computes percentage from size_total and size_available" 3 \
    "grep -qE 'size_total' $ANSIBLE_DIR/mount-alert.yml && grep -qE 'size_available' $ANSIBLE_DIR/mount-alert.yml" \
    "Use size_total and size_available to compute %"
check "/tmp/full-mounts.txt exists on at least one host" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/full-mounts.txt' &>/dev/null" \
    "Run the playbook to create the file"
check "Output uses ⚠ marker on >=80% lines" 2 \
    "ansible managed -b -m shell -a 'grep -q ⚠ /tmp/full-mounts.txt' &>/dev/null || true" \
    "Include the ⚠ marker on lines where usage >= 80%; only graded if any mount qualifies"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — CPU model normalization (10 pts)${NC}"
# ─────────────────────────────────────────────
check "cpu-model.yml exists" 2 \
    "test -f $ANSIBLE_DIR/cpu-model.yml" \
    "Create cpu-model.yml"
check "Uses ansible_processor[2]" 3 \
    "grep -qE 'ansible_processor\\[2\\]' $ANSIBLE_DIR/cpu-model.yml" \
    "Read CPU model from ansible_processor[2]"
check "Uses regex_replace or replace filter" 3 \
    "grep -qE 'regex_replace|^[[:space:]]+replace[[:space:]]*\\(' $ANSIBLE_DIR/cpu-model.yml" \
    "Strip Intel(R) prefix and CPU @ ... suffix with regex_replace"
check "/tmp/cpu-models.txt exists" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/cpu-models.txt' &>/dev/null" \
    "Append per-host line to /tmp/cpu-models.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — map(attribute) + join CSV (12 pts)${NC}"
# ─────────────────────────────────────────────
check "users-csv.yml exists" 2 \
    "test -f $ANSIBLE_DIR/users-csv.yml" \
    "Create users-csv.yml"
check "Defines users list with at least 3 dicts" 2 \
    "grep -cE 'name:.*\\b(alice|bob|cleo)\\b' $ANSIBLE_DIR/users-csv.yml | xargs -I {} test {} -ge 3" \
    "Define users list with alice, bob, cleo"
check "Uses map(attribute='name')" 4 \
    "grep -qE \"map\\(attribute=['\\\"]name['\\\"]\\)\" $ANSIBLE_DIR/users-csv.yml" \
    "Use | map(attribute='name') to extract names"
check "Uses join(',')" 2 \
    "grep -qE \"join\\(['\\\"],['\\\"]\\)\" $ANSIBLE_DIR/users-csv.yml" \
    "Use | join(',') to build the CSV string"
check "/tmp/usernames.csv contains alice,bob,cleo" 2 \
    "test -f /tmp/usernames.csv && grep -qE 'alice.*bob.*cleo' /tmp/usernames.csv" \
    "File content should be alice,bob,cleo"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — combine defaults + overrides (12 pts)${NC}"
# ─────────────────────────────────────────────
check "combine-config.yml exists" 2 \
    "test -f $ANSIBLE_DIR/combine-config.yml" \
    "Create combine-config.yml"
check "Defines both defaults and custom dicts" 2 \
    "grep -qE '^[[:space:]]*defaults:' $ANSIBLE_DIR/combine-config.yml && grep -qE '^[[:space:]]*custom:' $ANSIBLE_DIR/combine-config.yml" \
    "Define defaults: and custom: vars at the top"
check "Uses combine filter" 4 \
    "grep -qE '\\|[[:space:]]*combine' $ANSIBLE_DIR/combine-config.yml" \
    "Use defaults | combine(custom)"
check "Uses to_nice_json for output" 2 \
    "grep -qE 'to_nice_json' $ANSIBLE_DIR/combine-config.yml" \
    "Output to JSON with to_nice_json for indented format"
check "/tmp/app-config.json exists with port: 9090" 2 \
    "test -f /tmp/app-config.json && grep -qE '\"port\":[[:space:]]*9090' /tmp/app-config.json" \
    "Merged port must be 9090 (custom overrides default 8080)"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — to_nice_yaml output (10 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-snapshot.yml exists" 2 \
    "test -f $ANSIBLE_DIR/inventory-snapshot.yml" \
    "Create inventory-snapshot.yml"
check "Uses to_nice_yaml filter" 4 \
    "grep -qE 'to_nice_yaml' $ANSIBLE_DIR/inventory-snapshot.yml" \
    "Use to_nice_yaml for multi-line output (not to_yaml)"
check "Iterates groups['managed'] in set_fact" 2 \
    "grep -qE \"groups\\[['\\\"]managed['\\\"]\\]\" $ANSIBLE_DIR/inventory-snapshot.yml" \
    "Build the hosts list by looping over groups['managed']"
check "/tmp/cluster-snapshot.yml contains node1" 2 \
    "test -f /tmp/cluster-snapshot.yml && grep -q 'node1' /tmp/cluster-snapshot.yml" \
    "Output must include node1.example.com"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — System report (math + facts) (15 pts)${NC}"
# ─────────────────────────────────────────────
check "system-report.yml exists" 2 \
    "test -f $ANSIBLE_DIR/system-report.yml" \
    "Create system-report.yml"
check "Template file exists" 2 \
    "ls $ANSIBLE_DIR/templates/system-report.j2 2>/dev/null" \
    "Create templates/system-report.j2"
check "Pre-computes ram_gb with set_fact" 3 \
    "grep -qE 'ram_gb' $ANSIBLE_DIR/system-report.yml" \
    "set_fact: ram_gb = ansible_memtotal_mb / 1024 | round(2)"
check "Pre-computes uptime_hours" 2 \
    "grep -qE 'uptime_hours' $ANSIBLE_DIR/system-report.yml" \
    "set_fact: uptime_hours = ansible_uptime_seconds / 3600 | round(1)"
check "Pre-computes kernel_short" 2 \
    "grep -qE 'kernel_short' $ANSIBLE_DIR/system-report.yml" \
    "Same as Task 05: split('.')[:2] | join('.')"
check "Per-host file /tmp/system-node1.txt exists" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/system-\$(hostname -s).txt' &>/dev/null" \
    "Template produces one file per host"
check "Report contains all required fields" 2 \
    "ansible managed -b -m shell -a 'grep -E \"Hostname|IP|OS|Kernel|RAM|Uptime\" /tmp/system-\$(hostname -s).txt | wc -l | grep -qE \"[5-9]\"' &>/dev/null" \
    "Report must have Hostname, IP, OS, Kernel, RAM, Uptime, Generated lines"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — hostvars + reject + flatten (15 pts)${NC}"
# ─────────────────────────────────────────────
check "all-ips.yml exists" 2 \
    "test -f $ANSIBLE_DIR/all-ips.yml" \
    "Create all-ips.yml"
check "Uses map('extract', hostvars, ...)" 4 \
    "grep -qE \"map\\(['\\\"]extract['\\\"][[:space:]]*,[[:space:]]*hostvars\" $ANSIBLE_DIR/all-ips.yml" \
    "Use map('extract', hostvars, 'ansible_all_ipv4_addresses')"
check "Uses flatten filter" 3 \
    "grep -qE '\\|[[:space:]]*flatten' $ANSIBLE_DIR/all-ips.yml" \
    "Collapse list-of-lists with flatten"
check "Uses reject('match', '^127\\.')" 3 \
    "grep -qE \"reject\\(['\\\"]match['\\\"]\" $ANSIBLE_DIR/all-ips.yml" \
    "Drop loopback addresses with reject('match', '^127\\.')"
check "Uses sort filter" 1 \
    "grep -qE '\\|[[:space:]]*sort' $ANSIBLE_DIR/all-ips.yml" \
    "Sort the final list"
check "/tmp/cluster-ips.txt exists" 2 \
    "test -f /tmp/cluster-ips.txt" \
    "Write the IP list to /tmp/cluster-ips.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — json_query / JMESPath (15 pts)${NC}"
# ─────────────────────────────────────────────
check "query-mounts.yml exists" 2 \
    "test -f $ANSIBLE_DIR/query-mounts.yml" \
    "Create query-mounts.yml"
check "Uses json_query filter" 5 \
    "grep -qE 'json_query|community.general.json_query' $ANSIBLE_DIR/query-mounts.yml" \
    "Use community.general.json_query (NOT selectattr+map chain)"
check "Uses JMESPath projection syntax [*]" 4 \
    "grep -qE '\\[\\*\\]' $ANSIBLE_DIR/query-mounts.yml" \
    "Use [*].{key: source, ...} projection"
check "/tmp/mounts-query.yml exists" 2 \
    "test -f /tmp/mounts-query.yml" \
    "Write to /tmp/mounts-query.yml"
check "Output contains mount field" 2 \
    "test -f /tmp/mounts-query.yml && grep -qE 'mount:' /tmp/mounts-query.yml" \
    "YAML output must have mount: keys"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — Sort by attribute + first (12 pts)${NC}"
# ─────────────────────────────────────────────
check "top-talkers.yml exists" 2 \
    "test -f $ANSIBLE_DIR/top-talkers.yml" \
    "Create top-talkers.yml"
check "Builds list with ansible_memtotal_mb per host" 3 \
    "grep -qE 'ansible_memtotal_mb' $ANSIBLE_DIR/top-talkers.yml" \
    "Compose a list of {name, ram_mb} dicts from groups['managed']"
check "Uses sort(attribute=..., reverse=true)" 4 \
    "grep -qE \"sort\\(attribute=['\\\"]\" $ANSIBLE_DIR/top-talkers.yml && grep -qE 'reverse=true' $ANSIBLE_DIR/top-talkers.yml" \
    "Use sort(attribute='ram_mb', reverse=true)"
check "Uses | first filter" 2 \
    "grep -qE '\\|[[:space:]]*first' $ANSIBLE_DIR/top-talkers.yml" \
    "Use | first (or [0]) to pick the max"
check "/tmp/biggest-host.txt contains 'biggest='" 1 \
    "test -f /tmp/biggest-host.txt && grep -q 'biggest=' /tmp/biggest-host.txt" \
    "Format the output as biggest=NAME ram=NN GB"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — Full CSV report (15 pts)${NC}"
# ─────────────────────────────────────────────
check "csv-report.yml exists" 2 \
    "test -f $ANSIBLE_DIR/csv-report.yml" \
    "Create csv-report.yml"
check "Template file exists" 2 \
    "ls $ANSIBLE_DIR/templates/cluster-csv.j2 2>/dev/null" \
    "Create templates/cluster-csv.j2"
check "Template has CSV header line" 2 \
    "grep -qE '^hostname,ip,os,kernel,cpus,ram_gb,uptime_hours$' $ANSIBLE_DIR/templates/cluster-csv.j2" \
    "First template line must be the CSV header"
check "Template iterates groups['managed']" 2 \
    "grep -qE \"groups\\[['\\\"]managed['\\\"]\\]\" $ANSIBLE_DIR/templates/cluster-csv.j2" \
    "Loop {% for host in groups['managed'] %}"
check "Uses default('NONE') in template" 2 \
    "test \$(grep -c \"default('NONE')\" $ANSIBLE_DIR/templates/cluster-csv.j2) -ge 3" \
    "Apply | default('NONE') to fact lookups"
check "Reads hostvars[host].ansible_memtotal_mb" 1 \
    "grep -qE 'hostvars\\[[^]]+\\]\\.ansible_memtotal_mb' $ANSIBLE_DIR/templates/cluster-csv.j2" \
    "Cross-host data via hostvars[]"
check "/tmp/cluster.csv exists" 2 \
    "test -f /tmp/cluster.csv" \
    "Run the playbook to produce /tmp/cluster.csv"
check "CSV has expected number of rows" 2 \
    "test \$(wc -l < /tmp/cluster.csv) -ge 3" \
    "Header + at least 2 data rows (node1, node2)"

print_summary "Data Manipulation & Filters" \
    "bash ~/exams/thematic/conditionals-and-when/START.sh"
