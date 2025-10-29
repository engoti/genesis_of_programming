#!/usr/bin/env bash
# .github/scripts/validate.sh
set -euo pipefail

# ------------------------------------------------------------
# 1. Detect languages from src/ (you already have this)
# ------------------------------------------------------------
detect_languages() {
  find src -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

# ------------------------------------------------------------
# 2. Helper: run a check and record PASS/FAIL
# ------------------------------------------------------------
OUT_DIR="${GITHUB_WORKSPACE:-$(pwd)}/validate"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/index.html"

start_report() {
  cat >"$REPORT" <<'EOF'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Nightly Validation</title>
<style>
  body{font-family:sans-serif;margin:2rem;background:#fafafa;}
  table{border-collapse:collapse;width:100%;}
  th,td{border:1px solid #ddd;padding:.5rem;}
  th{background:#eee;}
  .pass{background:#e6ffed;color:#006b24;}
  .fail{background:#ffe6e6;color:#b00020;}
</style>
</head><body>
<h1>Nightly Validation – $(date -u "+%Y-%m-%d %H:%M UTC")</h1>
<table><tr><th>Language</th><th>Status</th><th>Details</th></tr>
EOF
}

add_row() {
  local name="$1" status="$2" details="$3"
  local class=$([ "$status" = "PASS" ] && echo pass || echo fail)
  printf '<tr class="%s"><td>%s</td><td>%s</td><td><pre>%s</pre></td></tr>\n' \
    "$class" "$name" "$status" "$details" >>"$REPORT"
}

finish_report() {
  cat >>"$REPORT" <<'EOF'
</table></body></html>
EOF
}

# ------------------------------------------------------------
# 3. Language validators
# ------------------------------------------------------------
validate_node() {
  # Install Node if missing
  if ! command -v node >/dev/null; then
    echo "Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  node --version && npm --version
}

validate_python() {
  python3 --version && pip3 --version
  # optional: install a framework
  pip3 install --quiet flask || true
}

validate_go() {
  go version
}

validate_rust() {
  rustc --version
}

# add more as you need…

# ------------------------------------------------------------
# 4. Main driver
# ------------------------------------------------------------
main() {
  start_report

  # If a language is passed as argument, validate only that one
  if [ $# -eq 1 ]; then
    lang="$1"
    echo "Validating $lang..."
    output=$( "validate_$lang" 2>&1 ) && status=PASS || status=FAIL
    add_row "$lang" "$status" "$output"
  else
    # Full run – detect from src/
    echo "Detecting languages from src/..."
    while IFS= read -r lang; do
      echo "Validating $lang..."
      if output=$( "validate_$lang" 2>&1 ); then
        add_row "$lang" "PASS" "$output"
      else
        add_row "$lang" "FAIL" "$output"
      fi
    done < <(detect_languages)
  fi

  finish_report
  echo "Report written to $REPORT"
}

main "$@"