# === Run from your workstation ===

# Verify
kubectl --kubeconfig=2-config/client.kubeconfig get componentstatuses
# Expected output:
# Warning: v1 ComponentStatus is deprecated in v1.19+
# NAME                 STATUS    MESSAGE             ERROR
# controller-manager   Healthy   ok
# scheduler            Healthy   ok
# etcd-0               Healthy   {"health":"true"}
# etcd-1               Healthy   {"health":"true"}
# etcd-2               Healthy   {"health":"true"}


kubectl --kubeconfig=2-config/client.kubeconfig get nodes
# Expected output:
# NAME       STATUS   ROLES    AGE   VERSION
# worker-0   Ready    <none>   22h   v1.20.4
# worker-1   Ready    <none>   22h   v1.20.4
# worker-2   Ready    <none>   22h   v1.20.4