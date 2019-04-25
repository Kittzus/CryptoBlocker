CryptoBlocker
==============

This solution allows for numerous types of storage devices to be monitored from a machine running a Windows OS.  

<b> How it Works</b>

If a user attempts to modify or create a malicious file on a monitored storage device, the main script of this proof of concept (PoC) will notify the defined administrator via email of the attempted malicious activity.  If the monitored storage device is distributed from a FreeNAS server, the Samba_server service will be stopped to prevent futher malicious activity.  In addition, all activity occurring on the monitored device will be written to a log file.



<b>Prerequisites</b>

There are two known prerequitesites that must be installed on the machine where the main script will be executed from. [Prerequitesites can be found here.](http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library#Downloads) 

1. Windows Management Framework version 5 or higher
2. PowerShell module SSHSessions, available in the PowerShell gallery


<b>Script Definitions</b>

There are three scripts included in the PoC.  

1. <b>RegisterScheduledTasks.ps1 </b>

    This script will create two separate scheduled tasks within Window's Task Scheduler.  

2. <b>downloadExeriantList.ps1</b>

    This script will execute once daily.  It will pull an updated file extension list from [Experiant Consulting](https://fsrm.experiant.ca/api/v1/get) and save it to a file that will later be used to determine if saved files are malicious in nature.

3. <b>monitorFileshare.ps1</b>

    This script will execute at each system startup and continue running while the system is on.  It monitors a predefined storage locations for changes and analyzes the changes for malicious content.  

<b>Implementation of Proof of Concept</b>

1. Download PoC folder to the computer that will be used for monitoring
2. Update the variables within the scripts to match the environment the scipt will be ran in.
    * downloadExperiantList.ps1 contains two variables that require envirnoment-spcicific values
    * monitorFileshare.ps1 contains numerous environment-specific variables that must be provided.
3. Execute the 'RegisterScheduledTasks.ps1' script.  
4. Execute the 'downloadExperiantList.ps1' script to initialize the extension file.
5. Restart the computer to activate the scheduled start-up event - to start the monitor script.


<b>Usage</b>

<b>This proof of concpet does not stop a ransomware infection from occurring or spreading to other systems.</b> 

These scripts are provided as-is.  This proof of concept does not prevent the loss of data.  It creates an opportunity for an administrator to respond to suspicious activity. 

<b>Acknowledgements</b>

 Portions of this script were modeled from the following sources:

    https://superuser.com/a/844034/413983
    http://www.jonathanmedd.net/2013/08/using-ssh-to-access-linux-servers-in-powershell.html
    http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
    https://stackoverflow.com/questions/23953926/how-to-execute-a-powershell-script-automatically-using-windows-task-scheduler
    https://stackoverflow.com/a/36355678/1885954_
    https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/08/playing-with-json-and-powershell/ 

