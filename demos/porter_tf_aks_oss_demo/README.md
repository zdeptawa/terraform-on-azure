# Build an Azure + Terraform Cloud Native Application Bundle Using Porter

This exercise will demonstrate building a Terraform based Cloud Native Application Bundle (CNAB) for Azure using Porter.

## Prerequisites

In order to complete this exercise, you will need to have a recent Docker Desktop installed or you'll want to use [Play With Docker](https://labs.play-with-docker.com/) and you'll also need a Docker registry that you can push to. If you don't have one, a free DockerHub account will work. To create one of those, please visit https://hub.docker.com/signup.

You'll also need to make sure Porter is [installed](https://porter.sh/install/).

## Review the terraform/ directory

The `terraform` directory contains a set of Terraform configurations that will utilize the Azure provider to create an Azure Kubernetes Service cluster in an Azure Resource Group. The terraform state file (.tfstate) will be stored remotely in an Azure Storage Account. The files in this directory are not specific for use with CNAB or Porter. If you have other terraform configurations, they can be used here as well if you set up your porter.yaml file correctly as well as any environment variables needed.

## Review the porter.yaml

First, you need a run tool that knows how to execute all the required tools in the proper order with parameters and credentials properly wired to each tool. Next, you need to build a Dockerfile that will contain that run tool, along with all of the supporting tools and configuration. Finally, you need to generate a `bundle.json` that contains a reference to the invocation image along with definitions of parameters, credentials and outputs for the bundle.

Porter was developed to make this experience much easier for anyone that wants to build a bundle. Porter is driven from a single declarative file, called the `porter.yaml`. In this file, you define what capabilities you want to leverage (mixins), define your parameters, credentials and outputs, and then declare what should happen for each action (i.e. install, upgrade, uninstall).

Review the `porter.yaml` to see what each of these sections looks like.

## Update the porter.yaml

Now, update the `porter.yaml` and change the following values:

```
invocationImage: zdeptawa/porter-oss-aks-demo:v0.1.0
tag: zdeptawa/porter-oss-aks-demo:v0.1.0
```

For each of these, change the Docker-like reference to point to your own Docker registry. For example, if my Docker user name is `dockeruser`, I'd change that these lines to:

```
invocationImage: dockeruser/porter-oss-aks-demo:v0.1.0
tag: dockeruser/porter-oss-aks-demo:v0.1.0
```

## Build The Bundle!

Now that you have modified the `porter.yaml`, the next step is to build the bundle. To do that, run the following command.

```
porter build
```

That's it! Porter automates all the things that were required in our manual step. Once this is complete, you can review the generated `Dockerfile`, along with the `bundle.json` in the `.cnab` directory. Now, you can install the bundle using Porter.

## Install the Bundle

In order to install this bundle, you will need Azure credentials in the form of a Service Principal. If you already have a service principal, skip the next section.

### Generating a Service Principal

```
az ad sp create-for-rbac --name oss-demo -o table
```

Once you run this command, it will output a table similar to this:

```
AppId                                 DisplayName         Name                       Password                              Tenant
------------------------------------  ------------------  -------------------------  ------------------------------------  ------------------------------------
<some value>                          oss-demo            http://oss-demo      <some value>                            <some value>
```

Copy these values and move on to setting up your environment variables.

### Setting Environment Variables

You'll need the following Service Principal information, along with an Azure Subscription ID:

* Client ID (also called AppId)
* Client Secret (also called Password)
* Tenant Id (also called Tenant)

You will also need to gather the following information:

* SSH Public Key (most commonly contents of ~/.ssh/id_rsa.pub)
* Backend Storage Account (storage account name where you'd like to store your remote terraform state)
* Backend Storage Container (container name within the storage account)
* Backend Storage Access Key (access key for the storage account)

These will need to be in a set of environment variables for use in generating a CNAB credential set. Set them like this:

```
export TF_VAR_client_id=<CLIENT_ID>
export TF_VAR_tenant_id=<TENANT_ID>
export TF_VAR_client_secret=<CLIENT_SECRET>
export TF_VAR_subscription_id=<SUBSCRIPTION_ID>
export TF_VAR_ssh_public_key=<SSH_PUB_KEY>
export TF_VAR_backend_storage_account=<BACKEND_STORAGE_ACCOUNT_NAME>
export TF_VAR_backend_storage_container=<BACKEND_STORAGE_CONTAINER_NAME>
export TF_VAR_backend_storage_access_key=<BACKEND_STORAGE_ACCOUNT_ACCESS_KEY>
```

### Generate a CNAB CNAB credential set

A CNAB defines one or more `credentials` in the `bundle.json`. In this exercise, we defined these in our `porter.yaml` and the resulting `bundle.json` contains the credential definitions. Before we can install the bundle, we need to create something called a `credential set` that specifies how to map our Service Principal information into these `credentials`. We'll use Porter to do that:

```
porter credentials generate
```

This command will generate a new `credential set` that maps our environment variables to the `credential` in the bundle. Now we're ready to install the bundle.

### Install the Bundle

Now, you're ready to install the bundle. Replace `<your-name>` with a username like `carolynvs`.

```
porter install -c porter-oss-aks-demo
```

### View the Outputs

Now that you've installed the bundle, you can view any outputs that were created with the `porter bundle` command.

```
porter bundle show porter-oss-aks-demo
```

### Uninstall the Bundle

Now that you're done testing, you can uninstall the bundle using the `porter uninstall` command.

```
porter uninstall -c porter-oss-aks-demo
```
