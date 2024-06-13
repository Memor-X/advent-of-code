@echo off
:init
SET testFiles=%1
SET compileResults=%2
GOTO varcheck

:varcheck
IF [%testFiles%]==[] GOTO default_testFiles
IF [%compileResults%]==[] GOTO default_compileResults
GOTO main

:default_testFiles
SET testFiles="all"
GOTO varcheck

:default_compileResults
SET compileResults="true"
GOTO varcheck

:main
CLS
pwsh ".\Tests.ps1" -suite %testFiles%
IF %compileResults%=="true" (
    compile.bat
)
PAUSE
