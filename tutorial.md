# terraforming the cloud - part 1

![Terraforming the cloud architecture][tfc-arch]

## Temas abordados neste modulo

* Estrutura base de um projecto terraform: `main.tf`, `variables.tf`, `outputs.tf`
* Utilização de `variable`, `data`, `resource` e `output`.
* `terraform.tfvars` é usado por defeito se tiver presente na mesma diretória.
* Os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.
* Gestão de alterações: **simples**, **disruptivas** e **dependentes**.
* Importação de recursos existentes.
* Exercicio final.

**Tempo estimado**: Cerca de 2 horas

**Pré requisitos**: Antes de começares, é necessário verificares algumas coisas:

Certifica-te que tens a `google-cloud-shell` devidamente autorizada correndo este comando:

```bash
gcloud config set project tto-workshops-lab-848993 && gcloud config set accessibility/screen_reader false
```

Garante que tens a extensão da HashiCorp Terraform instalada:

Vai às tuas extensões:

![Cloud Shell Extensions][tfc-cloud-shell-extensions]

<sub>💡Para abrires as imagens clica na mesma com o botão direito do rato e escolhe a opção "Abrir Imagem num novo Separador</sub>

Instala a extensão:

![Cloud Shell Extensions Install][tfc-cloud-shell-extensions-install]

Regressa ao "Explorer":

![Cloud Shell File Explorer][tfc-cloud-shell-explorer]

Para evitar que o terraform peça o nome do projeto a cada `apply`, podemos definir o nome do projeto por defeito:

* Abrir o ficheiro `terraform.tfvars`
* Descomentar a linha `project_id` e adicionar o id do projeto.

Utiliza o comando:

* Windows: **CTRL + K + U**
* Mac: **CMD + K + U**

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

💡Para evitar que o terraform peça o nome do projeto a cada `plan`, podemos definir o nome do projeto por defeito:

* Abrir o ficheiro <walkthrough-editor-select-line filePath="terraform.tfvars" startLine="0" endLine="0" startCharacterOffset="0" endCharacterOffset="200">terraform.tfvars</walkthrough-editor-select-line>.
* Descomentar a linha `project_id` e adicionar o id do projeto que aparece a amarelo na linha de comandos.

Utiliza o comando:

* Windows: **CTRL + K + U**
* Mac: **CMD + K + U**

### Comando `apply`

