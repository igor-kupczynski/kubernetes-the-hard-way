# === Run from your workstation ===
export CFG="2-config/client.kubeconfig"

# Install core DNS add-on
export COREDNS_VER=1.7.0
kubectl --kubeconfig=$CFG apply -f "https://storage.googleapis.com/kubernetes-the-hard-way/coredns-${COREDNS_VER}.yaml"

# Show pods created by core DNS
kubectl --kubeconfig=$CFG get pods -l k8s-app=kube-dns -n kube-system

# Run a pod and use it to verify if core DNS works as expected
kubectl --kubeconfig=$CFG run busybox --image=busybox:1.28 --command -- sleep 3600
kubectl --kubeconfig=$CFG get pods -l run=busybox
POD_NAME=$(kubectl --kubeconfig=$CFG get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl --kubeconfig=$CFG exec -ti $POD_NAME -- nslookup kubernetes

# # Expected output
# Server:    10.32.0.10
# Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local
#
# Name:      kubernetes
# Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local


# # But we have:
# nslookup: can't resolve 'kubernetes'
# command terminated with exit code 1