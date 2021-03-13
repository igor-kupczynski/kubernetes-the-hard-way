# === Run from your workstation ===
export CFG="2-config/client.kubeconfig"

# Install core DNS add-on
export COREDNS_VER=1.7.0
#kubectl --kubeconfig=$CFG apply -f "https://storage.googleapis.com/kubernetes-the-hard-way/coredns-${COREDNS_VER}.yaml"
# we need to add `forward . /etc/resolv.conf` to the config
kubectl --kubeconfig=$CFG apply -f https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/7ec90f5509395f31850954a90d22fb9ea0943efe/deployments/coredns.yaml

# Show pods created by core DNS
kubectl --kubeconfig=$CFG get pods -l k8s-app=kube-dns -n kube-system

# Run a pod and use it to verify if core DNS works as expected
kubectl --kubeconfig=$CFG run busybox --image=busybox:1.28 --command -- sleep 3600
kubectl --kubeconfig=$CFG get pods -l run=busybox
POD_NAME=$(kubectl --kubeconfig=$CFG get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl --kubeconfig=$CFG exec -ti $POD_NAME -- nslookup kubernetes
