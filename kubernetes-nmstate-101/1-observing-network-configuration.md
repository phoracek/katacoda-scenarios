Please hang tight while the cluster is being setup, it should take approximately
X minutes.

This cluster will consist of two nodes, one master and one worker. Both of them
will have interface `eth0` connected to the default cluster network, `eth1` and
`eth2` connected to an isolated network `192.168.1.0/24`, `eth3` and `eth4`
connected to an isolated network `192.168.2.0/24`. Both of these isolated
networks have a DHCP server running.

The operator periodically reports state of node network interfaces to the API
server. These reports are available through `NodeNetworkState` objects that are
created per each node.

# List all handled nodes

List `NodeNetworkStates` from all nodes:

`kubectl get nodenetworkstates`{{execute}}

You can also use short name `nns` to reach the same effect:

`kubectl get nns`{{execute}}

# Read state of a specific node

By using `-o yaml` you obtain the full network state of the given node:

`kubectl get nns node01 -o yaml`{execute}

As you can see, the object is cluster-wide (i.e. does not belong to a
namespace). Its `name` reflects the name of the Node it represents.

The main part of the object is located in `spec.currentState`. It contains the
DNS configuration, list of interfaces observed on the host and their
configuration, and routes.

<!-- TODO: Link API introduction once it is added to docs -->

Last attribute of the object is `lastSuccessfulUpdateTime`. It keeps a timestamp
recording the last successful update of the report. Since the report is updated
periodically and won't get updated while the node is not reachable (e.g. during
reconfiguration of networking), this value can be used to evaluate whether the
observed state is fresh enough.
