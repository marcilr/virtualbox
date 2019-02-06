rem save-VM-state-and-export-to-OVF-and-VMDK.bat
rem Created Wed Feb  6 11:02:19 AST 2019
rem by Raymond E. Marcil <marcilr@gmail.com>
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
SET ERROR=0
SET RUNNING_INICIAL=2
 
ECHO Starting backup VM "%VM%"...
 
:check_running
%VBOXMANAGE% list runningvms > %TEMP%\runningvms.txt
FIND "%VM%" %TEMP%\runningvms.txt > nul
 
IF %errorlevel% EQU 0 (
    SET RUNNING_INICIAL=1
) ELSE (
    SET RUNNING_INICIAL=0
)
 
DEL %TEMP%\runningvms.txt
 
IF %RUNNING_INICIAL% EQU 1 (
    ECHO Saving state VM "%VM%"...
    %VBOXMANAGE% controlvm "%VM%" savestate
 
    IF %errorlevel% NEQ 0 (
        SET ERROR=1
        GOTO end
    )
)
 
:export_vm
ECHO Exporting VM "%VM%"...
TIMEOUT /t 3 /nobreak > nul
SET FECHA=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
%VBOXMANAGE% export "%VM%" -o "%BACKUP_DIR%%VM% %FECHA%.ovf"
 
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
 
:end
IF %ERROR% GTR 0 (
    ECHO Error ^(%ERROR%^) while creating backup VM "%VM%".
) ELSE (
    ECHO Backup finished OK.
)

