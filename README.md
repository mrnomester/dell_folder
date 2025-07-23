## Утилита для массового удаления папок в домене Active Directory  

**PowerShell-скрипт для удаления указанной папки на всех компьютерах домена через админскую шару.**  

---

## ⚠️ Ключевые требования  
- **Active Directory**: Скрипт использует `Get-ADComputer` для получения списка ПК.  
- **Административные права**:  
  - На машине, где запускается скрипт  
  - Доступ к `\\{PC_NAME}\c$\` (админская шара) на целевых компьютерах  
- **PowerShell 5.1+** и модуль `ActiveDirectory`  

> **Важно!** Скрипт удаляет папку **рекурсивно** без возможности восстановления!  

---

## 🛠 Настройка  

### 1. Обязательные параметры  
Измените путь к удаляемой папке в скрипте (`delete_folder_all_pc.ps1`):  
```powershell
$folderPath = "\\$computer\c$\Users\Public\RAMCleaner"  # Замените на целевой путь  
```

### 2. Дополнительные настройки  
| Параметр | Рекомендация |  
|----------|--------------|  
| **Исключение серверов** | Добавьте фильтр: `Get-ADComputer -Filter "OperatingSystem -notlike '*Server*'"` |  
| **Логирование в файл** | Добавьте `Start-Transcript -Path "C:\Logs\folder_cleanup.log"` в начало скрипта |  
| **Подтверждение** | Раскомментируйте `$confirmation = Read-Host "Вы уверены? (y/n)"` перед циклом |  

---

## 🚀 Запуск  

### Вручную (с повышенными правами):  
```powershell
powershell.exe -ExecutionPolicy Bypass -File "\\путь\к\delete_folder_all_pc.ps1"
```

### Через GPO (для доменного развертывания):  
1. **Разместите скрипт** в сетевой папке с доступом для `Domain Computers`.  
2. **Настройте политику**:  
   - **Computer Configuration → Policies → Windows Settings → Scripts → Startup**  
   - Добавьте команду:  
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File "\\сетевой_путь\delete_folder_all_pc.ps1"
     ```  

---

## 📊 Выходные данные  
Скрипт выводит цветные статусы в реальном времени:  

| Цвет | Статус | Значение |  
|------|--------|----------|  
| 🟢 **Зеленый** | `[SUCCESS]` | Папка удалена |  
| 🔴 **Красный** | `[ERROR]` | Ошибка удаления (нет прав/файл занят) |  
| 🟡 **Желтый** | `[SKIPPED]` | Папка не существует |  
| ⚪ **Серый** | `[OFFLINE]` | Компьютер недоступен |  

---

## ⚠️ Типовые проблемы  

| Ошибка | Решение |  
|--------|---------|  
| **«Access Denied»** | Проверьте права на `c$` и запуск от **администратора домена** |  
| **«Cannot bind parameter Filter»** | Установите модуль `ActiveDirectory` (`Add-WindowsFeature RSAT-AD-PowerShell`) |  
| **Скрипт зависает** | Добавьте таймаут: `Test-Connection -ComputerName $computer -Count 1 -Timeout 2 -Quiet` |  

---

## 🔒 Безопасность  
1. **Тестирование**: Запустите сначала на 2-3 тестовых ПК.  
2. **Бэкап**: Для критичных папок используйте резервное копирование:  
   ```powershell
   Compress-Archive -Path $folderPath -DestinationPath "\\backup\папка_$computer.zip"
   ```  
3. **Альтернатива**: Для точечного удаления используйте `-WhatIf`:  
   ```powershell
   Remove-Item -Path $folderPath -Recurse -Force -WhatIf
   ```  

---

## 💡 Оптимизация  
- **Параллельное выполнение**: Добавьте `ForEach-Object -Parallel` (требуется PS 7+):  
  ```powershell
  $computers | ForEach-Object -Parallel { ... } -ThrottleLimit 10
  ```  
- **Электронные уведомления**: Интегрируйте `Send-MailMessage` для отчетов.  

---

**Для внутреннего использования** | Адаптируйте под вашу инфраструктуру.  
Copyright © 2025 Кодельник Максим Сергеевич | MIT License
