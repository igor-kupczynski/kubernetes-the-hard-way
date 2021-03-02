PREFIX?=$(shell echo ${USER})-learn-k8s

.PHONY: apply
apply:
	@ terraform apply -var="prefix=${PREFIX}"