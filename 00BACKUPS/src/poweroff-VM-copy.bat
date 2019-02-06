rem poweroff-VM-copy.sh
rem Created Wed Feb  6 10:54:23 AST 2019
rem by Raymond E. Marcil <marcilr@gmail.com>
rem
rem poweroff VM and copy folder
rem
rem Links
rem =====
rem Backup script for Windows OS (BATCH)
rem by antoniofr » 23. Nov 2015, 10:00
rem https://forums.virtualbox.org/viewtopic.php?f=6&t=74793
rem
rem Download scripts here:
rem http://www.michublog.com/informatica/script-batch-para-crear-copias-de-seguridad-de-maquinas-virtuales-de-virtualbox-desde-windows
rem

@ECHO OFF
CLS
 
SET "VM=Ubuntu Server 14.04"
SET "VM_DIR=C:\VirtualBox VMs\"
SET "BACKUP_DIR=C:\VirtualBox VMs\backup\"
SET VBOXMANAGE="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
SET RAR="C:\Program Files\WinRAR\Rar.exe"
SET CICLOS=10
SET PAUSAS=5
SET SOLICITUD_APAGADO=0
SET ERROR=0
SET RUNNING_INICIAL=2
 
ECHO Starting backup VM "%VM%"...
 
:check_running
%VBOXMANAGE% list runningvms > %TEMP%\runningvms.txt
FIND "%VM%" %TEMP%\runningvms.txt > nul
 
IF %errorlevel% EQU 0 (
    SET RUNNING=1
) ELSE (
    SET RUNNING=0
)
 
IF %RUNNING_INICIAL% EQU 2 (
    SET RUNNING_INICIAL=%RUNNING%
)
 
IF %CICLOS% GTR 0 (
    IF %RUNNING% EQU 1 (
        IF %SOLICITUD_APAGADO% EQU 0 (
            SET SOLICITUD_APAGADO=1
            ECHO Power off VM "%VM%"...
            %VBOXMANAGE% controlvm "%VM%" acpipowerbutton
        )
 
        ECHO Waiting VM "%VM%" shut down...
        TIMEOUT /t %PAUSAS% /nobreak > nul
        SET /a CICLOS-=1
        GOTO check_running
    ) ELSE (
        ECHO VM "%VM%" is power off now...
    )
)
 
DEL %TEMP%\runningvms.txt
 
IF %RUNNING% EQU 1 (
    SET ERROR=1
    GOTO end
)
 
:copy_vm
ECHO Copying VM "%VM%"...
TIMEOUT /t 3 /nobreak > nul
XCOPY "%VM_DIR%%VM%" "%BACKUP_DIR%%VM%" /E /I /Y
 
IF %errorlevel% NEQ 0 (
    SET ERROR=2
    GOTO end
)
 
:start_vm
IF %RUNNING_INICIAL% EQU 1 (
    ECHO Starting VM "%VM%"...
    %VBOXMANAGE% startvm "%VM%"
     
    IF %errorlevel% NEQ 0 (
        SET ERROR=3
        GOTO end
    )
)
 
:compress_backup
ECHO Compressing backup VM "%VM%"...
SET FECHA=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
%RAR% a -r -ep1 -o+ "%BACKUP_DIR%%VM% %FECHA%.rar" "%BACKUP_DIR%%VM%"
 
IF %errorlevel% NEQ 0 (
    SET ERROR=4
    GOTO end
)
 
:delete_uncompressed_backup
ECHO Removing uncompressed backup VM "%VM%"...
RMDIR "%BACKUP_DIR%%VM%" /S /Q
 
IF %errorlevel% NEQ 0 (
    SET ERROR=5
    GOTO end
)
 
:end
IF %ERROR% GTR 0 (
    ECHO Error ^(%ERROR%^) while creating backup VM "%VM%".
) ELSE (
    ECHO Backup finished OK.
)

