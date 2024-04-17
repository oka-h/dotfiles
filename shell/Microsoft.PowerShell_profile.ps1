Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode Vi

function prompt {
  if (Get-Command git -ErrorAction Ignore) {
    $TempErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Ignore'
    $Branches = git branch
    $ErrorActionPreference = $TempErrorActionPreference
  }

  Write-Host
  Write-Host -NoNewLine -ForegroundColor 'Green' "$Env:USERNAME@$Env:COMPUTERNAME"
  Write-Host -NoNewLine " $(Get-Location)"

  if ($Branches -ne $Null) {
    Write-Host -NoNewLine ' ['
    Write-Host -NoNewLine -ForegroundColor 'Cyan' $(($Branches | Select-String '^\*').ToString().Trim() -replace '^\* *', '')
    Write-Host -NoNewLine ']'
  }

  Write-Host

  if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).`
    IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    return '# '
  }
  else {
    return '$ '
  }
}

Set-PSReadlineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadlineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadlineKeyHandler -Chord Ctrl+p -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Chord Ctrl+n -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord Ctrl+t -Function YankLastArg
Set-PSReadlineKeyHandler -Chord Ctrl+k -ScriptBlock {
  Set-Location ..
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

if (Get-Alias ls -ErrorAction Ignore) {
  Remove-Item alias:ls
}

function global:ls {
  Get-ChildItem $args | Format-Wide -AutoSize
}

function global:la {
  Get-ChildItem -force $args | Format-Wide -AutoSize
}

function global:lal {
  Get-ChildItem -force $args
}

Set-Alias l ls
Set-Alias ll Get-ChildItem
Set-Alias lla lal

if (Get-Alias diff -ErrorAction Ignore) {
  Remove-Item -Force alias:diff
}

function global:diff {
  cmd /c fc /n $args
}

if (Get-Command gvim -ErrorAction Ignore) {
  Set-Alias e gvim
}
elseif (Get-Command vim -ErrorAction Ignore) {
  Set-Alias e vim
}

$ChocolateyProfile = "$Env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module $ChocolateyProfile
}

$LocalProfile = "$(Split-Path -Path $PROFILE)\Microsoft.PowerShell_profile_local.ps1"
if (Test-Path($LocalProfile)) {
  . $LocalProfile
}
