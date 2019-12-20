# This script is intended to be called on by a non-administrative account to create a scheduled task to do administrative things
# The account that runs this script must have permissions for C:\Windows\Tasks
# powershell.exe -file C:\Windows\System32\WindowsPowerShell\v1.0\Scripts\Create-RestartServicesScheduledTask.ps1

$TaskName = 'Restart-Services'
$Script = "C:\Windows\System32\WindowsPowerShell\v1.0\Scripts\Restart-Services.ps1"

# creates a scheduled task that will run immediately
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
$Error.Clear()
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"-Argument "-File $($Script)"
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(5)
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$Principal = New-ScheduledTaskPrincipal -RunLevel Highest -UserId SYSTEM
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal
$CompleteTask = Register-ScheduledTask -TaskName $TaskName -InputObject $Task -User 'SYSTEM' -Force
$CompleteTask | Set-ScheduledTask

# check and see if scheduled task still exists. Exit the script once it doesn't

While($Error.Count -eq 0){
    try{
    $Time = Get-Date
    $TaskCheck = Get-ScheduledTask $TaskName -ErrorAction SilentlyContinue
    $TaskCheck | Add-Member -NotePropertyName "Time" -NotePropertyValue $Time.ToString()
    "$($TaskCheck.Time) $($TaskCheck.State)"
    Start-Sleep -Seconds 1
    }catch{break}
}
"Done"