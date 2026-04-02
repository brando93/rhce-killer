# Contributing to RHCE Killer

Thank you for your interest in contributing to RHCE Killer! This document provides guidelines for contributing to the project.

## 🎯 Ways to Contribute

### 1. **Report Issues**
- Bug reports
- Documentation improvements
- Feature requests
- Exam content suggestions

### 2. **Submit Pull Requests**
- New exam tasks
- Improved grading scripts
- Documentation updates
- Bug fixes
- Infrastructure improvements

### 3. **Share Feedback**
- Share your experience using the lab
- Suggest improvements
- Report what worked well
- Identify areas for enhancement

## 📋 Contribution Guidelines

### Before You Start
1. Check existing issues and PRs to avoid duplicates
2. Open an issue to discuss major changes
3. Fork the repository
4. Create a feature branch

### Code Standards

#### Bash Scripts
- Use `#!/bin/bash` shebang
- Add comments for complex logic
- Use meaningful variable names
- Follow existing code style
- Test scripts before submitting

#### Ansible Content
- Follow Ansible best practices
- Use FQCN for modules (e.g., `ansible.builtin.copy`)
- Include comments in playbooks
- Test on Rocky Linux 9
- Validate with `ansible-lint`

#### Documentation
- Use clear, concise language
- Include examples
- Update README.md if needed
- Check spelling and grammar

### Exam Content Guidelines

When creating new exam tasks:

1. **Educational Value**
   - Focus on real-world scenarios
   - Cover EX294 objectives
   - Progressive difficulty
   - Clear learning outcomes

2. **Task Structure**
   - Clear requirements
   - Specific deliverables
   - Point values
   - Verification criteria

3. **Solutions**
   - Step-by-step instructions
   - Complete code examples
   - Explanation of concepts
   - Alternative approaches

4. **Grading Scripts**
   - Specific validation checks
   - Helpful error messages
   - Hints for failed checks
   - Accurate point calculation

## 🔄 Pull Request Process

### 1. Prepare Your Changes
```bash
# Fork and clone the repo
git clone https://github.com/YOUR_USERNAME/rhce-killer.git
cd rhce-killer

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ...

# Test your changes
make up
make sync-exams
# Test the specific exam/feature
```

### 2. Commit Your Changes
```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "Add: New exam task for advanced loops"

# Push to your fork
git push origin feature/your-feature-name
```

### 3. Create Pull Request
- Go to the original repository
- Click "New Pull Request"
- Select your feature branch
- Fill in the PR template
- Wait for review

### 4. PR Review Process
- Maintainers will review your PR
- Address any feedback
- Make requested changes
- PR will be merged when approved

## 📝 Commit Message Format

Use clear, descriptive commit messages:

```
Type: Brief description

Detailed explanation if needed

Examples:
- Add: New exam-06 for advanced troubleshooting
- Fix: Grading script error in exam-03 task 5
- Update: README with new installation instructions
- Refactor: Improve grade.sh performance
- Docs: Add troubleshooting section to README
```

## 🧪 Testing Requirements

Before submitting a PR:

### For Exam Content
- [ ] Test all tasks on fresh deployment
- [ ] Verify grading script works correctly
- [ ] Check all hints are helpful
- [ ] Validate solutions are complete
- [ ] Test on Rocky Linux 9

### For Infrastructure Changes
- [ ] Test Terraform deployment
- [ ] Verify all instances start correctly
- [ ] Check networking configuration
- [ ] Test SSH connectivity
- [ ] Validate bootstrap scripts

### For Documentation
- [ ] Check for typos and grammar
- [ ] Verify all links work
- [ ] Test code examples
- [ ] Ensure formatting is correct

## 🎨 Style Guide

### Bash Scripts
```bash
#!/bin/bash
# Description of what this script does

# Use meaningful variable names
EXAM_DIR="/home/student/exams"
POINTS=0

# Add comments for complex logic
# Check if file exists and has correct permissions
if [[ -f "$file" ]] && [[ $(stat -c %a "$file") == "644" ]]; then
    echo "✅ File permissions correct"
    ((POINTS+=5))
fi
```

### Ansible Playbooks
```yaml
---
# Description of playbook purpose
- name: Configure web servers
  hosts: managed
  become: true
  
  tasks:
    - name: Install httpd package
      ansible.builtin.dnf:
        name: httpd
        state: present
      
    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
```

## 🐛 Reporting Bugs

When reporting bugs, include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: Exact steps to reproduce
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: OS, Ansible version, etc.
6. **Logs**: Relevant error messages or logs

Example:
```markdown
**Bug**: Grade script fails on exam-02 task 3

**Steps to Reproduce**:
1. Deploy lab with `make up`
2. Complete exam-02 task 3
3. Run `bash ~/exams/exam-02/grade.sh`

**Expected**: Task 3 should pass with 10 points

**Actual**: Script errors with "file not found"

**Environment**:
- Rocky Linux 9.3
- Ansible 2.14
- Terraform 1.5.7

**Logs**:
```
/home/student/exams/exam-02/grade.sh: line 45: test.yml: No such file or directory
```
```

## 💡 Feature Requests

When requesting features:

1. **Use Case**: Describe the problem or need
2. **Proposed Solution**: Your idea for solving it
3. **Alternatives**: Other approaches considered
4. **Benefits**: How this helps users

## 📚 Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [EX294 Exam Objectives](https://www.redhat.com/en/services/training/ex294-red-hat-certified-engineer-rhce-exam-red-hat-enterprise-linux-8)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)

## 🤝 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior
- Be respectful and considerate
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information

## 📞 Getting Help

- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions
- **Questions**: Tag your issue with "question"

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation

Thank you for contributing to RHCE Killer! 🎉