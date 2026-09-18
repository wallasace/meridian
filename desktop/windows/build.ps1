<#
  Builds Meridian.exe for Windows.

  Usage:   .\desktop\windows\build.ps1
  Output:  desktop\windows\dist\Meridian.exe   (self-contained, no .NET needed to run)

  Requires the .NET SDK 8 once, on the build machine only:
      winget install Microsoft.DotNet.SDK.8
#>
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $here

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
  Write-Host "The .NET SDK was not found." -ForegroundColor Yellow
  Write-Host "Install it once with:  winget install Microsoft.DotNet.SDK.8"
  Pop-Location; exit 1
}

Write-Host "Compiling Meridian for Windows..." -ForegroundColor Cyan
dotnet publish Meridian.csproj -c Release -o dist | Out-String | Write-Host

# Trim what the person does not need next to the executable.
Get-ChildItem dist -Include *.pdb, *.xml -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

$exe = Join-Path $here 'dist\Meridian.exe'
if (Test-Path $exe) {
  $mb = [math]::Round((Get-Item $exe).Length / 1MB, 1)
  Write-Host "`nDone: $exe  ($mb MB)" -ForegroundColor Green
  Write-Host "Ship the whole 'dist' folder — index.html must sit beside the .exe."
} else {
  Write-Host "`nBuild finished but Meridian.exe was not found in dist\." -ForegroundColor Red
  Pop-Location; exit 1
}

Pop-Location
