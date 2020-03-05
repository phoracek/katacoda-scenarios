Another maybe surprising behavior is, that by removing an interface, original
configuration of the node interfaces is not restored. In case of the bonding it
means that after it is deleted, its slave NICs won't come back up, even if they
had previously configured IP address. The operator is not owning the interfaces
and does not want to do anything that is not explicitly specified, that's up to
the user.

`NodeNetworkState` shows that both of the NICs are now down and without any IP
configuration.

`kubectl get nns kind-worker -o yaml`{{execute}}

In order to configure IP on previously enslaved NICs, one needs to use a policy
explicitly specifying that.

Let's look at the manifest:

`cat eth1-eth2_up.yaml`{{execute}}

And apply it:

`kubectl apply -f eth1-eth2_up.yaml`{{execute}}

Wait for the Policy to get applied:

`kubectl wait nncp eth1 eth2 --for condition=Available --timeout 2m`{{execute}}

Both NICs are now back up and with assigned IPs:

`kubectl get nns kind-worker -o yaml`{{execute}}
