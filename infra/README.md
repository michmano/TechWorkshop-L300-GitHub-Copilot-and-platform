# Azure Infrastructure for ZavaStorefront

This directory contains the Bicep templates and configuration files for provisioning Azure infrastructure to host the ZavaStorefront web application.

## Architecture Overview

The infrastructure provisions the following Azure resources in the `westus3` region:

- **Azure Container Registry (ACR)**: Stores Docker container images for the application
- **Linux App Service (Web App for Containers)**: Hosts the containerized .NET 6 application
- **App Service Plan**: Linux-based plan with Basic B1 SKU (suitable for dev environment)
- **Application Insights**: Provides monitoring and telemetry for the web application
- **Log Analytics Workspace**: Backend for Application Insights logs
- **Microsoft Foundry (AI Hub)**: Provides access to GPT-4 and Phi models
- **Storage Account**: Required for AI Hub
- **Key Vault**: Required for AI Hub secure secrets management

## Key Features

- **RBAC-based ACR Access**: App Service uses system-assigned managed identity with AcrPull role assignment (no passwords)
- **No Local Docker Required**: Container builds use `az acr build` (cloud-based builds)
- **Application Monitoring**: Integrated Application Insights for observability
- **AI-Ready**: Microsoft Foundry hub configured for GPT-4 and Phi models
- **Infrastructure as Code**: All resources defined in modular Bicep templates
- **Azure Developer CLI (AZD)**: Simplified deployment workflow with `azd up`

## Directory Structure

```
infra/
├── main.bicep                  # Root orchestration template
├── main.parameters.json        # Parameter values for deployment
├── README.md                   # This file
└── modules/
    ├── acr.bicep              # Azure Container Registry
    ├── appService.bicep       # App Service (Web App)
    ├── appServicePlan.bicep   # App Service Plan
    ├── appInsights.bicep      # Application Insights
    ├── logAnalytics.bicep     # Log Analytics Workspace
    ├── aiHub.bicep            # Microsoft Foundry AI Hub
    ├── storageAccount.bicep   # Storage Account for AI Hub
    ├── keyVault.bicep         # Key Vault for AI Hub
    └── roleAssignment.bicep   # RBAC role assignments
```

## Prerequisites

Before deploying the infrastructure, ensure you have:

1. **Azure Subscription**: An active Azure subscription
2. **Azure CLI**: Version 2.50.0 or later
   ```bash
   az --version
   az login
   ```
3. **Azure Developer CLI (AZD)**: Install from https://aka.ms/azd-install
   ```bash
   azd version
   ```
4. **Permissions**: Sufficient permissions to create resources and assign roles in the subscription

## Deployment Instructions

### Option 1: Using Azure Developer CLI (Recommended)

1. **Initialize AZD** (if not already initialized):
   ```bash
   azd init
   ```
   Follow the prompts to configure your environment.

2. **Preview the deployment** (optional but recommended):
   ```bash
   azd provision --preview
   ```
   This shows what resources will be created without actually creating them.

3. **Provision and deploy** everything:
   ```bash
   azd up
   ```
   This command will:
   - Create all Azure resources
   - Build the Docker container image using ACR
   - Deploy the application to App Service

4. **Get deployment outputs**:
   ```bash
   azd env get-values
   ```
   This displays important values like the web app URL, ACR name, etc.

### Option 2: Using Azure CLI Directly

1. **Create a resource group**:
   ```bash
   az group create --name rg-zavastore-dev-westus3 --location westus3
   ```

2. **Deploy the Bicep template**:
   ```bash
   az deployment group create \
     --resource-group rg-zavastore-dev-westus3 \
     --template-file infra/main.bicep \
     --parameters infra/main.parameters.json \
     --parameters environmentName=dev
   ```

3. **Build and push the Docker image**:
   ```bash
   # Get the ACR name from deployment outputs
   ACR_NAME=$(az deployment group show \
     --resource-group rg-zavastore-dev-westus3 \
     --name main \
     --query properties.outputs.acrName.value -o tsv)
   
   # Build and push image to ACR
   az acr build --registry $ACR_NAME --image zavastore:latest .
   ```

