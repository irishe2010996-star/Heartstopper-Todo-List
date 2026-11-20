$ErrorActionPreference='Stop'
try{
    $guard=[IO.File]::Open(
        (Join-Path $PSScriptRoot '.unload-confirm.lock'),
        [IO.FileMode]::OpenOrCreate,
        [IO.FileAccess]::ReadWrite,
        [IO.FileShare]::None
    )
}catch [IO.IOException]{return}
try{
    Add-Type -AssemblyName System.Windows.Forms
    $first=[Windows.Forms.MessageBox]::Show(
        'Hide the To Do widget? Your Microsoft To Do tasks will remain unchanged.',
        'Hide widget - confirmation 1 of 2',
        [Windows.Forms.MessageBoxButtons]::YesNo,
        [Windows.Forms.MessageBoxIcon]::Question,
        [Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if($first -ne [Windows.Forms.DialogResult]::Yes){return}

    $second=[Windows.Forms.MessageBox]::Show(
        'Hide it now? You can load it again from Rainmeter.',
        'Hide widget - final confirmation',
        [Windows.Forms.MessageBoxButtons]::YesNo,
        [Windows.Forms.MessageBoxIcon]::Warning,
        [Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if($second -ne [Windows.Forms.DialogResult]::Yes){return}

    . (Join-Path $PSScriptRoot 'widget-paths.ps1')
    $paths=Get-WidgetPaths
    & $paths.RainmeterExe '!DeactivateConfig' 'ToDo'
}finally{
    $guard.Dispose()
}