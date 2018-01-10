#-------------------------------------
# Script: RegisterScheduledTasks.ps1
# Version: v20170717.1.1
# Comments: Creates Scheduled Tasks
# Author: John Murphy
#-------------------------------------
##Scheduled Task for updataing extension list daily
## $filePath1 must be the full path of the 'downloadExperiantList.ps1' script included in the repository
$filePath1 = "downloadExperiantList.ps1"
$trigger1 = New-ScheduledTaskTrigger -Daily -At 5am

Register-ScheduledJob -Name DownloadList -FilePath $filePath1 -Trigger $trigger1

##Scheduled Task for starting monitor script during startup of computer
## $filePath2 must be the full path of the 'monitorFileShare.ps1' script included in the repository
$filePath2 = "monitorFileShare.ps1"
$trigger2 = New-ScheduledTaskTrigger -AtStartup

Register-ScheduledJob -Name MonitorFileShare -FilePath $filePath2 -Trigger $trigger2