4. **Deploy to App Service**:
   ```bash
   APP_NAME=$(az deployment group show \
     --resource-group rg-zavastore-dev-westus3 \
     --name main \
     --query properties.outputs.appServiceName.value -o tsv)
   
   az webapp config container set \
     --name $APP_NAME \
     --resource-group rg-zavastore-dev-westus3 \
     --docker-custom-image-name $ACR_NAME.azurecr.io/zavastore:latest
   ```

## Parameters

The main deployment parameters are defined in `main.parameters.json`:

- `environmentName`: Environment name (e.g., `dev`, `staging`, `prod`)
- `location`: Azure region (default: `westus3`)
- `dockerImageAndTag`: Container image name and tag (default: `zavastore:latest`)

You can override these during deployment:

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file infra/main.bicep \
  --parameters environmentName=staging location=eastus
```

## Outputs

After successful deployment, the following outputs are available:

- `appServiceUrl`: Public URL of the deployed web application
- `acrLoginServer`: Login server for the Container Registry
- `acrName`: Name of the Container Registry
- `appInsightsName`: Name of the Application Insights instance
- `aiHubName`: Name of the AI Hub (Microsoft Foundry)

View outputs:
```bash
az deployment group show \
  --resource-group <resource-group-name> \
  --name main \
  --query properties.outputs
```

## Updating the Deployment

To update the infrastructure or redeploy the application:

1. **Update infrastructure**:
   ```bash
   azd provision
   ```

2. **Rebuild and redeploy application**:
   ```bash
   azd deploy
   ```

3. **Or do both at once**:
   ```bash
   azd up
   ```

## Cleaning Up Resources

To delete all resources and avoid ongoing charges:

```bash
# Using AZD
azd down

# Or using Azure CLI
az group delete --name rg-zavastore-dev-westus3 --yes --no-wait
```

## Cost Considerations

This infrastructure is configured for a **dev environment** with minimal SKUs:

- ACR: Basic tier
- App Service Plan: Basic B1 (1 core, 1.75 GB RAM)
- Log Analytics: Pay-as-you-go (PerGB2018)
- Storage Account: Standard_LRS
- Key Vault: Standard tier
- AI Hub: Basic tier

**Estimated monthly cost**: ~$55-75 USD (excluding data transfer and AI model usage)

For production workloads, consider:
- ACR: Standard or Premium tier
- App Service Plan: Standard or Premium tier
- Storage Account: Zone-redundant (ZRS) or geo-redundant (GRS)

## Security Notes

- **No Admin Passwords**: App Service pulls images from ACR using managed identity and RBAC (AcrPull role)
- **HTTPS Only**: App Service is configured to enforce HTTPS
- **Soft Delete Enabled**: Key Vault has soft delete enabled (7-day retention)
- **TLS 1.2**: Storage Account requires minimum TLS 1.2
- **Public Access**: Blob public access is disabled on storage account

## Troubleshooting

### Common Issues

1. **ACR Pull Fails**:
   - Ensure the App Service managed identity has AcrPull role on ACR
   - Check that `acrUseManagedIdentityCreds` is set to `true` in App Service config

2. **Application Insights Not Showing Data**:
   - Verify `APPLICATIONINSIGHTS_CONNECTION_STRING` is set in App Service configuration
   - Check that Application Insights SDK is properly initialized in the application

3. **AI Hub Deployment Fails**:
   - Verify that `westus3` region supports Microsoft Foundry
   - Check subscription quotas for Machine Learning workspaces

4. **Deployment Takes Long Time**:
   - Initial deployments may take 10-15 minutes
   - ACR builds depend on application size and complexity

### Get Help

For deployment issues:
```bash
# View deployment operation details
az deployment group show \
  --resource-group <resource-group-name> \
  --name main

# View deployment logs
az monitor activity-log list \
  --resource-group <resource-group-name>
```

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Microsoft Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
