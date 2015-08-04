# ImageBackup
Media file backup Powershell script

Use the script for copying the images and videos for example external backup drive etc.

## Example of use
(Powershell command):
```.\ImageBackup.ps1 -pathFrom c:/temp/from -pathTo c:/temp/to```

# Params
## pathFrom
  Path to the folder which contains the media files. Script doesn't delete the files after execution!
  Files on the <pathFrom> must be on the one level - subfolders aren't suppoerted
## pathTo
  Path to the  folder where the pathFrom folder contents will be copied.
  The structure of the pathTo folder is generated as <year>/<month>_<monthDesc> like:
  
# Organizing logic
* looking the picture taken date --> year is 2015, month is 7 --> copied the file to the folder 2015/07_heina/<file>
* if date taken doesn't found, using file last saved date  
