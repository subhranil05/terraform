# This challange is to create AWS resources and deploy it via terraform


## Now follow the terraform files to create Docker resources and deploy it via terraform


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