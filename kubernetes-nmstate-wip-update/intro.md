# kubernetes-nmstate 101

kubernetes-nmstate [keɪ ɛn ɛm steɪt] is an operator that enables you to do
declarative node network configuration driven through Kubernetes API.

This 101 tutorial will guide you through basics of:

* Observing network configuration of your nodes
* Configuring a bonding interface across all your nodes
* Configuring a VLAN interface on a selected node
* Removing interfaces
* Restoring original network configuration
* Troubleshooting issues with the configuration

For more info about kubernetes-nmstate, its deployment, comprehensive tutorial
covering all the features and guides about all supported interfaces, visit its
[GitHub repository]( https://github.com/nmstate/kubernetes-nmstate/).
