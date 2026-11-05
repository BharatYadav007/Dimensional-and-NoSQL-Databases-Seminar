. (Join-Path $PSScriptRoot 'common.ps1')
Add-Type -AssemblyName System.Drawing
$directory = Join-Path $script:SeminarRoot 'screenshots'
$entries = @(Get-ChildItem -LiteralPath $directory -File |
    Where-Object Extension -In '.png','.jpg','.jpeg' |
    Sort-Object Name | ForEach-Object {
        $picture = [Drawing.Image]::FromFile($_.FullName)
        try {
            [PSCustomObject]@{
                filename = $_.Name
                status = 'captured'
                evidence_type = 'actual application or desktop screenshot'
                width = $picture.Width
                height = $picture.Height
                bytes = $_.Length
                file_last_write_time = $_.LastWriteTime.ToString('o')
                sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
            }
        } finally { $picture.Dispose() }
    })
if ($entries.Count -eq 0) { throw 'No screenshots exist. No capture status has been fabricated.' }
$json = [PSCustomObject]@{
    generated_at = (Get-Date).ToString('o')
    note = 'Hashes and dimensions describe the existing original files. Last-write time is filesystem metadata.'
    screenshots = $entries
} | ConvertTo-Json -Depth 5
[IO.File]::WriteAllText((Join-Path $directory 'manifest.json'), $json, (New-Object Text.UTF8Encoding $false))
Write-Host "Indexed $($entries.Count) existing screenshots."
