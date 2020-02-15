In the following example, we will create a Policy that configures a bonding over
NICs `eth1` and `eth2` across the whole cluster.

First of all, let's see the manifest:

`cat bond0-eth1-eth2_up.yaml`{{execute}}

As we can see, the Policy has a name (`metadata.name`) and desired state
(`spec.desiredState`). The desired state can contains declarative specification
of the node network configuration following [nmstate
API](https://nmstate.github.io/).

Now, apply the manifest:

`kubectl apply -f bond0-eth1-eth2_up.yaml`{{execute}}

Wait for the Policy to be successfully applied:

`kubectl wait nncp bond0-eth1-eth2 --for condition=Available --timeout 2m`{{execute}}

List all the Policies applied on the cluster:

`kubectl get nodenetworkconfigurationpolicies`{{execute}}

We can also use short name `nncp` to reach the same effect:

`kubectl get nncp`{{execute}}

By using `-o yaml` we obtain the full Policy with its current state:

`kubectl get nncp bond0-eth1-eth2 -o yaml`{{execute}}

The `status` section contains conditions (previously used with the `wait`
command). There is one for successful configuration (`Available`) and one for a
failed one (`Degraded`). As the output show, the Policy was applied successfully
on both nodes.

As mentioned in the introduction, for each Policy there is a set of Enactments
created by the operator. List of Enactments of all Policies and Nodes:

`kubectl get nodenetworkconfigurationenactments`{{execute}}

We can also use short name `nnce` to reach the same effect:

`kubectl get nnce`{{execute}}

By using `-o yaml` we obtain the full status of given Enactment:

`kubectl get nnce node01.bond0-eth1-eth2 -o yaml`{{execute}}

The output contains the `desiredState` applied by the Policy for the given Node.
It also contains a list of conditions. This list is more detailed than the one
in Policy. It shows whether the Policy matched given Node
(`AllSelectorsMatching`), if the `desiredState` is currently being applied on
the node (`Progressing`), if the configuration failed (`Failing`) or succeeded
(`Available`).

Our Enactment shows that it successfully applied the configuration, let's use
`NodeNetworkState` to verify it:

`kubectl get nns node01 -o yaml`{{execute}}

As seen in the output, the configuration is indeed applied and there is a bond
available with two NICs used as its slaves.
