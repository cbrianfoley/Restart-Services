# Restart-Services.ps1
# restarts a list of services

# this is intended to be used with Create-RestartServicesScheduledTask.ps1 script

# powershell.exe -file C:\Windows\System32\WindowsPowerShell\v1.0\Scripts\Create-RestartServicesScheduledTask.ps1

$Services = "VMMS","VSS" #edit this line to add/remove services

$Error.Clear()
Start-Transcript -Append -Path C:\Temp\Restart-Services.log

foreach ($service in $Services){
    $servicestate = Get-Service $service -ErrorAction SilentlyContinue

    if ($servicestate.Status -eq 'Stopped'){
        try{
            "$($service) service is Stopped. Starting."
            Start-Service $service -Verbose
            continue
        }
        catch { 
            "Error starting service."
        }
    }
    if ($servicestate.Status -eq 'Running'){
        "$($service) service is Running. Restarting."
        try{
            Stop-Service $service -Force -Verbose
        }
        catch{
            "Error stopping. Attempting to use force."
            $process = Get-CimInstance win32_service -Filter "name like '$($service)'"
            Stop-Process -Id $process.ProcessId -Force -PassThru -Verbose -ErrorAction SilentlyContinue
        }
        try{
            Start-Service $service -Verbose -ErrorAction SilentlyContinue
            continue
        }
        catch{
            "Error starting service."
            $Error
            $Error.Clear()
            continue
        }
    }
    if ($Error){
        "$($service) service threw an error."
        $Error
        $Error.Clear()
        continue
    }
    else {
        "$($service) is $($servicestate.Status). Attempting to restart using force."
        $process = Get-CimInstance win32_service -Filter "name like '$($service)'"
        Stop-Process -Id $process.ProcessId -Force -PassThru -Verbose -ErrorAction SilentlyContinue
        Start-Service $service -Verbose
    }

}

Unregister-ScheduledTask -TaskName 'Restart-Services' -Confirm:$false -ErrorAction SilentlyContinue

Stop-Transcript