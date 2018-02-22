@echo off
setlocal
set Path=C:\Program Files (x86)\GnuWin32\bin;%Path%
set TARGET=http://your.website.com/here.html

: http://www.gnu.org/software/wget/manual/wget.html
:
: -e  --execute
: -o  --output-file
: -p  --page-requisites
: -r  --recursive
:     --spider
: -w  --wait

wget --spider -o wget.log -e robots=off --wait 1 -r -p %TARGET%

endlocal
