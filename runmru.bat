@echo off & setlocal
for /f "tokens=3" %%i in ('reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v MRUList') do set mrulist=%%i
set /a pos=0
:mruparse
if "%mrulist%" NEQ "" (set mru=%mrulist:~,1%) else goto aftermru
for /f "tokens=1-2,*" %%i in ('reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v %mru%') do set mruContent=%%k
if "%mruContent:~-2%"=="\1" set mruContent=%mruContent:~,-2%
set /p=%mru%) <nul& echo %mruContent%
set /a pos+=1
set mrulist=%mrulist:~1%
goto mruparse
:aftermru
set tags=
set /p "tags=Please input the items to delete: "
:tagsparse
if "%tags%" NEQ "" (set tag=%tags:~,1%) else goto aftertags
reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v %tag% /f>NUL
set tags=%tags:~1%
goto tagsparse
:aftertags
