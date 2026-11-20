# todo-render.ps1 -- read cache + settings + pending -> generate ToDo.ini -> refresh. NO network.
$ErrorActionPreference='Stop'
$dir=$PSScriptRoot; if(-not $dir){$dir=Split-Path -Parent $MyInvocation.MyCommand.Definition}
. (Join-Path $dir 'widget-paths.ps1')
$widgetPaths=Get-WidgetPaths
$skinDir=$widgetPaths.ToDoSkinDir
$rmExe=$widgetPaths.RainmeterExe
if(-not (Test-Path $skinDir)){ New-Item -ItemType Directory -Path $skinDir -Force | Out-Null }

# --- settings: alpha, width, vis rows, locked, fontsz% ---
$alpha=236; $width=300; $vis=10; $locked=0; $fontsz=100
$sf=Join-Path $dir 'settings.txt'
if(Test-Path $sf){ $sl=@(Get-Content $sf -Encoding UTF8); if($sl.Count -ge 1 -and $sl[0]){$alpha=[int]$sl[0]}; if($sl.Count -ge 2 -and $sl[1]){$width=[int]$sl[1]}; if($sl.Count -ge 3 -and $sl[2]){$vis=[int]$sl[2]}; if($sl.Count -ge 4 -and $sl[3]){$locked=[int]$sl[3]}; if($sl.Count -ge 5 -and $sl[4]){$fontsz=[int]$sl[4]} }
function RF($p,$def){ $v=$def; $f=Join-Path $dir $p; if(Test-Path $f){ $x=@(Get-Content $f -Encoding UTF8); if($x.Count -ge 1 -and $x[0] -ne $null -and $x[0] -ne ''){$v=[int]$x[0]} }; $v }
$tips=RF 'tips.txt' 1
$panel=0
$off=0

# --- pending add-state ---
$pend=Join-Path $dir 'pending.txt'
$pImp=$false; $pLabel=''
if(Test-Path $pend){ $pl=@(Get-Content $pend -Encoding UTF8); if($pl.Count -ge 1){$pImp=($pl[0] -eq '1')}; if($pl.Count -ge 3){$pLabel=$pl[2]} }

# --- tasks from cache ---
$cache=Join-Path $dir 'tasks.json'
$sorted=@(); $near=0; $impc=0; $total=0
if(Test-Path $cache){ try{ $d=Get-Content $cache -Raw -Encoding UTF8|ConvertFrom-Json; $sorted=@($d.tasks); $near=[int]$d.near; $impc=[int]$d.impc; $total=[int]$d.total }catch{} }

