#
# post-configuration.ps1
#
$keyVaultName = $ProjectName + "-keyvault"
$appName = $ProjectName + "-setter"
$rgLocation = (Get-AzResourceGroup -Name $rgName).Location

Set-AzWebApp -ResourceGroupName $rgName -Name $appName -AssignIdentity $True
$appId = (Get-AzWebApp -ResourceGroupName $rgName -Name $appName).identity. PrincipalId

Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $rgName `
                           -ObjectId $appId -PermissionsToSecrets get,list,set,delete,backup,restore,recover 