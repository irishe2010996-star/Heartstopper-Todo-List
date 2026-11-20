# Build the scrollbar helper from source. Does not run the executable.
$ErrorActionPreference='Stop'
if($env:OS -ne 'Windows_NT' -or $PSVersionTable.PSEdition -ne 'Desktop'){
    throw 'Build using Windows PowerShell 5.1 (powershell.exe), not PowerShell 7.'
}
$source=Join-Path $PSScriptRoot 'src\ScrollbarDrag.cs'
$target=Join-Path $PSScriptRoot 'widget-scroll-drag-v2.exe'
$temporary=Join-Path $PSScriptRoot ('drag-build-'+[guid]::NewGuid().ToString('N')+'.exe')
try{
    Add-Type -TypeDefinition ([IO.File]::ReadAllText($source)) -OutputAssembly $temporary -OutputType WindowsApplication
    Move-Item -LiteralPath $temporary -Destination $target -Force
}finally{
    if(Test-Path -LiteralPath $temporary){Remove-Item -LiteralPath $temporary}
}
Write-Host 'Scrollbar helper built from src/ScrollbarDrag.cs.' -ForegroundColor Cyan
