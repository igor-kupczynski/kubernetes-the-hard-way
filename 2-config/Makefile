PREFIX?=$(shell echo ${USER})-learn-k8s

CA = ca.pem ca-key.pem
COMPONENT_CERTIFICATES = \
	admin.pem admin-key.pem  \
	kube-controller-manager.pem kube-controller-manager-key.pem \
	kube-proxy.pem kube-proxy-key.pem \
	kube-scheduler.pem kube-scheduler-key.pem
COMPONENT_KUBECONFIGS = \
	kube-proxy.kubeconfig \
	kube-controller-manager.kubeconfig \
	kube-scheduler.kubeconfig
WORKER_CERTIFICATES = \
	worker-0.pem worker-0-key.pem \
	worker-1.pem worker-1-key.pem \
	worker-2.pem worker-2-key.pem
WORKER_KUBECONFIGS = \
	worker-0.kubeconfig \
	worker-1.kubeconfig \
	worker-2.kubeconfig
CONTROLLER_CERTIFICATES = \
	kubernetes.pem kubernetes-key.pem \
	service-account.pem service-account-key.pem
CONTROLLER_KUBECONFIGS = \
	admin.kubeconfig


KUBERNETES_REGION := $(shell echo "now" && gcloud config get-value compute/region)
KUBERNETES_PUBLIC_ADDRESS := $(shell gcloud compute addresses describe ${PREFIX}-kubernetes-the-hard-way --region ${KUBERNETES_REGION} --format 'value(address)')
KUBERNETES_HOSTNAMES := "kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local"


.PHONY: all
all: upload-worker-keys upload-worker-kubeconfig upload-controller-keys upload-controller-kubeconfigs

.PHONY: clean
clean:
	@ rm -f *.csr
	@ rm -f *.pem


# === CA ===
ca-key.pem: ca-config.json ca-csr.json
	@ cfssl gencert -initca ca-csr.json | cfssljson -bare ca

ca.pem: ca-key.pem

# === Components ===
admin-key.pem: $(CA) admin-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  admin-csr.json | cfssljson -bare admin
admin.pem: admin-key.pem

kube-controller-manager-key.pem: $(CA) kube-controller-manager-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
kube-controller-manager.pem: kube-controller-manager-key.pem

kube-proxy-key.pem:  $(CA) kube-proxy-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  kube-proxy-csr.json | cfssljson -bare kube-proxy
kube-proxy.pem: kube-proxy-key.pem

kube-scheduler-key.pem: $(CA) kube-scheduler-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
kube-scheduler.pem: kube-scheduler-key.pem

kube-proxy.kubeconfig: ${COMPONENT_CERTIFICATES}
	@ kubectl config set-cluster kubernetes-the-hard-way \
		    --certificate-authority=ca.pem \
		    --embed-certs=true \
		    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
		    --kubeconfig=kube-proxy.kubeconfig ;\
		kubectl config set-credentials system:kube-proxy \
		    --client-certificate=kube-proxy.pem \
		    --client-key=kube-proxy-key.pem \
		    --embed-certs=true \
		    --kubeconfig=kube-proxy.kubeconfig ;\
		kubectl config set-context default \
		    --cluster=kubernetes-the-hard-way \
		    --user=system:kube-proxy \
		    --kubeconfig=kube-proxy.kubeconfig ;\
		kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

kube-controller-manager.kubeconfig: $(COMPONENT_CERTIFICATES) 
	@ kubectl config set-cluster kubernetes-the-hard-way \
		    --certificate-authority=ca.pem \
		    --embed-certs=true \
		    --server=https://127.0.0.1:6443 \
		    --kubeconfig=kube-controller-manager.kubeconfig ;\
		kubectl config set-credentials system:kube-controller-manager \
		    --client-certificate=kube-controller-manager.pem \
		    --client-key=kube-controller-manager-key.pem \
		    --embed-certs=true \
		    --kubeconfig=kube-controller-manager.kubeconfig ;\
	 	kubectl config set-context default \
		    --cluster=kubernetes-the-hard-way \
		    --user=system:kube-controller-manager \
		    --kubeconfig=kube-controller-manager.kubeconfig ;\
	 	kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

kube-scheduler.kubeconfig: $(COMPONENT_CERTIFICATES)
	@ kubectl config set-cluster kubernetes-the-hard-way \
		    --certificate-authority=ca.pem \
		    --embed-certs=true \
		    --server=https://127.0.0.1:6443 \
		    --kubeconfig=kube-scheduler.kubeconfig ;\
		kubectl config set-credentials system:kube-scheduler \
		    --client-certificate=kube-scheduler.pem \
		    --client-key=kube-scheduler-key.pem \
		    --embed-certs=true \
		    --kubeconfig=kube-scheduler.kubeconfig ;\
		kubectl config set-context default \
		    --cluster=kubernetes-the-hard-way \
		    --user=system:kube-scheduler \
		    --kubeconfig=kube-scheduler.kubeconfig ;\
		kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig


