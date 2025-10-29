#!/bin/bash
set -e

echo "Setting up Genesis of Programming with src/ structure..."

# Install compilers and tools
sudo apt-get update && sudo apt-get install -y \
    build-essential gcc g++ clang cmake gdb valgrind \
    sqlite3 nginx curl wget zip unzip tree htop jq bat fzf

# npm global tools
npm install -g typescript eslint prettier live-server yarn pnpm truffle

# Python packages
pip install --upgrade pip flask django numpy pandas

# Ruby gems
gem install rails bundler

# Go tools
go install golang.org/x/tools/gopls@latest

# Rust tools
rustup component add rustfmt clippy

# SDKMAN! for Java, Kotlin, etc.
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-openjdk
sdk install kotlin

# === CREATE src/ FOLDER STRUCTURE ===
mkdir -p src/{python,javascript,go,rust,java,c,cpp,ruby,php,html,css,typescript}

# === SAMPLE FILES ===
cat > src/python/hello.py << 'EOF'
print("Hello from Python!")
EOF

cat > src/javascript/index.js << 'EOF'
console.log("Hello from JavaScript!");
EOF

cat > src/go/main.go << 'EOF'
package main
import "fmt"
func main() { fmt.Println("Hello from Go!") }
EOF

cat > src/c/hello.c << 'EOF'
#include <stdio.h>
int main() { printf("Hello from C!\n"); return 0; }
EOF

echo "src/ folder created. Ready for contributions!"
echo "Open an issue → add your hello world → open PR"