@REM Author:        lxvs <jn.apsd@gmail.com>
@REM Last Updated:  2021-06-17

@echo off
@setlocal enableextensions disabledelayedexpansion
set "version=0.1.2"
title RunMRU v%version%

for /f "tokens=3" %%i in ('reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v MRUList') do set "mrulist=%%i"
if "%mrulist%" == "" exit /b 1
set /a "pos=0"

:mruparse
if "%mrulist%" NEQ "" (set "mru=%mrulist:~0,1%") else goto aftermru
set "mruContent="
for /f "tokens=1-2,*" %%i in ('reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v %mru%') do set "mruContent=%%k"
if not defined mruContent (
    set "mrulist=%mrulist:~1%"
    goto mruparse
)
if "%mruContent:~-2%"=="\1" set "mruContent=%mruContent:~0,-2%"
set /p=%mru%) <nul

set "mruContent=%mruContent:|=^|%"
set "mruContent=%mruContent:&=^&%"
@echo %mruContent%
set /a "pos+=1"
set "mrulist=%mrulist:~1%"
goto mruparse

:aftermru
set "tags="
set /p "tags=Please input the items to delete (Input %% to delete all): "

:tagsparse
if "%tags%" == "%%" (
    reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /f 1>NUL
    exit /b
)
if not "%tags%" == "" (set "tag=%tags:~0,1%") else exit /b
reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /v %tag% /f 1>NUL
set "tags=%tags:~1%"
goto tagsparse
