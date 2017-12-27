:: Enables/disables Android app components via ADB
:: ADB service must be running, ADB must be accesible in PATH and have Root on the device!
::   %1 - e|d, enable or disable
::   %2 - file with components list, one per line. Comments start with #

@ECHO OFF 

SETLOCAL

:: check parameters 
IF .%1.==.. GOTO :NoParam
IF .%2.==.. GOTO :NoParam

IF .%1.==.e. SET Action=enable
IF .%1.==.d. SET Action=disable
IF NOT DEFINED Action GOTO :NoParam

:: check for ADB
CALL adb shell su -C "exit" 2> nul || ECHO ADB error: not found or device not connected or has no root && GOTO :EOF

FOR /F %%S IN (%2) DO (
	CALL :ProcessLine "%%S"
)

GOTO :EOF

:: ~~~~~~~~~~ Sub :ProcessLine ~~~~~~~~~~~~~

:ProcessLine
	SET Str=%~1%
	SET First=%Str:~0,1%
	:: Filter comments and empty lines
	IF .%First%.==.. GOTO :EOF
	IF .%First%.==.#. GOTO :EOF

	:: Do process
	ECHO ^> Processing %Str%...
	CALL adb shell su -c "pm %Action% %Str%"
	GOTO :EOF

:: ~~~~~~~~~~ End Sub :ProcessLine ~~~~~~~~~~~~~

:NoParam 
ECHO %~n0. Command line error: "%*" 
EXIT /B 1