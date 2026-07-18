@echo off
setlocal enabledelayedexpansion
:: Asegurar que los caracteres en el menú de pantalla se muestren correctamente
chcp 65001 > nul

title Auditoria y Mantenimiento OEM - @Manganzond ManganzónDigital

:: 1. Verificar si se está ejecutando como Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ============================================================
    echo ¡ERROR! Este script debe ejecutarse como Administrador.
    echo Por favor, haz clic derecho y selecciona "Ejecutar como administrador".
    echo ============================================================
    pause
    exit /b
)

:: 2. Configurar entorno del Log portátil (En la misma carpeta del script)
for /f "tokens=1-3 delims=/.- " %%a in ("%date%") do (
    set "ano=%%c"
    set "mes=%%b"
    set "dia=%%a"
)
if "%ano%"=="" set "ano=%date:~-4%"
if "%mes%"=="" set "mes=%date:~4,2%"
if "%dia%"=="" set "dia=%date:~0,2%"

:: %~dp0 apunta con total precisión al directorio de origen en el pendrive
set "LOG_FILE=%~dp0Mantenimiento_%COMPUTERNAME%_%ano%-%mes%-%dia%.log"

:: Inicializar el Log portátil con texto plano limpio para evitar caracteres corruptos
if not exist "%LOG_FILE%" (
    echo ==================================================== > "%LOG_FILE%"
    echo   REPORTE DE MANTENIMIENTO - %COMPUTERNAME% >> "%LOG_FILE%"
    echo   Fecha: %date% >> "%LOG_FILE%"
    echo   Creado por: @Manganzond ManganzónDigital >> "%LOG_FILE%"
    echo   Venezuela. >> "%LOG_FILE%"
    echo ==================================================== >> "%LOG_FILE%"
)

call :log_msg "INFO" "Script de mantenimiento iniciado por el administrador."

:menu
cls
echo ============================================================
echo      HERRAMIENTA DE ASISTENCIA Y AUDITORÍA OEM
echo ============================================================
echo   Creado por @Manganzond ManganzónDigital. Venezuela
echo   [Ruta Log: %LOG_FILE%]
echo ============================================================
echo  [1] Revisar activación y Clave OEM (BIOS)
echo  [2] Deshabilitar Protección en Tiempo Real (Temporal)
echo  [3] Reparar sistema (DISM + SFC)
echo  [4] Limpieza profunda de componentes (DISM)
echo  [5] Restablecer PC de cero (Mantener archivos)
echo  [6] Restablecer PC de cero (Borrar todo)
echo  [7] Abrir carpeta de Logs en ubicación del script
echo  [8] Salir
echo ============================================================
set "opc="
set /p opc="Selecciona una opción (1-8): "

if "%opc%"=="1" goto info_oem
if "%opc%"=="2" goto apagar_defender
if "%opc%"=="3" goto reparar
if "%opc%"=="4" goto limpiar
if "%opc%"=="5" goto reset_soft
if "%opc%"=="6" goto reset_hard
if "%opc%"=="7" goto abrir_logs
if "%opc%"=="8" goto salir_script
goto menu

:info_oem
cls
echo === REVISANDO LICENCIA Y ACTIVACIÓN ===
echo Ejecutando diagnóstico lineal... por favor espere...
call :log_msg "AUDIT" "Iniciando auditoría de licencia OEM/Sistema."

echo -------------------------------------------------- >> "%LOG_FILE%"
echo [AUDIT_DETALLE] Consultando clave de manera aislada... >> "%LOG_FILE%"

:: Ejecución aislada: PowerShell escribe directo al LOG sin colapsar el CMD (Usando texto plano)
powershell -NoProfile -Command "$key = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey; if ($key) { Write-Output 'Clave OEM de fabrica encontrada: '$key } else { Write-Output 'No se detecto clave OEM inyectada en la BIOS/UEFI.' }" >> "%LOG_FILE%" 2>&1

echo [AUDIT_DETALLE] Ejecutando SLMGR dli y xpr... >> "%LOG_FILE%"
call cscript //nologo %systemroot%\system32\slmgr.vbs /dli >> "%LOG_FILE%" 2>&1
call cscript //nologo %systemroot%\system32\slmgr.vbs /xpr >> "%LOG_FILE%" 2>&1
echo -------------------------------------------------- >> "%LOG_FILE%"

