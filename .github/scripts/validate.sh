#!/bin/bash
# Auto-detects languages from src/ + validates installation + Hello World

set -euo pipefail

echo "🔍 Detecting languages from src/..."
# Extract languages from src/ subdirectories
mapfile -t languages < <(find src -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

mkdir -p validate

# Test each language
passing=0
failing=()

for lang in "${languages[@]}"; do
  echo "🧪 Validating $lang..."
  
  # Navigate to language directory
  lang_dir="src/$lang"
  if [ ! -d "$lang_dir" ]; then
    failing+=("$lang")
    echo "⚠️ $lang: Directory not found"
    continue
  fi
  cd "$lang_dir" || continue
  
  # Find hello_world file (any extension)
  hello_file=$(compgen -G "hello_world.*")
  if [ -z "$hello_file" ]; then
    failing+=("$lang")
    echo "⚠️ $lang: No hello_world.* file found"
    cd - >/dev/null
    continue
  fi
  
  # Run based on language (install if needed)
  case "$lang" in
    "Python")
      python3 "$hello_file" && echo "$lang: PASS" && ((passing++)) || failing+=("$lang")
      ;;
    "Node.js"|"JavaScript")
      node "$hello_file" && echo "$lang: PASS" && ((passing++)) || failing+=("$lang")
      ;;
    "Rust")
      if ! command -v rustc >/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
      fi
      rustc "$hello_file" -o hello && ./hello && echo "$lang: PASS" && ((passing++)) || failing+=("$lang")
      ;;
    "Go")
      if ! command -v go >/dev/null; then
        sudo apt update && sudo apt install -y golang-go
      fi
      go run "$hello_file" && echo "$lang: PASS" && ((passing++)) || failing+=("$lang")
      ;;
    "COBOL")
      if ! command -v cobc >/dev/null; then
        sudo apt update && sudo apt install -y gnucobol
      fi
      cobc -x "$hello_file" && ./hello_world && echo "$lang: PASS" && ((passing++)) || failing+=("$lang")
      ;;
    *)
      echo "⚠️ $lang: No auto-test yet (manual validation needed)"
      failing+=("$lang")
      ;;
  esac
  
  cd - >/dev/null
done

# Generate status.json for badges
fail_json=$(printf '%s\n' "${failing[@]}" | jq -R . | jq -s .)
echo "{\"passing\":$passing,\"failing\":$fail_json,\"lastRun\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" > validate/status.json

echo "✅ Validation complete!"