$ErrorActionPreference = "Stop"

$Repo = "SyncMeIn/ReeveGo"
$Arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "arm64" } else { "amd64" }
$Asset = "reeve-go-windows-$Arch.exe"
$BaseUrl = "https://github.com/$Repo/releases/latest/download"
$InstallDir = if ($env:REEVEGO_INSTALL_DIR) { $env:REEVEGO_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Reeve-Go" }

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("reevego-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

try {
    $BinTmp = Join-Path $TmpDir $Asset
    $SumTmp = Join-Path $TmpDir "sha256sums.txt"

    Write-Host "Downloading $Asset from $Repo..."
    Invoke-WebRequest -Uri "$BaseUrl/$Asset" -OutFile $BinTmp
    Invoke-WebRequest -Uri "$BaseUrl/sha256sums.txt" -OutFile $SumTmp

    Write-Host "Verifying SHA-256 checksum..."
    $ExpectedLine = Get-Content $SumTmp | Where-Object { $_ -match "\s+$([regex]::Escape($Asset))$" } | Select-Object -First 1
    if (-not $ExpectedLine) { throw "Checksum entry for $Asset not found in sha256sums.txt" }
    $ExpectedHash = ($ExpectedLine -split "\s+")[0].ToLowerInvariant()
    $ActualHash = (Get-FileHash $BinTmp -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ActualHash -ne $ExpectedHash) {
        throw "Checksum mismatch! expected=$ExpectedHash actual=$ActualHash"
    }

    $Dest = Join-Path $InstallDir "reeve-go.exe"
    Move-Item -Force $BinTmp $Dest
    Write-Host "Installed to $Dest"
    & $Dest --version
} finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
