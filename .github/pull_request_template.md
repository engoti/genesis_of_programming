## Pull Request Type

# Pull Request: Add [Language/Tool Name]

> Thank you for contributing to **genesis_of_programming**!  
> This PR adds support for **[Language/Tool Name]**.

---

## Language / Tool
- **Name**: `[e.g., Objective-C, PowerShell, Terraform]`
- **Category**: `[e.g., Systems, Scripting, DevOps, Mobile, Legacy]`
- **Website**: `[Official URL]`

---

## Changes Made

### 1. **README Update**
- [ ] Added `[Language]` to the top language list
- [ ] Added installation instructions under **Installing [Language]**
- [ ] Added VS Code extension recommendation (if applicable)

### 2. **Example Code**
- [ ] Created `src/[language]/hello_world.[ext]`  
  *(e.g., `src/objective-c/hello_world.m`)*
- [ ] Code compiles/runs successfully

### 3. **Issue Template (Optional)**
- [ ] Created `issues/[language].md` for future contributions

---

## Prerequisites Installed
List any required dependencies:
- [ ] `brew install [package]` (macOS)
- [ ] `sudo apt install [package]` (Ubuntu)
- [ ] `choco install [package]` (Windows)
- [ ] Node.js / Python / JDK / etc.

> Example:  
> - [x] Xcode Command Line Tools (`xcode-select --install`)  
> - [x] GNOME Objective-C runtime (`libobjc2`)

---

## Screenshots / Output (Optional but encouraged)
```bash
$ [command to run]
Hello, World from Objective-C!

''''

---

## How to Add This to Your Repo

1. Go to your GitHub repo:  
   `https://github.com/engoti/genesis_of_programming`

2. Create the folder and file:



3. Paste the above content.

4. Commit:
```bash
git add .github/PULL_REQUEST_TEMPLATE.md
git commit -m "chore: add PR template for new language contributions"
git push

#Objective_C
src/
└── objective-c/
    └── hello_world.m

issues/
└── objective-c.md

#Example(hello-world.m)
#import <Foundation/Foundation.h>

int main() {
    NSLog(@"Hello, World from Objective-C!");
    return 0;
}
''''