# === Workers ===
worker-%-key.pem: $(CA) worker-%-csr.json
	@ WORKER='worker-$*' ;\
		EXTERNAL_IP=$$(gcloud compute instances describe ${PREFIX}-$${WORKER} --format 'value(networkInterfaces[0].accessConfigs[0].natIP)') ;\
		INTERNAL_IP=$$(gcloud compute instances describe ${PREFIX}-$${WORKER} --format 'value(networkInterfaces[0].networkIP)') ;\
		cfssl gencert \
		  -ca=ca.pem \
		  -ca-key=ca-key.pem \
		  -config=ca-config.json \
		  -hostname=$${WORKER},$${EXTERNAL_IP},$${INTERNAL_IP} \
		  -profile=kubernetes \
		  $${WORKER}-csr.json | cfssljson -bare $${WORKER}
worker-0.pem: worker-0-key.pem
worker-1.pem: worker-1-key.pem
worker-2.pem: worker-2-key.pem

.PHONY: upload-worker-keys-%
upload-worker-keys-%: $(WORKER_CERTIFICATES)
	@ INSTANCE='worker-$*' ;\
		gcloud compute scp ca.pem $${INSTANCE}-key.pem $${INSTANCE}.pem ${PREFIX}-$${INSTANCE}:~/

.PHONY: upload-worker-keys
upload-worker-keys: upload-worker-keys-0 upload-worker-keys-1 upload-worker-keys-2

worker-%.kubeconfig: $(WORKER_CERTIFICATES)
	@ WORKER='worker-$*' ;\
		kubectl config set-cluster kubernetes-the-hard-way \
		    --certificate-authority=ca.pem \
		    --embed-certs=true \
		    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
		    --kubeconfig=$${WORKER}.kubeconfig ;\
		kubectl config set-credentials system:node:$${WORKER} \
		    --client-certificate=$${WORKER}.pem \
		    --client-key=$${WORKER}-key.pem \
		    --embed-certs=true \
		    --kubeconfig=$${WORKER}.kubeconfig ;\
		kubectl config set-context default \
		    --cluster=kubernetes-the-hard-way \
		    --user=system:kube-proxy \
		    --kubeconfig=kube-proxy.kubeconfig ;\
		kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

.PHONY: upload-worker-kubeconfig-%
upload-worker-kubeconfig-%: $(WORKER_KUBECONFIGS) ${COMPONENT_KUBECONFIGS}
	@ INSTANCE='worker-$*' ;\
		gcloud compute scp $${INSTANCE}.kubeconfig kube-proxy.kubeconfig ${PREFIX}-$${INSTANCE}:~/

.PHONY: upload-worker-kubeconfig
upload-worker-kubeconfig: upload-worker-kubeconfig-0 upload-worker-kubeconfig-1 upload-worker-kubeconfig-2


# === Controllers ===
service-account-key.pem: $(CA) service-account-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  service-account-csr.json | cfssljson -bare service-account
service-account.pem: service-account-key.pem

kubernetes-key.pem: $(CA) kubernetes-csr.json
	@ cfssl gencert \
		  -ca=ca.pem \
		  -ca-key=ca-key.pem \
		  -config=ca-config.json \
		  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
		  -profile=kubernetes \
		  kubernetes-csr.json | cfssljson -bare kubernetes
kubernetes.pem: kubernetes-key.pem

.PHONY: upload-controller-keys-%
upload-controller-keys-%: $(CONTROLLER_CERTIFICATES)
	@ INSTANCE='controller-$*' ;\
		gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${PREFIX}-$${INSTANCE}:~/

.PHONY: upload-controller-keys
upload-controller-keys: upload-controller-keys-0 upload-controller-keys-1 upload-controller-keys-2

admin.kubeconfig:  $(CONTROLLER_CERTIFICATES)
	@ kubectl config set-cluster kubernetes-the-hard-way \
	    --certificate-authority=ca.pem \
	    --embed-certs=true \
	    --server=https://127.0.0.1:6443 \
	    --kubeconfig=admin.kubeconfig ;\
	kubectl config set-credentials admin \
	    --client-certificate=admin.pem \
	    --client-key=admin-key.pem \
	    --embed-certs=true \
	    --kubeconfig=admin.kubeconfig ;\
	kubectl config set-context default \
	    --cluster=kubernetes-the-hard-way \
	    --user=admin \
	    --kubeconfig=admin.kubeconfig ;\
	kubectl config use-context default --kubeconfig=admin.kubeconfig

.PHONY: upload-controller-kubeconfigs-%
upload-controller-kubeconfigs-%: ${CONTROLLER_KUBECONFIGS} $(COMPONENT_KUBECONFIGS)
	@ INSTANCE='controller-$*' ;\
		gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${PREFIX}-$${INSTANCE}:~/

.PHONY: upload-controller-kubeconfigs
upload-controller-kubeconfigs: upload-controller-kubeconfigs-0 upload-controller-kubeconfigs-1 upload-controller-kubeconfigs-2