[CmdletBinding()]
param([Parameter(Mandatory)][ValidatePattern('^[a-zA-Z0-9_-]+\.png$')][string]$Filename)
# Captures the actual foreground desktop. It does not construct or alter output.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
if (-not ('SeminarScreenDpi' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class SeminarScreenDpi {
    [DllImport("user32.dll")]
    public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
}
'@
}
# Use physical screen pixels on displays with Windows scaling enabled.
$oldDpiContext = [SeminarScreenDpi]::SetThreadDpiAwarenessContext([IntPtr](-4))
$screenshots = Join-Path (Split-Path -Parent $PSScriptRoot) 'screenshots'
New-Item -ItemType Directory -Force -Path $screenshots | Out-Null
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width,$bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.CopyFromScreen($bounds.Location,[System.Drawing.Point]::Empty,$bounds.Size)
    $bitmap.Save((Join-Path $screenshots $Filename),[System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $graphics.Dispose()
    $bitmap.Dispose()
    if ($oldDpiContext -ne [IntPtr]::Zero) { [void][SeminarScreenDpi]::SetThreadDpiAwarenessContext($oldDpiContext) }
}
Write-Host "Saved actual desktop screenshot: $Filename"
