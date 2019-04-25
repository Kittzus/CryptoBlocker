#-------------------------------------
# Script: downloadExperiantList.ps1
# Version: v20170717.1.1
# Comments: Downloads current list of extensions from Experiant Consulting
# Author: John Murphy
#-------------------------------------
##Website to download file extensions from##
$website = "https://fsrm.experiant.ca/api/v1/get"
##Location of flat file of extensions##
$filePath = ""
##Name of flat file##
$fileName =""

$webclient = New-Object System.Net.WebClient
$jsonString = $webclient.DownloadString($website)

$filePath = $filePath + $fileName
$jsonString | Out-File $filePath 
