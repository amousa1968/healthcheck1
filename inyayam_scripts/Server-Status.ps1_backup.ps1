## You need to run this command before executing the script to "fix powershell Execution Policy setting".
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
<# Script will look for list of Windows Server and create status report monitor
Command Line Switchs
ServerName -list C:\inyayam_scripts\powershell\ServerName.txt  you can change the location
-o	Yes	The location to store the HTML file.	C:\inyayam_scripts\powershell\Scripts
-cpualert minimum percentage of usage that alert status should be raised 95%
-diskalert	No	The minimum percentage of usage that alert status should be raised 85%
-memalert	No	The minimum percentage of usage that alert status should be raised 90%
#>
<#
    Creates a status report of Windows Servers.
    Script will generate a HTM report from the list of Windows servers.
#The command is as follows:
	cd to the script location 
	./Server-Status.ps1 -List C:\inyayam_scripts\powershell\ServerList.txt -O C:\inyayam_scripts\powershell\Scripts -DiskAlert 85 -CpuAlert 80 -MemAlert 80 -Refresh 160    

 .PARAMETER List
    The path to a text file with a list of server names to monitor.

 .PARAMETER O
    The path where the HTML report should be output to. The filename will be WinServ-Status-Report.htm.

 .PARAMETER DiskAlert
    The percentage of disk usage that should cause the disk space alert to be raised.
    
	The script will execute using the list of servers and output a html report called WinServ-Status-Report.htm to C:\inyayam_scripts\powershell\Scripts folder.
    The script will re-run every 2 minutes.
#>

<#
$ServerListFile = "C:\inyayam_scripts\powershell\ServerList.txt"   
$ServerName = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
$Result = @()  
ForEach($computername in $ServerName)  
{ 
#> 

## Set up command line switches and what variables they map to
[CmdletBinding()]
Param(
    [parameter(Mandatory=$True)]
    [alias("List")]
    $ServerName,
    [parameter(Mandatory=$True)]
    [alias("O")]
    $OutputPath,
    [alias("CpuAlert")]
    $CpuAlertThreshold,
    [alias("MemAlert")]
    $MemAlertThreshold,
    [alias("Refresh")]
    $RefreshTime,
	[switch]$UseSsl)

## Function to get the up time from the server
Function Get-UpTime
{
    param([string] $LastBootTime)
    $Uptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($LastBootTime)
    "$($Uptime.Days) days $($Uptime.Hours)h $($Uptime.Minutes)m"
}

## Begining of the loop. Lower down the loop is broken if the refresh option is not configured.
Do{

    ## Change value of the following parameter as needed
#	$OutputFile = "C:\inyayam_scripts\powershell\Scripts\WinServ-Status-Report.htm"
    $ServerListFile = "C:\inyayam_scripts\powershell\ServerList.txt"  
    $ServerName = Get-Content $ServerName -ErrorAction SilentlyContinue 
    $Result = @() 

## Look through the servers in the file provided
#    ForEach ($ServerName in $ServerName)
	ForEach ($ComputerName in $ServerName)
    {
        $PingStatus = Test-Connection -ComputerName $ServerName -Count 1 -Quiet

        ## If server responds, get uptime and disk info
        If ($PingStatus)
        {
            $OperatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $ServerName
			$CpuData = Get-WmiObject -class win32_processor –computername $ServerName
            $CpuAlert = $false
            $CpuUsage = Get-WmiObject Win32_Processor -Computername $ServerName | Measure-Object -Property LoadPercentage -Average | ForEach-Object {$_.Average; If($_.Average -ge $CpuAlertThreshold){$CpuAlert = $True}; "%"}
            $Uptime = Get-Uptime($OperatingSystem.LastBootUpTime)
            $MemAlert = $false
            $MemUsage = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ServerName | ForEach-Object {“{0:N0}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100)/ $_.TotalVisibleMemorySize); If((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100)/ $_.TotalVisibleMemorySize -ge $MemAlertThreshold){$MemAlert = $True}; "%"}
            $DiskAlert = $false
            $DiskUsage = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Where-Object {$_.DriveType -eq 3} | Foreach-Object {$_.DeviceID, [Math]::Round((($_.Size - $_.FreeSpace) * 100)/ $_.Size); If([Math]::Round((($_.Size - $_.FreeSpace) * 100)/ $_.Size) -ge $DiskAlertThreshold){$DiskAlert = $True}; "%"}
            $IPv4Address = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $ServerName | Select-Object -Expand IPAddress | Where-Object { ([Net.IPAddress]$_).AddressFamily -eq "InterNetwork" }
#			$ErrorAction = Get-WinEvent -FilterHashTable | ForEach-Object @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-3) $ErrorAction = $True}; "-#"}
				
		}
	
        ## Put the results together
        $Result += [PSCustomObject] @{
#        $Result += New-Object PSObject -Property @{
	        ServerName = $ServerName
		    IPV4Address = $IPv4Address
		    Status = $PingStatus
            CpuUsage = $CpuUsage
            CpuAlert = $CpuAlert
		    Uptime = $Uptime
            MemUsage = $MemUsage
            MemAlert = $MemAlert
			CpuData = $CpuData

	    }

        ## Clear the variables after obtaining and storing the results so offline servers don't have duplicate info.
    }	Clear-Variable IPv4Address
        Clear-Variable Uptime
        Clear-Variable MemUsage
        Clear-Variable CpuUsage
		Clear-Variable CpuData