# --- fonts (scaled) + geometry ---
$fontsz=100; $latin='Segoe UI'; $cjk='Segoe UI'; $font=$cjk; $mdl='Segoe MDL2 Assets'; $sym='Segoe UI Symbol'
if($fontsz -lt 80){$fontsz=80}; if($fontsz -gt 140){$fontsz=140}
$fsc=$fontsz/100.0
function Zf($v){ $r=[int][Math]::Round($v*$fsc); if($r -lt 6){6}else{$r} }
$fsT=Zf 13; $fsTask=Zf 12; $fsDue=Zf 11; $fsInfo=Zf 10; $fsUpd=Zf 9; $fsPh=Zf 11; $fsEmpty=Zf 12; $fsBul=Zf 13; $fsLbl=Zf 9; $fsB=9
$width=360; $W=$width; if($W -lt 240){$W=240}; if($W -gt 460){$W=460}
$padX=22; $headY=14; $listY=96
$rowH=(Zf 13)+17; $listY+=$rowH
$inX=$padX+64; $ibW=$W-$inX-$padX; if($ibW -lt 90){$ibW=90}
if($vis -lt 3){$vis=3}; if($vis -gt 20){$vis=20}
$visN=[Math]::Min(6,[Math]::Max(1,$total))   # fixed box height (empty space if fewer tasks; scroll if more)
$maxOff=[Math]::Max(0,$total-$visN)
if($off -gt $maxOff){$off=$maxOff}; if($off -lt 0){$off=0}
$overflow=($total -gt $visN)
$listH=$visN*$rowH
$addBarY=$listY+$listH+18
$footY=$addBarY+38
$togY=$footY+18
if($panel){ $s1=$togY+18; $s2=$s1+18; $s3=$s2+18; $s4=$s3+18; $H=$s4+22 } else { $H=$addBarY+48 }
$scrollU='MouseScrollUpAction=[!CommandMeasure WidgetScroll "Scroll(-1)"]'
$scrollD='MouseScrollDownAction=[!CommandMeasure WidgetScroll "Scroll(1)"]'
$L=New-Object System.Collections.Generic.List[string]
$L.Add('[Rainmeter]'); $L.Add('Update=1000'); $L.Add('AccurateText=1'); $L.Add('DynamicWindowSize=1'); $L.Add('')
$L.Add('[Variables]'); $L.Add('Dir='+$dir); $L.Add('')
$L.Add('[MeasureAuto]'); $L.Add('Measure=Calc'); $L.Add('Formula=((MeasureAuto+1)%15)'); $L.Add('IfCondition=(MeasureAuto=0)'); $L.Add('IfTrueAction=["#Dir#\run-export.vbs"]'); $L.Add('')
$L.Add('[MeasureInput]'); $L.Add('Measure=Plugin'); $L.Add('Plugin=InputText'); $L.Add("X=$inX"); $L.Add("Y=$addBarY"); $L.Add("W=$ibW"); $L.Add('H=30'); $L.Add('SolidColor=52,45,39,255'); $L.Add('FontColor=245,245,245,255'); $L.Add("FontFace=$font"); $L.Add("FontSize=$fsTask"); $L.Add('DefaultValue='); $L.Add('Command1=["#Dir#\run-action.vbs" "add" "$UserInput$"]'); $L.Add('')
$L.Add('[MeterBg]'); $L.Add('Meter=Shape'); $L.Add("Shape=Rectangle 0,0,$W,$H,3 | Fill Color 36,31,28,250 | StrokeWidth 1 | Stroke Color 180,159,130,65"); $L.Add('')
# header
$L.Add('[Title]'); $L.Add('Meter=String'); $L.Add("X=$padX"); $L.Add("Y=$headY"); $L.Add("FontFace=$latin"); $L.Add("FontSize=$fsT"); $L.Add('FontWeight=700'); $L.Add('FontColor=255,255,255,255'); $L.Add('AntiAlias=1'); $L.Add('Text=TO DO'); $L.Add('LeftMouseDoubleClickAction=["#Dir#\run-auth.vbs"]'); $L.Add('ToolTipText=Double-click to sign in or switch account'); $L.Add('')
$tipColor=if($tips){'255,255,255,150'}else{'218,153,166,220'}
$L.Add('[BtnTips]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX-72)"); $L.Add("Y=$($headY+1)"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$mdl"); $L.Add("FontSize=$fsB"); $L.Add("FontColor=$tipColor"); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0xE897); $L.Add('LeftMouseUpAction=["#Dir#\run-action.vbs" "tips"]'); $L.Add('ToolTipText=Toggle tooltips'); $L.Add('')
$lockGlyph=if($locked){[char]0xE72E}else{[char]0xE785}; $lockColor=if($locked){'218,153,166,235'}else{'255,255,255,140'}
$L.Add('[BtnLock]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX-48)"); $L.Add("Y=$($headY+1)"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$mdl"); $L.Add("FontSize=$fsB"); $L.Add("FontColor=$lockColor"); $L.Add('AntiAlias=1'); $L.Add('Text='+$lockGlyph); $L.Add('LeftMouseUpAction=["#Dir#\run-action.vbs" "lock"]'); $L.Add('ToolTipText=Lock position and size'); $L.Add('')
$L.Add('[BtnRefresh]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX-24)"); $L.Add("Y=$($headY+1)"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$mdl"); $L.Add("FontSize=$fsB"); $L.Add('FontColor=255,255,255,150'); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0xE72C); $L.Add('LeftMouseUpAction=["#Dir#\run-export.vbs"]'); $L.Add('ToolTipText=Refresh'); $L.Add('')
$L.Add('[BtnClose]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX)"); $L.Add("Y=$($headY+1)"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$mdl"); $L.Add("FontSize=$fsB"); $L.Add('FontColor=255,255,255,150'); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0xE8BB); $L.Add('LeftMouseUpAction=[!DeactivateConfig]'); $L.Add('ToolTipText=Close; reopen using desktop shortcut'); $L.Add('')
# tasks (viewport)
$twid=$W-$padX-70; if($overflow){$twid-=8}
if($total -eq 0){
  $L.Add('[Empty]'); $L.Add('Meter=String'); $L.Add("X=$($W/2)"); $L.Add("Y=$listY"); $L.Add('StringAlign=CenterTop'); $L.Add("FontFace=$font"); $L.Add("FontSize=$fsEmpty"); $L.Add('FontColor=255,255,255,140'); $L.Add('AntiAlias=1'); $L.Add('Text=No pending tasks'); $L.Add('')
} else {
  for($k=0;$k -lt $total;$k++){
    $i=$off+$k; if($i -ge $total){break}
    $t=$sorted[$i]; $y=$listY + $k*$rowH
    $star=if($t.Star){[char]0x2605+' '}else{''}
    $tcolor=if($t.Star){'218,153,166,255'}else{'237,229,213,255'}
    $dcolor=if($t.Near){'226,161,174,255'}else{'192,170,148,230'}
    $tfont=if($t.Title -match '[一-鿿]' -and $t.Title -notmatch '[A-Za-z]'){$cjk}else{$latin}
    $dfont=if($t.Due -match '[一-鿿]' -and $t.Due -notmatch '[A-Za-z]'){$cjk}else{$latin}
    $L.Add("[B$k]"); $L.Add('Meter=String'); $L.Add("X=$padX"); $L.Add("Y=$y"); $L.Add("FontFace=$sym"); $L.Add("FontSize=$fsBul"); $L.Add('FontColor=255,255,255,160'); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0x25CB); $L.Add('LeftMouseUpAction=["#Dir#\run-action.vbs" "complete" "'+$t.ListId+'" "'+$t.TaskId+'"]'); $L.Add("MouseOverAction=[!SetOption B$k Text `"$([char]0x25CF)`"][!UpdateMeter B$k][!Redraw]"); $L.Add("MouseLeaveAction=[!SetOption B$k Text `"$([char]0x25CB)`"][!UpdateMeter B$k][!Redraw]"); if($overflow){$L.Add($scrollU); $L.Add($scrollD)}; $L.Add('ToolTipText=Mark completed'); $L.Add('')
    $L.Add("[T$k]"); $L.Add('Meter=String'); $L.Add("X=$($padX+20)"); $L.Add("Y=$y"); $L.Add("W=$twid"); $L.Add('ClipString=1'); $L.Add("FontFace=$tfont"); $L.Add("FontSize=$fsTask"); $L.Add("FontColor=$tcolor"); $L.Add('AntiAlias=1'); $L.Add('Text='+$star+$t.Title); if($overflow){$L.Add($scrollU); $L.Add($scrollD)}; $L.Add('')
    if($t.Due -ne ''){ $L.Add("[D$k]"); $L.Add('Meter=String'); $L.Add("X=$($W-$padX)"); $L.Add("Y=$y"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$dfont"); $L.Add("FontSize=$fsDue"); $L.Add("FontColor=$dcolor"); $L.Add('AntiAlias=1'); $L.Add('Text='+$t.Due); $L.Add('') }
  }
}
if($overflow){
  $thmH=[Math]::Max(16,[int]($listH*$visN/$total)); $thmY=$listY+[int](($listH-$thmH)*($off/[double]$maxOff))
  $L.Add('[SbTrack]'); $L.Add('Meter=Shape'); $L.Add("Shape=Rectangle $($W-7),$listY,3,$listH,1 | Fill Color 255,255,255,26 | StrokeWidth 0"); $L.Add($scrollU); $L.Add($scrollD); $L.Add('')
  $L.Add('[SbThumb]'); $L.Add('Meter=Shape'); $L.Add("Shape=Rectangle $($W-7),$thmY,3,$thmH,1 | Fill Color 205,205,212,150 | StrokeWidth 0"); $L.Add($scrollU); $L.Add($scrollD); $L.Add('')
}
# add bar (star/cal left, plus right)
$ph='Add task…'; if($pLabel){ $ph=$ph+'   · '+$pLabel }
$starGlyph=if($pImp){[char]0xE735}else{[char]0xE734}; $starColor=if($pImp){'218,153,166,255'}else{'255,255,255,150'}
$calColor=if($pLabel){'218,153,166,255'}else{'255,255,255,150'}
$L.Add('[InputBox]'); $L.Add('Meter=Shape'); $L.Add("Shape=Rectangle $inX,$addBarY,$ibW,26,2 | Fill Color 52,45,39,255 | StrokeWidth 1 | Stroke Color 255,255,255,30"); $L.Add('LeftMouseUpAction=[!CommandMeasure "MeasureInput" "ExecuteBatch 1"]'); $L.Add('ToolTipText=Type a task and press Enter'); $L.Add('')
$L.Add('[Placeholder]'); $L.Add('Meter=String'); $L.Add("X=$($inX+9)"); $L.Add("Y=$($addBarY+8)"); $L.Add("FontFace=$font"); $L.Add("FontSize=$fsPh"); $L.Add('FontColor=200,200,205,170'); $L.Add('AntiAlias=1'); $L.Add('Text='+$ph); $L.Add('LeftMouseUpAction=[!CommandMeasure "MeasureInput" "ExecuteBatch 1"]'); $L.Add('')
$L.Add('[StarBtn]'); $L.Add('Meter=String'); $L.Add("X=$($padX+8)"); $L.Add("Y=$($addBarY+7)"); $L.Add('StringAlign=CenterTop'); $L.Add("FontFace=$mdl"); $L.Add('FontSize=12'); $L.Add("FontColor=$starColor"); $L.Add('AntiAlias=1'); $L.Add('Text='+$starGlyph); $L.Add('LeftMouseUpAction=["#Dir#\run-action.vbs" "togglestar"]'); $L.Add('ToolTipText=Important'); $L.Add('')
$L.Add('[CalBtn]'); $L.Add('Meter=String'); $L.Add("X=$($padX+40)"); $L.Add("Y=$($addBarY+7)"); $L.Add('StringAlign=CenterTop'); $L.Add("FontFace=$mdl"); $L.Add('FontSize=12'); $L.Add("FontColor=$calColor"); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0xE787); $L.Add('LeftMouseUpAction=["#Dir#\run-cal.vbs"]'); $L.Add('RightMouseUpAction=["#Dir#\run-action.vbs" "setdate" ""]'); $L.Add('ToolTipText=Choose date; right-click to clear'); $L.Add('')
$L.Add('[AddBtn]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX-8)"); $L.Add("Y=$($addBarY+7)"); $L.Add('StringAlign=CenterTop'); $L.Add("FontFace=$mdl"); $L.Add('FontSize=13'); $L.Add('FontColor=218,153,166,235'); $L.Add('AntiAlias=1'); $L.Add('Text='+[char]0xE710); $L.Add('LeftMouseUpAction=[!CommandMeasure "MeasureInput" "ExecuteBatch 1"]'); $L.Add('ToolTipText=Add task'); $L.Add('')
# footer: counts + time
$info='Due '+$near+'  Starred '+$impc+'  All '+$total
$L.Add('[Info]'); $L.Add('Meter=String'); $L.Add("X=$padX"); $L.Add("Y=$footY"); $L.Add("FontFace=$font"); $L.Add("FontSize=$fsInfo"); $L.Add('FontColor=255,255,255,150'); $L.Add('AntiAlias=1'); $L.Add('Text='+$info); $L.Add('')
$L.Add('[Upd]'); $L.Add('Meter=String'); $L.Add("X=$($W-$padX)"); $L.Add("Y=$footY"); $L.Add('StringAlign=RightTop'); $L.Add("FontFace=$latin"); $L.Add("FontSize=$fsUpd"); $L.Add('FontColor=255,255,255,90'); $L.Add('AntiAlias=1'); $L.Add('Text='+(Get-Date).ToString('HH:mm')); $L.Add('')
# collapse/expand toggle (bottom-left)
$togGlyph=if($panel){[char]0xE70D}else{[char]0xE76C}
$L.Add('[BtnPanel]'); $L.Add('Meter=String'); $L.Add("X=$padX"); $L.Add("Y=$togY"); $L.Add("FontFace=$mdl"); $L.Add('FontSize=10'); $L.Add('FontColor=200,205,215,190'); $L.Add('AntiAlias=1'); $L.Add('Text='+$togGlyph); $L.Add('LeftMouseUpAction=["#Dir#\run-action.vbs" "panel"]'); $L.Add('ToolTipText=Show or hide controls'); $L.Add('')
# sliders (only when expanded)
if($panel){
  $Tx=$padX+64; $Tw=$W-$Tx-$padX; $thumbR=5
  function Slider($name,$labY,$lab,$frac,$verb){
    $tcy=$labY+8; $thx=[int]($Tx+$frac*$Tw)
    $script:L.Add("[Lb$name]"); $script:L.Add('Meter=String'); $script:L.Add("X=$padX"); $script:L.Add("Y=$($labY+2)"); $script:L.Add("FontFace=$cjk"); $script:L.Add("FontSize=$fsLbl"); $script:L.Add('FontColor=255,255,255,120'); $script:L.Add('AntiAlias=1'); $script:L.Add('Text='+$lab); $script:L.Add('')
    $script:L.Add("[Tk$name]"); $script:L.Add('Meter=Shape'); $script:L.Add("Shape=Rectangle $Tx,$($tcy-1),$Tw,3,1 | Fill Color 255,255,255,45 | StrokeWidth 0"); $script:L.Add('')
    $script:L.Add("[Fl$name]"); $script:L.Add('Meter=Shape'); $script:L.Add("Shape=Rectangle $Tx,$($tcy-1),$($thx-$Tx),3,1 | Fill Color 205,205,210,110 | StrokeWidth 0"); $script:L.Add('')
    $script:L.Add("[Th$name]"); $script:L.Add('Meter=Shape'); $script:L.Add("Shape=Ellipse $thx,$tcy,$thumbR | Fill Color 235,238,245,240 | StrokeWidth 1 | Stroke Color 90,90,100,200"); $script:L.Add('')
    $script:L.Add("[$name]"); $script:L.Add('Meter=Shape'); $script:L.Add("Shape=Rectangle $Tx,$labY,$Tw,16 | Fill Color 0,0,0,1 | StrokeWidth 0")
    if(-not $locked){
      $script:L.Add('LeftMouseDownAction=["#Dir#\run-action.vbs" "set'+$verb+'" "$MouseX$" "'+$Tx+'" "'+$Tw+'"]')
      $script:L.Add('MouseScrollUpAction=["#Dir#\run-action.vbs" "'+$verb+'" "up"]')
      $script:L.Add('MouseScrollDownAction=["#Dir#\run-action.vbs" "'+$verb+'" "down"]')
    }
    $script:L.Add('ToolTipText='+$(if($locked){'Locked'}else{'Click to set; scroll to adjust'})); $script:L.Add('')
  }
  $afrac=($alpha-40)/215.0; if($afrac -lt 0){$afrac=0}; if($afrac -gt 1){$afrac=1}
  $wfrac=($W-240)/220.0; if($wfrac -lt 0){$wfrac=0}; if($wfrac -gt 1){$wfrac=1}
  $hfrac=($vis-3)/17.0; if($hfrac -lt 0){$hfrac=0}; if($hfrac -gt 1){$hfrac=1}
  $ffrac=($fontsz-80)/60.0; if($ffrac -lt 0){$ffrac=0}; if($ffrac -gt 1){$ffrac=1}
  Slider 'SlOpa' $s1 'Opacity' $afrac 'opacity'
  Slider 'SlFnt' $s2 'Font' $ffrac 'font'
  Slider 'SlWid' $s3 'Width' $wfrac 'width'
  Slider 'SlHgt' $s4 'Height' $hfrac 'height'
}

if(-not $tips){ $L=@($L | Where-Object {$_ -notmatch '^ToolTipText='}) }
# Soft paper theme v1
$paper=New-Object System.Collections.Generic.List[string]
$section=''
foreach($line in $L){
    if($line -match '^\[(.+)\]$'){$section=$Matches[1]}
    if($section -in @('Info','Upd','BtnPanel','BtnTips','BtnLock','AddBtn')){continue}

    if($line -match '^FontColor='){
        $line='FontColor=53,53,59,255'
        if($section -match '^D\d+$'){$line='FontColor=134,120,133,255'}
        if($section -eq 'Placeholder'){$line='FontColor=137,135,133,255'}
        if($section -in @('BtnRefresh','BtnClose')){$line='FontColor=145,145,142,255'}
        if($section -eq 'StarBtn'){$line='FontColor=191,139,153,255'}
        if($section -eq 'CalBtn'){$line='FontColor=126,158,174,255'}
        if($section -eq 'AddBtn'){$line='FontColor=130,156,112,255'}
    }

    if($section -eq 'Title'){
        if($line -match '^Text='){$line='Text=𝕋𝕠 𝔻𝕠'}
        if($line -match '^FontFace='){$line='FontFace=Cambria Math'}
        if($line -match '^FontSize='){$line='FontSize=20'}
        if($line -match '^FontWeight='){$line='StringStyle=Normal'}
    }

    if($section -eq 'MeterBg' -and $line -match '^Shape='){
        $line="Shape=Rectangle 0,0,$W,$H,6 | Fill Color 250,246,234,255 | StrokeWidth 0"
    }
    if($section -eq 'InputBox' -and $line -match '^Shape='){
        $line="Shape=Rectangle $inX,$addBarY,$ibW,26,3 | Fill Color 242,236,222,255 | StrokeWidth 0"
    }
    if($section -eq 'MeasureInput' -and $line -match '^SolidColor='){
        $line='SolidColor=242,236,222,255'
    }
    $paper.Add($line)
}
$L=$paper

$colors=@('171,206,223','231,180,189','181,202,151','242,198,148')
$angles=@(-20,15,-12,25)
for($i=0;$i -lt 4;$i++){
    $L.Add("[PaperLeaf$i]")
    $L.Add('Meter=Shape')
    $L.Add("X=$($padX+$i*35)")
    $L.Add('Y=55')
    $L.Add("Shape=Path LeafOutline | Fill Color $($colors[$i]),255 | StrokeWidth 1 | Stroke Color 109,118,112,220 | Rotate $($angles[$i]),16,18 | Scale 0.75,0.75,0,0")
    $L.Add('LeafOutline=2,26 | CurveTo 10,15,8,24,11,20 | CurveTo 8,5,9,12,7,10 | CurveTo 17,12,15,11,15,12 | CurveTo 25,3,21,12,24,8 | CurveTo 23,19,28,10,27,16 | CurveTo 30,19,26,17,28,18 | CurveTo 18,28,26,25,23,27 | CurveTo 17,34,18,30,18,32 | CurveTo 13,26,14,29,14,28 | CurveTo 2,26,9,29,5,28 | ClosePath 1')
    $L.Add("Shape2=Curve 4,29,24,9,16,22,0 | StrokeWidth 1 | Stroke Color 109,118,112,190 | Rotate $($angles[$i]),16,18 | Scale 0.75,0.75,0,0")
    $L.Add('')
}
# Rainbow mention overlay
Add-Type -AssemblyName System.Drawing
$bitmap=New-Object Drawing.Bitmap 1,1
$graphics=[Drawing.Graphics]::FromImage($bitmap)
$font=New-Object Drawing.Font($latin,[single]$fsTask)
$result=New-Object 'System.Collections.Generic.List[string]'
$section='';$label='';$tagWidth=0

try {
foreach($line in $L){
    if($line -match '^\[(.+)\]$'){
        $section=$Matches[1]
        if($section -match '^T(\d+)$'){
            $index=[int]$Matches[1]
            $task=$sorted[$off+$index]
            $label='@'+$task.Title
            $tagWidth=[int][Math]::Min($twid,[Math]::Ceiling($graphics.MeasureString($label,$font).Width)+12)
            $tagHeight=[int][Math]::Ceiling($graphics.MeasureString('Ag',$font).Height)+2
            $result.Add("[MentionBackground$index]")
            $result.Add('Meter=Shape')
            $result.Add("X=$($padX+20)")
            $result.Add("Y=$($listY+$index*$rowH)")
            $result.Add("Shape=Rectangle 0,0,$tagWidth,$tagHeight,4 | Fill Color 221,218,243,80 | StrokeWidth 0")
            if($overflow){$result.Add($scrollU);$result.Add($scrollD)}
            $result.Add('')
        }
    }

    if($section -match '^PaperLeaf\d+$' -or $section -in @('PosterKicker','PosterRule','Info','Upd','BtnPanel','BtnTips','BtnLock','AddBtn')){continue}

    if($section -eq 'MeterBg' -and $line -match '^Shape='){
        $result.Add("Shape=Rectangle 0,0,$W,$H,8 | Fill LinearGradient FlagBlend | StrokeWidth 0")
        $result.Add('FlagBlend=270 | 213,133,170,255 ; 0.0 | 227,159,195,255 ; 0.08 | 220,204,237,255 ; 0.25 | 151,184,234,255 ; 0.60 | 151,145,204,96 ; 1.0')
        continue
    }

    if($line -match '^FontColor='){
        $line='FontColor=53,53,59,255'
        if($section -match '^T\d+$'){$line='FontColor=66,68,143,255'}
        if($section -match '^D\d+$'){$line='FontColor=82,77,103,255'}
        if($section -in @('Placeholder','BtnRefresh','BtnClose')){$line='FontColor=143,140,148,255'}
    }

    if($section -match '^T\d+$'){
        if($line -match '^Text='){$line='Text='+$label}
        if($line -match '^W='){$line='W='+[Math]::Max(8,$tagWidth-8)}
        if($line -eq 'Meter=String'){
            $result.Add($line);$result.Add('Padding=4,1,4,1');continue
        }
    }

    if($section -eq 'Title'){
        # Soft white title v1
        if($line -match '^FontColor='){
            $line='FontColor=255,250,253,245'
        }
        if($line -eq 'Meter=String'){
            $result.Add('StringEffect=Shadow')
            $result.Add('FontEffectColor=100,76,123,90')
        }

        if($line -match '^Text='){$line='Text=𝕋𝕠 𝔻𝕠'}
        if($line -match '^FontFace='){$line='FontFace=Cambria Math'}
        if($line -match '^FontSize='){$line='FontSize=20'}
        if($line -match '^FontWeight=|^StringStyle='){$line='StringStyle=Normal'}
    }

    if($section -eq 'InputBox' -and $line -match '^Shape='){
        $line="Shape=Rectangle $inX,$addBarY,$ibW,30,4 | Fill Color 255,255,255,80 | StrokeWidth 0"
    }
    if($section -eq 'MeasureInput' -and $line -match '^SolidColor='){
        $line='SolidColor=245,241,240,255'
    }
    # Iceberg blue star
    if($section -eq 'StarBtn' -and $line -match '^FontColor='){
        $line='FontColor=141,232,255,255'
    }
    # Champagne calendar
    if($section -eq 'CalBtn' -and $line -match '^FontColor='){
        $line='FontColor=255,230,163,255'
    }
    # Larger input icons
    if($section -in @('StarBtn','CalBtn')){
        if($line -match '^FontSize='){$line='FontSize=15'}
        if($line -match '^Y='){$line="Y=$($addBarY+5)"}
    }
    $result.Add($line)
}
} finally {
    $font.Dispose();$graphics.Dispose();$bitmap.Dispose()
}

$L=$result
$L.Add('[ReferenceLeaves]')
$L.Add('Meter=Image')
$L.Add('ImageName='+(Join-Path $dir 'soft-rainbow-leaves.png'))
$L.Add("X=$padX")
$L.Add('Y=41')
$L.Add('W=148')
$L.Add('H=49')
$L.Add('PreserveAspectRatio=1')
$L.Add('')
$L.Add('[NickCharlie]')
$L.Add('Meter=Image')
$L.Add('ImageName='+(Join-Path $dir 'nick-charlie.png'))
$L.Add("X=$($W-$padX-154)")
$L.Add('Y=12')
$L.Add('W=120')
$L.Add('H=80')
$L.Add('PreserveAspectRatio=1')
$L.Add('')
# Scattered leaves v1
Add-Type -AssemblyName System.Drawing
$leafPath=Join-Path $dir 'soft-rainbow-leaves.png'
$leafImage=[Drawing.Image]::FromFile($leafPath)
try {
    $imgW=$leafImage.Width
    $imgH=$leafImage.Height
} finally {
    $leafImage.Dispose()
}

$placements=@(
    @(0,145,6,13,18,-20),
    @(1,123,14,11,16,12),
    @(2,163,30,19,25,20),
    @(3,($W-33),69,16,21,-15),
    @(1,($W-55),39,11,16,-15),
    @(0,($W-29),13,15,21,20),
    @(1,175,70,11,16,10),
    @(2,($W-52),82,12,16,-15),
    @(3,($W*0.58),8,11,15,25),
    @(0,($W*0.70),28,20,27,-12),
    @(1,($W*0.82),9,12,17,18),
    @(2,($W*0.55),48,14,19,-25),
    @(3,($W*0.78),65,18,24,12),
    @(0,($W*0.63),83,10,14,-18),
    @(1,($W*0.46),96,10,14,15),
    @(2,($W*0.86),99,10,14,-10)
)

$placements += @(
    @(0,23,37,8,11,-25),
    @(1,72,35,8,11,15),
    @(2,119,33,9,12,-12),
    @(3,168,40,8,11,22),
    @(1,35,104,8,11,-18),
    @(2,78,100,8,11,25),
    @(0,128,108,7,10,-15),
    @(3,165,102,9,12,15)
)
for($i=0;$i -lt $placements.Count;$i++){
    $item=$placements[$i]
    $cropX=[int][Math]::Floor($imgW*$item[0]/4)
    $cropEnd=[int][Math]::Floor($imgW*($item[0]+1)/4)
    $cropW=$cropEnd-$cropX
    $cropY=0;$cropH=$imgH
    if($item[0] -eq 1){
        $cropX=[int]($imgW*0.315)
        $cropY=[int]($imgH*0.17)
        $cropW=[int]($imgW*0.145)
        $cropH=[int]($imgH*0.75)
    }

    $L.Add("[ScatterLeaf$i]")
    $L.Add('Meter=Image')
    $L.Add('ImageName='+$leafPath)
    $L.Add("ImageCrop=$cropX,$cropY,$cropW,$cropH,1")
    $L.Add("X=$($item[1])")
    $L.Add("Y=$($item[2])")
    $L.Add("W=$($item[3])")
    $L.Add("H=$($item[4])")
    $L.Add("ImageRotate=$($item[5])")
    $L.Add('PreserveAspectRatio=1')
    $L.Add('')
}
# Live scrolling v1
$liveLines=New-Object 'System.Collections.Generic.List[string]'
$liveSection='';$viewportAdded=$false
foreach($liveLine in $L){
    if($liveLine -match '^\[(.+)\]$'){$liveSection=$Matches[1]}
    $isTaskRow=$liveSection -match '^(?:B|T|D|MentionBackground)(\d+)$'
    if($isTaskRow){$liveIndex=[int]$Matches[1]}

    if($isTaskRow -and !$viewportAdded){
        $liveLines.Add('[TaskViewport]')
        $liveLines.Add('Meter=Shape')
        $liveLines.Add('X=0')
        $liveLines.Add("Y=$listY")
        $liveLines.Add("W=$($W-12)")
        $liveLines.Add("H=$listH")
        $liveLines.Add("Shape=Rectangle 0,0,$($W-12),$listH | Fill Color 255,255,255,255 | StrokeWidth 0")
        $liveLines.Add($scrollU)
        $liveLines.Add($scrollD)
        $liveLines.Add('')
        $viewportAdded=$true
    }

    if($isTaskRow -and $liveLine -match '^(Y|Container|Group|DynamicVariables)='){
        continue
    }
    if($liveSection -eq 'SbThumb' -and $liveLine -match '^Y='){
        $liveLine="Y=($listY+(($listH-$thmH)*#ListOffset#/$maxOff))"
    }
    if($liveSection -eq 'SbThumb' -and $liveLine -match '^Shape='){
        $liveLine="Shape=Rectangle 0,0,3,$thmH,1 | Fill Color 205,205,212,150 | StrokeWidth 0"
    }

    $liveLines.Add($liveLine)

    if($liveLine -eq '[Rainmeter]'){
        $liveLines.Add("SkinWidth=$W")
        $liveLines.Add("SkinHeight=$H")
    }
    if($liveLine -eq '[Variables]'){
        $liveLines.Add('ListOffset=0')
        $liveLines.Add("LiveTaskCount=$total")
        $liveLines.Add("LiveVisibleRows=$visN")
    }
    if($isTaskRow -and $liveLine -match '^Meter='){
        $liveLines.Add('Container=TaskViewport')
        $liveLines.Add('Group=LiveTaskRows')
        $liveLines.Add('DynamicVariables=1')
        $liveLines.Add("Y=(($liveIndex-#ListOffset#)*$rowH)")
        if($liveSection -match '^D\d+$'){
            $liveLines.Add($scrollU)
            $liveLines.Add($scrollD)
        }
    }
    if($liveSection -eq 'SbThumb' -and $liveLine -match '^Meter='){
        $liveLines.Add('Group=LiveScrollbar')
        $liveLines.Add('DynamicVariables=1')
        $liveLines.Add("X=$($W-7)")
        $liveLines.Add("Y=($listY+(($listH-$thmH)*#ListOffset#/$maxOff))")
    }
    if($liveSection -eq 'MeterBg' -and $liveLine -match '^Meter='){
        $liveLines.Add($scrollU)
        $liveLines.Add($scrollD)
    }
}
$liveLines.Add('[WidgetScroll]')
$liveLines.Add('Measure=Script')
$liveLines.Add('ScriptFile='+(Join-Path $dir 'widget-scroll.lua'))
$liveLines.Add('UpdateDivider=-1')
$liveLines.Add('')
$L=$liveLines
if(!($L -match '^Meter=')){
    throw 'Refusing to save a skin without meters.'
}
# Pastel scrollbar v1
$sidebarLines=New-Object 'System.Collections.Generic.List[string]'
$sidebarSection=''
foreach($sidebarLine in $L){
    if($sidebarLine -match '^\[(.+)\]$'){$sidebarSection=$Matches[1]}
    if($sidebarSection -in @('SbTrack','SbThumb')){
        if($sidebarLine -match '^(X|W|H|Shape|LeftMouseDownAction|MouseActionCursor|ToolTipText)='){
            continue
        }
    }
    $sidebarLines.Add($sidebarLine)

    if($sidebarSection -eq 'SbTrack' -and $sidebarLine -eq 'Meter=Shape'){
        $sidebarLines.Add("X=$($W-10)")
        $sidebarLines.Add("Y=$listY")
        $sidebarLines.Add('W=7')
        $sidebarLines.Add("H=$listH")
        $sidebarLines.Add("Shape=Rectangle 0,0,7,$listH,3 | Fill Color 221,218,243,35 | StrokeWidth 0")
        $sidebarLines.Add('LeftMouseDownAction=[!CommandMeasure WidgetScroll "Jump($MouseY$)"]')
        $sidebarLines.Add('MouseActionCursor=1')
        $sidebarLines.Add('ToolTipText=Click the track to jump')
    }
    if($sidebarSection -eq 'SbThumb' -and $sidebarLine -eq 'Meter=Shape'){
        $sidebarLines.Add("X=$($W-10)")
        $sidebarLines.Add('W=7')
        $sidebarLines.Add("H=$thmH")
        $sidebarLines.Add("Shape=Rectangle 0,0,7,$thmH,3 | Fill Color 221,218,243,80 | StrokeWidth 0")
        $sidebarLines.Add('LeftMouseDownAction=[!CommandMeasure WidgetScroll "Scroll(0)"]')
        $sidebarLines.Add('ToolTipText=Use the wheel or click the track')
    }
}
$L=$sidebarLines
# Pinned faded card v1
$cardLines=New-Object 'System.Collections.Generic.List[string]'
$cardSection=''
foreach($cardLine in $L){
    if($cardLine -match '^\[(.+)\]$'){$cardSection=$Matches[1]}
    if($cardSection -ne 'NickCharlie'){$cardLines.Add($cardLine)}
}
$L=$cardLines
# White card and auto sync v2
$whiteLines = New-Object 'System.Collections.Generic.List[string]'
$whiteSection = ''
foreach ($whiteLine in $L) {
    if ($whiteLine -match '^\[(.+)\]$') {
        $whiteSection = $Matches[1]
    }
    if ($whiteSection -in @('NickCharlie','BtnClose','BtnRefresh')) {
        continue
    }
    if ($whiteSection -eq 'MeterBg') {
        if ($whiteLine -match '^FlagBlend=') {
            continue
        }
        if ($whiteLine -match '^Shape=') {
            $whiteLine = "Shape=Rectangle 1,1,$($W-2),$($H-2),8 | Fill Color 255,255,255,51 | StrokeWidth 1.3 | Stroke Color 255,255,255,102 | StrokeDashes 4,3"
        }
    }
    $whiteLines.Add($whiteLine)
}
$L = $whiteLines
# Blue leaf styling v1
$bluePalette=@('145,221,255','92,180,239','175,203,240','102,208,226','205,239,255','64,139,214','139,163,228','174,226,235','111,197,255','192,211,248','76,166,190','124,149,199')
$blueLines=New-Object 'System.Collections.Generic.List[string]'
$blueSection=''
foreach($blueLine in $L){
    if($blueLine -match '^\[(.+)\]$'){
        $blueSection=$Matches[1]
    }
    if($blueSection -eq 'ReferenceLeaves'){continue}
    if($blueSection -match '^ScatterLeaf(\d+)$'){
        $blueIndex=[int]$Matches[1] % $bluePalette.Count
        if($blueLine -match '^Image(?:Tint|Greyscale)='){continue}
        $blueLines.Add($blueLine)
        if($blueLine -eq 'Meter=Image'){
            $blueLines.Add('Greyscale=1')
            $blueLines.Add('ImageTint='+$bluePalette[$blueIndex])
        }
        continue
    }
    if($blueSection -eq 'MeterBg' -and $blueLine -match '^Shape='){
        $blueLine=$blueLine.Replace('StrokeWidth 1.3','StrokeWidth 2.5').Replace('StrokeDashes 4,3','StrokeDashes 9,5')
    }
    $blueLines.Add($blueLine)
}
# Mixed main leaves v1
$blueMain=@(
    @(22,50,36,48),
    @(65,57,23,31),
    @(94,44,43,57),
    @(143,54,32,43)
)
for($blueN=0;$blueN -lt 4;$blueN++){
    $blueX=[int][Math]::Floor($imgW*$blueN/4)
    $blueEnd=[int][Math]::Floor($imgW*($blueN+1)/4)
    $blueLines.Add("[BlueReferenceLeaf$blueN]")
    $blueLines.Add('Meter=Image')
    $blueLines.Add('ImageName='+$leafPath)
    $blueLines.Add("ImageCrop=$blueX,0,$($blueEnd-$blueX),$imgH,1")
    $blueLines.Add('Greyscale=1')
    $blueLines.Add('ImageTint='+$bluePalette[$blueN])
    $blueLines.Add("X=$($blueMain[$blueN][0])")
    $blueLines.Add("Y=$($blueMain[$blueN][1])")
    $blueLines.Add("W=$($blueMain[$blueN][2])")
    $blueLines.Add("H=$($blueMain[$blueN][3])")
    $blueLines.Add('PreserveAspectRatio=1')
    $blueLines.Add('')
}
$L=$blueLines
# White calendar blue garden v1
$calendarLines=New-Object 'System.Collections.Generic.List[string]'
$calendarSection=''
foreach($calendarLine in $L){
    if($calendarLine -match '^\[(.+)\]$'){
        $calendarSection=$Matches[1]
    }
    if($calendarSection -eq 'CalBtn' -and $calendarLine -match '^FontColor='){
        $calendarLine='FontColor=255,255,255,255'
    }
    $calendarLines.Add($calendarLine)
}
$L=$calendarLines
# Fully mixed blue leaves v1
$mixedLines=New-Object 'System.Collections.Generic.List[string]'
$mixedSection=''
foreach($mixedLine in $L){
    if($mixedLine -match '^\[(.+)\]$'){
        $mixedSection=$Matches[1]
    }
    if($mixedSection -match '^(ReferenceLeaves|ScatterLeaf\d+|BlueReferenceLeaf\d+)$'){
        continue
    }
    $mixedLines.Add($mixedLine)
}
$mixedPalette=@(
    '170,210,255',
    '125,185,255',
    '255,255,100',
    '150,200,255',
    '190,220,255',
    '255,255,145',
    '105,170,250',
    '80,140,220',
    '160,205,255',
    '255,255,80',
    '140,190,255',
    '180,215,255',
    '255,255,165',
    '115,180,255'
)
$mixedPositions=@(
    @(0,20,61,35,-32),
    @(1,72,54,27,24),
    @(3,112,75,31,-26),
    @(2,160,8,21,32),
    @(0,171,60,36,-19),
    @(1,215,17,24,28),
    @(3,258,51,40,-31),
    @(2,304,9,25,18),
    @(0,321,67,26,27),
    @(2,59,101,14,-28),
    @(3,143,40,16,35),
    @(1,218,88,20,-24),
    @(0,278,104,12,32),
    @(2,102,41,14,-18)
)
for($mixedI=0;$mixedI -lt $mixedPositions.Count;$mixedI++){
    $p=$mixedPositions[$mixedI]
    $cropX=[int][Math]::Floor($imgW*$p[0]/4)
    $cropEnd=[int][Math]::Floor($imgW*($p[0]+1)/4)
    $cropW=$cropEnd-$cropX
    $cropY=0
    $cropH=$imgH
    if($p[0] -eq 1){
        $cropX=[int]($imgW*0.315)
        $cropY=[int]($imgH*0.17)
        $cropW=[int]($imgW*0.145)
        $cropH=[int]($imgH*0.75)
    }
    $mixedX=[int]($p[1]*$W/360)
    $mixedH=[int][Math]::Round($p[3]*1.32)
    $mixedLines.Add("[MixedBlueLeaf$mixedI]")
    $mixedLines.Add('Meter=Image')
    $mixedLines.Add('ImageName='+$leafPath)
    $mixedLines.Add("ImageCrop=$cropX,$cropY,$cropW,$cropH,1")
    $mixedLines.Add('Greyscale=1')
    $mixedLines.Add('ImageTint='+$mixedPalette[$mixedI % $mixedPalette.Count])
    $mixedLines.Add("X=$mixedX")
    $mixedLines.Add("Y=$($p[2])")
    $mixedLines.Add("W=$($p[3])")
    $mixedLines.Add("H=$mixedH")
    $mixedLines.Add("ImageRotate=$($p[4])")
    $mixedLines.Add('PreserveAspectRatio=1')
    $mixedLines.Add('')
}
$L=$mixedLines
# Direct smooth scrolling v1
$smoothLines=New-Object 'System.Collections.Generic.List[string]'
$smoothSection=''
foreach($smoothLine in $L){
    if($smoothLine -match '^\[(.+)\]$'){
        $smoothSection=$Matches[1]
    }
    if($smoothSection -eq 'SoftScrollTimer'){continue}
    if($smoothLine -match '^UpdateDivider='){continue}
    if($smoothSection -eq 'Rainmeter' -and $smoothLine -match '^Update='){
        $smoothLine='Update=20'
    }
    $smoothLines.Add($smoothLine)
    if($smoothLine -match '^Measure='){
        if($smoothSection -eq 'WidgetScroll'){
            $smoothLines.Add('UpdateDivider=1')
        }else{
            $smoothLines.Add('UpdateDivider=50')
        }
    }
    if($smoothLine -match '^Meter='){
        $smoothLines.Add('UpdateDivider=-1')
    }
}
$L=$smoothLines
# Random blue dates v1
$dateBlues=@(
    '85,145,225','105,165,240','125,185,250','145,195,250',
    '100,150,225','115,175,245','155,205,255','80,145,215',
    '135,180,240','95,165,235','165,210,255','120,160,220',
    '140,200,255','105,180,250'
)
$dateBlues=@($dateBlues | Get-Random -Count $dateBlues.Count)
$dateBlueIndex=0
$dateLines=New-Object 'System.Collections.Generic.List[string]'
$dateSection=''
$dateBlue=''
foreach($dateLine in $L){
    if($dateLine -match '^\[(.+)\]$'){
        $dateSection=$Matches[1]
        if($dateSection -match '^D\d+$'){
            $dateBlue=$dateBlues[$dateBlueIndex % $dateBlues.Count];$dateBlueIndex++
        }
    }
    if($dateSection -match '^D\d+$' -and $dateLine -match '^FontColor='){
        $dateLine="FontColor=$dateBlue,255"
    }
    $dateLines.Add($dateLine)
}
$L=$dateLines
# Draggable scrollbar v1
$dragLines=New-Object 'System.Collections.Generic.List[string]'
$dragSection=''
foreach($dragLine in $L){
    if($dragLine -match '^\[(.+)\]$'){
        $dragSection=$Matches[1]
    }
    if($dragSection -eq 'SbThumb'){
        if($dragLine -match '^(LeftMouseDownAction|LeftMouseUpAction|MouseActionCursor|ToolTipText)='){
            continue
        }
    }
    $dragLines.Add($dragLine)
    if($dragSection -eq 'SbThumb' -and $dragLine -eq 'Meter=Shape'){
        $dragLines.Add('LeftMouseDownAction=[!CommandMeasure WidgetScroll "BeginDrag()"]["#Dir#\widget-scroll-drag.exe" "#CURRENTCONFIGY#" "[SbThumb:Y]" "$MouseY$"]')
        $dragLines.Add('MouseActionCursor=1')
        $dragLines.Add('ToolTipText=Drag to scroll')
    }
}
$L=$dragLines
# Scrollbar inset v2
$barLines=New-Object 'System.Collections.Generic.List[string]'
$barSection=''
foreach($barLine in $L){
    if($barLine -match '^\[(.+)\]$'){
        $barSection=$Matches[1]
    }
    if($barSection -in @('SbTrack','SbThumb')){
        if($barLine -match '^X='){continue}
        $barLines.Add($barLine)
        if($barLine -eq 'Meter=Shape'){
            $barLines.Add("X=$($W-25)")
        }
    }else{
        $barLines.Add($barLine)
    }
}
$L=$barLines
# Date scrollbar spacing v1
$spacingLines=New-Object 'System.Collections.Generic.List[string]'
$spacingSection=''
foreach($spacingLine in $L){
    if($spacingLine -match '^\[(.+)\]$'){
        $spacingSection=$Matches[1]
    }
    if($spacingSection -match '^D\d+$'){
        if($spacingLine -match '^(X|StringAlign)='){continue}
        $spacingLines.Add($spacingLine)
        if($spacingLine -eq 'Meter=String'){
            $spacingLines.Add("X=$($W-39)")
            $spacingLines.Add('StringAlign=RightTop')
        }
    }else{
        $spacingLines.Add($spacingLine)
    }
}
$L=$spacingLines
# Bright pink overdue dates v1
$overduePinks=@(
    '244,91,140','235,106,147','245,125,160',
    '229,99,139','239,135,165','235,116,155'
)
$pinkSections=@{}
$pinkSection=''
foreach($pinkLine in $L){
    if($pinkLine -match '^\[(.+)\]$'){
        $pinkSection=$Matches[1]
    }
    if($pinkSection -match '^D\d+$' -and $pinkLine -match '^Text=.*Overdue'){
        $pinkSections[$pinkSection]=$true
    }
}
$pinkLines=New-Object 'System.Collections.Generic.List[string]'
$pinkSection=''
foreach($pinkLine in $L){
    if($pinkLine -match '^\[(.+)\]$'){
        $pinkSection=$Matches[1]
    }
    if($pinkSections.ContainsKey($pinkSection) -and $pinkLine -match '^FontColor='){
        $pinkLine="FontColor=$($overduePinks[(Get-Random -Minimum 0 -Maximum $overduePinks.Count)]),255"
    }
    $pinkLines.Add($pinkLine)
}
$L=$pinkLines
# Native desktop margin v2
Add-Type -AssemblyName System.Windows.Forms
$edgeScreen=[Windows.Forms.Screen]::PrimaryScreen
$edgeSettings=$widgetPaths.RainmeterIni
if(Test-Path -LiteralPath $edgeSettings){
    $edgeIni=[IO.File]::ReadAllText($edgeSettings)
    $edgeMatch=[regex]::Match(
        $edgeIni,'(?ms)^\[ToDo\]\s*\r?\n(?<body>.*?)(?=^\[|\z)'
    )
    if($edgeMatch.Success){
        $edgeX=[regex]::Match(
            $edgeMatch.Groups['body'].Value,'(?m)^WindowX=(-?\d+)\s*$'
        )
        $edgeY=[regex]::Match(
            $edgeMatch.Groups['body'].Value,'(?m)^WindowY=(-?\d+)\s*$'
        )
        if($edgeX.Success -and $edgeY.Success){
            $edgePoint=New-Object Drawing.Point -ArgumentList (
                [int]$edgeX.Groups[1].Value+[int]($W/2)
            ),(
                [int]$edgeY.Groups[1].Value+[int]($H/2)
            )
            $edgeScreen=[Windows.Forms.Screen]::FromPoint($edgePoint)
        }
    }
}
$edgeLeft=20+[Math]::Max(0,$edgeScreen.WorkingArea.Left-$edgeScreen.Bounds.Left)
$edgeTop=20+[Math]::Max(0,$edgeScreen.WorkingArea.Top-$edgeScreen.Bounds.Top)
$edgeRight=20+[Math]::Max(0,$edgeScreen.Bounds.Right-$edgeScreen.WorkingArea.Right)
$edgeBottom=20+[Math]::Max(0,$edgeScreen.Bounds.Bottom-$edgeScreen.WorkingArea.Bottom)

$edgeSections=@{}
$edgeSection=''
foreach($edgeLine in $L){
    if($edgeLine -match '^\[(.+)\]$'){
        $edgeSection=$Matches[1]
        $edgeSections[$edgeSection]=@{
            Meter=$false;Child=$false;Input=$false;X='0';Y='0'
        }
    }
    if(!$edgeSections.ContainsKey($edgeSection)){continue}
    $edgeData=$edgeSections[$edgeSection]
    if($edgeLine -match '^Meter='){$edgeData.Meter=$true}
    if($edgeLine -match '^Container='){$edgeData.Child=$true}
    if($edgeSection -eq 'MeasureInput'){$edgeData.Input=$true}
    if($edgeLine -match '^(X|Y)=(.*)$'){
        $edgeData[$Matches[1]]=$Matches[2]
    }
}
$edgeLines=New-Object 'System.Collections.Generic.List[string]'
$edgeSection=''
foreach($edgeLine in $L){
    if($edgeLine -match '^\[(.+)\]$'){$edgeSection=$Matches[1]}
    $edgeData=$edgeSections[$edgeSection]
    if($edgeSection -eq 'Rainmeter'){
        if($edgeLine -match '^SkinWidth='){
            $edgeLine="SkinWidth=$($W+$edgeLeft+$edgeRight)"
        }
        if($edgeLine -match '^SkinHeight='){
            $edgeLine="SkinHeight=$($H+$edgeTop+$edgeBottom)"
        }
    }
    $edgeShift=$edgeData -and !$edgeData.Child -and (
        $edgeData.Meter -or $edgeData.Input
    )
    if($edgeShift -and $edgeLine -match '^(X|Y)='){continue}
    $edgeLines.Add($edgeLine)
    if($edgeShift -and $edgeLine -match '^(Meter|Measure)='){
        $edgeLines.Add("X=($($edgeData.X)+$edgeLeft)")
        $edgeLines.Add("Y=($($edgeData.Y)+$edgeTop)")
    }
}
$L=$edgeLines
# Drag-only scrollbar v2
$dragOnlyLines=New-Object 'System.Collections.Generic.List[string]'
$dragOnlySection=''
foreach($dragOnlyLine in $L){
    if($dragOnlyLine -match '^\[(.+)\]$'){
        $dragOnlySection=$Matches[1]
    }
    if($dragOnlySection -in @('SbTrack','SbThumb')){
        if($dragOnlyLine -match '^(LeftMouseDownAction|LeftMouseUpAction|DynamicVariables|MouseActionCursor|ToolTipText)='){
            continue
        }
    }
    $dragOnlyLines.Add($dragOnlyLine)
    if($dragOnlySection -in @('SbTrack','SbThumb') -and $dragOnlyLine -eq 'Meter=Shape'){
        $dragOnlyLines.Add('DynamicVariables=1')
        $dragOnlyLines.Add(
            ('LeftMouseDownAction=[!CommandMeasure WidgetScroll "BeginDrag()"]["#Dir#\widget-scroll-drag.exe" "#CURRENTCONFIGY#" "[{0}:Y]" "$MouseY$"]' -f $dragOnlySection)
        )
        $dragOnlyLines.Add('LeftMouseUpAction=[!CommandMeasure WidgetScroll "EndDrag()"]')
        $dragOnlyLines.Add('MouseActionCursor=1')
        $dragOnlyLines.Add('ToolTipText=Hold and drag to scroll')
    }
}
$L=$dragOnlyLines
# Direct mouse drag v3
$mouseDragLines=New-Object 'System.Collections.Generic.List[string]'
$mouseDragSection=''
foreach($mouseDragLine in $L){
    if($mouseDragLine -match '^\[(.+)\]$'){
        $mouseDragSection=$Matches[1]
    }
    if($mouseDragSection -in @('SbTrack','SbThumb')){
        if($mouseDragLine -match '^(LeftMouseDownAction|LeftMouseUpAction|DynamicVariables|MouseActionCursor|ToolTipText)='){
            continue
        }
    }
    $mouseDragLines.Add($mouseDragLine)
    if($mouseDragSection -in @('SbTrack','SbThumb') -and $mouseDragLine -eq 'Meter=Shape'){
        $mouseDragLines.Add('DynamicVariables=1')
        $mouseDragLines.Add('LeftMouseDownAction=["#Dir#\widget-scroll-drag-v2.exe"]')
        $mouseDragLines.Add('MouseActionCursor=1')
        $mouseDragLines.Add('ToolTipText=Hold and drag to scroll')
    }
}
$L=$mouseDragLines
# Confirmed unload menu v1
$unloadLines=New-Object 'System.Collections.Generic.List[string]'
$unloadSection=''
foreach($unloadLine in $L){
    if($unloadLine -match '^\[(.+)\]$'){
        $unloadSection=$Matches[1]
    }
    if($unloadSection -eq 'Rainmeter' -and $unloadLine -match '^RightMouseUpAction='){
        continue
    }
    $unloadLines.Add($unloadLine)
    if($unloadLine -eq '[Rainmeter]'){
        $unloadLines.Add('RightMouseUpAction=[!SkinCustomMenu]')
        $unloadLines.Add('ContextTitle=Unload (confirm twice)')
        $unloadLines.Add('ContextAction=["#Dir#\confirm-unload.vbs"]')
        $unloadLines.Add('ContextTitle2=Manage widget')
        $unloadLines.Add('ContextAction2=[!Manage "Skins" "ToDo"]')
    }
}
$L=$unloadLines
# Soft overdue mentions v2
$softOverdue=@{}
$softSection=''
foreach($softLine in $L){
    if($softLine -match '^\[(.+)\]$'){
        $softSection=$Matches[1]
    }
    if($softSection -match '^D\d+$' -and $softLine -match '^Text=.*Overdue'){
        $softOverdue[$softSection]=$true
    }
}
$softDatePinks=@(
    '195,113,142','207,128,151','190,105,135',
    '212,137,159','199,120,147','204,130,155'
)
$softLines=New-Object 'System.Collections.Generic.List[string]'
$softSection=''
foreach($softLine in $L){
    if($softLine -match '^\[(.+)\]$'){
        $softSection=$Matches[1]
    }
    if($softSection -match '^(T|D)(\d+)$'){
        $softKind=$Matches[1]
        $softKey='D'+$Matches[2]
        if($softOverdue.ContainsKey($softKey) -and $softLine -match '^FontColor='){
            if($softKind -eq 'T'){
                $softLine='FontColor=226,153,179,255'
            }else{
                $softColor=$softDatePinks[
                    (Get-Random -Minimum 0 -Maximum $softDatePinks.Count)
                ]
                $softLine="FontColor=$softColor,255"
            }
        }
    }
    $softLines.Add($softLine)
}
$L=$softLines
# Atomic skin save v1
$skinFile=Join-Path $skinDir 'ToDo.ini'
$temporarySkin=Join-Path $skinDir ('ToDo-'+[guid]::NewGuid().ToString('N')+'.tmp')
try{
    [IO.File]::WriteAllText($temporarySkin,($L -join "`r`n"),[Text.Encoding]::Unicode)
    for($attempt=0;$attempt -lt 5;$attempt++){
        try{
            if([IO.File]::Exists($skinFile)){
                [IO.File]::Replace($temporarySkin,$skinFile,[NullString]::Value)
            }else{
                [IO.File]::Move($temporarySkin,$skinFile)
            }
            break
        }catch [IO.IOException]{
            if($attempt -eq 4){throw}
            Start-Sleep -Milliseconds 50
        }
    }
}finally{
    if([IO.File]::Exists($temporarySkin)){
        [IO.File]::Delete($temporarySkin)
    }
}
if(Test-Path $rmExe){ & $rmExe '!Refresh' 'ToDo' 2>$null }
Write-Output ('rendered total='+$total+' vis='+$visN+' off='+$off+' panel='+$panel+' font='+$fontsz+' (w='+$W+' a='+$alpha+' lk='+$locked+')')