call :log_msg "INFO" "Auditoría de licencia completada de forma segura."
echo.
echo [+] Proceso finalizado en segundo plano de manera lineal.
echo [+] Toda la información detallada se ha guardado en el archivo .log
echo.
pause
goto menu

:apagar_defender
cls
echo === AJUSTANDO EXCLUSIÓN / PROTECCIÓN ===
echo Solicitando a PowerShell exclusión de la unidad C:\ para acelerar el mantenimiento...
call :log_msg "DEFENDER" "Intentando añadir exclusion temporal de C:\ para optimizar E/S."

powershell -Command "Add-MpPreference -ExclusionPath 'C:\'" >> "%LOG_FILE%" 2>&1
if %errorLevel% eq 0 (
    call :log_msg "SUCCESS" "Exclusión de C:\ añadida correctamente en Windows Defender."
    echo Exclusión temporal de la unidad C:\ activada.
) else (
    call :log_msg "ERROR" "Fallo al añadir exclusión. Posible protección contra alteraciones activa."
)

echo.
echo Intentando apagar el monitoreo en tiempo real...
call :log_msg "DEFENDER" "Intentando ejecutar Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >> "%LOG_FILE%" 2>&1
echo Operación procesada. Revisa el log para validar si Windows Defender bloqueó el comando.
echo.
pause
goto menu

:reparar
cls
echo === REPARACIÓN DEL SISTEMA ===
echo 1/2 Reemplazando componentes dañados (DISM)... Esto puede tardar varios minutos.
call :log_msg "DISM" "Iniciando comando /RestoreHealth..."
dism /online /cleanup-image /restorehealth >> "%LOG_FILE%" 2>&1
if %errorLevel% eq 0 (
    call :log_msg "SUCCESS" "DISM /RestoreHealth finalizó con éxito."
    echo DISM completado con éxito.
) else (
    call :log_msg "ERROR" "DISM detectó errores o fue interrumpido. Código: %errorLevel%"
    echo DISM finalizó con alertas. Verifica el log.
)

echo.
echo 2/2 Verificando integridad de archivos de sistema (SFC)...
call :log_msg "SFC" "Iniciando comando /scannow..."
sfc /scannow >> "%LOG_FILE%" 2>&1
call :log_msg "INFO" "SFC /scannow finalizado."
echo SFC completado.
echo.
pause
goto menu

:limpiar
cls
echo === LIMPIEZA PROFUNDA DE COMPONENTES ===
echo Reduciendo el tamaño de WinSxS y eliminando actualizaciones obsoletas...
echo (Este proceso suele ser demorado, no cierres la ventana)
call :log_msg "DISM" "Iniciando /startcomponentcleanup /resetbase"
dism /online /cleanup-image /startcomponentcleanup /resetbase >> "%LOG_FILE%" 2>&1
if %errorLevel% eq 0 (
    call :log_msg "SUCCESS" "Limpieza de base de componentes completada."
    echo Limpieza exitosa.
) else (
    call :log_msg "ERROR" "Falló la limpieza profunda. Código: %errorLevel%"
    echo Hubo un inconveniente al limpiar componentes. Revisa el log.
)
echo.
pause
goto menu

:reset_soft
cls
call :log_msg "RESET" "Usuario invocó el restablecimiento manteniendo archivos del OS."
echo Lanzando entorno nativo de recuperación...
systemreset.exe
goto menu

:reset_hard
cls
call :log_msg "RESET" "CRITICO: Usuario invocó el restablecimiento de fabrica borrando TODO."
echo Lanzando entorno nativo de recuperación de fábrica...
systemreset.exe -factoryreset
goto menu

:abrir_logs
explorer.exe /select,"%LOG_FILE%"
goto menu

:salir_script
call :log_msg "INFO" "Script finalizado por el usuario de forma controlada."
exit

:: ====================================================
:: FUNCIONES SUBRUTINA
:: ====================================================
:log_msg
echo [%time%] [%~1] %~2 >> "%LOG_FILE%"
goto :eof