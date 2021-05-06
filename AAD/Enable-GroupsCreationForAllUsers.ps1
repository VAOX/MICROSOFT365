
<##################################################################################################
#
.SYNOPSIS
This will re-enable creating Microsoft 365 Groups for all users
You must have the Preview version of the Azure AD PowerShell module:
    Uninstall-Module AzureAD
    Install-Module AzureADPreview
Source of script:
https://docs.microsoft.com/en-us/microsoft-365/admin/create-groups/manage-creation-of-groups?view=o365-worldwide
.NOTES
    FileName:    Enable-GroupsCreationForAllUsers.ps1
    Author:      Tony Pemberton
    Created:     May 2021
    Revised:     
    Version:     1.0  
    
#>
###################################################################################################

Import-Module AzureADPreview -Force

$GroupName = ""
$AllowGroupCreation = "True"


$CheckForGroup = Get-AzureADGroup -All $true | Where-Object DisplayName -eq $GroupName

if ($CheckForGroup -eq $null -or $CheckForGroup -eq "") {
    New-AzureADGroup -DisplayName $GroupName -SecurityEnabled $true -MailEnabled $false -MailNickName sg-GroupCreators

    $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
    if(!$settingsObjectID)
    {
	      $template = Get-AzureADDirectorySettingTemplate | Where-object {$_.displayname -eq "group.unified"}
        $settingsCopy = $template.CreateDirectorySetting()
        New-AzureADDirectorySetting -DirectorySetting $settingsCopy
        $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
    }

    $settingsCopy = Get-AzureADDirectorySetting -Id $settingsObjectID
    $settingsCopy["EnableGroupCreation"] = $AllowGroupCreation

    if($GroupName)
    {
	    $settingsCopy["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $GroupName).objectid
    } else {
    $settingsCopy["GroupCreationAllowedGroupId"] = $GroupName
    }
    Set-AzureADDirectorySetting -Id $settingsObjectID -DirectorySetting $settingsCopy

    (Get-AzureADDirectorySetting -Id $settingsObjectID).Values

    Write-Host 
    Write-Host "Please add users to the new Security group to enable Groups creation." -ForegroundColor Yellow
    Write-Host
    Write-Host "Script completed." -ForegroundColor Green


} else {

    Write-Host "Security group for Group Creators already exists; no changes will be made." -ForegroundColor Red
    Write-Host 
    Write-Host "Exiting script." -ForegroundColor Red
    Write-Host
}

