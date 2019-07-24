#
# setter-resources.ps1
#
$appName = $ProjectName + "-setter"
$serverName = $ProjectName + "-plan"
$keyVaultName = $ProjectName + "-keyvault"
$Today = Get-Date -Format "yyyyMMdd"
$storageName = $ProjectName + $Today + "sa"

$rgLocation = (Get-AzResourceGroup -Name $rgName).Location
$serverId = (Get-AzResource -ResourceGroupName $rgName -ResourceType microsoft.web/serverfarms -Name $serverName).ResourceId


New-AzResource -ResourceGroupName $rgName -Location $rgLocation -ResourceType Microsoft.Storage/storageAccounts -ResourceName $storageName `
               -kind "StorageV2" -Sku @{name="Standard_LRS";tier=0} -Properties @{AccessTier="Hot"} -Force
$storageKey = Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $storageName
$connectionString = "DefaultEndpointsProtocol=https;AccountName=" + $storageName + ";AccountKey=" + $storageKey + "2019-04-01"
$prop=@{serverFarmId=$serverId;`
        siteConfig=@{`
            "nodeVersion"="10.14.1";`
            "linuxFxVersion"="DOCKER|mcr.microsoft.com/azure-functions/node:2.0-node8-appservice";
            "appSettings"=@(@{name="AzureWebJobsStorage";value=$connectionString };`
                            @{name="WEBSITE_RUN_FROM_PACKAGE";value=$zipUrl};`
                            @{name="FUNCTIONS_WORKER_RUNTIME";value="node" };`
                            @{name="WEBSITE_NODE_DEFAULT_VERSION";value="10.14.1"};`
                            @{name="FUNCTIONS_EXTENSION_VERSION";value="2"};`
                            @{name="VAULT_NAME";value=$keyVaultName}`
                          );`
            "cors"=@{allowedOrigins=@("*")};`
            "reserved"="true"`
        };`
        identity=@{type="SystemAssigned"}}

New-AzResource -ResourceGroupName $rgName -Location $rgLocation -ResourceType Microsoft.Web/sites `
               -ResourceName $appName -kind "functionapp,linux,container"  -Properties $prop -Force