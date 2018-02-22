@echo off
setlocal
:: pushd \\dev1.honeywell.com\dfs\ab02\ngtools\tools
push C:\Users\Ayman\Documents\GitHub\PowerShell-Scripts\healthcheck1-master\inyayam_scripts\sites-healthchecks

C:\Users\Ayman\Documents\GitHub\PowerShell-Scripts\healthcheck1-master\inyayam_scripts\sites-healthchecks
cls

where curl >nul 2>&1
if errorlevel 1 set curlpath=C:\Users\Ayman\Documents\GitHub\Tools\curl\bin\
:: curl\bin\

title %0: %date%

set env=

for /f "tokens=1-2*" %%a in (sitelist.txt) do call :check %%a %%b %%c %1 %2 %3
goto :eof

:check
  set check=%1
  if "%check:~0,1%" == "!" goto :eof

  if not "%env%" == "%1" (
    set env=%1
    echo .
    echo . %1: %time%
    echo .

  ) 

  set bell=
  if /i "%1" == "%4" (
    set bell=
  )
  if /i "%1" == "%5" (
    set bell=
  )
  if /i "%1" == "%6" (
    set bell=
  )

  set application=%2          
  set host=
  for /f "tokens=2 delims=:/" %%x in ("%3") do for /f "tokens=1-2 delims=:- " %%y in ('nslookup %%x 2^>nul') do if /i "%%y" == "name" set host=%%z

  %curlpath%curl -f %3 >nul 2>&1

  if errorlevel 1 (
    echo *	%application:~0,10% ^(%host%^)	DOWN	%3 %bell%
  ) else (
    echo .	%applicatIon:~0,10% ^(%host%^)	 UP	
  )
  goto :eof
