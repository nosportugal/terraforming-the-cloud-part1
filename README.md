# terraforming the cloud - part 1

![Terraforming the cloud architecture][tfc-arch]

Temas abordados neste modulo:

* Os 4 principais comandos de terraform: `init`, `plan`, `apply` e `destroy`.
* Estrutura base de um projecto terraform: `main.tf`, `variables.tf`, `outputs.tf`
* Utilização de `variable`, `data`, `resource` e `output`.
* `terrafom.tfvars` é usado por defeito se tiver presente na mesma diretória.
* Gestão de alterações: **simples**, **disruptivas** e **dependentes**.
* Destruição seletiva de recursos.

## iniciar o tutorial (setup automatico)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/calexandre/terraforming-the-cloud-part1&cloudshell_tutorial=tutorial.md)

---

## setup do ambiente (manual)

Esta secção explica como preparar o IDE para poderem executar os comandos do tutorial.

Abaixo seguem dois guias para configuração em:

1. Google Cloud Shell
2. Visual Studio Code

### configurar a cloud shell

Abrir o endereço <https://console.cloud.google.com> e autenticar.

De seguida, ativar a cloud shell:

![tfc-cloudshell-activate]

Abrir em nova janela:

![tfc-cloushell-open-new]

Abrir editor:

![tfc-cloushell-open-editor]

Fechar a janela do terminal no fundo:

![tfc-cloushell-close-terminal]

Abrir novo terminal (embebido no editor):

![tfc-cloushell-new-terminal]

Clonar o projeto:

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part1 && cd terraforming-the-cloud-part1
```

Abrir o editor na pasta do projeto:

![tfc-cloushell-open-folder]

E agora que têm o editor pronto, podemos autenticar a consola com o GCP:

```bash
gcloud config set project tf-gke-lab-01-np-000001
```

Para iniciar o tutorial, executamos o seguinte comando na consola:

```bash
teachme tutorial.md
```

## configurar o vscode

> apenas válido para vscode em WSL (windows-subsystem-linux) - instalações em powershell não são suportadas

Caso decidam usar o `vscode`, é necessário garantirem que têm os seguintes binários instalados.
As instruções que seguem vão instalar as tools necessárias:

1. terraform
2. kubectl
3. gcloud

```bash
# instalar as tools necessárias (podem skipar se já têm instaladas)
sudo ./scripts/install-terraform.sh        # terraform
sudo ./scripts/install-kubectl.sh          # kubectl
curl https://sdk.cloud.google.com | bash   # gcloud

# reinicializar a shell
exec -l $SHELL

# inicializar o cliente gcloud
gcloud init
gcloud auth application-default login

# definir o projeto por defeito (opcional)
gcloud config set project tf-gke-lab-01-np-000001
```

Por fim, podemos clonar o projeto:

```bash
git clone https://github.com/nosportugal/terraforming-the-cloud-part1 && cd terraforming-the-cloud-part1
```

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
gcloud compute ssh <vm-name> --project=tf-gke-lab-01-np-000001 --zone europe-west1-b

# obter o self-link de uma vpc a importar do lado do GCP
gcloud compute networks list --uri | grep "$(terraform output -raw my_identifier)"

# obter o self-link de uma subnet a importar do lado do GCP
gcloud compute networks subnets list --uri | grep "$(terraform output -raw my_identifier)"
```
<!-- markdownlint-disable-file MD013 -->

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[tfc-arch]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"

[tfc-cloudshell-activate]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-activate.png "Cloudshell activate screenshot"

[tfc-cloushell-open-new]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-open-new.png "Cloudshell open new window screenshot"

[tfc-cloushell-open-editor]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-open-editor.png "Cloudshell open editor screenshot"

[tfc-cloushell-close-terminal]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-close-terminal.png "Cloudshell close terminal window screenshot"

[tfc-cloushell-new-terminal]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-new-terminal.png "Cloudshell new terminal window screenshot"

[tfc-cloushell-open-folder]: https://github.com/nosportugal/terraforming-the-cloud-part1/raw/main/images/cloudshell-open-folder.png "Cloudshell open folder screenshot"
