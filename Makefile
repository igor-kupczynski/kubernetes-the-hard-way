PREFIX?=$(shell echo ${USER})-learn-k8s

.PHONY: all
all: infra pki

.PHONY: clean
clean:
	$(MAKE) -C 1-infra clean
	$(MAKE) -C 2-config clean

.PHONY: infra
infra:
	$(MAKE) -C 1-infra

.PHONY: pki
pki: infra
	$(MAKE) -C 2-config

.PHONY: ssh-controller-%
ssh-controller-%:
	@ gcloud compute ssh ${PREFIX}-controller-$*

.PHONY: ssh-worker-%
ssh-worker-%:
	@ gcloud compute ssh ${PREFIX}-worker-$*