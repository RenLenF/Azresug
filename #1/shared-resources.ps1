#
# shared-resources.ps1
#
$serverName = $ProjectName + "-plan"
$keyVaultName = $ProjectName + "-keyvault"
$rgLocation = (Get-AzResourceGroup -Name $rgName).Location
New-AzResource -ResourceGroupName $rgName -Location $rgLocation -ResourceType microsoft.web/serverfarms -ResourceName $serverName `
               -kind linux -Properties @{reserved="true"} -Sku @{name="B1";tier="Basic"; size="B1"; family="B"; capacity="1"} -Force

New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName -Location $rgLocation
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $rgName `
                           -ObjectId $MyId -PermissionsToSecrets get,list,set,delete,backup,restore,recover `
                           -PermissionsToKeys decrypt,encrypt,unwrapkey,wrapkey,verify,sign,get,list,update,create,import,delete,backup,restore,recover

$secureString = ConvertTo-SecureString -string "default" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "default" -SecretValue $secureString

$cnt = 0
for($idx=0; $idx -lt 2; $idx++) {
    $name = "secretName" + $idx
    $secureString = ConvertTo-SecureString -string $name -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $name -SecretValue $secureString
}

