# terraforming the cloud - part 1

Temas abordados neste modulo:

* Os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.
* Estrutura base de um projecto terraform: `main.tf`, `variables.tf`, `outputs.tf`
* Utilização de `variable`, `data`, `resource` e `output`.
* `terrafom.tfvars` é usado por defeito se tiver presente na mesma diretória.
* Gestão de alterações: **simples**, **disruptivas** e **dependentes**.
* Destruição seletiva de recursos.

## preparar o ambiente

**autenticar a consola com o GCP**
- Abrir o endereço <https://console.cloud.google.com> e autenticar

```bash
gcloud config set project tf-gke-lab-01-np-000001
``` 

**clonar o projecto git que vamos usar**
```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part1 && cd terraforming-the-cloud-part1
```

**obter a última versão do terraform**
```bash
sudo scripts/install-terraform.sh
```

## 1. o primeiro contacto

```bash
# init
terraform init

# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan

## verificar que o recurso remoto foi criado
gcloud compute instances list --project tf-gke-lab-01-np-000001

# destroy
terraform destroy

## verificar que o recurso remoto foi destruido
gcloud compute instances list --project tf-gke-lab-01-np-000001
```

## 2. lidar com as alterações

> *Assegurar que os recursos previamente criados foram devidamente destruidos: `terraform destroy`.`*

**Assegurar a recriação dos recursos (`plan` e `apply`):**
```bash
# plan
terraform plan -out plan.tfplan

# apply
terraform apply plan.tfplan
```

**Tentar entrar para a máquina via SSH**
```bash
# podem obter o comando a partir do output do terraform, ou executar o seguinte
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

> não deverá ser possível fazer ssh porque precisamos de introduzir uma firewall-tag
> vamos então efectuar uma alteração **não-disruptiva**

### 2.1 Introduzindo alterações não-disruptivas

> **As alterações não disruptivas são pequenas alterações que possibilitam a re-configuração do recurso sem que este tenha que se recriado, não afetando as suas dependências**

- Editar o ficheiro `main.tf`, localizar o recurso `google_compute_instance.default` e descomentar o campo `tags = [ "allow-iap" ]` na definição do recurso
- Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `update in-place` - isto é uma alteração simples.


Como adicionámos uma tag que permite indicar à firewall o acesso SSH por IAP, podemos então testar novo comando de SSH:
```bash
# para entrar via SSH
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.2 Introduzindo alterações disruptivas

> **As alterações disruptivas são provocadas por alterações de propriedades que provocam a recriação do recurso e consequentes dependencias**

- Localizar o recurso `google_compute_instance.default` e alterar o campo `name` para o seguinte: `"${random_pet.this.id}-vm-new"`
- Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `replacement` - é uma alteração disruptiva.

Aplicar o plan e verificar e acompanhar verificando que irá acontecer um `destroy` seguido de um `create`:
```bash
terraform apply plan.tfplan
```

Verificar que o SSH continua a ser possível, mesmo com a nova instância:
```bash
# para entrar via SSH
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.3 Introduzindo alterações dependentes

> **As alterações também podem ser derivadas de dependêndencias, e quando isso acontece, todo o grafo de dependendencias é afetado.**

- Editar o ficheiro `terraform.tfvars` e alterar o valor da variavel `prefix` de `nos` para `woo`

Executar o `plan` e verificar todo o grafo de dependencias é afetado
```bash
# plan & observe
terraform plan -out plan.tfplan

# apply & observe
terraform apply plan.tfplan
```
*Notem que apenas alterámos uma mera variável...*

>**NOTA: NÃO DESTRUIR OS RECURSOS pois vamos usa-los no próximo passo**

## 3. importar recursos já existentes

**Assegurar que não existem alterações pendentes:**

```bash
# plan
terraform plan -out plan.tfplan

# apply (caso não esteja up-to-date)
terraform apply plan.tfplan
```


### 3.1 Criar uma vpc e respetiva subnet usando os comandos gcloud**
```bash
gcloud compute networks create $(terraform output -raw my_identifier) --project=tf-gke-lab-01-np-000001 --subnet-mode=custom

gcloud compute networks subnets create default-subnet --project=tf-gke-lab-01-np-000001 --range=10.0.0.0/9 --network=$(terraform output -raw my_identifier) --region=$(terraform output -raw region) 
```

### 3.2 Criar os recursos manualmente

Ir ao ficheiro `import-exercise.tf` e descomentar o bloco `resource "google_compute_network" "imported"`

1. SE tentarem efectuar o `plan` e `apply` irá dar um erro pois o recurso já existe.
2. Terá que ser importado para o state do terraform

Proceder à importação do recurso:
```bash
terraform import google_compute_network.imported projects/$(terraform output -raw project_id)/global/networks/$(terraform output -raw my_identifier)
```
---

Ir ao ficheiro `import-exercise.tf` e descomentar o bloco `resource "google_compute_subnetwork" "imported"`

1. SE tentarem efectuar o `plan` e `apply` irá dar um erro pois o recurso já existe.
2. Terá que ser importado para o state do terraform

Proceder à importação do recurso:
```bash
terraform import google_compute_subnetwork.imported projects/$(terraform output -raw project_id)/regions/$(terraform output -raw region)/subnetworks/default-subnet
```

### 3.3 Criar novos recursos dependentes dos recursos importados

Neste passo iremos criar novos recursos (mais uma Virtual Machine) que irão precisar dos recursos que foram previamente importados.

- Descomentar os seguintes blocos no ficheiro `import-exercise.tf`
  - `resource "google_compute_instance" "vm2"`
  - `resource "google_compute_firewall" "imported_iap"`

Executar o `plan` e `apply` e verificar que os novos recursos vão ser criados usando as dependências que foram importadas previamente:
```bash
# plan & observe
terraform plan -out plan.tfplan

# apply & observe
terraform apply plan.tfplan
```

Após a criação dos recursos, podem (se quiserem) fazer SSH para a nova instância usando a *hint* dada pelo comando em output `terraform output vm2`.


No final, destruir os recursos criados: 
```bash
terraform destroy
```

🔚🏁 Chegámos ao fim 🏁🔚

## Comandos úteis

```bash
# obter a lista de machine-types
gcloud compute machine-types list --zones=europe-west1-b --sort-by CPUS

# listar a lista de regioes disponiveis
gcloud compute regions list

# listar as zonas disponiveis para uma dada regiao
gcloud compute zones list | grep europe-west1

# listar VMs para um dado projecto
gcloud compute instances list --project tf-gke-lab-01-np-000001

# ligar à VM usando o IAP
cloud compute ssh <vm-name> --project=tf-gke-lab-01-np-000001 --zone europe-west1-b
```