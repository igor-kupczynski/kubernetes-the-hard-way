PREFIX?=$(shell echo ${USER})-learn-k8s

CA = ca.pem ca-key.pem ca-config.json
COMPONENTS = \
	admin.pem \
	kube-controller-manager.pem \
	kube-proxy.pem \
	kube-scheduler.pem \
	service-account.pem \
	kubernetes-key.pem
WORKERS = worker-0.pem worker-1.pem worker-2.pem

.PHONY: all
all: $(CA) $(COMPONENTS) $(WORKERS)

.PHONY: clean
clean:
	@ rm -f *.csr
	@ rm -f *.pem

ca-key.pem: ca-config.json ca-csr.json
	@ cfssl gencert -initca ca-csr.json | cfssljson -bare ca

ca.pem: ca-key.pem

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

service-account-key.pem: $(CA) service-account-csr.json
	@ cfssl gencert \
	  -ca=ca.pem \
	  -ca-key=ca-key.pem \
	  -config=ca-config.json \
	  -profile=kubernetes \
	  service-account-csr.json | cfssljson -bare service-account
service-account.pem: service-account-key.pem

worker-%-key.pem: $(CA) worker-%-csr.json
	@ WORKER=$$(echo $@ | cut -d'-' -f 1,2) ;\
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
worker-1.pem: worker-2-key.pem
worker-2.pem: worker-2-key.pem


kubernetes-key.pem: $(CA) kubernetes-csr.json
	@ REGION=$$(gcloud config get-value compute/region) ;\
		KUBERNETES_PUBLIC_ADDRESS=$$(gcloud compute addresses describe ${PREFIX}-kubernetes-the-hard-way --region $${REGION} --format 'value(address)') ;\
		KUBERNETES_HOSTNAMES='kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local' ;\
		cfssl gencert \
		  -ca=ca.pem \
		  -ca-key=ca-key.pem \
		  -config=ca-config.json \
		  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,$${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,$${KUBERNETES_HOSTNAMES} \
		  -profile=kubernetes \
		  kubernetes-csr.json | cfssljson -bare kubernetes
kubernetes.pem: kubernetes-key.pem