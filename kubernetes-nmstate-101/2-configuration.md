The operator allows users to configure various network interface types, DNS and
routing on cluster nodes. The configuration is driven by two main object types,
`NodeNetworkConfigurationPolicy` (Policy) and
`NodeNetworkConfigurationEnactment` (Enactment).

A Policy describes what is the desired network configuration on cluster nodes.
It is created by used and applies cluster-wide. On the other hand, an Enactment
is a read-only object that carries execution state of a Policy per each Node.

Policies are applied on node via NetworkManager. Thanks to this, the
configuration is persistent on the node and survives reboots.
