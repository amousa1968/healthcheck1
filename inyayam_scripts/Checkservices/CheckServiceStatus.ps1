#############################################################################
#  Ayman Mousa L2 team, and wrote it for fun    
#  Application Services Monitoring Script only on Windows
#############################################################################

# You need to run this command before executing the script to "fix powershell Execution Policy setting".
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# Script will look for list of Windows Servers and create status applications services report monitor
# You can add list servers + services to the text files (Server.txt & Services.txt)

############################Define Server & Services Variable ###############
$ServerList = Get-Content ".\Server.txt"

$ServicesList = Get-Content ".\Services.txt"

#############################Define other variables##########################

$report = ".\report\report.htm" 

##############################################################################

$checkrep = Test-Path ".\report\report.htm" 

If ($checkrep -like "True")

{

Remove-Item ".\report\report.htm"

}

New-Item ".\report\report.htm" -type file

################################ADD HTML Content#############################

Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>Service Status Report</title>' 
add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}" 
add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #000000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='Lavender'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Service Status Report</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
 
add-content $report  "<table width='100%'>" 
Add-Content $report "<tr bgcolor='IndianRed'>" 
Add-Content $report  "<td width='10%' align='center'><B>Server Name</B></td>" 
Add-Content $report "<td width='50%' align='center'><B>Service Name</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Status</B></td>" 
Add-Content $report "</tr>" 


########################################################################################################

################################## Get Services Status #################################################

Function servicestatus ($serverlist, $serviceslist)

{

foreach ($machineName in $serverlist) 

 { 
  foreach ($service in $serviceslist)
     {
  
      $serviceStatus = get-service -ComputerName $machineName -Name $service
    
		 if ($serviceStatus.status -eq "Running") {
 
         Write-Host $machineName `t $serviceStatus.name `t $serviceStatus.status -ForegroundColor Green 
         $svcName = $serviceStatus.name 
         $svcState = $serviceStatus.status         
         Add-Content $report "<tr>" 
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $machineName</B></td>" 
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B>$svcName</B></td>" 
         Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>" 
         Add-Content $report "</tr>" 
              
                                                   }

	        else 
                                                   { 
       Write-Host $machineName `t $serviceStatus.name `t $serviceStatus.status -ForegroundColor Red 
         $svcName = $serviceStatus.name 
         $svcState = $serviceStatus.status          
         Add-Content $report "<tr>" 
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>$machineName</td>" 
         Add-Content $report "<td bgcolor= 'GainsBoro' align=center>$svcName</td>" 
         Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
         Add-Content $report "</tr>" 
         
                                                  } 

             

       } 


 } 

}

############################################Call Function#############################################

servicestatus $ServerList $ServicesList

############################################Close HTMl Tables#########################################


Add-content $report  "</table>" 
Add-Content $report "</body>" 
Add-Content $report "</html>" 

## End