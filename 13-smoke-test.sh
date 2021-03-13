# === Run from your workstation ===
export CFG="2-config/client.kubeconfig"

## Create and view a secret ##
kubectl --kubeconfig=$CFG create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"

gcloud compute ssh igor-learn-k8s-controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

## Run and verify a depolyment ##
kubectl --kubeconfig=$CFG create deployment nginx --image=nginx
kubectl --kubeconfig=$CFG get pods -l app=nginx


### Port forwarding ###
export POD_NAME=$(kubectl --kubeconfig=$CFG get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}") && echo $POD_NAME
kubectl --kubeconfig=$CFG port-forward $POD_NAME 8080:80

curl --head http://127.0.0.1:8080  # In new terminal, then ^C the port forwarding


### Logs ###
kubectl --kubeconfig=$CFG logs $POD_NAME


### Exec ###
kubectl --kubeconfig=$CFG exec -ti $POD_NAME -- nginx -v


## Services ###
kubectl --kubeconfig=$CFG expose deployment nginx --port 80 --type NodePort
export NODE_PORT=$(kubectl --kubeconfig=$CFG get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}') && echo $NODE_PORT
gcloud compute firewall-rules create igor-learn-k8s-kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network igor-learn-k8s-kubernetes-the-hard-way
export EXTERNAL_IP=$(gcloud compute instances describe igor-learn-k8s-worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)') && echo $EXTERNAL_IP
curl -I "http://${EXTERNAL_IP}:${NODE_PORT}"


### Clean up the firewall rule ###
gcloud -q compute firewall-rules delete igor-learn-k8s-kubernetes-the-hard-way-allow-nginx-service
# rest is cleaned with terraform