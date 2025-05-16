# EnterVisualStudioDevShell

EnterVisualStudioDevShell is a PowerShell module that provides a convenient way to enter the Visual Studio Developer Command Prompt for a specific VC++ version.

Visual Studio ships with a PS module to enter the Developer Command Prompt, but it is not very user-friendly.
This module provides a PowerShell function that allows you to enter the Developer Command Prompt directly from PowerShell, with autocompletion for the installed VC++ versions.

It allows you to quickly switch between different versions of the Developer Command Prompt without having to navigate through the Visual Studio installation directories manually.

## Features
- Enter the Developer Command Prompt
  - with the latest VC++ version
    ```ps
    Enter-VisualStudioDevShell
    ```
  - with a specific VC++ version
    ```ps
    Enter-VisualStudioDevShell -vcToolsVersion 14.44.34823
    ```
  - The  `vcToolsVersion` parameter provides autocompletion for the installed VC++ versions.
- List available VC++ versions
  ```ps
  Get-InstalledVCToolVersions -List
  ```
  Example output:
  ```text
  Major  Minor  Build  Revision
  -----  -----  -----  --------
  14     43     34808  -1
  14     38     33130  -1
  14     35     32215  -1
  14     30     30705  -1
  ```
- Automatically detects the installed Visual Studio versions and their corresponding Developer Command Prompt paths.

## Installation
- Clone the repository and move the `EnterVisualStudioDevShell` directory to your PowerShell module path (e.g., `%USERPROFILE%\Documents\PowerShell\Modules`), or create a link to the module directory.

## Configuration
The module automatically detects the installed Visual Studio versions and their corresponding Developer Command Prompt paths. However, if you have a custom installation or need to specify a different path, you can create a configuration file named `config.json` in `$ModuleRoot\PersistentData`.

E.g. if you installed the module to `%USERPROFILE%\Documents\PowerShell\Modules\EnterVisualStudioDevShell`, the config file would have to be placed at `%USERPROFILE%\Documents\PowerShell\Modules\EnterVisualStudioDevShell\PersistentData\config.json`. The configuration file should contain a JSON object with the following structure:

```json
{
  "VSInstallDir" : "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community"
}
```

## Limitations
- The module is designed to work with Visual Studio 2022 and later versions.
- No support for multiple versions of Visual Studio installed side by side (you can specify which installation to use in the config file though).
