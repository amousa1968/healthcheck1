Measure-Command -Expression {

Get-WinEvent -LogName application -ea 0 |

Where-Object { $_.providername -match 'wmi' -AND

$_.TimeCreated -gt [datetime]::today }

}


Get-eventlog -Logname System -EntryType ("Error")

Get-eventlog -Logname Application -After (Get-Date).AddDays(-5) -EntryType ("Error", "Critical", "Warning") 

# Warning level=3
# Error level=2 
# Information level=4

$message = 'Event log entry.'
Get-WinEvent -FilterHashTable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-3)}
Write-EventLog -LogName 'monitor.log' -Source 'C:\inyayam_scripts\powershell\Script_log' -EntryType Information -EventId '1' -Category 0 -Message $message

Get-EventLog -LogName Application -EntryType Error -After (Get-Date).AddDays(-3) 