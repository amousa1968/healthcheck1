#=============================================================================# 
# Script_name -server_name $env: computername -comment "Scheduled_reboot")                                                                           # 
# Restart-Server.ps1                                                          # 
# Simple PowerShell script to reboot a server.                                # 
# Ayman Mousa                                             					  # 
# Date: 02.08.2018                                                            # 
#=============================================================================# 
 
Param([Parameter(Mandatory = $false)][switch]$NoMaintenanceMode) 
  
function Main { 
  if(!$NoMaintenanceMode) { 
    .\Restart-Server.ps1 -Server $env:computername -Minutes 30 -Comment "Scheduled Reboot" 
    } 
  Start-Sleep -Seconds 30 
  $eventLog = New-Object System.Diagnostics.EventLog("System") 
  $eventLog.MachineName = "." 
  $eventLog.Source = "Scheduled Reboot" 
  $eventLog.WriteEntry("The server has begun its scheduled reboot.","Information",22) 
  $server = Get-WmiObject Win32_OperatingSystem 
  $server.PSBase.Scope.Options.EnablePrivileges = $true 
  $null = $server.Reboot() 
  } 
 
Main