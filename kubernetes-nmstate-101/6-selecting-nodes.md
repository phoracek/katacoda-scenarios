All the Policies we used so far were applied on all nodes across the cluster. It
is however possible to select only a subset of nodes using via a node selector.

In the following example, we configure a VLAN interface with tag 100 over a NIC
`eth1`. This configuration will be done only on node which has labels matching
all the key-value pairs in the `nodeSelector`.

Let's look at the manifest:

`cat vlan100_node01_up.yaml`{{execute}}

And then apply it:

`kubectl apply -f vlan100_node01_up.yaml`{{execute}}

Wait for the Policy to get applied:

`kubectl wait nncp vlan100 --for condition=Available --timeout 2m`{{execute}}

The list of Enactments then shows that the Policy has been applied only on
Node `node01`, while `node02` is reporting `NodeSelectorNotMatching`:

`kubectl get nnce`{{execute}}

After a closer observation of `status.conditions`, we can see that it was indeed
caused by not-matching selectors:

`kubectl get nnce node02.vlan100 -o yaml`{{execute}}
