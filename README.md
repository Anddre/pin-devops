## Repo para proyecto pin mundose



## Como correrlo

Crear el archivo terraform.tfvars con los datos de acceso a aws usando como base terraform.tfvars-sample.

```bash

$ terraform init

$ terraform validate

$ terraform plan

$ terraform apply

$ terraform destroy
```



## Conectarse a la instancia

```bash

# Cambiarle los permisos a la key generada
$ chmod 400 key.pem

$ ssh -i "key.pem" ubuntu@IP_INSTANCIA_EC2


```