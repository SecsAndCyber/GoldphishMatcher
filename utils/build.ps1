$godotPath = "D:\Program Files\Godot\4.3\godot_console.exe"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDir = "$scriptDir\.." | Convert-Path

$exportHtml5Dir = "$rootDir\exports\HTML5"
if (Test-Path $exportHtml5Dir) {
    Remove-Item "$exportHtml5Dir\*" -Recurse -Force
}

$exportWindowsDir = "$rootDir\exports\Windows"
if (Test-Path $exportWindowsDir) {
    Remove-Item "$exportWindowsDir\*" -Recurse -Force
}

$exportAndroidDir = "$rootDir\exports\Android"
if (Test-Path $exportAndroidDir) {
    Remove-Item "$exportAndroidDir\*" -Recurse -Force
}

Write-Output "Starting the build process... $rootDir"
& $godotPath --editor --path $rootDir --export-release "Web" $exportHtml5Dir\index.html
& $godotPath --editor --path $rootDir --export-release "Windows Desktop" $exportWindowsDir\GoldphishMatcher.exe
& $godotPath --editor --path $rootDir --export-release "Android" $exportAndroidDir\GoldphishMatcher.aab