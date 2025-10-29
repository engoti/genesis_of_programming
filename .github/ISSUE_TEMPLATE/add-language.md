---
name: "Add New Language / Tool"
about: Request to add support for a new programming language, framework, or tool
title: 'feat: add [Language Name]'
labels: enhancement, new-language
assignees: ''

---

## Language / Tool to Add

**Name**:  
*(e.g., Objective-C, PowerShell, Terraform)*

**Category**:  
*(e.g., Mobile, Scripting, DevOps, Systems, Legacy)*

**Official Website**:  
*(e.g., https://developer.apple.com/objective-c/)*

---

## Why Should It Be Added?

> Explain the relevance:
- Widely used in industry?
- Educational value?
- Historical significance?
- Emerging technology?

---

## Installation Requirements

List required tools/installers:

| OS | Command / Installer |
|----|---------------------|
| macOS | `brew install X` |
| Linux (Ubuntu) | `sudo apt install X` |
| Windows | Chocolatey / MSI / WSL |

> Example:  
> - [ ] Xcode Command Line Tools  
> - [ ] GNUstep (for Objective-C on Linux/Windows)

---

## VS Code Support

- Extension Name: *(e.g., "Objective-C" by Microsoft)*  
- Link: *(VS Code Marketplace URL)*

---

## Example "Hello World" Plan

```text
File: src/objective-c/hello_world.m
Expected output: "Hello, World from Objective-C!"

This is a Template that shows how you can additionally add languages that ain't in this Repo!

The issue Below will be used to track progress and assign a contributor


---

## 2. `.github/ISSUE_TEMPLATE/fix-language.md`

```markdown
---
name: "Fix Language Instructions"
about: Report outdated, broken, or unclear installation/code for an existing language
title: 'fix: [Language] - [Brief Issue]'
labels: bug, documentation
assignees: ''

---

## Language / Tool

**Name**: *(e.g., Rust, Python, Laravel)*

**Affected Section**:  
- [ ] Installation Instructions  
- [ ] Example Code (`hello_world.*`)  
- [ ] VS Code Setup  
- [ ] Prerequisites

---

## Current Problem

> Describe what's wrong:

```text
Example:
`rustc` command not found after following install steps on Ubuntu.

EXPECTED BEHAVIOR

After `curl --proto '=https' ... | sh`, `rustc --version` should work.


$ rustc --version
bash: rustc: command not found

- curl ... | sh
+ curl ... | sh && source "$HOME/.cargo/env"

