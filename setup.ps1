# Current-user setup. Rainmeter is a separately installed prerequisite.
$ErrorActionPreference='Stop'
$dir=$PSScriptRoot
. (Join-Path $dir 'widget-paths.ps1')
$paths=Get-WidgetPaths
if(!(Test-Path -LiteralPath (Join-Path $dir 'soft-rainbow-leaves.png'))){
    throw 'Leaf artwork is not bundled. See assets/README.md before running setup.'
}
if(!(Test-Path -LiteralPath (Join-Path $dir 'widget-scroll-drag-v2.exe'))){
    & (Join-Path $dir 'build-helper.ps1')
}
Start-Process -FilePath $paths.RainmeterExe
Start-Sleep -Seconds 3
$paths=Get-WidgetPaths
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Rainmeter' -Value ('"'+$paths.RainmeterExe+'"') -PropertyType String -Force|Out-Null
foreach($entry in @(
    @('settings.txt',"236`n360`n6`n0`n100"),
    @('tips.txt','1'),@('panel.txt','0'),@('scroll.txt','0'),@('pending.txt',"0`n`n")
)){
    $path=Join-Path $dir $entry[0]
    if(!(Test-Path -LiteralPath $path)){
        [IO.File]::WriteAllText($path,$entry[1],[Text.UTF8Encoding]::new($false))
    }
}
if(!(Test-Path -LiteralPath (Join-Path $dir 'token.dat'))){& (Join-Path $dir 'todo-auth.ps1')}
if(!(Test-Path -LiteralPath (Join-Path $dir 'token.dat'))){throw 'Sign-in did not complete.'}
& (Join-Path $dir 'todo-export.ps1')|Out-Null
# An unchanged cache can make the exporter return without generating a skin.
& (Join-Path $dir 'todo-render.ps1')|Out-Null
& $paths.RainmeterExe '!RefreshApp'
Start-Sleep -Seconds 1
& $paths.RainmeterExe '!ActivateConfig' 'ToDo' 'ToDo.ini'
foreach($pair in @(@('KeepOnScreen','1'),@('SnapEdges','0'),@('Draggable','1'),@('AutoSelectScreen','1'),@('AlwaysOnTop','-2'))){
    $bang=if($pair[0] -eq 'AlwaysOnTop'){'!ZPos'}else{'!'+$pair[0]}
    & $paths.RainmeterExe $bang $pair[1] 'ToDo'
    & $paths.RainmeterExe '!WriteKeyValue' 'ToDo' $pair[0] $pair[1] $paths.RainmeterIni
}
$shell=New-Object -ComObject WScript.Shell
$shortcut=$shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('DesktopDirectory')) 'Heartstopper Todo List.lnk'))
$shortcut.TargetPath='wscript.exe'
$shortcut.Arguments='"'+(Join-Path $dir 'open-widget.vbs')+'"'
$shortcut.WorkingDirectory=$dir
$shortcut.Description='Open Heartstopper Todo List'
$shortcut.Save()
Write-Host 'Ready. Current-user startup enabled; right-click for the confirmed Unload action.' -ForegroundColor Cyan
