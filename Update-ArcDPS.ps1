<#
.SYNOPSIS
    Automatic software updater for ArcDPS (a Guild Wars 2 add-in DPS meter).
.DESCRIPTION
    This program is designed to check the ArcDPS website for updated versions of the
    program, and install it into the appropriate Guild Wars 2 folder. The script may
    be run over and over, and when newer versions of ArcDPS are found, the newer version
    is downloaded, any existing version is backed up, and the new version is installed.

    You can use the -uninstall option to remove ArcDPS from your Guild Wars 2 folder.

    You can use the -revert to swap the backup and installed version. Doing this requires
    that you have a backup. Reverting a second time swaps the backup again effectively
    re-installing the newest version. This cycles back and forth between the two copies
    of ArcDPS.

    Warning: Use a DPS meter at your own discretion. See ArcDPS link for more details.
.LINK
    Regarding ArcDPS use in Guild Wars 2, please see https://help.guildwars2.com/hc/en-us/articles/360013625034-Policy-Third-Party-Programs
    For more information in Guild Wars 2, please see https://welcome.guildwars2.com/
    For more information on ArcDPS, please see https://www.deltaconnected.com/arcdps/
    For help with ArcDPS, please see https://flamesofthemist.com/arcdps-guide/
.PARAMETER revert
    Toggle between backup and installed version of ArcDPS. Used to revert or troubleshoot
    a new version of ArcDPS.
.PARAMETER uninstall
    Used to uinstall ArcDPS from your Guild Wars 2 folder.
.EXAMPLE
    PS C:\\> Update-ArcDPS.ps1
    Check for a new version of ArcDPS, and if one is available, download and install it.
.EXAMPLE
    PS C:\\> Update-ArcDPS.ps1 -uninstall
    Deletes ArcDPS and the backup, if it exists.
.EXAMPLE
    PS C:\\> Update-ArcDPS.ps1 -revert
    Reverts to the previous version of ArcDPS. Only works if you have a backup version.
.NOTES
    Author: Frisky.7952
    Last Edit: 6/12/2020
    Version 1.0 - Initial release

    Use this script at your own risk.
    While every effort was made to ensure that this script works as described, all software
    has bugs. No warranty is expressed or implied. No representation as to accuracy or
    completness of this software is expressed or implied.
#>
param(
    [switch]$revert = $false,
    [switch]$uninstall = $false
)

'Update-ArcDPS - ArcDPS Auto-Updater'
Write-Host -ForegroundColor Cyan "                by Frisky.7952"
''
$versionMinimum = [Version]'4.0.0.0'
"PowerShell required version: $versionMinimum"
"         Running PowerShell: $($PSVersionTable.PSVersion)"
if ($versionMinimum -gt $PSVersionTable.PSVersion) {
     Write-Host -ForegroundColor Red "Error: Requires at least PowerShell version $versionMinimum to run."
     exit
}

$ArcDPS_Site = "https://www.deltaconnected.com/arcdps/x64/"
$ArcDPS_DLL = "d3d11.dll"
$ArcDPS_HashFile = $ArcDPS_DLL+".md5sum"

$GuildWars2InstallDirectory = Join-Path $env:ProgramFiles -ChildPath "Guild Wars 2\bin64"

$install_path = Join-Path $GuildWars2InstallDirectory $ArcDPS_DLL

If ($revert) {
    If ($uninstall) {
        Write-Host -ForegroundColor Red "You may only specify either -revert or -uninstall, but not both."
        exit
    }

    try {
        Write-Host "Reverting to backup..."
        $backup_path = "{0}.backup" -f $install_path
        If (-Not (Test-Path $backup_path)) {
            Write-Host "There is currently no backup"
            Write-Host -ForegroundColor Red "ArcDPS could not be reverted"
            exit
        }
        If (Test-Path $install_path) {
            Write-Host "Swapping existing ArcDPS with backup"
            Move-Item $install_path -Destination ("{0}.temp_backup" -f $install_path)
            Move-Item $backup_path -Destination $install_path
            Move-Item ("{0}.temp_backup" -f $install_path) -Destination $backup_path
            If (Test-Path $install_path -NewerThan (Get-Item $backup_path).LastWriteTime) {
                Write-Host -ForegroundColor Cyan "ArcDPS is now newer than backup (Installed)"
            } Else {
                Write-Host -ForegroundColor Cyan "Backup is now newer than ArcDPS (Reverted)"
            }
            Write-Host -ForegroundColor Green "ArcDPS reverted to backup"
        } Else {
            Move-Item $backup_path -Destination $install_path
            Write-Host -ForegroundColor Green "ArcDPS reverted to backup"
        }
    } catch {
        Write-Host -ForegroundColor Red "Error: Could not revert ArcDPS"
    }

    exit
}

