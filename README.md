# Kubernetes the Hard Way

Scripts and resources to play with Kelsey Hightower's [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Running the Makefile will get you through to the step 06:
```
01-prerequisites.md
02-client-tools.md
03-compute-resources.md
04-certificate-authority.md
05-kubernetes-configuration-files.md
06-data-encryption-keys.md
```

TODO:
- [ ] Replace the elaborate `2-config/Makefile` with ansible

## Prerequisites

### Install required dependencies on macOS

```sh
brew bundle
```

### Authenticate with Google Cloud

Install Google Cloud SDK https://cloud.google.com/sdk/docs/quickstart

Then authenticate and set command line defaults:
```sh
gcloud config configurations create personal-k8s
gcloud config set project <project>
gcloud config set account <email>
gcloud auth login --no-launch-browser
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c
```


### Create/select project

Configure:
- Create a new project in your google cloud console
- Setup it's name:
```sh
$ cd 1-infra
1-infra$ cp terraform.tfvars.example terraform.tfvars
1-infra$ vim terraform.tfvars
```


## Start the resources

Spin up:
```sh
# In the root directory
$ make apply
```

SSH to the controllers:
```sh
$ make ssh-controller-0
$ make ssh-controller-1
$ make ssh-controller-2
```

SSH to the workers:
```sh
$ make ssh-controller-0
$ make ssh-controller-1
$ make ssh-controller-2
```

Spin down:
```sh
$ make clean
```

