# iagora_deployment



## How to use vm bicep deployment templates

To deploy the virtual machine and associated resources using the provided Bicep template, follow these steps:

### Step 1: Install Azure CLI

Ensure that the Azure CLI is installed. If it is not installed, use the following command:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Step 2: Log in to Your Azure Account

After installing Azure CLI, log in to the Azure account:

```bash
az login
```

This command will open a browser window to log in with Azure credentials. If using a remote machine without a graphical interface, use:

```bash
az login --use-device-code
```

### Step 3: Install Bicep CLI

Once logged in, install Bicep CLI by running:

```bash
az bicep install
```

### Step 4: Upgrade Bicep CLI (Optional)

To ensure the latest version of Bicep is installed, upgrade it using:

```bash
az bicep upgrade
```

### Step 5: Verify Bicep Installation

Verify the Bicep installation by checking the version:

```bash
az bicep version
```

### Step 6: Deploy the Bicep Template

Since all necessary parameters are included directly within the `vm-deploy.bicep` file, there is no need to manage a separate `parameters.json` file. Deploy the resources using the following command:

```bash
az deployment group create --resource-group <your-resource-group> --template-file <path/to/template.bicep> --parameters <key1=value1> <key2=value2>
```

**Explanation of Parameters**:
- **`<your-resource-group>`**: Replace with the name of the Azure resource group where the resources will be deployed.
- **`<path/to/template.bicep>`**: Replace with the path to the Bicep file containing the deployment configuration.
- **`<key1=value1> <key2=value2>`**: Replace with custom parameters to override defaults from the Bicep file.



### Step 7 Customize the Deployment

Parameters can be adjusted directly in the `vm-deploy.bicep` file before running the deployment command. This approach simplifies management and customization of deployments without the need for a separate parameters file.


### Step 8: Verify the Deployment

Parameters can be adjusted directly in the `vm-deploy.bicep` file before running the deployment command. This approach simplifies management and customization of deployments without the need for a separate parameters file.

```bash
az resource list --resource-group <your-resource-group>
```

