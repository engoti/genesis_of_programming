#!/usr/bin/env bash
# .github/scripts/validate.sh
set -euo pipefail

# ------------------------------------------------------------
# 1. Output directory & HTML report setup
# ------------------------------------------------------------
OUT_DIR="${GITHUB_WORKSPACE:-$(pwd)}/validate"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/index.html"

start_report() {
  cat >"$REPORT" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Nightly Validation Report</title>
  <style>
    body{font-family:sans-serif;margin:2rem;background:#fafafa;}
    table{border-collapse:collapse;width:100%;}
    th,td{border:1px solid #ddd;padding:.5rem;text-align:left;}
    th{background:#eee;}
    .pass{background:#e6ffed;color:#006b24;}
    .fail{background:#ffe6e6;color:#b00020;}
    pre{margin:0;white-space:pre-wrap;}
  </style>
</head>
<body>
<h1>Nightly Full Validation – $(date -u "+%Y-%m-%d %H:%M UTC")</h1>
<table>
<tr><th>Language</th><th>Status</th><th>Details</th></tr>
EOF
}

add_row() {
  local name="$1" status="$2" details="$3"
  local class=$( [ "$status" = "PASS" ] && echo "pass" || echo "fail" )
  printf '<tr class="%s"><td>%s</td><td>%s</td><td><pre>%s</pre></td></tr>\n' \
    "$class" "$name" "$status" "$(echo "$details" | escape_html)" >>"$REPORT"
}

escape_html() {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

finish_report() {
  cat >>"$REPORT" <<'EOF'
</table>
</body></html>
EOF
}

# ------------------------------------------------------------
# 2. Language detectors (run from src/ folders)
# ------------------------------------------------------------
detect_languages() {
  find src -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort
}

# ------------------------------------------------------------
# 3. VALIDATOR FUNCTIONS
# ------------------------------------------------------------

validate_python() {
  echo "Checking Python..."
  python3 --version
  pip3 --version
  # Optional: install a tiny package to prove pip works
  pip3 install --quiet flask >/dev/null
  python3 -c "import flask; print('Flask version:', flask.__version__)"
}

validate_node() {
  echo "Checking Node.js..."
  node --version
  npm --version
  # Optional: install a tiny package
  npm install -g npm@latest >/dev/null 2>&1
  echo "npm updated to $(npm --version)"
}

validate_go() {
  echo "Checking Go..."
  go version
  # Optional: build a hello world
  echo 'package main
import "fmt"
func main(){fmt.Println("Go works!")}' > /tmp/hello.go
  go run /tmp/hello.go
}

validate_rust() {
  echo "Checking Rust..."
  rustc --version
  cargo --version
  # Optional: compile a tiny program
  mkdir -p /tmp/rusthello
  cat > /tmp/rusthello/Cargo.toml <<'EOF'
[package]
name = "hello"
version = "0.1.0"
edition = "2021"
EOF
  cat > /tmp/rusthello/src/main.rs <<'EOF'
fn main() { println!("Rust works!"); }
EOF
  (cd /tmp/rusthello && cargo build --quiet && ./target/debug/hello)
}

# ------------------------------------------------------------
# 4. MAIN driver
# ------------------------------------------------------------
main() {
  start_report

  if [ $# -eq 1 ]; then
    # ---- Run a single language (used by GitHub Actions) ----
    lang="$1"
    echo "=== Validating $lang ==="
    if output=$( validate_"$lang" 2>&1 ); then
      add_row "$lang" "PASS" "$output"
    else
      add_row "$lang" "FAIL" "$output"
    fi
  else
    # ---- Full run – detect from src/ ----
    echo "Detecting languages in src/..."
    while IFS= read -r lang; do
      echo "=== Validating $lang ==="
      if output=$( validate_"$lang" 2>&1 ); then
        add_row "$lang" "PASS" "$output"
      else
        add_row "$lang" "FAIL" "$output"
      fi
    done < <(detect_languages)
  fi

  finish_report
  echo "Report written to $REPORT"
}

# Run the script
main "$@"