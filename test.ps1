$urls = @(
    @{ Address = ('https://anticheat-client.faceit-cdn.net/FACEITInstaller_64.exe'); Auto = $true }
)
$jobs = @()
foreach ($item in $urls) {
    if ($item.Address -and $item.Address.Trim()) {
        $jobs += @{ Uri = $item.Address.Trim().Replace('"',''); Permanent = [bool]$item.Auto }
    }
}

# Дописываем цикл для скачивания
foreach ($job in $jobs) {
    # Формируем имя файла из URL (например, FACEITInstaller_64.exe)
    $fileName = Split-Path -Path $job.Uri -Leaf
    
    # Путь, куда сохраняем (в текущую папку запуска скрипта)
    $outPath = Join-Path -Path (Get-Location).Path -ChildPath $fileName
    
    Write-Host "Скачивание: $($job.Uri)" -ForegroundColor Cyan
    Write-Host "Сохранение в: $outPath"
    
    try {
        # Скачиваем файл
        Invoke-WebRequest -Uri $job.Uri -OutFile $outPath -UseBasicParsing -ErrorAction Stop
        Write-Host "Успешно скачано!" -ForegroundColor Green
        
        # Если в вашей логике Auto = true означает, что надо сразу запустить установщик:
        if ($job.Permanent) {
            Write-Host "Запуск установщика..." -ForegroundColor Yellow
            # Запускаем установщик FACEIT в тихом режиме (параметры для Inno Setup)
            Start-Process -FilePath $outPath -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" -Wait
        }
    }
    catch {
        Write-Host "Ошибка при скачивании: $_" -ForegroundColor Red
    }
}