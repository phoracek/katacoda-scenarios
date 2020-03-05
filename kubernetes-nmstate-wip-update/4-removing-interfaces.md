One may expect that by removal of the Policy, the applied configuration would be
reverted. However, that's not the case. The Policy is not owning the
configuration on the host, it is merely applying the difference needed to reach
the desired state. After removal of the Policy, the configuration on the node
remains the same.

In order to remove a configured interface from nodes, we need to explicitly
specify it in the Policy. That can by done by changing the `state: up` of the
interface to `state: absent`.

Let's see the manifest used for removal:

`cat bond0-eth1-eth2_absent.yaml`{{execute}}

Now, apply the manifest:

`kubectl apply -f bond0-eth1-eth2_absent.yaml`{{execute}}

Alternative approach to `apply` would be to use `edit` and change the state from `up` to `absent` manually (if you don't know how to navigate using vim, don't execute this):

`kubectl edit nncp bond0-eth1-eth2`{{execute}}

Wait for the Policy to be applied and the interface removed:

`kubectl wait nncp bond0-eth1-eth2 --for condition=Available --timeout 2m`{{execute}}

After the Policy is applied, it is not needed anymore and it can be deleted:

`kubectl delete nncp bond0-eth1-eth2`{{execute}}
