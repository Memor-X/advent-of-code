@echo off
:init
SET testFiles=%1
GOTO varcheck

:varcheck
IF [%testFiles%]==[] GOTO default_testFiles
GOTO main

:default_testFiles
SET testFiles="all"
GOTO varcheck

:main
CLS
pwsh ".\Tests.ps1" -suite %testFiles%
PAUSE
