PREFIX?=$(shell echo ${USER})-learn-k8s

.PHONY: all
all: infra pki

.PHONY: clean
clean:
	$(MAKE) -C 1-infra clean
	$(MAKE) -C 2-pki clean

.PHONY: infra
infra:
	$(MAKE) -C 1-infra

.PHONY: pki
pki: infra
	$(MAKE) -C 2-pki