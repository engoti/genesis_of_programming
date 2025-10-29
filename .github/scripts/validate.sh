#!/bin/bash
set -euo pipefail

echo "Detecting languages from src/..."
mapfile -t languages < <(find src -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

mkdir -p validate
passing=0
failing=()

for lang in "${languages[@]}"; do
  echo "Validating $lang..."
  lang_dir="src/$lang"
  cd "$lang_dir" 2>/dev/null || { failing+=("$lang"); continue; }

  hello_file=$(ls hello_world.* 2>/dev/null | head -1)
  [[ -n "$hello_file" ]] || { failing+=("$lang"); cd -; continue; }

  case "$lang" in
    Python)
      python3 "$hello_file" >/dev/null 2>&1 && ((passing++)) || failing+=("$lang")
      ;;
    "Node.js"|JavaScript)
      node "$hello_file" >/dev/null 2>&1 && ((passing++)) || failing+=("$lang")
      ;;
    Rust)
      if ! command -v rustc >/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
      fi
      rustc "$hello_file" -o hello && ./hello >/dev/null 2>&1 && ((passing++)) || failing+=("$lang")
      ;;
    Go)
      if ! command -v go >/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y golang-go
      fi
      go run "$hello_file" >/dev/null 2>&1 && ((passing++)) || failing+=("$lang")
      ;;
    COBOL)
      if ! command -v cobc >/dev/null 2>&1; then
        echo "Installing gnucobol..."
        sudo apt-get update -qq
        sudo apt-get install -y gnucobol
      fi
      cobc -x "$hello_file" && ./a.out >/dev/null 2>&1 && ((passing++)) || failing+=("$lang")
      ;;
    *)
      failing+=("$lang")
      ;;
  esac

  cd - >/dev/null
done

# Generate status.json
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
fail_json=$(printf '%s\n' "${failing[@]}" | jq -R . | jq -s .)
echo "{\"passing\":$passing,\"failing\":$fail_json,\"lastRun\":\"$timestamp\"}" > validate/status.json

echo "$passing PASS | ${#failing[@]} FAIL"