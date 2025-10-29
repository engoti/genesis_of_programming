# Run in PowerShell
@'
console.log("Hello from Node.js!");
'@ | Set-Content -Path "src/Node.js/hello_world.js" -Encoding UTF8 -NoNewline