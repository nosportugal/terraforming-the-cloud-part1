# terraforming the cloud - part 1

![Terraforming the cloud architecture][tfc-arch]

## Temas abordados neste modulo

* Estrutura base de um projecto terraform: `main.tf`, `variables.tf`, `outputs.tf`
* Utilização de `variable`, `data`, `resource` e `output`.
* `terrafom.tfvars` é usado por defeito se tiver presente na mesma diretória.
* Os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.
* Gestão de alterações: **simples**, **disruptivas** e **dependentes**.
* Destruição seletiva de recursos.

**Tempo estimado**: Cerca de 2 horas

Antes de começares, certifica-te que tens a `google-cloud-shell` devidamente autorizada correndo este comando:

```bash
gcloud config set project tf-gke-lab-01-np-000001
```

De seguida, clica no botão **Start** para começares.

## 1. o primeiro contacto

Nesta secção iremos executar os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.

### Comando `init`

> *[from docs:](https://www.terraform.io/docs/cli/commands/init.html) The `terraform init` command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.*

```bash
terraform init
```

### Comando `plan`

> *[from docs:](https://www.terraform.io/docs/cli/commands/plan.html) The `terraform plan` command creates an execution plan. By default, creating a plan consists of:*
>
> * *Reading the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.*
> * *Comparing the current configuration to the prior state and noting any differences.*
> * *Proposing a set of change actions that should, if applied, make the remote objects match the configuration.*

```bash
terraform plan -out plan.tfplan
```

### Comando `apply`

> *[from docs:](https://www.terraform.io/docs/cli/commands/apply.html) The `terraform apply` command executes the actions proposed in a Terraform plan.*

```bash
terraform apply plan.tfplan
```

verificar que o recurso remoto foi criado:

```bash
gcloud compute instances list --project tf-gke-lab-01-np-000001
```

### Comando `destroy`

> *[from docs:](https://www.terraform.io/docs/cli/commands/destroy.html) The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.*
>
> *While you will typically not want to destroy long-lived objects in a production environment, Terraform is sometimes used to manage ephemeral infrastructure for development purposes, in which case you can use `terraform destroy` to conveniently clean up all of those temporary objects once you are finished with your work.*

```bash
terraform destroy
```

verificar que o recurso remoto foi destruido:

```bash
gcloud compute instances list --project tf-gke-lab-01-np-000001
```

## 2. lidar com as alterações

Nesta secção iremos demonstrar a utilização de terraform perante varios tipos de alterações.

> *Assegurar que os recursos previamente criados foram devidamente destruidos: `terraform destroy`.`*

### Assegurar a recriação dos recursos (`plan` e `apply`)

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

### Tentar entrar para a máquina via SSH

Podem obter o comando a partir do output do terraform, ou usando o comando `gcloud`:

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

> não deverá ser possível fazer ssh porque precisamos de introduzir uma firewall-tag
> vamos então efectuar uma alteração **não-disruptiva**

### 2.1 Introduzindo alterações não-disruptivas

> **As alterações não disruptivas são pequenas alterações que possibilitam a re-configuração do recurso sem que este tenha que se recriado, não afetando as suas dependências**

* Editar o ficheiro `main.tf`, localizar o recurso `google_compute_instance.default` e descomentar o campo `tags = [ "allow-iap" ]` na definição do recurso
* Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `update in-place` - isto é uma alteração simples.

Como adicionámos uma tag que permite indicar à firewall o acesso SSH por IAP, podemos então testar novo comando de SSH:

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.2 Introduzindo alterações disruptivas

> **As alterações disruptivas são provocadas por alterações de propriedades que provocam a recriação do recurso e consequentes dependencias**

* Localizar o recurso `google_compute_instance.default` e alterar o campo `name` para o seguinte: `"${random_pet.this.id}-vm-new"`
* Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `replacement` - é uma alteração disruptiva.

Aplicar o `plan`, verificar e acompanhar observando na execução do terraform que irá acontecer um `destroy` seguido de um `create`:

```bash
terraform apply plan.tfplan
```

Verificar que o SSH continua a ser possível, mesmo com a nova instância:

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.3 Introduzindo alterações dependentes

> **As alterações também podem ser derivadas de dependêndencias, e quando isso acontece, todo o grafo de dependendencias é afetado.**

* Editar o ficheiro `terraform.tfvars` e alterar o valor da variavel `prefix` de `nos` para `woo`

Executar o `plan` e verificar todo o grafo de dependencias é afetado:

```bash
terraform plan -out plan.tfplan
```

Executar o `apply`:

```bash
terraform apply plan.tfplan
```

*Notem que apenas alterámos uma mera variável...*

>**NOTA: NÃO DESTRUIR OS RECURSOS pois vamos usa-los no próximo passo**

## 3. importar recursos já existentes

Nesta secção iremos abordar um comando particularmente útil: `terraform import`

> *[from docs:](https://www.terraform.io/docs/cli/import/index.html)Terraform is able to import existing infrastructure. This allows you take resources you've created by some other means and bring it under Terraform management.*
>
> *This is a great way to slowly transition infrastructure to Terraform, or to be able to be confident that you can use Terraform in the future if it potentially doesn't support every feature you need today.*

Assegurar que não existem alterações pendentes:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

### 3.1 Criar uma vpc e respetiva subnet usando os comandos gcloud

Nesta parte vamos criar recursos recorrendo a uma ferramenta externa ao terraform por forma a criar um use-case de recursos que existem fora do `state` do terraform.

O objetivo é simular recursos que já existiam para que os possamos *terraformar*.

Criar uma vpc:

```bash
gcloud compute networks create $(terraform output -raw my_identifier)-vpc --project=$(terraform output -raw project_id) --subnet-mode=custom
```

Criar uma subnet:

```bash
gcloud compute networks subnets create $(terraform output -raw my_identifier)-subnet --project=$(terraform output -raw project_id) --range=10.0.0.0/9 --network=$(terraform output -raw my_identifier)-vpc --region=$(terraform output -raw region)
```

### 3.2 Importar os recursos para o terraform state

Agora iremos colocar em prática os comandos de `import` para passar a gerir os recursos pelo terraform.

Ir ao ficheiro `import-exercise.tf` e descomentar os blocos

* `resource "google_compute_network" "imported"`
* `resource "google_compute_subnetwork" "imported"`

1. SE tentarem efectuar o `plan` e `apply` irá dar um erro pois o recurso já existe.
2. Terá que ser importado para o state do terraform

Verificar que o terraform vai tentar criar os recursos porque ainda não estão importados:

Executar o `plan` seguido pelo `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

**O que vai acontecer é que o GCP vai retornar um erro `4xx` indicando que estamos a tentar criar um recurso que já existe - é normal e esperado pois precisamos de proceder à importação.**

---

Para proceder à importação, precisamos de obter o `self_link` do recurso a importar do lado do GCP tal como descrito nas instruções de importação para o recurso [`google_compute_network`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#import) e [`google_compute_subnetwork`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork#import).

Se precisarem, podem obter o `uri` do recurso usando os seguinte comandos

Obter o `uri` para a `google_compute_network`:

```bash
gcloud compute networks list --uri | grep "$(terraform output -raw my_identifier)"
```

Importar o recurso:

```bash
terraform import google_compute_network.imported projects/$(terraform output -raw project_id)/global/networks/$(terraform output -raw my_identifier)-vpc
```

---

Agora temos que fazer o mesmo para o recurso `google_compute_subnetwork`.

Obter o `uri` para a `google_compute_subnetwork`:

```bash
gcloud compute networks subnets list --uri | grep "$(terraform output -raw my_identifier)"
```

Importar o recurso:

```bash
terraform import google_compute_subnetwork.imported projects/$(terraform output -raw project_id)/regions/$(terraform output -raw region)/subnetworks/$(terraform output -raw my_identifier)-subnet
```

> Agora, se tentarmos agora fazer `plan`, vamos verificar que o terraform indica que não tem alterações à infraestrutura, confirmando que os recursos foram importados som sucesso.

Testar o `plan`:

```bash
terraform plan -out plan.tfplan
```

### 3.3 Criar novos recursos dependentes dos recursos importados

Neste passo iremos criar novos recursos (mais uma Virtual Machine) que irão precisar dos recursos que foram previamente importados.

* Descomentar os seguintes blocos no ficheiro `import-exercise.tf`
  * `resource "google_compute_instance" "vm2"`
  * `resource "google_compute_firewall" "imported_iap"`

Executar o `plan` e `apply` e verificar que os novos recursos vão ser criados usando as dependências que foram importadas previamente:

Observar o `plan`:

```bash
terraform plan -out plan.tfplan
```

Observar o `apply`:

```bash
terraform apply plan.tfplan
```

> **Tip**: após a criação dos recursos, podem fazer SSH para a nova instância usando a *hint* dada pelo comando em output.

```bash
terraform output vm2
```

## 4. wrap-up & destroy

Destruir os conteúdos!

```bash
terraform destroy
```

🔚🏁 Chegámos ao fim 🏁🔚

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-disable-file MD033 -->

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[tfc-arch]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"
