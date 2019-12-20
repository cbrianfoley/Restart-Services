$Services = "VMMS","VSS"

foreach ($service in $Services){
    $servicestate = Get-Service $service -ErrorAction SilentlyContinue
    if ($Error){
        "$($service) service doesn't exist, or another error occured."
        $Error.Clear()
    }
    if ($servicestate.Status -eq 'Stopped'){
        try{
            "$($service) service is stopped. Starting."
            Start-Service $service -Verbose
        }
        catch { 
            "Error starting service. Attempting to use force"
        }
    }
    if ($servicestate.Status -eq 'Running'){
        "$($service) service is Running. Restarting."
        try{
            Stop-Service $service -Verbose
        }
        catch{
            "Error stopping. Attempting to use force."
            Stop-Service $service -Force -Verbose
        }
        try{
            Start-Service $service -Verbose
        }
        catch{
            "Error starting service."
        }
    }
    else {
        "$($service) is $($servicestate). Attempting to restart using force."
        Stop-Service $service -Force -Verbose
        Start-Service $service
    }
}