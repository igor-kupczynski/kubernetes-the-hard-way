PREFIX?=$(shell echo ${USER})-learn-k8s

.PHONY: all
all: apply

.PHONY: clean
clean:
	@ terraform destroy -var="prefix=${PREFIX}"

.PHONY: apply
apply:
	@ terraform apply -var="prefix=${PREFIX}" 