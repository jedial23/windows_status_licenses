# Windows Status & Licenses Assistant

Developed by **@Jedial23** for **ManganzónDigital**.

🌐 [English Version](#english-version) | [Versión en Español](#versión-en-español)

---

## English Version

A lightweight automated utility in `.bat` format designed for portable technical support environments (such as multiboot flash drives using Ventoy or Easy2Boot). It allows system administrators to audit Windows/Office activation states, troubleshoot KMS blocks, and trigger native recovery environments without depending on a static drive letter.

### 🚀 Features

*   **Agnostic:** Safely queries the ACPI/MSDM product key directly from the BIOS/UEFI using isolated PowerShell CIM instances, preventing terminal crashes on custom clone PCs.
*   **Integrated:** Automates standard Microsoft Office path mapping to execute native `ospp.vbs` licensing diagnostics in the background.
*   **Network-Ready:** Includes a dedicated live network submenu to explicitly open Port `1688` (inbound/outbound) or temporarily toggle firewall profiles to bypass KMS server handshake blocks.
*   **Secure:** Automatically validates administrative privileges before running core deployment tools (`DISM /RestoreHealth` + `SFC /scannow`).
*   **Clean:** Leverages native component compression (`/startcomponentcleanup /resetbase`) to deeply purge obsolete system updates and free up drive space.

### 📁 Flash Drive Structure

For the script to log sessions perfectly in your diagnostic environments, place the files maintaining this hierarchical structure in your USB drive:

```text
/windows_status_licenses
│   .gitignore                 # Prevents client transaction logs from being tracked
│   windows_status_tool.bat    # Core executable utility script
│
└───/logs                      # Auto-created target directory for host diagnostic outputs