The purpose of the project is to create an Azure AKS-native, scalable solution, that receives messages from a Service Bus queue and stores them in a blob container.

It uses Terraform to perform the following:
- Creating an Azure container registry
- Building the Python code for message processing as a Docker image and pushing it to the registry
- Creating the Azure Service Bus and Storage Account
- Creating the Kubernetes cluster with Karpenter and KEDA enabled
- Deploying the message processor as a ScaledJob, with a dedicated NodePool, using a Helm chart

### Prerequisites:

- Azure CLI installed and configured
- Terraform installed
- Docker installed
- kubectl installed

### Environment setup

1. Login to your Azure subscription (`az login`)
2. Provide the URL of this Git repository as a Terraform variable:
```
cat <<EOF > terraform/terraform.tfvars
git_repo = "https://..."
EOF
```
Other variables in `terraform/variables.tf` are optional.

3.
```
export ARM_SUBSCRIPTION_ID=<your Azure subscription ID>
```
4. Run:
```
./deploy.sh
```
This will create the entire setup of the application using Terraform.

The environment details will be displayed at the end as Terraform outputs.

#### Testing:
In the Azure portal, go to the **Service Bus queue** and click on **Send messages**.
Provide some text and click **Send**.
Then go to the **Storage Account container** and verify that a file with the message content was created.


### Teardown

Run:
```
./delete.sh
```
This will delete the Terraform setup.