$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'widget-paths.ps1')
$paths=Get-WidgetPaths
Start-Process -FilePath $paths.RainmeterExe
Start-Sleep -Seconds 1
if(!(Test-Path -LiteralPath (Join-Path $paths.ToDoSkinDir 'ToDo.ini'))){
    & (Join-Path $PSScriptRoot 'todo-render.ps1')|Out-Null
}
& $paths.RainmeterExe '!RefreshApp'
Start-Sleep -Milliseconds 500
& $paths.RainmeterExe '!ActivateConfig' 'ToDo' 'ToDo.ini'
