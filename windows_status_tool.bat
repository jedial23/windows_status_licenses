@echo off
setlocal enabledelayedexpansion
:: Asegurar que los caracteres en el menú de pantalla se muestren correctamente
chcp 65001 > nul

title Asistencia OEM y Red - @Manganzond ManganzónDigital

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

:: 2. Configurar entorno del Log portátil (En subcarpeta \logs)
for /f "tokens=1-3 delims=/.- " %%a in ("%date%") do (
    set "ano=%%c"
    set "mes=%%b"
    set "dia=%%a"
)
if "%ano%"=="" set "ano=%date:~-4%"
if "%mes%"=="" set "mes=%date:~4,2%"
if "%dia%"=="" set "dia=%date:~0,2%"

:: Configurar directorio de destino y asegurar su existencia de forma nativa
set "LOG_DIR=%~dp0logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set "LOG_FILE=%LOG_DIR%\Mantenimiento_%COMPUTERNAME%_%ano%-%mes%-%dia%.log"

if not exist "%LOG_FILE%" (
    echo ==================================================== > "%LOG_FILE%"
    echo   REPORTE DE MANTENIMIENTO - %COMPUTERNAME% >> "%LOG_FILE%"
    echo   Fecha: %date% >> "%LOG_FILE%"
    echo   Creado por: @Manganzond ManganzonDigital >> "%LOG_FILE%"
    echo   Venezuela. >> "%LOG_FILE%"
    echo ==================================================== >> "%LOG_FILE%"
)

call :log_msg "INFO" "Script de mantenimiento iniciado por el administrador."

:menu
cls
echo ============================================================
echo      HERRAMIENTA DE ASISTENCIA Y AUDITORÍA OEM / KMS
echo ============================================================
echo   Creado por @Manganzond ManganzónDigital. Venezuela
echo   [Ruta Log: %LOG_FILE%]
echo ============================================================
echo  [1] Revisar activación y Clave OEM (BIOS)
echo  [2] Revisar activación de Microsoft Office
echo  [3] Modo Diagnóstico de Red (Abrir Puerto 1688 / Desactivar Firewall)
echo  [4] Deshabilitar Protección en Tiempo Real Defender (Temporal)
echo  [5] Reparar sistema (DISM + SFC)
echo  [6] Limpieza profunda de componentes (DISM)
echo  [7] Restablecer PC de cero (Mantener archivos)
echo  [8] Restablecer PC de cero (Borrar todo)
echo  [9] Abrir carpeta de Logs en Pendrive
echo  [10] Salir
echo ============================================================
set "opc="
set /p opc="Selecciona una opción (1-10): "

if "%opc%"=="1" goto info_oem
if "%opc%"=="2" goto info_office
if "%opc%"=="3" goto diagnostico_red
if "%opc%"=="4" goto apagar_defender
if "%opc%"=="5" goto reparar
if "%opc%"=="6" goto limpiar
if "%opc%"=="7" goto reset_soft
if "%opc%"=="8" goto reset_hard
if "%opc%"=="9" goto abrir_logs
if "%opc%"=="10" goto salir_script
goto menu

:info_oem
cls
echo === REVISANDO LICENCIA Y ACTIVACIÓN ===
echo Ejecutando diagnóstico lineal... por favor espere...
call :log_msg "AUDIT" "Iniciando auditoria de licencia OEM/Sistema."

echo -------------------------------------------------- >> "%LOG_FILE%"
echo [AUDIT_DETALLE] Consultando clave de manera aislada... >> "%LOG_FILE%"

powershell -NoProfile -Command "$key = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey; if ($key) { Write-Output 'Clave OEM de fabrica encontrada: '$key } else { Write-Output 'No se detecto clave OEM inyectada en la BIOS/UEFI.' }" >> "%LOG_FILE%" 2>&1

echo [AUDIT_DETALLE] Ejecutando SLMGR dli y xpr... >> "%LOG_FILE%"
call cscript //nologo %systemroot%\system32\slmgr.vbs /dli >> "%LOG_FILE%" 2>&1
call cscript //nologo %systemroot%\system32\slmgr.vbs /xpr >> "%LOG_FILE%" 2>&1
echo -------------------------------------------------- >> "%LOG_FILE%"

