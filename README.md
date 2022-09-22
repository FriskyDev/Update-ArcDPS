# Update-ArcDPS.ps1

Automatic software updater for ArcDPS (a Guild Wars 2 add-in DPS meter).

## Description

This program is designed to check the ArcDPS website for updated versions of the
program, and install it into the appropriate Guild Wars 2 folder. The script may
be run over and over, and when newer versions of ArcDPS are found, the newer version
is downloaded, any existing version is backed up, and the new version is installed.

You can use the `-uninstall` option to remove ArcDPS from your Guild Wars 2 folder.

You can use the `-revert` to swap the backup and installed version. Doing this requires
that you have a backup. Reverting a second time swaps the backup again effectively
re-installing the newest version. This cycles back and forth between the two copies
of ArcDPS.

> Warning: Use a DPS meter at your own discretion. See ArcDPS link for more details.

For more information, see the [developer's site (https://deltaconnected.com/...)](https://www.deltaconnected.com/arcdps/).

## Installation and Use

You can simply use the script from a PowerShell command prompt as you normally would. See the examples supplied below.

Or, there are some links (Windows shortcuts) provided that will allow you to run each of
the actions by double-clicking on the appropriate shortcut. The PowerShell window will
remain open after executing the script so you can see the result. Just close the window
or type exit and `Enter`.

The shortcuts use a relative path to the local folder. To move them to your desktop, you will
need to either copy the script to your desktop or place the script in your normal scripts folder
and update either the shortcut path to the script, or the `Start In` folder.

The format of the shortcut target command is as shown (this example is for the revert command):

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit -ExecutionPolicy Bypass -File .\Update-ArcDPS.ps1 -Arguments -revert
```

## Links

* [Regarding ArcDPS use in Guild Wars 2](https://help.guildwars2.com/hc/en-us/articles/360013625034-Policy-Third-Party-Programs)
* [More information in Guild Wars 2](https://welcome.guildwars2.com/)
* [More information on ArcDPS](https://www.deltaconnected.com/arcdps/)
* [Help with ArcDPS](https://flamesofthemist.com/arcdps-guide/)


## Parameters
| Switch | Description |
| :----- | :---------- |
| `-revert` | Toggle between backup and installed version of ArcDPS.<br/> Used to revert or troubleshoot a new version of ArcDPS. |
| `-uninstall` | Used to uinstall ArcDPS from your Guild Wars 2 folder. |

## Examples

Check for a new version of ArcDPS, and if one is available, download and install it.

```
    PS C:\> Update-ArcDPS.ps1
    
```

Deletes ArcDPS and the backup, if it exists.

```
    PS C:\\> Update-ArcDPS.ps1 -uninstall
```

Reverts to the previous version of ArcDPS. Only works if you have a backup version.

```
    PS C:\\> Update-ArcDPS.ps1 -revert
```

## Notes

> Author: Frisky.7952

```
Version 1.0 6/12/2020 - Initial release
```

Use this script at your own risk.
While every effort was made to ensure that this script works as described, all software
has bugs. No warranty is expressed or implied. No representation as to accuracy or
completness of this software is expressed or implied.


```
Version 1.1 6/13/2022 - Update for DirectX 11
```

Updated for use with DX11 (d3d11.dll) in the new location. You can go back to the
old behavior by changing back to the dxd9.dll and add `\bin64` back to the end of
the bin-path.
