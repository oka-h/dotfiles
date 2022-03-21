Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -EditMode Vi

function prompt {
    Write-Host
    Write-Host -NoNewLine -ForegroundColor "Green" "$env:USERNAME@$env:COMPUTERNAME"
    Write-Host " $(Get-Location)"
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).`
        IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        return "# "
    }
    else {
        return "$ " 
    }
}

Set-PSReadlineKeyHandler -Chord Ctrl+w -Function UnixWordRubout
Set-PSReadlineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadlineKeyHandler -Chord Ctrl+p -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Chord Ctrl+n -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord Ctrl+t -Function YankLastArg
Set-PSReadlineKeyHandler -Chord Ctrl+k -ScriptBlock {
    Set-Location ..
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

if (Get-Alias ls 2>${NULL}) {
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

if (Get-Command gvim 2>${NULL}) {
    Set-Alias e gvim
}
elseif (Get-Command vim 2>${NULL}) {
    Set-Alias e vim
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
