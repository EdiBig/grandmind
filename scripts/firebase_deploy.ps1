param(
  [string]$ProjectId = "",
  [string]$Only = "firestore:rules,firestore:indexes,storage"
)

$firebase = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebase) {
  Write-Error "Firebase CLI not found in PATH. Install with: npm install -g firebase-tools"
  exit 1
}

$deployArgs = @("deploy", "--only", $Only)
if ($ProjectId -ne "") {
  $deployArgs += @("--project", $ProjectId)
}

& $firebase.Path @deployArgs
