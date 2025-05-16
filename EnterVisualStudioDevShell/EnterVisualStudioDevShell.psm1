function Find-InstalledVsVersions
{
    return  Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
        ForEach-Object { Get-ItemProperty $_.PsPath } |
        Where-Object {
            $_.DisplayName -like '*Visual Studio*' -and
            $_.InstallLocation.Length -gt 0
        } |
        Sort-Object InstallDate -Descending |
        ForEach-Object { $_.InstallLocation } |
        Where-Object { Test-Path (Join-Path $_ 'Common7\IDE') }
}

function Get-VsInstallDir
{
    $Script:ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath '\PersistentData\config.json'
    if (Test-Path $Script:ConfigPath) {
        $Script:Config = Get-Content -Path $Script:ConfigPath | ConvertFrom-Json
        if ($Script:Config.VSInstallDir) {

            if (!(Test-Path (Join-Path $Script:Config.VSInstallDir "VC\Tools\MSVC")))
            {
                throw "The specified Visual Studio installation directory $($Script:Config.VSInstallDir) does not exist or points to a wrong directory."
            }

            return $Script:Config.VSInstallDir
        }
    }

    $Script:vs_installations = Find-InstalledVsVersions
    if ($Script:vs_installations.Count -eq 0) {
        Write-Error "No Visual Studio installations found."
        return $null
    }

    if ($Script:vs_installations.Count -gt 1) {
        Write-Host "Multiple Visual Studio installations found. Using the most recent one." -ForegroundColor Yellow
    }

    return $Script:vs_installations | Select-Object -First 1
}

function Get-InstalledVCToolVersions
{
    $Script:vc_root = Get-VsInstallDir
    $Script:vc_tools_dir = Join-Path $Script:vc_root "VC\Tools\MSVC"
    $Script:version_regex = '(\d+\.\d+\.\d+)'
    return Get-ChildItem $Script:vc_tools_dir -Directory |
        Where-Object { $_.Name -match $Script:version_regex } |
        ForEach-Object { [version]$_.Name } |
        sort-object -Descending
}

function Enter-VisualStudioDevShell
{
    param(
        [ValidateScript({ $_ -in (Get-InstalledVCToolVersions) }, ErrorMessage = "Specified version is not installed.")]
        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete)
            [array] $validValues = (Get-InstalledVCToolVersions)
            $validValues -like "$wordToComplete*"
        })]
        [string]$vcToolsVersion = (Get-InstalledVCToolVersions)[0]
    )

    $Script:vc_root = Get-VsInstallDir

    Write-Host "Setting up Visual Studio Command Prompt environment variables for version $vcToolsVersion..."
    Import-Module (Join-Path $Script:vc_root Common7\Tools\Microsoft.VisualStudio.DevShell.dll)
    Enter-VsDevShell -VsInstallPath $Script:vc_root -DevCmdArguments "-arch=x64 -vcvars_ver=$vcToolsVersion" >$null 2>&1
    Write-Host "`nVisual Studio Command Prompt variables set."
}

Export-ModuleMember -Function Enter-VisualStudioDevShell
Export-ModuleMember -Function Get-InstalledVCToolVersions
