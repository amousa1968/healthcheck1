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

$result += [PSCustomObject] @{ 
    ServerName = "$computername"
    CPULoad = "$($AVGProc.Average)%"
    MemLoad = "$($OS.MemoryUsage)%"
    CDrive = "$($vol.'C PercentFree')%"
#    Uptime = "$up"
}

## Get Uptime
#$UPTIME=Get-WmiObject Win32_OperatingSystem
#$up = [Management.ManagementDateTimeConverter]::ToDateTime($UPTIME.LastBootUpTime) | Out-String

Get-WmiObject Win32_OperatingSystem | Select-Object LastBootUpTime


$Outputreport = "<HTML><TITLE> Server Health Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#99000"" face=""Microsoft Tai le"">
                 <H2> Server Health Report </H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>Server Name</B></TD>
                   <TD><B>Avrg.CPU Utilization</B></TD>
                   <TD><B>Memory Utilization</B></TD>
                   <TD><B>C Drive Utilizatoin</B></TD>
                   <TD><B>UPTime</B></TD>
                   </TR>"
                   

Foreach($Entry in $Result) 

    { 
      if(($Entry.CpuLoad) -or ($Entry.memload) -ge "80") 
      { 
        $Outputreport += "<TR bgcolor=white>" 
      } 
      else
       {
        $Outputreport += "<TR>" 
      }
      $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.CDrive)</TD></TR>" 
    }
 $Outputreport += "</Table></BODY></HTML>" 
    } 

$Outputreport | out-file "C:\inyayam_scripts\powershell\Scripts\Result $(Get-Date -Format yyy-mm-dd-hhmm).htm"



# cat '.\inyayam_scripts\powershell\ServerList.txt' | Get-ComputerStats | Format-Table

#$Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.CDrive)</TD></TR>" 
   # }