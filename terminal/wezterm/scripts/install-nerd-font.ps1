[CmdletBinding()]
param(
    [string]$NerdFontVersion = '3.5.1'
)
$ErrorActionPreference = 'Stop'
$temp = Join-Path $env:TEMP "nerd-font-$NerdFontVersion"
$zip = Join-Path $temp 'JetBrainsMono.zip'
$extract = Join-Path $temp 'extract'
$dest = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
New-Item -ItemType Directory -Force -Path $temp,$extract,$dest | Out-Null
if (-not (Test-Path -LiteralPath $zip)) {
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v$NerdFontVersion/JetBrainsMono.zip" -OutFile $zip
}
Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
$fonts = @(
    @{ File = 'JetBrainsMonoNerdFontMono-Regular.ttf'; Name = 'JetBrainsMono NFM Regular (TrueType)' },
    @{ File = 'JetBrainsMonoNerdFontMono-Bold.ttf'; Name = 'JetBrainsMono NFM Bold (TrueType)' },
    @{ File = 'JetBrainsMonoNerdFontMono-Italic.ttf'; Name = 'JetBrainsMono NFM Italic (TrueType)' },
    @{ File = 'JetBrainsMonoNerdFontMono-BoldItalic.ttf'; Name = 'JetBrainsMono NFM Bold Italic (TrueType)' }
)
$reg = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Software\Microsoft\Windows NT\CurrentVersion\Fonts')
foreach ($font in $fonts) {
    $source = Join-Path $extract $font.File
    $target = Join-Path $dest $font.File
    Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
    $reg.SetValue($font.Name, $target, [Microsoft.Win32.RegistryValueKind]::String)
    Write-Host "Installed: $target"
}
$reg.Close()
Write-Host 'Nerd Font installed. Restart WezTerm to refresh the DirectWrite font cache.'