If ($uninstall) {
    try {
        Write-Host "Uninstalling ArcDPS..."
        $backup_path = "{0}.backup" -f $install_path
        $was_uninstalled = $false
        If (Test-Path $backup_path) {
            Write-Host "Deleting backup"
            Remove-Item $backup_path
            $was_uninstalled = $true
        }
        If (Test-Path $install_path) {
            Write-Host "Deleting ArcDPS"
            Remove-Item $install_path
            $was_uninstalled = $true
        }
        If ($was_uninstalled) {
            Write-Host -ForegroundColor Green "ArcDPS removed"
        } Else {
            Write-Host -ForegroundColor Cyan "ArcDPS was not currently installed"
        }
    } catch {
        Write-Host -ForegroundColor Red "Error: Could not uninstall ArcDPS"
    }

    exit
}

# download the file
$uri = $ArcDPS_Site+$ArcDPS_DLL
$out = Join-Path $env:TEMP $ArcDPS_DLL
Write-Host ("Requesting file: {0}" -f $uri)
try {
    $response = Invoke-WebRequest -Uri $uri -PassThru -OutFile $out -ErrorAction Stop
    If ($response.StatusCode -eq 200) {
        # now download the MD5 checksum
        $md5_uri = $ArcDPS_Site+$ArcDPS_HashFile
        Write-Host ("Requesting file: {0}" -f $md5_uri)
        $md5_response = Invoke-WebRequest -Uri $md5_uri -ErrorAction Stop
        If ($md5_response.StatusCode -eq 200) {
            $bytes = $md5_response.Content
            $md5_from_site = [System.Text.Encoding]::ASCII.GetString($bytes)
            $md5_from_site = $md5_from_site.SubString(0, $md5_from_site.IndexOf(' ')).ToUpper()
            Write-Host "Validating MD5 checksum..."
            Write-Host ("         MD5: {0}" -f $md5_from_site)
            $md5_of_file = Get-FileHash -Algorithm MD5 -Path $out
            $md5_computed = $md5_of_file.Hash.ToUpper()
            Write-Host ("Computed MD5: {0}" -f $md5_computed)
            If ($md5_from_site -eq $md5_computed) {
                Write-Host "File is legit"
            } Else {
                Write-Host -ForegroundColor Red "Error: Downloaded file does not match MD5 hash"
                exit
            }
        } Else {
            Write-Host -ForegroundColor Red ("Error: {0} failed get ArcDPS MD5 hash" -f $response.StatusCode)
            exit
        }

        $out_file = Get-ChildItem $out
        $last_update = [DateTime]::Parse($response.Headers["Last-Modified"])
        $out_file.LastWriteTime = $last_update
    } Else {
        Write-Host -ForegroundColor Red ("Error: {0} failed get ArcDPS" -f $response.StatusCode)
        exit
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host -ForegroundColor Red ("Error: {0} failed to download ArcDPS" -f $statusCode)
    Write-Host -ForegroundColor Yellow ("Debug: {0}" -f $_.Exception)
    exit
}

# check if the file is newer
$dl_date = (Get-Item $out).LastWriteTime
$need_install = $false
If (Test-Path $install_path) {
    # ArcDPS is currently installed
    $install_exists = $true
    $install_date = ("{0:G}" -f (Get-Item $install_path).LastWriteTime)
    If (Test-Path $install_path -OlderThan $dl_date) {
        # the new version is newer than the installed
        Write-Host ("ArcDPS Site: {0:G}" -f $dl_date)
        Write-Host ("  Installed: {0}" -f $install_date)
        $need_install = $true
    }
} Else {
    # ArcDPS is not even installed
    Write-Host ("ArcDPS Site: {0:G}" -f $dl_date)
    Write-Host "ArcDPS not currently installed."
    $install_exists = $false
    $need_install = $true
    $install_date = "fresh install"
}

If ($need_install) {
    Write-Host ("Updating ArcDPS.. {0}" -f $install_date)
    If ($install_exists) {
        $backup_path = "{0}.backup" -f $install_path
        If (Test-Path $backup_path) {
            Write-Host "Deleting old backup"
            Remove-Item $backup_path
        }

        Write-Host "Backing up current version"
        Move-Item $install_path -Destination $backup_path
    }
    Move-Item -Path $out -Destination $install_path
    Write-Host ("ArcDPS: {0:G}" -f (Get-Item $install_path).LastWriteTime)
    Write-Host -ForegroundColor Green "Installed new version of ArcDPS"
} Else {
    Write-Host ("ArcDPS Site: {0:G}" -f $dl_date)
    Write-Host ("  Installed: {0}" -f $install_date)
    Write-Host -ForegroundColor Green "ArcDPS is already up to date."
}
