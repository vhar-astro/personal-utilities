param(
  [string]$TargetVersion = "2.1.63"
)

$ErrorActionPreference = "Stop"
$Package = "@anthropic-ai/claude-code@$TargetVersion"
$SettingsDir = Join-Path $HOME ".claude"
$SettingsFile = Join-Path $SettingsDir "settings.json"

Write-Host "[1/4] Installing Claude Code $TargetVersion via npm..."
npm install -g $Package

Write-Host "[2/4] Ensuring ~/.claude/settings.json exists..."
New-Item -ItemType Directory -Path $SettingsDir -Force | Out-Null
if (-not (Test-Path $SettingsFile)) {
  "{}" | Set-Content -Path $SettingsFile -Encoding UTF8
}

Write-Host "[3/4] Disabling Claude auto-updater in settings..."
$jsonRaw = Get-Content -Path $SettingsFile -Raw
if ([string]::IsNullOrWhiteSpace($jsonRaw)) { $jsonRaw = "{}" }
$obj = $jsonRaw | ConvertFrom-Json

if (-not $obj.env) {
  $obj | Add-Member -MemberType NoteProperty -Name env -Value ([pscustomobject]@{}) -Force
}
$obj.env | Add-Member -MemberType NoteProperty -Name DISABLE_AUTOUPDATER -Value "1" -Force
$obj.env | Add-Member -MemberType NoteProperty -Name CLAUDE_CODE_DISABLE_1M_CONTEXT -Value "1" -Force
$obj.env | Add-Member -MemberType NoteProperty -Name CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING -Value "1" -Force

$obj | ConvertTo-Json -Depth 100 | Set-Content -Path $SettingsFile -Encoding UTF8

Write-Host "[4/4] Verifying..."
$ver = claude --version
$envObj = (Get-Content -Path $SettingsFile -Raw | ConvertFrom-Json).env
$disabled = $envObj.DISABLE_AUTOUPDATER
$disable1M = $envObj.CLAUDE_CODE_DISABLE_1M_CONTEXT
$disableAdaptive = $envObj.CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING
Write-Host "claude version: $ver"
Write-Host "DISABLE_AUTOUPDATER: $disabled"
Write-Host "CLAUDE_CODE_DISABLE_1M_CONTEXT: $disable1M"
Write-Host "CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING: $disableAdaptive"
Write-Host "Done."
Write-Host ""
Read-Host -Prompt "Press Enter to exit"
