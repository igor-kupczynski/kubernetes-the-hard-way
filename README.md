# Kubernetes the Hard Way

Terraform resrouces to play with Kelsey Hightower's [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Configure:
```
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Authenticate with gcloud:
```
gcloud config configurations create personal-k8s
gcloud config set project <project>
gcloud config set account <email>
gcloud auth login --no-launch-browser
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c
```

Spin up:
```sh
terraform apply
```

Connect to the node:
```sh
gcloud compute ssh igor-learn-k8s-controller-0
```

Spin down:
```sh
terraform destroy
```

