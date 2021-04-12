# 00 - terraform-basic

Temas abordados neste modulo:

* Os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.
* Utilização de `variable`, `data`, `resource` e `output`.
* `terrafom.tfvars` é usado por defeito se tiver presente na mesma diretória.
* Gestão de alterações: **simples**, **disruptivas** e **dependentes**.
* Destruição seletiva de recursos.

## o primeiro contacto

```bash
# init
terraform init

# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan

## verificar que o recurso remoto foi criado
gcloud iam service-accounts list --project=tf-gke-lab-01-np-000001

# destroy
terraform destroy

## verificar que o recurso remoto foi destruido
gcloud iam service-accounts list --project=tf-gke-lab-01-np-000001
```

## lidar com as alterações

Assegurar que os recursos foram devidamente destruidos: `terraform destroy`

Recriar os recursos:

```bash
# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan
```

**Introduzindo alterações:**

- Editar o ficheiro `main.tf`, localizar o recurso `google_service_account.default` e alterar o campo `display_name`.
- Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `update in-place` - isto é uma alteração simples.
- Localizar o recurso `google_service_account.default` e alterar o campo `account_id`
- Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `replacement` - é uma alteração disruptiva.

Aplicar o plan:
```bash
terraform apply plan.tfplan
```

**As alterações também podem ser derivadas de dependêndencias, e quando isso acontece, todo o grafo de dependendencias é afetado.**

- Editar o ficheiro `terraform.tfvars` e alterar o valor da variavel `prefix`

Executar o `plan` e verificar todo o grafo de dependencias é afetado
```bash
# plan & observe
terraform plan -out plan.tfplan

# apply & observe
terraform apply plan.tfplan
```
*Notem que apenas alterámos uma mera variável...*

No final, destruir os recursos criados: `terraform destroy`

## destruir seletivamente

Assegurar que os recursos previamente criados foram devidamente destruidos: `terraform destroy`

Recriar os recursos:

```bash
# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan
```

Destruir apenas o recurso `google_service_account.default`:
```bash
# ler o aviso do terraform antes de aceitar
terraform destroy -target="google_service_account.default"
```

No final, destruir os recursos criados: `terraform destroy`

## importar recursos já existentes


Assegurar que os recursos previamente criados foram devidamente destruidos: `terraform destroy`

Recriar os recursos:

```bash
# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan
```

Agora vamos criar uma `service_account` usando cliente `gcloud` e depois vamos importar esse recurso para o nosso terraform state.

Uma vez que o identificador é gerado aleatoriamente, vamos adicionar novos `outputs` ao terraform por forma a obter um valor calculado deterministicamente, para usar posteriormente:

Acrescentar o seguinte conteudo ao ficheiro `outputs.tf`:
```bash
output "imported_service_account_id" {
    value = "${random_pet.this.id}-imported"
}

output "imported_service_account_id_path" {
    value = "projects/${var.project_id}/serviceAccounts/${random_pet.this.id}-imported@${var.project_id}.iam.gserviceaccount.com"
}
```

`plan` e `apply`:
```bash
# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan
```
Observando o resultado, temos novos outputs.

Podemos obter os valores usando o `terraform output`:

Obter o valor do `imported_service_account_id`:
```bash
terraform output imported_service_account_id
```

Com esse valor, vamos criar então a `service_account`:

```bash
# criar a service_account
gcloud iam service-accounts --project=tf-gke-lab-01-np-000001 create $(terraform output imported_service_account_id)
```

Agora que temos um recurso "rogue", podemos então importa-lo.

Antes de importar, é preciso criar o recurso.
* No ficheiro `main.tf` acrescentar o seguinte no final do ficheiro:
```bash
resource "google_service_account" "imported" {
  account_id = "${random_pet.this.id}-imported"
  project = data.google_project.this.project_id
}
``` 
Neste momento, se executarmos o `plan` o terraform vai tentar criar o recurso, pois não sabe que existe um igual já criado. Se por ventura avançarmos com a criação, esta vai falhar devido a um conflito.

```bash
terraform plan -out plan.tfplan
```

Por esse motivo, é que o temos que importar para o estado primeiro.

Agora podemos proceder à importação do recurso:

```bash
terraform import google_service_account.imported "$(terraform output imported_service_account_id_path)"
```

Se tudo correr bem, o recurso foi importado com sucesso, e passou agora a ser gerido pelo state do terraform. 

**Todas as futuras alterações a este recurso passam a ser feitas por Terraform.**

Se executarmos o `plan` é possível confirmar que não existem alterações:

```bash
terraform plan -out plan.tfplan
```

No final, destruir os recursos criados: 
```bash
terraform destroy
```