> *[from docs:](https://www.terraform.io/docs/cli/commands/apply.html) The `terraform apply` command executes the actions proposed in a Terraform plan.*

```bash
terraform apply plan.tfplan
```

⏰ Tempo médio do apply - 1 min.

verificar que o recurso remoto foi criado:

```bash
gcloud compute instances list
```

### Comando `destroy`

> *[from docs:](https://www.terraform.io/docs/cli/commands/destroy.html) The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.*
>
> *While you will typically not want to destroy long-lived objects in a production environment, Terraform is sometimes used to manage ephemeral infrastructure for development purposes, in which case you can use `terraform destroy` to conveniently clean up all of those temporary objects once you are finished with your work.*

```bash
terraform destroy
```

⏰ Tempo médio do destroy - 2 min.

verificar que o recurso remoto foi destruido:

```bash
gcloud compute instances list
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

⏰ Tempo médio do apply - 1 min.

### Tentar entrar para a máquina via SSH

Podem obter o comando a partir do output do terraform, ou usando o comando `gcloud`:

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

> não deverá ser possível fazer ssh porque precisamos de introduzir uma firewall-tag
> vamos então efectuar uma alteração **não-disruptiva**

### 2.1 Introduzindo alterações não-disruptivas

> **As alterações não disruptivas são pequenas alterações que possibilitam a re-configuração do recurso sem que este tenha que ser recriado, não afetando as suas dependências**

* Editar o ficheiro <walkthrough-editor-select-line filePath="main.tf" startLine="57" endLine="57" startCharacterOffset="0" endCharacterOffset="200">main.tf</walkthrough-editor-select-line>, localizar o recurso `google_compute_instance.default` e descomentar o campo `tags = [ "allow-iap" ]` na definição do recurso

Utiliza o comando:

* Windows: **CTRL + K + U**
* Mac: **CMD + K + U**

Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `update in-place` - isto é uma alteração simples.

```bash
terraform plan -out plan.tfplan
```

Executar `terraform apply plan.tfplan`.

```bash
terraform apply plan.tfplan
```

⏰ Tempo médio do apply - 1 min.

Como adicionámos uma tag que permite indicar à firewall o acesso SSH por IAP, podemos então testar novo comando de SSH:

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.2 Introduzindo alterações disruptivas

> **As alterações disruptivas são provocadas por alterações de propriedades que provocam a recriação do recurso e consequentes dependencias**

* No ficheiro <walkthrough-editor-select-line filePath="main.tf" startLine="53" endLine="53" startCharacterOffset="0" endCharacterOffset="200">main.tf</walkthrough-editor-select-line>, localizar o recurso `google_compute_instance.default` e alterar o campo `name` para o seguinte: `"${random_pet.this.id}-vm-new"`
* Executar `terraform plan -out plan.tfplan` e verificar que o Terraform irá efectuar um `replacement` - é uma alteração disruptiva.

```bash
terraform plan -out plan.tfplan
```

Aplicar o `plan`, verificar e acompanhar observando na execução do terraform que irá acontecer um `destroy` seguido de um `create`:

```bash
terraform apply plan.tfplan
```

⏰ Tempo médio do apply - 3 min.

Verificar que o SSH continua a ser possível, mesmo com a nova instância:

<sub>*o comando pode não funcionar logo...pode demorar até 1 minuto depois da VM ser criada.*</sub>

```bash
gcloud compute ssh $(terraform output -raw vm_name) --project=$(terraform output -raw project_id) --zone $(terraform output -raw vm_zone)
```

### 2.3 Introduzindo alterações dependentes

> **As alterações também podem ser derivadas de dependêndencias, e quando isso acontece, todo o grafo de dependendencias é afetado.**

* Editar o ficheiro <walkthrough-editor-select-line filePath="terraform.tfvars" startLine="1" endLine="1" startCharacterOffset="10" endCharacterOffset="13">terraform.tfvars</walkthrough-editor-select-line> e alterar o valor da variavel `prefix` de `gcp` para `new`

Executar o `plan` e verificar todo o grafo de dependencias é afetado:

```bash
terraform plan -out plan.tfplan
```

Executar o `apply`:

```bash
terraform apply plan.tfplan
```

⏰ Tempo médio do apply - 3 min.

*Notem que apenas alterámos uma mera variável...*

>**NOTA: NÃO DESTRUIR OS RECURSOS pois vamos usa-los no próximo passo**

## 3. importar recursos já existentes

Disponível a partir do terraform `v1.5`. Toda a documentação deste capítulo está descrita [aqui](https://developer.hashicorp.com/terraform/tutorials/state/state-import).

> *[from docs:](https://developer.hashicorp.com/terraform/tutorials/state/state-import)Terraform supports bringing your existing infrastructure under its management. By importing resources into Terraform, you can consistently manage your infrastructure using a common workflow.*
>
> *This is a great way to slowly transition infrastructure to Terraform, or to be able to be confident that you can use Terraform in the future if it potentially doesn't support every feature you need today.*

Assegurar que não existem alterações pendentes:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

### 3.1 Criar um recurso (`google_compute_network`) usando os comandos gcloud

Nesta parte vamos criar recursos recorrendo a uma ferramenta externa ao terraform por forma a criar um use-case de recursos que existem fora do `state` do terraform.

O objetivo é simular recursos que já existiam para que os possamos *terraformar*.

Criar uma vpc:

```bash
gcloud compute networks create $(terraform output -raw my_identifier)-vpc --project=$(terraform output -raw project_id) --subnet-mode=custom
```

### 3.2 Importar recursos existentes

O processo de importação de recursos consiste em duas partes:

* obtenção da informação do recurso na cloud
* criação de um bloco `import` que irá indicar ao terraform que o recurso já existe e que o mesmo deve ser gerido pelo terraform.

---

O primeiro passo da importação de recursos é [declarar a importação dos mesmos](https://developer.hashicorp.com/terraform/tutorials/state/state-import).

Para isto, [temos que definir o bloco `import`](https://developer.hashicorp.com/terraform/tutorials/state/state-import#define-import-block), que necessita de dois argumentos:

* `id`: o id do recurso a importar do lado do GCP
* `to`: o identificador terraform do recurso a importar

Exemplo de um bloco `import`:

```hcl
import {
  id = "projects/ten21-terraforming-p-154457/global/networks/somevpc"
  to = google_compute_network.imported
}
```

Para o exercicio que segue, vamos ao ficheiro <walkthrough-editor-select-line filePath="import-exercise.tf" startLine="2" endLine="10" startCharacterOffset="0" endCharacterOffset="200">import-exercise.tf</walkthrough-editor-select-line> e descomentar os blocos `import { ... }`

Utiliza o comando:

* Windows: **CTRL + K + U**
* Mac: **CMD + K + U**

Antes de efetuar a importação precisamos de obter o `id` do recurso a importar do lado do GCP tal como descrito nas instruções de importação para o recurso [`google_compute_network`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#import).

Existem várias formas para obter o `id` dos recursos, neste exemplo usamos os comandos `gcloud`:

Obter o `id` para a `google_compute_network`:

```bash
gcloud compute networks list --uri | grep "$(terraform output -raw my_identifier)" | sed "s~https://www.googleapis.com/compute/v1/~~"
```

Agora que temos o identificador dos recursos, temos que preencher o respetivo `id` no bloco `import`:

* Substituir o `id` do recurso `google_compute_network` no bloco `import` do ficheiro <walkthrough-editor-select-line filePath="import-exercise.tf" startLine="3" endLine="3" startCharacterOffset="8" endCharacterOffset="14">import-exercise.tf</walkthrough-editor-select-line>

---

Vamos então correr o `plan`, mas vamos usar a opção `-generate-config-out` para gerar o código dos recursos que vão ser importados para o ficheiro `imported-resources.tf`:

```bash
terraform plan -out plan.tfplan -generate-config-out imported-resources.tf
```

Podemos inspeccionar os conteudos do ficheiro <walkthrough-editor-select-line filePath="imported-resources.tf" startLine="0" endLine="100" startCharacterOffset="0" endCharacterOffset="200">imported-resources.tf</walkthrough-editor-select-line>.

Por fim, o `apply` para executar a operação planeada:

```bash
terraform apply plan.tfplan
```

Agora, se tentarmos agora fazer `plan` novamente, vamos verificar que o terraform indica que não tem alterações à infraestrutura, confirmando que os recursos foram importados som sucesso.

Testar o `plan`:

```bash
terraform plan -out plan.tfplan
```

## 4. Exercício

Neste exercicio o objectivo é aplicar alguns dos conhecimentos adquiridos nesta sessão sem que exista uma solução pronta para descomentarem 😉.

Prentende-se o seguinte:

* 👉 Devem fazer o exercicio no ficheiro <walkthrough-editor-open-file filePath="final-exercise.tf">final-exercise.tf</walkthrough-editor-open-file>.
* 👉 Criar uma Google Cloud Service Account com os seguintes requisitos:
  * `account_id` deverá ser prefixada com valor definido no recurso `random_pet.this.id` para evitar colisões de nomes
* 👉 Criar uma Google Cloud Compute Instance com os seguintes requisitos:
  * Nome da máquina deverá ser prefixado com valor definido no recurso `random_pet.this.id` para evitar colisões de nomes
  * Tipo de máquina: `e2-small`
  * Zona: `europe-west1-b`
  * Deverá conter uma tag `allow-iap`
  * A rede (`subnetwork`) onde a VM vai correr fica ao vosso critério: podem criar uma nova, ou podem usar as já existentes.
  * A máquina deverá correr com a `google_service_account` previamente criada.
* 👉 Por fim, deverão testar o correto aprovisionamento fazendo `ssh` para a máquina que acabaram de criar.

### Ajudas😵

💡 Usem a pesquisa no terraform registry / google para saberem mais informação acerca dos recursos que estão a usar:

* [`google_service_account`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account)
* [`google_compute_instance`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

Para fazeres ssh faz o seguinte comando:

```bash
gcloud compute ssh <COMPUTE_INSTANCE_NAME> --project <PROJECT-ID> --zone <ZONE-NAME>
```

<sub>💡Preenche os campos necessários com a informação referente à tua Compute Instance Name, Project ID e Zone</sub>

💡 Uma subnet já existente poderá ser <walkthrough-editor-select-line filePath="main.tf" startLine="46" endLine="49" startCharacterOffset="0" endCharacterOffset="200">data.google_compute_subnetwork.default.self_link</walkthrough-editor-select-line>.

💡 Caso não consigam fazer `ssh`, também podem consultar a descrição da VM recorrendo ao comando:

```bash
gcloud compute instances describe COMPUTE_INSTANCE_NAME --zone=COMPUTE_INSTANCE_ZONE
```

## 5. wrap-up & destroy

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

[tfc-arch]: https://github.com/tentwentyone/terraforming-the-cloud-gcp-basic-part1/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"

[tfc-cloud-shell-extensions]: https://github.com/tentwentyone/terraforming-the-cloud-gcp-basic-part1/raw/main/images/cloudshell-extensions.png "Cloud Shell Extensions"

[tfc-cloud-shell-extensions-install]: https://github.com/tentwentyone/terraforming-the-cloud-gcp-basic-part1/raw/main/images/cloudshell-extensions-install.png "Cloud Shell Extensions Install"

[tfc-cloud-shell-explorer]: https://github.com/tentwentyone/terraforming-the-cloud-gcp-basic-part1/raw/main/images/cloudshell-file-explorer.png "Cloud Shell File Explorer"
