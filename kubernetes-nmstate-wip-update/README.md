# kind cluster

These scripts will setup a multi-node Kubernetes 1.17 cluster with secondary
NICs enabled with DHCP and running NetworkManager. It will also install
kubernetes-nmstate into this cluster.

Build kind node image with NetworkManager and push it to public registry:

```shell
docker build -t quay.io/phoracek/kind-node-networkmanager -f Dockerfile .
docker push quay.io/phoracek/kind-node-networkmanager
```

Start multi-node kind cluster with kubernetes-nmstate:

> **Caution:** This command will configure networking on the host.

```shell
sudo ./cluster.sh
```
