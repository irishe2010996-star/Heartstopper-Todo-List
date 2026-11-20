# Shared path resolution. No installers, elevation, or network calls.
function Get-WidgetPaths {
    $root=$PSScriptRoot
    $config=@{}
    $configFile=Join-Path $root 'widget.config.json'
    if(Test-Path -LiteralPath $configFile){
        $config=Get-Content -LiteralPath $configFile -Raw -Encoding UTF8|ConvertFrom-Json
    }
    function Expand-WidgetPath([string]$value){
        if([string]::IsNullOrWhiteSpace($value)){return $null}
        $value=[Environment]::ExpandEnvironmentVariables($value)
        if(![IO.Path]::IsPathRooted($value)){$value=Join-Path $root $value}
        [IO.Path]::GetFullPath($value)
    }
    $candidates=New-Object 'System.Collections.Generic.List[string]'
    if($config.rainmeterExe){$candidates.Add((Expand-WidgetPath $config.rainmeterExe))}
    else{
        foreach($process in @(Get-Process -Name Rainmeter -ErrorAction SilentlyContinue)){
            try{if($process.Path){$candidates.Add($process.Path)}}catch{}
        }
        foreach($base in @($env:ProgramFiles,${env:ProgramFiles(x86)})){
            if($base){$candidates.Add((Join-Path $base 'Rainmeter\Rainmeter.exe'))}
        }
    }
    $exe=$candidates|Where-Object{Test-Path -LiteralPath $_ -PathType Leaf}|Select-Object -First 1
    if(!$exe){throw 'Rainmeter.exe not found. Install Rainmeter yourself or set rainmeterExe in widget.config.json.'}
    $exe=[IO.Path]::GetFullPath($exe)
    $exeDir=Split-Path -Parent $exe
    if($config.rainmeterIni){$ini=Expand-WidgetPath $config.rainmeterIni}
    elseif(Test-Path -LiteralPath (Join-Path $exeDir 'Rainmeter.ini')){$ini=Join-Path $exeDir 'Rainmeter.ini'}
    else{
        if(!$env:APPDATA){throw 'APPDATA is unavailable. Set rainmeterIni explicitly in widget.config.json.'}
        $ini=Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'
    }
    $skins=$null
    if($config.skinsDirectory){$skins=Expand-WidgetPath $config.skinsDirectory}
    elseif(Test-Path -LiteralPath $ini){
        $iniText=[IO.File]::ReadAllText($ini)
        $section=[regex]::Match($iniText,'(?ms)^\[Rainmeter\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
        $match=[regex]::Match($section.Groups['body'].Value,'(?im)^\s*SkinPath\s*=\s*(.*?)\s*$')
        if($match.Success -and $match.Groups[1].Value){
            $skins=[Environment]::ExpandEnvironmentVariables($match.Groups[1].Value.Trim())
            if(![IO.Path]::IsPathRooted($skins)){$skins=Join-Path (Split-Path -Parent $ini) $skins}
        }
    }
    if(!$skins){
        if((Split-Path -Parent $ini) -eq $exeDir){$skins=Join-Path $exeDir 'Skins'}
        else{$skins=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins'}
    }
    [pscustomobject]@{
        Root=$root;RainmeterExe=$exe;RainmeterIni=$ini
        SkinsDirectory=$skins
        ToDoSkinDir=(Join-Path $skins 'ToDo')
        CalendarSkinDir=(Join-Path $skins 'ToDoCal')
    }
}
