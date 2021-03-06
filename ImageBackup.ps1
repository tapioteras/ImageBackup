# Author: Tapio Teräs 04.08.2015
# Specs:
# * Copies images and videos from param folder to specified folder structure based on media metadata.
# * Script orders files by year and month by date taken date - If date taken doesn't found, using file last saved date.
# * The month folders are hard coded in Finnish
# * Script doesn't delete the source (parmFrom dir) contents
# Param requirements:
# * All the "pathFrom" param files must be in one folder - subfolders are not supported
# * Script should run as administrator priviligies

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)] [string]$pathFrom,
   [Parameter(Mandatory=$True)] [string]$pathTo)

Write-Host "Getting images form path $pathFrom..."

# declaring the month folder name mappings:
$monthFolders = @{
    1 = "01_tammi";
    2 = "02_helmi";
    3 = "03_maalis";
    4 = "04_huhti";
    5 = "05_touko";
    6 = "06_kesa";
    7 = "07_heina";
    8 = "08_elo";
    9 = "09_syys";
    10 = "10_loka";
    11 = "11_marras";
    12 = "12_joulu"
}

Write-Host "*********************************"

# Image file ref:
[reflection.assembly]::LoadWithPartialName("System.Drawing")

# Getting files from param dir with media file filter:
$files = Get-ChildItem $pathFrom -Recurse | where{$_.Extension -match "gif|jpg|jpeg|png|mov|avi|mpg|mp4"}

# declaring file counter:
$i = 1

# Looping trough the pathFrom dir files:
foreach ($file in $files)
{
    $dateString = ""
    $dateParts = "";

    try
    {
        Write-Host "Trying to read image file $file..."
        
        # Trying to read date taken date from media file metadata:
        $pic = New-Object System.Drawing.Bitmap($file.FullName)
        $ImgBytes = $pic.GetPropertyItem(36867).Value
        $dateString = [System.Text.Encoding]::ASCII.GetString($ImgBytes) 
        
        # Date taken found, parsing:
        if ($dateString)
        {            
            $dateParts = $dateString.Split(": ")
            $dateParts[0] = [int]::Parse($dateParts[0]) # year
            $dateParts[1] = [int]::Parse($dateParts[1]) # month
            $dateParts[2] = [int]::Parse($dateParts[2]) # day
            
            Write-Host "Image #$i date taken at"$dateParts[0]"/"$dateParts[1]"/"$dateParts[2]
        }
    }
    catch [System.Exception], [System.IO.IOException]
    {
       $dateParts = ""
       # Date taken handling caused an error: trying to get the date last saved:
       Write-Warning "Couldn't read date last taken. Using date last saved"
       $dateString = Get-Date $file.LastWriteTime
       Write-Host "Image #$i date last saved at $dateString"
    }
    
    Write-Host "Trying to copy the file to the destination folder..."
    
    try
    {
        # Trying to get file year and month:
        
        if (!$dateParts)
        {
            # Date from date last saved:
            $fileMonth = [int]::Parse($dateString.Month)
            $fileYear = [int]::Parse($dateString.Year)
        }
        else
        {
            # Date from date taken:
            $fileYear = $dateParts[0]
            $fileMonth = $dateParts[1]
        }
        
        # Getting the proper month folder name from month folder mapping hashmap:
        $monthFolder = $monthFolders[[int]$fileMonth]
        
        # Building a dest folder path:
        $filePathTo = "$pathTo/$fileYear/$monthFolder"
        
        Write-Host "Copying file "$file.FullName" to folder $filePathTo/$file... (month $fileMonth)"
        
        # Creating the root folder if not exists:
        if (!(Test-Path -path $filePathTo)) { New-Item $filePathTo -Type Directory }
        
        # Copying the file to the dest folder:
        Copy-Item $file.FullName "$filePathTo/$file" -Recurse -Container
    }
    catch [System.Exception]
    {
        Write-Error "File $file not copied to the destination folder because of error (check param path access or availability)"
        # Terminate the progress with error return code
        return 1
    }
    
    Write-Host ""
    $i++
}

Write-Host "*********************************"
Write-Host "All the ($i pcs) files have been processed"
return 0 