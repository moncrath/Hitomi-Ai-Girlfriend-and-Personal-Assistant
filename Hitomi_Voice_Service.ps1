# Hitomi Voice Service - Background Listener
$folder = "D:\AI\Hitomi_Core"
$file = "hitomi_voice.txt"
$soundFolder = "D:\AI\Hitomi_Core\sound"

$path = Join-Path $folder $file
if (-not (Test-Path $path)) {
    New-Item -Path $path -ItemType File -Force | Out-Null
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = $file
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$action = {
    $path = $Event.SourceEventArgs.FullPath
    Start-Sleep -Milliseconds 100
    try {
        $soundFile = (Get-Content $path -Raw).Trim()
        if ([string]::IsNullOrWhiteSpace($soundFile)) { return }
        
        $soundPath = Join-Path $soundFolder $soundFile
        if (Test-Path $soundPath) {
            Write-Host "Hitomi is speaking: $soundFile"
            $safeSoundPath = $soundPath -replace "'", "''"
            $playScript = "Add-Type -AssemblyName PresentationCore; `$player = New-Object System.Windows.Media.MediaPlayer; `$player.Open('$safeSoundPath'); `$player.Play(); Start-Sleep -Seconds 10"
            Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy", "Bypass", "-Command", $playScript
        }
    } catch {
        Write-Host "Error reading voice file: $_"
    }
}

Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null

Write-Host "=========================================="
Write-Host "   Hitomi Voice Service is ONLINE"
Write-Host "=========================================="
Write-Host "Monitoring $path for voice commands."
Write-Host "Please leave this window open."
Write-Host "Press Ctrl+C to stop."

while ($true) {
    Start-Sleep -Seconds 1
}
