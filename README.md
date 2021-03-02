# Kubernetes the Hard Way

Terraform resrouces to play with Kelsey Hightower's [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

## Install required dependencies on macOS

```sh
brew bundle
```

## Authenticate with Google Cloud

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


## Setup resources

Configure:
- Create a new project in your google cloud console
- Setup it's name:
```sh
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Spin up:
```sh
make apply
```

Connect to the node:
```sh
gcloud compute ssh igor-learn-k8s-controller-0
```

Spin down:
```sh
make clean
```

