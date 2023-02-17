# This challange is to create Kubernetes resources and deploy it via terraform


## Install terraform

### GPG is required for the package signing key

```sh
    sudo apt update && sudo apt install gpg
```

### Download the signing key to a new keyring

```sh
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```
 ### Add the HashiCorp repo

```sh
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

### update packages

```sh
    sudo apt update 
```

### Install a specific terraform version package

```sh
    sudo apt install terraform=1.1.5
```

## Now follow the terraform files to create Kubernetes resources and deploy it via terraform


### Check the provider informations, initialize terraform working directory and validate terraform syntax

```sh
    terraform init
    terraform validate
```

### Check terraform plan and if all good deploy

```sh
    terraform plan
    terraform apply --auto-approve
```


### Destroy the resources after all validations passed

```sh
    terraform destroy --auto-approve
```