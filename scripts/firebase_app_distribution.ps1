param(
  [string]$AppId = "1:891051622598:android:68c9f9d42b3f233c10d7c7",
  [string]$ArtifactPath = "",
  [string]$Testers = "",
  [string]$Groups = "kinesa-testers",
  [string]$ProjectId = "grandmind-kinesa",
  [string]$ReleaseNotes = "New build for testing",
  [switch]$BuildApk,
  [switch]$BuildAab
)

$firebase = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebase) {
  Write-Error "Firebase CLI not found in PATH. Install with: npm install -g firebase-tools"
  exit 1
}

if ($AppId -eq "") {
  Write-Error "AppId is required. Example: --AppId 1:1234567890:android:abcdef123456"
  exit 1
}

if ($BuildApk -or $BuildAab) {
  $flutter = Get-Command flutter -ErrorAction SilentlyContinue
  if (-not $flutter) {
    $flutter = Get-Command "C:\\dev\\flutter\\bin\\flutter.bat" -ErrorAction SilentlyContinue
  }
  if (-not $flutter) {
    Write-Error "Flutter not found in PATH. Set PATH or install Flutter."
    exit 1
  }

  if ($BuildAab) {
    & $flutter.Path build appbundle --release
    $ArtifactPath = "build\\app\\outputs\\bundle\\release\\app-release.aab"
  } else {
    & $flutter.Path build apk --release
    $ArtifactPath = "build\\app\\outputs\\flutter-apk\\app-release.apk"
  }
}

if ($ArtifactPath -eq "") {
  Write-Error "ArtifactPath is required. Provide an APK or AAB path or use -BuildApk/-BuildAab."
  exit 1
}

if ($Testers -eq "" -and $Groups -eq "") {
  Write-Error "Provide at least one of: -Testers or -Groups."
  exit 1
}

$args = @("appdistribution:distribute", $ArtifactPath, "--app", $AppId, "--release-notes", $ReleaseNotes)
if ($Testers -ne "") {
  $args += @("--testers", $Testers)
}
if ($Groups -ne "") {
  $args += @("--groups", $Groups)
}
if ($ProjectId -ne "") {
  $args += @("--project", $ProjectId)
}

& $firebase.Path @args
