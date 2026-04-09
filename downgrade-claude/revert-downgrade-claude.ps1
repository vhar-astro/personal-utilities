$ErrorActionPreference = "Stop"
$Package = "@anthropic-ai/claude-code@latest"
$SettingsDir = Join-Path $HOME ".claude"
$SettingsFile = Join-Path $SettingsDir "settings.json"

Write-Host "[1/3] Updating Claude Code to latest via npm..."
npm install -g $Package

Write-Host "[2/3] Removing envs from settings.json..."
if (Test-Path $SettingsFile) {
  $jsonRaw = Get-Content -Path $SettingsFile -Raw
  if ([string]::IsNullOrWhiteSpace($jsonRaw)) { $jsonRaw = "{}" }
  $obj = $jsonRaw | ConvertFrom-Json

  if ($obj.env) {
    foreach ($name in @("DISABLE_AUTOUPDATER","CLAUDE_CODE_DISABLE_1M_CONTEXT","CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING")) {
      if ($obj.env.PSObject.Properties.Name -contains $name) {
        $obj.env.PSObject.Properties.Remove($name)
      }
    }
    if (($obj.env.PSObject.Properties | Measure-Object).Count -eq 0) {
      $obj.PSObject.Properties.Remove("env")
    }
  }

  $obj | ConvertTo-Json -Depth 100 | Set-Content -Path $SettingsFile -Encoding UTF8
} else {
  Write-Host "settings.json not found, skipping."
}

Write-Host "[3/3] Verifying..."
$ver = claude --version
Write-Host "claude version: $ver"
if (Test-Path $SettingsFile) {
  $envObj = (Get-Content -Path $SettingsFile -Raw | ConvertFrom-Json).env
  $disabled = if ($envObj) { $envObj.DISABLE_AUTOUPDATER } else { $null }
  $disable1M = if ($envObj) { $envObj.CLAUDE_CODE_DISABLE_1M_CONTEXT } else { $null }
  $disableAdaptive = if ($envObj) { $envObj.CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING } else { $null }
  Write-Host "DISABLE_AUTOUPDATER: $(if ($disabled) { $disabled } else { 'removed' })"
  Write-Host "CLAUDE_CODE_DISABLE_1M_CONTEXT: $(if ($disable1M) { $disable1M } else { 'removed' })"
  Write-Host "CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING: $(if ($disableAdaptive) { $disableAdaptive } else { 'removed' })"
}
Write-Host "Done."
Write-Host ""
Read-Host -Prompt "Press Enter to exit"
