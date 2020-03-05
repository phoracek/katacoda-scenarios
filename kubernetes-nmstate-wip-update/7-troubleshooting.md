Node network configuration is a risky business. A lot can go wrong and when it
does, it can render the whole node unreachable and non-operational. This guide
will show you how to obtain information about failed configuration and how does
the operator protect the user from breaking the cluster networking.

If any of the following cases render the configuration faulty, the setup will be
automatically rolled back and Enactment will report the failure.

* Configuration fails to be applied on the host (due missing interfaces,
  inability to obtain IP, invalid attributes, ...)
* Connectivity to the default gateway is broken
* Connectivity to the API server is broken

In the following example, we will create a Policy configuring and unavailable
interface and observe the results.

First, let's look at the manifest:

`cat eth666_up.yaml`{{execute}}

And then apply it:

`kubectl apply -f eth666_up.yaml`{{execute}}

Let's wait for `Degraded` condition since we anticipate the Policy to fail.
Usually, one would wait for `Available` until the timeout.

`kubectl wait nncp eth666 --for condition=Degraded --timeout 2m`{{execute}}

We can list the Enactments to see why we are in the `Degraded` state:

`kubectl get nnce`{{execute}}

Both Enactments of eth666 Policy have `FailedToConfigure`, let's see why:

`kubectl get nnce kind-worker.eth666 -o yaml`{{execute}}

The message in `Failing` condition is currently a little bloated since it
contains the whole error output of a failed call. The interesting message is in
the `ERROR` log line:

```
Connection activation failed on connection_id eth666: error=nm-manager-error-quark: No suitable device found for this connection
```

The configuration therefore failed due to absence of NIC `eth666` on the node.
Now we can either fix the Policy to edit an available interface or safely remove
it:

`kubectl delete nncp eth666`{{execute}}