#		Clear-Variable EventLogs
    
# Event Logs
#	  Get-WinEvent -FilterHashTable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-3)}
        $css= "<style>"
        $css= $css+ "BODY{ text-align: center; background-color:white;}"
        $css= $css+ "TABLE{    font-family: 'Lucida Sans Unicode', 'Lucida Grande', Sans-Serif;font-size: 12px;margin: 10px;width: 100%;text-align: center;border-collapse: collapse;border-top: 7px solid #004466;border-bottom: 7px solid #004466;}"
        $css= $css+ "TH{font-size: 13px;font-weight: normal;padding: 1px;background: #cceeff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #004466;}"
        $css= $css+ "TD{padding: 1px;background: #e5f7ff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #669;hover:black;}"
        $css= $css+  "TD:hover{ background-color:#004466;}"
        $css= $css+ "</style>" 
        Get-WinEvent -FilterHashTable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-3)}

        $ServerName=Get-Content("C:\inyayam_scripts\powershell\ServerList.txt")
        $body =@()

        foreach ($strComputer in $ServerName) 
        {
        $body += Get-WinEvent -ComputerName $strComputer -FilterHashtable @{logname="System"; Level=2; starttime=$StartDate} -ErrorAction SilentlyContinue
    }
        $body | ConvertTo-HTML -Head $css MachineName,ID,LevelDisplayName,TimeCreated,Message > C:\inyayam_scripts\powershell\Scripts\eventlogs.htm
  
