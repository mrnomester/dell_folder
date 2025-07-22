# Функция для проверки прав администратора
function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Проверяем, запущен ли скрипт с правами администратора
if (-not (Test-IsAdmin)) {
    Write-Host "Скрипт не запущен с правами администратора. Перезапускаем с повышенными правами..."
    
    # Получаем полный путь к текущему скрипту
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # Запускаем скрипт с повышенными правами
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Импорт модуля AD
Import-Module ActiveDirectory

# Получить ВСЕ компьютеры домена (включая Domain Controllers, Servers и обычные ПК)
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Удалить папку на каждом компьютере
foreach ($computer in $computers) {
    $folderPath = "\\$computer\c$\Users\Public\RAMCleaner"
    
    # Проверить доступность компьютера
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        # Проверить существование папки
        if (Test-Path $folderPath) {
            try {
                Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
                Write-Host "[SUCCESS] $computer : Папка удалена." -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] $computer : Ошибка удаления. $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "[SKIPPED] $computer : Папка не существует." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[OFFLINE] $computer : Компьютер недоступен." -ForegroundColor Gray
    }
}