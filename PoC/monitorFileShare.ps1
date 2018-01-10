<#----------------------------------------------------------
	Script:		monitorFileShare.ps1
	Version: 	v20170717
	Comments:	Sets up FileSystemWatchers and responds
				to potentially harmful file changes
	Author:		John Murphy
----------------------------------------------------------#>
<#VARIABLE DECLARATION#>
##	A FileSystemWatcher is defined for each storage area that requires monitoring.
	$watcher = New-Object System.IO.FileSystemWatcher	##	Defines Storage area to monitor
	$watcher.Path = ""									##	Path to storage area to monitor
	$watcher.Filter = "*.*"								##	Defines what files to monitor within Storage area
	$watcher.IncludeSubdirectories = $true				##	Watcher monitoring depth
	$watcher.EnableRaisingEvents = $true				##	Allows $watcher to take action on events
##	------------------------------------------------------------------------------------------------
##	JSON extension file loading - Loads extension to monitor for into local variable
	$jsonFile = ""										##	Complete path to file saved by script 'downloadExperiantList.ps1'
	$jsonString = Get-Content -Raw -Path $jsonFile		##	Converts file to string
	$json = $jsonString | ConvertFrom-json				##	Converts string to object containing the extensions to monitor
##	------------------------------------------------------------------------------------------------
##	Email notification - Used to send email notification to defined administrator
	$senderEmail = ""									##	From email address
	$senderPassword = ""								##	Password for 'From' email address
	$receiverEmail = ""									##	Email of administrator to notify
	$smtpServer = ""									##	SMTP server to use when sending email
	$smtpSendPort = ""									##	port used to send SMTP email (587)
##	------------------------------------------------------------------------------------------------
##	FreeNAS Samba Server - Used to disable Samba server on FreeNAS
	$freenasRoot = "root"								##	FreeNAS user with access to shutting down a service
	$rootPassword = ""									##	Password of above FreeNAS user
	$freenasName = ""									##	Server name, FQDN, or IP address of FreeNAS server
##	------------------------------------------------------------------------------------------------
##	Log file - used to log events detected by $watcher
	$logFile = ""										##	Full path to location where log file will be stored
<#END VARIABLE DECLARATION#>
##-------------------------------------------
##	Function:	Send-ToEmail
##	Purpose:	Sends email to predefined administrator 
##				using credentials provided in variable declaration
##-------------------------------------------
function Send-ToEmail($extension, $path){
    $emailMessage = New-Object Net.Mail.MailMessage
    $emailMessage.From = $senderEmail
    $emailMessage.To.Add($receiverEmail)
    $emailMessage.Subject = "Suspicious File Detected"
    $emailMessage.Body = "A suspicious file was detected located at $path"

    $smtpClient = New-Object Net.Mail.SmtpClient($smtpServer,$smtpSendPort)
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($senderEmail,$senderPassword)
    $smtpClient.Send($emailMessage)
    Write-Host "Message Sent"
}
##-------------------------------------------
##	Function:	Disable-FreeNAS-Samba
##	Purpose:	Stops Samba-Server service on FreeNAS server
##	Prerequisites:	Requires WMF v5 and higher
##					Requires Module = SshSessions
##-------------------------------------------
function Disable-FreeNAS-Samba(){
    New-SshSession -ComputerName $freenasName -Username $freenasRoot -Password $rootPassword
    Invoke-SshCommand -ComputerName $freenasName -Command "service samba_server stop"
    Remove-SshSession -ComputerName $freenasName
    Write-Host "Samba has been stopped"
}
##------------------------------------------
## Define Actions to take after an event is detected
##------------------------------------------
$action = { $path = $Event.SourceEventArgs.FullPath
	$fileName = Split-Path $path -Leaf
	$changeType = $Event.SourceEventArgs.ChangeType
	$user = $env:USERNAME
	$logline = "$(Get-Date), $changeType, $path, $user, $computer"
	Add-content $logFile -value $logline
	Write-Host "The file '$fileName' was '$changeType' by '$user'"
	foreach($obj in $json.filters)
	{
		if("$fileName" -like "$obj")
		{
			Disable-FreeNAS-Samba
			Send-ToEmail($obj,$path)
		}
	}
	Write-Host "Action Complete"             
}
##------------------------------------------
## Register events to monitor
##------------------------------------------
Register-ObjectEvent $watcher "Created" -Action $action 
Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Deleted" -Action $action
Register-ObjectEvent $watcher "Renamed" -Action $action
while($true){Start-Sleep 5}


<# Portions of this script were modeled from the following sources:
	https://superuser.com/a/844034/413983
	http://www.jonathanmedd.net/2013/08/using-ssh-to-access-linux-servers-in-powershell.html
	http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
	https://stackoverflow.com/questions/23953926/how-to-execute-a-powershell-script-automatically-using-windows-task-scheduler
	https://stackoverflow.com/a/36355678/1885954_
	https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/08/playing-with-json-and-powershell/
#>