KNMSTATE_VERSION=v0.15.2

function dump_manifests() {
    echo 'apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: bond0-eth1-eth2
spec:
  desiredState:
    interfaces:
    - name: bond0
      type: bond
      state: up
      ipv4:
        dhcp: true
        enabled: true
      link-aggregation:
        mode: balance-rr
        slaves:
        - eth1
        - eth2' > bond0-eth1-eth2_up.yaml

    echo 'apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: bond0-eth1-eth2
spec:
  desiredState:
    interfaces:
    - name: bond0
      state: absent' > bond0-eth1-eth2_absent.yaml

    echo 'apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: eth1
spec:
  desiredState:
    interfaces:
    - name: eth1
      type: ethernet
      state: up
      ipv4:
        dhcp: true
        enabled: true
---
apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: eth2
spec:
  desiredState:
    interfaces:
    - name: eth2
      type: ethernet
      state: up
      ipv4:
        dhcp: true
        enabled: true' > eth1-eth2_up.yaml

    echo 'apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: vlan100
spec:
  nodeSelector:
    kubernetes.io/hostname: kind-worker
  desiredState:
    interfaces:
    - name: eth1.100
      type: vlan
      state: up
      vlan:
        base-iface: eth1
        id: 100' > vlan100_kind-worker_up.yaml

    echo 'apiVersion: nmstate.io/v1alpha1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: eth666
spec:
  desiredState:
    interfaces:
    - name: eth666
      type: ethernet
      state: up' > eth666_up.yaml
}

function _knmstate::_wait_for_deployment() {
    namespace=$1
    name=$2

    for i in {300..0}; do
        desiredNumberScheduled=$(kubectl get daemonset -n ${namespace} ${name} -o=jsonpath='{.status.desiredNumberScheduled}')
        numberAvailable=$(kubectl get daemonset -n ${namespace} ${name} -o=jsonpath='{.status.numberAvailable}')

        if [ "$desiredNumberScheduled" == "$numberAvailable" ]; then
            break
        fi

        if [ $i -eq 0 ]; then
            echo "${namespace}/${name} have not turned ready within the given timeout"
            exit 1
        fi

        sleep 1
    done
}

function _knmstate::setup() {
    echo 'Installing kubernetes-nmstate ...'
    echo '   Applying manifests'
    for file in \
        namespace \
        service_account \
        role \
        role_binding \
        nmstate.io_nodenetworkstates_crd \
        nmstate.io_nodenetworkconfigurationpolicies_crd \
        nmstate.io_nodenetworkconfigurationenactments_crd \
        operator \
    ; do
        kubectl apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/${KNMSTATE_VERSION}/${file}.yaml > /dev/null
    done

    echo '   Waiting for the operator to become ready'
    _knmstate::_wait_for_deployment nmstate nmstate-handler
    echo '   Ready'

    # There is a bug in kubectl where CRD shorts fail the first time they are used
    kubectl get nns &> /dev/null || true
    kubectl get nncp &> /dev/null || true
    kubectl get nnce &> /dev/null || true
}

function prepare_cluster() {
    curl -LsO https://raw.githubusercontent.com/phoracek/kind-networking/master/cluster.sh
    source cluster.sh
    export WORKER_NODES=1
    export SECONDARY_NETWORKS=2
    export NICS_PER_SECONDARY_NETWORK=2
    cluster::setup

    export PATH=$(cluster::path):${PATH}
    _knmstate::setup

    # Wait for the worker to join the cluster
    while ! kubectl get nns kind-worker &> /dev/null; do
        sleep 1
    done

    clear
    echo 'The cluster is ready'

    PS1='$ ' bash
}

dump_manifests
clear
prepare_cluster
