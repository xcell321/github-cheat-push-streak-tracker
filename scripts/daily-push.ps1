$repo = "C:\CAPSTONE\github-cheat-push-streak-tracker"
$log = Join-Path $repo "scripts\daily-push.log"
Set-Location $repo

function Log($msg) {
    Add-Content -Path $log -Value ("$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg")
}

Log "Start"

git fetch origin main 2>&1 | Out-Null
git pull --rebase origin main 2>&1 | Out-Null

$today = Get-Date -Format 'yyyy-MM-dd'
$last = git log --grep='auto push' -1 --format='%cd' --date=format-local:'%Y-%m-%d'
if ($last -eq $today) {
    Log "Skip: already pushed today ($today)"
    exit 0
}

$content = Get-Content README.md -Raw
if ($content -notmatch 'cheat: \[(\d+)\]\[(\d+)\]') {
    Log "ERROR: counter pattern not found"
    exit 1
}
$tens = [int]$Matches[1]
$units = [int]$Matches[2] + 1
if ($units -gt 9) { $units = 0; $tens++ }
$new = "[$tens][$units]"
$content = $content -replace 'cheat: \[\d+\]\[\d+\]', "cheat: $new"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $repo "README.md"), $content, $utf8NoBom)

git config user.name "xcell321"
git config user.email "edsielursal39@gmail.com"
git add README.md
$msg = "cheat${new}: auto push (busy day)"
git commit -m $msg
git push origin main
if ($LASTEXITCODE -ne 0) {
    Log "ERROR: push failed"
    exit 1
}
Log "Pushed: $msg"
