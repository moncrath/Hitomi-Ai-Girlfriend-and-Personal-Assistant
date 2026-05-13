param([string]$AudioFile)
Add-Type -AssemblyName PresentationCore
$player = New-Object System.Windows.Media.MediaPlayer
$path = Join-Path (Get-Location) "sound\$AudioFile"
$player.Open([uri]$path)
$player.Play()
Start-Sleep -Seconds 10
