# Baut Finanzplaner + Installer -> dist\Finanzplaner-Setup.exe
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$pub  = Join-Path $root "build\publish"
$dist = Join-Path $root "dist"
Remove-Item $pub -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $pub, $dist | Out-Null

Write-Host "1/3  App veroeffentlichen (self-contained) ..."
dotnet publish "$root\src\Finanzplaner\Finanzplaner.csproj" -c Release -r win-x64 --self-contained true `
  -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:EnableCompressionInSingleFile=true `
  -p:DebugType=none -o $pub
if ($LASTEXITCODE -ne 0) { throw "publish fehlgeschlagen" }

Write-Host "2/3  Payload packen ..."
$zip = Join-Path $root "src\Setup\payload.zip"
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $pub "Finanzplaner.exe") -DestinationPath $zip -CompressionLevel Optimal
Copy-Item "$root\src\Finanzplaner\app.ico" "$root\src\Setup\app.ico" -Force

Write-Host "3/3  Installer bauen ..."
dotnet build "$root\src\Setup\Setup.csproj" -c Release -o "$root\build\setup"
if ($LASTEXITCODE -ne 0) { throw "Setup-Build fehlgeschlagen" }
Copy-Item "$root\build\setup\Finanzplaner-Setup.exe" "$dist\Finanzplaner-Setup.exe" -Force
Remove-Item $zip -Force
Write-Host ("Fertig: {0} ({1:N1} MB)" -f "$dist\Finanzplaner-Setup.exe", ((Get-Item "$dist\Finanzplaner-Setup.exe").Length/1MB))
