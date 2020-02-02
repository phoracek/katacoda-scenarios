KNMSTATE_VERSION=v0.13.0

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

curl -LsO https://raw.githubusercontent.com/phoracek/kind-networking/master/cluster.sh
source cluster.sh
export WORKER_NODES=1
export SECONDARY_NETWORKS=2
export NICS_PER_SECONDARY_NETWORK=2
cluster::setup

export PATH=$(cluster::path):${PATH}
_knmstate::setup

PS1='$ ' bash