call :log_msg "INFO" "Auditoria de licencia completada."
echo.
echo [+] Proceso finalizado. Detalles guardados en el archivo .log
echo [+] Si detecta canal KMS fallido, use la opcion [3] para liberar el puerto.
echo.
pause
goto menu

:info_office
cls
echo === REVISANDO LICENCIA DE MICROSOFT OFFICE ===
echo Buscando rutas de instalación de Office de manera aislada... por favor espere...
call :log_msg "AUDIT" "Iniciando auditoría de licencias de Microsoft Office."

echo -------------------------------------------------- >> "%LOG_FILE%"
echo [AUDIT_DETALLE] Buscando y ejecutando script ospp.vbs via PowerShell... >> "%LOG_FILE%"

powershell -NoProfile -Command "$r=@(\"$env:ProgramFiles\Microsoft Office\Office16\ospp.vbs\",\"${env:ProgramFiles(x86)}\Microsoft Office\Office16\ospp.vbs\",\"$env:ProgramFiles\Microsoft Office\Office15\ospp.vbs\",\"${env:ProgramFiles(x86)}\Microsoft Office\Office15\ospp.vbs\"); $f=$false; foreach($path in $r){ if(Test-Path $path){ $f=$true; Write-Output \"[OFFICE_DETECTADO] Ejecutando consulta en: $path\" | Out-File '%LOG_FILE%' -Encoding utf8 -Append; cscript //nologo $path /dstatus 2>&1 | Out-File '%LOG_FILE%' -Encoding utf8 -Append; } }; if(-not $f){ Write-Output \"[-] Alerta: No se encontraron rutas estandar de Office (ospp.vbs).\" | Out-File '%LOG_FILE%' -Encoding utf8 -Append; }"

echo -------------------------------------------------- >> "%LOG_FILE%"
call :log_msg "INFO" "Auditoria de Office completada de forma segura."
echo.
echo [+] Análisis finalizado en segundo plano sin interferencias.
echo [+] Los datos se han volcado por completo al archivo .log
echo.
pause
goto menu

:diagnostico_red
cls
echo ============================================================
echo        MODO DIAGNÓSTICO DE RED (COMPROBACIÓN KMS)
echo ============================================================
echo.
echo [1] Habilitar puerto 1688 en Firewall (Entrada/Salida)
echo [2] Desactivar Firewall de Windows por completo (Provisional)
echo [3] Volver a Activar Firewall de Windows
echo [4] Volver al menú principal
echo.
set "opc_red="
set /p opc_red="Selecciona una opción de red (1-4): "

if "%opc_red%"=="1" (
    call :log_msg "FIREWALL" "Abriendo puerto 1688 de forma explicita."
    netsh advfirewall firewall add rule name="KMS_Keeplive_In" dir=in action=allow protocol=TCP localport=1688 >> "%LOG_FILE%" 2>&1
    netsh advfirewall firewall add rule name="KMS_Keeplive_Out" dir=out action=allow protocol=TCP localport=1688 >> "%LOG_FILE%" 2>&1
    echo [+] Puerto 1688 TCP agregado a las reglas del Firewall.
    pause
    goto diagnostico_red
)
if "%opc_red%"=="2" (
    call :log_msg "FIREWALL" "Desactivando perfiles del Firewall provisionalmente."
    netsh advfirewall set allprofiles state off >> "%LOG_FILE%" 2>&1
    echo [¡ALERTA!] Todos los perfiles del Firewall de Windows se han APAGADO.
    echo Proceda a realizar los cambios o consultas de activacion necesarias ahora.
    pause
    goto diagnostico_red
)
if "%opc_red%"=="3" (
    call :log_msg "FIREWALL" "Restableciendo perfiles del Firewall a encendido."
    netsh advfirewall set allprofiles state on >> "%LOG_FILE%" 2>&1
    echo [+] Todos los perfiles del Firewall de Windows se han ACTIVADO correctamente.
    pause
    goto diagnostico_red
)
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
    call :log_msg "SUCCESS" "DISM /RestoreHealth finalizo con exito."
    echo DISM completado con éxito.
) else (
    call :log_msg "ERROR" "DISM detecto errores o fue interrupted. Codigo: %errorLevel%"
    echo DISM finalizo con alertas. Verifica el log.
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
    call :log_msg "ERROR" "Fallo la limpieza profunda. Codigo: %errorLevel%"
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
call :log_msg "RESET" "CRITICO: Usuario invocó el restablecimiento de fábrica borrando TODO."
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