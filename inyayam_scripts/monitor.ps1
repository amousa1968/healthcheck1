###################### Monitor Script ###########################
# INYAYAM                                                		#
# This is the script which will run the monitor script          #
# 																#
# Change details (if required) anywhere you see **CHANGE THIS** #
#################################################################
 $date = Get-Date
 $d = $date.day
 $m = $date.month
 $y = $date.year
#**CHANGE THIS** Set the location the report is saved to (must exist)
$File ="C:\inyayam_scripts\powershell\Script_log\$computersname.$d.$m.$y.txt"

"Running Reports"
.\monitor.ps1 | out-file -filepath $File -append


$listloc="C:\inyayam_scripts\powershell\ServerList.txt";
$computers=Get-Content $listloc
 $date = Get-Date
 $d = $date.day
 $m = $date.month
 $y = $date.year
 
	####################### Function For CPU Usage ###########################

function get-CPUUSAGE {
    param(
        #**CHANGE THIS** Set the CPU threshold
        [int] $threshold = 10
    )
 
    $ErrorActionPreference = "SilentlyContinue"
 
    # Test connection to computer
    if( !(Test-Connection -Destination $computersname -Count 1) ){
        "Could not connect to :: $computersname"
        return
    }
 
    # Get all the processes
    $processes = Get-WmiObject -ComputerName $computersname `
    -Class Win32_PerfFormattedData_PerfProc_Process `
    -Property Name, PercentProcessorTime
 
    $return= @()
 
    # Build up a return list
    foreach( $process in $processes ){
        if( $process.PercentProcessorTime -ge $threshold `
        -and $process.Name -ne "Idle" `
        -and $process.Name -ne "_Total"){
            $item = "" | Select Name, CPU
            $item.Name = $process.Name
            $item.CPU = $process.PercentProcessorTime
            $return += $item
            $item = $null
        }
    }
 
    # Sort the return data
    $return = $return | Sort-Object -Property CPU -Descending
    return $return
}
$cpuuage=get-CPUUSAGE 

 
""
"=== S T A R T  R E P O R T ==="
""

foreach ($computersname in $computers) { 


#Does all the checking   
       
   if (Test-Connection $computersname -erroraction silentlyContinue  ) {
	""
	"-------------------------"
     $computersname.ToUpper()
	"-------------------------"
	 ""
     ""
     $label="$computersname Status:	"
	 $label = $label.ToUpper()
     $labelup="UP";
	 ""
	 "****************************************"
     $label+$labelup 
	 "****************************************"
	 ""
     ""
     "Current CPU Usage"
     Get-WmiObject win32_processor -ComputerName $computersname | select LoadPercentage  |fl
     "Processes using above 10% cpu"
     ""
     if (!$cpuuage)
     {"No processes currently running above 10% CPU usage"}
     else {$cpuuage}
     ""
     ""
     "===== Memory Usage ====="
     ""
"-------PROCESS LIST BY MEMORY USAGE-------"
$fields = "Name",@{label = "Memory (MB)"; Expression = {$_.ws / 1mb}; Align = "Right"}
$processlist=get-process -ComputerName $computersname 
$processlist | Sort-Object -Descending WS | format-table $fields | Out-String
"------------------------------------------"
""
""
$freemem = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computersname

# Display free memory on PC/Server
"---------FREE MEMORY----------"
""
"System Name     : {0}" -f $freemem.csname
"Free Memory (MB): {0}" -f ([math]::round($freemem.FreePhysicalMemory / 1024, 2))
"Free Memory (GB): {0}" -f ([math]::round(($freemem.FreePhysicalMemory / 1024 / 1024), 2))
""
"------------------------------"
     ""
     ""
     ""
    "===list automatic services which are currently stopped==="
    ""
# get Auto that not Running:
Get-WmiObject Win32_Service -ComputerName $computersname |
Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |
# process them; in this example we just show them:
Format-Table -AutoSize @(
    'Name'
    'DisplayName'
    @{ Expression = 'State'; Width = 9 }
    @{ Expression = 'StartMode'; Width = 9 }
    'StartName'
) | Out-String -Width 300
    ""
    ""
    "===== ERRORS IN APPLICATION AND SYSTEM EVENT LOGS ====="
    $today=$Date.ToShortDateString()
    ""
    ""
    "--- Errors in Application event log for $today ---"
    ""
    $appevent=get-eventlog -log "Application" -entrytype Error -ComputerName $computersname -after $today
    If(!$appevent)
            {
                ""
                "No errors"
                ""
            }
    else    {
                ""
                $appevent | Format-Table -AutoSize -Wrap | Out-String -Width 300
                ""
            }
    ""
    "--- Errors in System event log for $today ---"
    ""
    $sysevent=get-eventlog -log "System" -entrytype Error -ComputerName $computersname  -after $today
        If(!$sysevent)
            {
                ""
                "No errors"
                ""
            }
    else    {
                ""
                $sysevent | Format-Table -AutoSize -Wrap | Out-String -Width 300
                ""
            }
    ""
    ""
   }
   else {
     $computersname
     ""
     $label="$computersname Status:	";
     $labeldown="DOWN";
     $label+$labeldown
     ""
     ""
   }
 }
    ""
   "=== E N D  O F  R E P O R T ==="
