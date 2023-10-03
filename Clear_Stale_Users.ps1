Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}
 
#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

Function Clear_Stale_Users()
{
# Prompt the user for the number of days. Uncomment to create 
#$days = Read-Host "Enter the number of days to keep profiles"

# Define the list of users to protect
$protected_users = @("administrator","cplapsadmin","all users","default","default user","public","USEP_Barrett","nate barrett")

# Get a list of all user profiles
$profiles = Get-ChildItem -Path "C:\Users" -Directory

# Loop through each profile and delete if it's older than the specified number of days
foreach ($profile in $profiles) {
    $username = $profile.Name
    $last_write = $profile.LastWriteTime
    
    #$age = New-TimeSpan -Start $last_write -End (Get-Date)
    $age = $last_write | New-TimeSpan
    Write-Host $age
    # Skip the profile if it belongs to a protected user
    if ($protected_users -contains $username) {
        Write-Host "Skipping protected user profile: $username"
        continue
    }
    
    # Delete the profile if it's older than the specified number of days
    if ($age.TotalDays -ge $days) {
        Write-Host "Deleting user profile: $username"
        Remove-Item -Path $profile.FullName -Recurse -Force
        
    }
}
#Exit and delete the script
#Read-Host "Press any key to exit..."
}

#Uncomment the line below to make this interactive
#Check-RunAsAdministrator

#Call Script
Clear_Stale_Users