# Windows & Office License Assistant / Auditoría y Asistencia OEM - KMS

A lightweight, portable, and production-ready Windows batch script utility designed for IT professionals and system administrators to audit, troubleshoot, and maintain Windows and Microsoft Office activation statuses. It seamlessly integrates advanced built-in Windows diagnostics, local component repair utilities, and temporary network/firewall overrides to resolve KMS or OEM activation bottlenecks.

Una utilidad ligera, portátil y lista para producción desarrollada en script por lotes (.bat) para Windows, diseñada para profesionales de TI y administradores de sistemas. Permite auditar, diagnosticar y mantener el estado de activación de Windows y Microsoft Office, integrando herramientas nativas de reparación y liberaciones temporales de red/firewall para solucionar bloqueos en canales KMS u OEM.

---

## 🚀 Features / Características

### English
*   **Agnostic Licensing Audit:** Safely extracts the ACPI/MSDM product key from the motherboard (BIOS/UEFI) using isolated CIM instance queries without crashing the terminal on custom or built-in clone PCs.
*   **Windows & Office Activation Status:** Queries active OS channels (Retail, OEM, Volume KMS) and maps standard Microsoft Office installation paths to execute `ospp.vbs` diagnostics.
*   **Modular Network Diagnostics:** Detects KMS connection failures and provides one-click native overrides to add inbound/outbound Firewall rules for Port `1688` or toggle all firewall profiles temporarily.
*   **System Refactoring & Repair:** Chains native deployment tools (`DISM /RestoreHealth` + `SFC /scannow`) to clean up component stores and repair corrupt protected system files affecting licensing services.
*   **Deep Component Cleanup:** Invokes advanced WinSxS compression routines (`/startcomponentcleanup /resetbase`) to purge obsolete windows updates and free up critical disk space.
*   **OS Bare-Metal Reset:** Direct programmatic access to native Windows recovery triggers (`systemreset.exe`) to perform soft or hard factory resets.
*   **Isolated Portability Logging:** Encodes chronological logs using dynamic UTF-8 standards to prevent character corruption. Logs are automatically routed to a dedicated internal directory, segregated from the repository source tracking.

### Español
*   **Auditoría de Licencias Agnóstica:** Extrae de forma segura la clave de producto ACPI/MSDM de la placa base (BIOS/UEFI) mediante consultas aisladas de instancias CIM, evitando que la consola colapse en equipos clonados o personalizados.
*   **Estado de Activación de Windows y Office:** Consulta los canales activos del SO (Retail, OEM, KMS de volumen) y mapea las rutas estándar de instalación de Microsoft Office para ejecutar diagnósticos con `ospp.vbs`.
*   **Diagnóstico Modular de Red:** Detecta fallas de conexión KMS y proporciona liberaciones nativas en un clic para añadir reglas de entrada/salida en el Firewall para el Puerto `1688` o apagar temporalmente todos los perfiles de red.
*   **Refactorización y Reparación del Sistema:** Encadena herramientas nativas de despliegue (`DISM /RestoreHealth` + `SFC /scannow`) para limpiar el almacén de componentes y reparar archivos corruptos del sistema que afecten los servicios de licenciamiento.
*   **Limpieza Profunda de Componentes:** Invoca rutinas avanzadas de compresión WinSxS (`/startcomponentcleanup /resetbase`) para purgar actualizaciones obsoletas de Windows y liberar espacio crítico en disco.
*   **Restablecimiento de Fábrica Nativo:** Acceso programático directo a los disparadores de recuperación nativos de Windows (`systemreset.exe`) para realizar restablecimientos de fábrica parciales o totales.
*   **Registro Portátil Aislado:** Codifica reportes cronológicos bajo estándares UTF-8 dinámicos para evitar la corrupción de caracteres. Los logs se enrutan automáticamente a un directorio interno dedicado, excluido del rastreo del repositorio.

---

## 📂 Repository Structure / Estructura del Repositorio

```text
/windows_status_licenses
│   .gitignore                 # Excludes local transaction logs from being tracked / Excluye los logs locales
│   windows_status_tool.bat    # Core executable utility script / Script utilitario principal ejecutable
│
└───/logs                      # Automated target folder for client logs (Auto-created if missing)
                               # Carpeta automatizada para logs de clientes (Auto-creada si no existe)