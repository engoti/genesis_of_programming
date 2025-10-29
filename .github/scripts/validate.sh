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
    pre{margin:0;white-space:pre-wrap;font-size:0.9em;}
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
<p><em>Generated on $(date -u "+%Y-%m-%d %H:%M UTC")</em></p>
</body></html>
EOF
}

# ------------------------------------------------------------
# 2. Language detection from src/
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
  pip3 install --quiet flask >/dev/null 2>&1
  python3 -c "import flask; print('Flask version:', flask.__version__)" 2>/dev/null || echo "Flask import failed"
}

validate_node() {
  echo "Checking Node.js..."
  node --version
  npm --version
  npm install -g npm@latest >/dev/null 2>&1 || echo "npm update skipped"
  echo "npm version: $(npm --version)"
}

validate_go() {
  echo "Checking Go..."
  go version
  echo 'package main; import "fmt"; func main(){fmt.Println("Go works!")}' > /tmp/hello.go
  go run /tmp/hello.go 2>/dev/null || echo "Go run failed"
}

validate_rust() {
  echo "Checking Rust..."
  rustc --version
  cargo --version
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
  (cd /tmp/rusthello && cargo build --quiet && ./target/debug/hello) 2>/dev/null || echo "Rust build failed"
}

# ------------------------------------------------------------
# 4. MAIN DRIVER
# ------------------------------------------------------------
main() {
  start_report

  if [ $# -eq 1 ]; then
    # Single language (called by GitHub Actions)
    lang="$1"
    echo "=== Validating $lang ==="
    if output=$( validate_"$lang" 2>&1 ); then
      add_row "$lang" "PASS" "$output"
    else
      add_row "$lang" "FAIL" "$output"
    fi
  else
    # Full auto-detect
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
  write_status_json  # ← This is the key for badges
  echo "Report + status.json written to $OUT_DIR"
}

# ------------------------------------------------------------
# 5. Generate status.json for README badges
# ------------------------------------------------------------
write_status_json() {
  local passing=0 failing=0
  passing=$(grep -c '<td>PASS</td>' "$REPORT" || echo 0)
  failing=$(grep -c '<td>FAIL</td>' "$REPORT" || echo 0)

  # Extract failing language names
  failing_list=$(grep -oP '<td>\K[^<]+(?=</td><td>FAIL</td>)' "$REPORT" | tr '\n' ',' | sed 's/,$//' || echo "")

  # Build JSON array
  if [ -z "$failing_list" ]; then
    failing_array="[]"
  else
    failing_array=$(printf '"%s",' $(echo "$failing_list" | tr ',' ' ') | sed 's/,$//')
    failing_array="[$failing_array]"
  fi

  cat > "$OUT_DIR/status.json" <<EOF
{
  "passing": $passing,
  "failing": $failing_array,
  "lastRun": "$(date -u '+%Y-%m-%d %H:%M UTC')"
}
EOF
}

# ------------------------------------------------------------
# 6. Run
# ------------------------------------------------------------
main "$@"