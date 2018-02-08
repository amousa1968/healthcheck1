#################################################################################  
## The purpose  
## Server Health Check  
## This scripts check the server Avrg CPU and Memory utlization along with C drive  
## disk utilization and sends an email to the receipents included in the script 
################################################################################  
 
$ServerListFile = "C:\inyayam_scripts\powershell\ServerList.txt"   
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
$Result = @()  
ForEach($computername in $ServerList)  
{ 
 
$AVGProc = Get-WmiObject -computername $computername win32_processor |  
Measure-Object -property LoadPercentage -Average | Select Average 
$OS = gwmi -Class win32_operatingsystem -computername $computername | 
Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }} 
$vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'C:'" | 
Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } } 

## Get Uptime
$UPTIME=Get-WmiObject Win32_OperatingSystem
$up = [Management.ManagementDateTimeConverter]::ToDateTime($UPTIME.LastBootUpTime) | Out-String

## Get version
$Version = (Get-WmiObject -class Win32_OperatingSystem).Caption | Out-String

## Get Uptime
$UPTIME=Get-WmiObject Win32_OperatingSystem
$up = [Management.ManagementDateTimeConverter]::ToDateTime($UPTIME.LastBootUpTime) | Out-String

## Get Disk Spaces
$Disk = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost -Filter "DriveType=3" |select -property DeviceID,@{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}},@{Name="Free Space(GB)";Expression={[decimal]("{0:N0}" -f($_.freespace/1gb))}},@{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}|ConvertTo-Html

## Get Critical Service Status here i have given SQL service you can pass different service name as per your requirement
$Private:wmiService =gsv -include "*SQL*" -Exclude "*ySQL*","*spo*"|select Name,DisplayName,Status|ConvertTo-Html
$Services =gsv -include "*SQL*" -Exclude "*ySQL*","*spo*"|select Name,DisplayName,Status|ConvertTo-Html 

## Get CPU Utilization
$CPU_Utilization = Get-Process|Sort-object -Property CPU -Descending| Select -first 5 -Property ID,ProcessName,@{Name = 'CPU In (%)';Expression = {$TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds;[Math]::Round( ($_.CPU * 100 /$TotalSec),2)}},@{Expression={$_.threads.count};Label="Threads";},@{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="VM(MB)";Expression={"{0:N3}" -f($_.VM/1mb)}}|ConvertTo-Html

   
$result += [PSCustomObject] @{  
        ServerName = "$computername" 
        CPULoad = "$($AVGProc.Average)%" 
        MemLoad = "$($OS.MemoryUsage)%" 
        CDrive = "$($vol.'C PercentFree')%"
		DDrive = "$($vol.'D PercentFree')%"
	} 
 
    $Outputreport = "<HTML><TITLE> Server Health Report </TITLE> 
                     <BODY background-color:peachpuff> 
                     <font color =""#99000"" face=""Microsoft Tai le""> 
                     <H2> Server Health Report </H2></font> 
                     <Table border=1 cellpadding=0 cellspacing=0> 
                     <TR bgcolor=gray align=center> 
                       <TD><B>Server Name</B></TD> 
                       <TD><B>Avrg.CPU Utilization</B></TD> 
                       <TD><B>Memory Utilization</B></TD> 
                       <TD><B>C Drive Utilizatoin</B></TD></TR>" 
                         
    Foreach($Entry in $Result)  
     
        {  
          if((($Entry.CpuLoad) -or ($Entry.memload)) -ge "80")  
          {  
            $Outputreport += "<TR bgcolor=red>"  
          }  
          else 
           { 
            $Outputreport += "<TR>"  
          } 
          $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.Cdrive)</TD></TR>"  
        } 
     $Outputreport += "</Table></BODY></HTML>"  
        }  
  
$Outputreport | out-file C:\inyayam_scripts\powershell\Scripts\Test.htm  
Invoke-Expression C:\inyayam_scripts\powershell\Scripts\Test.htm

# Get-Content "C:\inyayam_scripts\powershell\Scripts\Test.htm" -Wait -Tail 5

#### ayman tail the script
## Create an Timer instance 
#infinite loop for calling connect function   
#$job = Start-Job -ScriptBlock { & "server_healthcheck.ps1" }

# Get-Content "some_logfile.log" -Wait

