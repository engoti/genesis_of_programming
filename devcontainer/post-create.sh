#!/bin/bash
set -e

echo "Setting up Genesis of Programming environment..."

# Install additional tools via package managers
sudo apt-get update && sudo apt-get install -y \
    build-essential \
    clang \
    cmake \
    gcc \
    g++ \
    gdb \
    valgrind \
    sqlite3 \
    nginx \
    curl \
    wget \
    zip \
    unzip \
    tree \
    htop \
    jq \
    bat \
    fzf

# Install global npm packages
npm install -g \
    typescript \
    eslint \
    prettier \
    live-server \
    http-server \
    yarn \
    pnpm \
    truffle \
    ganache

# Install Python packages
pip install --upgrade pip
pip install flask django numpy pandas requests

# Install Ruby gems
gem install rails jekyll bundler

# Install Go tools
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Install Rust tools
rustup component add rustfmt clippy

# Install SDKMAN! and additional JDKs
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-openjdk
sdk install kotlin
sdk install scala
sdk install maven
sdk install gradle

# Create languages folder
mkdir -p languages/{python,javascript,go,rust,java,c,cpp,ruby,php,html,css}

# Create sample hello world files
cat > languages/python/hello.py << 'EOF'
print("Hello from Python!")
EOF

cat > languages/javascript/index.js << 'EOF'
console.log("Hello from JavaScript!");
EOF

cat > languages/go/main.go << 'EOF'
package main
import "fmt"
func main() { fmt.Println("Hello from Go!") }
EOF

echo "Environment ready! Open an issue and start coding."