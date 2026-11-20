$ErrorActionPreference='Stop'
try{
    & (Join-Path $PSScriptRoot 'todo-auth.ps1')
    & (Join-Path $PSScriptRoot 'todo-export.ps1')
}finally{
    Read-Host 'Done - press Enter to close'|Out-Null
}
