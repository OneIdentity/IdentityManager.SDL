#Requires -RunAsAdministrator

Param(
  [string]$delivery,
  [string]$destination = "."
)

$ErrorActionPreference = 'Stop'

if ( ! $delivery ){
    Write-Error "You have to provide a delivery folder as source."
    exit 1
}

$installmgr = Join-Path $delivery "Setup\InstallManager.Cli.exe"

if ( ! (Test-Path $installmgr ) ) {
    Write-Error "The installer under $installmgr does not exist. Please provide a valid delivery folder."
    exit 1
}

$mdkpath = Join-Path $delivery "Modules\MDK"
if ( ! (Test-Path $mdkpath ) ) {
    Write-Error "The delivery folder does not contain the MDK module."
    exit 1
}

$destination = Join-Path $PSScriptRoot $destination -Resolve

Write-Output "Preparing folder $destination with files from $delivery."

Write-Output "Copying binaries to Assemblies..."
& "$installmgr" --mode CopyInstall --rootpath "$delivery" --installpath "$destination\Assemblies" --filesonly --module LDP APC ADS RMB MDK --deploymenttarget API Client Server Server\Jobserver Client\Administration Client\DevelopmentAndTesting Client\Configuration >$null

Write-Output "Initializing Modules folder for master migration..."

# Remove existing link to avoid overwriting of files
if ([IO.Directory]::Exists("$destination\Modules\SDL")) {
    [IO.Directory]::Delete("$destination\Modules\SDL", $true)
}

Copy-Item -Path "$delivery\Modules"  -Destination "$destination" -Recurse -Force

Write-Output "Copying MDK files..."
if ([IO.Directory]::Exists("$destination\Modules\QBM\Database\MSSQL\MDK")) {
    [IO.Directory]::Delete("$destination\Modules\QBM\Database\MSSQL\MDK", $true)
}
Copy-Item -Path "$destination\Modules\MDK\Database\MSSQL"	-Destination "$destination\Modules\QBM\Database\MSSQL" -Recurse -Force
Rename-Item -Path "$destination\Modules\QBM\Database\MSSQL\MSSQL" -NewName "$destination\Modules\QBM\Database\MSSQL\MDK"

Write-Output "Linking SDL module into the Modules folder..."
if ([IO.Directory]::Exists("$destination\Modules\SDL")) {
    [IO.Directory]::Delete("$destination\Modules\SDL", $true)
}
New-Item -Path "$destination\Modules\SDL" -ItemType Junction -Value "$destination\SDL" -Force >$null

Write-Output ""
Write-Output "Your environment is now ready"



