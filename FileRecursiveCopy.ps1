# Copies source files recursively to destination folder in one level (no subfolders)
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)] [string]$Source,
   [Parameter(Mandatory=$True)] [string]$Dest)

Get-ChildItem $Source -Recurse | % {
    if (!((Get-Item $_.fullname) -is [System.IO.DirectoryInfo]))
    {
        Write-Host "Copying $_.fullname to destination folder $Dest..."
        Copy-Item $_.fullname "$Dest" -Recurse -Force
    }
}