## If there is a result put the HTML file together.
    If ($Result -ne $null)
  {

	
#		$HTML><TITLE> Server Health Report </TITLE>
		$HTML = '<style type="text/css">
                p {font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;font-size:14px}
                p {color:#ffffff;}
                #Header{font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;width:100%;border-collapse:collapse;}
                #Header td, #Header th {font-size:15px;text-align:left;border:1px solid #1a1a1a;padding:2px 2px 2px 7px;color:#ffffff;}
	            #Header th {font-size:16px;text-align:center;padding-top:5px;padding-bottom:4px;background-color:#a43f6c;color:#ffffff;}
	            #Header tr.alt td {color:#ffffff;background-color:#eaf2d3;}
                #Header tr:nth-child(even) {background-color:#a43f6c;}
                #Header tr:nth-child(odd) {background-color:#a43f6c;}
                body {background-color: #1a1a1a;}
	            </style>
                <head><meta http-equiv="refresh" content="30"></head>'

        $HTML += "<html><body>
            <table border=1 cellpadding=0 cellspacing=0 id=header>
            <tr>
                <th><b><font color=#e6e6e6>Server</font></b></th>
                <th><b><font color=#e6e6e6>Server IP</font></b></th>
                <th><b><font color=#e6e6e6>Status</font></b></th>
                <th><b><font color=#e6e6e6>CPU Usage</font></b></th>
                <th><b><font color=#e6e6e6>Memory Usage</font></b></th>
#                <th><b><font color=#e6e6e6>Disk Usage</font></b></th>
                <th><b><font color=#e6e6e6>Uptime</font></b></th>
            </tr>"


## Highlight the alerts if the alerts are triggered.
        ForEach($Entry in $Result)
        {
            If ($Entry.Status -eq $True)
            {
			#ServerName
                $HTML += "<td><font color=#00e600>$($Entry.ServerName)</font></td>"
            }

            Else
            {
			#ServerName
                $HTML += "<td><font color=#FF4D4D>&#10008 $($Entry.ServerName)</font></td>"
            }

            If ($Entry.Status -eq $True)
            {
			#IPV4Address
                $HTML += "<td><font color=#00e600>$($Entry.IPV4Address)</font></td>"
            }

            Else
            {
                $HTML += "<td><font color=#FF4D4D>&#10008 Offline</font></td>"
            }

            If ($Entry.Status -eq $True)
            {
                $HTML += "<td><font color=#00e600>&#10004 Online</font></td>"
            }

            Else
            {
                $HTML += "<td><font color=#FF4D4D>&#10008 Offline</font></td>"
            }

            If ($Entry.CpuUsage -ne $null)
            {
                If ($Entry.CpuAlert -eq $True)
                {
				#CpuUsage
                    $HTML += "<td><font color=#ffff4d>&#9888 $($Entry.CpuUsage)</font></td>"
                }

                Else
                {
				#CpuUsage
                    $HTML += "<td><font color=#00e600>&#10004 $($Entry.CpuUsage)</font></td>"
                }
            }
        
            Else
            {
                $HTML += "<td><font color=#FF4D4D>&#10008 Offline</font></td>"
            }

            If ($Entry.MemUsage -ne $null)
            {
                If ($Entry.MemAlert -eq $True)
                {
				#MemUsage
                    $HTML += "<td><font color=#ffff4d>&#9888 $($Entry.MemUsage)</font></td>"
                }

                Else
                {
				#MemUsage
                    $HTML += "<td><font color=#00e600>&#10004 $($Entry.MemUsage)</font></td>"
                }
            }

            Else
            {
                $HTML += "<td><font color=#FF4D4D>&#10008 Offline</font></td>"
            }


            }
        }

        ## Report the date and time the script ran.
        $HTML += "</table><p><font color=#e6e6e6>Status refreshed on: $(Get-Date -Format G)</font></p></body></html>"
#>
        ## Output the HTML file
	    #$HTML | Out-File $OutputFile
		
		
#		$Outputreport | out-file C:\inyayam_scripts\powershell\Scripts\WinServ-Status-Report.htm  

#		$Outputreport = C:\inyayam_scripts\powershell\Scripts\WinServ-Status-Report.htm
#		Invoke-Expression C:\inyayam_scripts\powershell\Scripts\WinServ-Status-Report.htm

        $HTML | Out-File $OutputFile
#		$Outputreport +
        ## If the refresh time option is configured, wait the specifed number of seconds then loop.
 <#       If ($RefreshTime -ne $null)
        {
            Start-Sleep -Seconds $RefreshTime
        }

#>

do{
    #$ServerName = Import-Csv -Path "C:\Users\mallee\Desktop\importer0.csv" -Delimiter ";"
    $ping= new-object System.Net.NetworkInformation.Ping
    start-sleep -Seconds 60
} until ($RefreshTime)
    }

## This will keep refreshing every "2" minutes and time option is not configured, stop the loop.
Until ($RefreshTime -eq $null)


## End