# gke-spot

This repository is an example to use GKE and Spot. If you want yo read more about it:

- [GKE](https://cloud.google.com/kubernetes-engine)
- [Spot VMs](https://cloud.google.com/spot-vms)
- [Spot VMs in GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/spot-vms)
- [Node Taints](https://cloud.google.com/kubernetes-engine/docs/how-to/node-taints)
- [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

Spot VMs are [Compute Engine virtual machine (VM) instances](https://cloud.google.com/compute/docs/instances) that are priced lower than standard Compute Engine VMs and provide no guarantee of availability. Spot VMs offer the same [machine types](https://cloud.google.com/compute/docs/machine-resource) and options as standard VMs.

The idea of this repository is to explalin how to use GKE nodes with Spot and demonstrante some examples.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project.

### Prerequisites

- git
- vscode
- terraform
- skaffold
- kubectl
- kubectx
- gcloud

To deloy this project you will need a Google Cloud account, [create here](https://cloud.google.com/).

#### Costs

This tutorial uses the following billable components of Google Cloud:

- [GKE](https://cloud.google.com/kubernetes-engine/pricing)

To generate a cost estimate based on your projected usage, use the [pricing calculator](https://cloud.google.com/products/calculator).

When you finish this tutorial, you can avoid continued billing by deleting the resources you created. For more information, see [Clean up](https://github.com/claick-oliveira/k8s-gateway-api#clean).

### Deploying

First of all you need to clone this repository:

```bash
git clone https://github.com/claick-oliveira/gke-spot
```

#### Infrastructure

First let's check the architecture that we will create.

#TODO: ## Add the architecture diagram

#### Terraform

Now that we know about the architecture and resources, let's create. First we need to connect our shell to the `gcloud`:

```bash
gcloud auth login
```

Now that we connected:

```bash
cd terraform
terraform apply
cd ..
```

This project you need to fill some variables:

- **gcp_project_name**: The GCP project name
- **gcp_region**: The GCP region
- **gcp_zone**: The GCP availability zone

The terraoform will create a GKE cluster named `gke-spot` with two node pools:

- ondemand
- spot

### Running the service

First we need to connect in our GKE:

```bash
gcloud container clusters get-credentials gke-spot --region <REGION> --project <PROJECT_ID>
```

Now we need to configure a kubeconfig, because skaffold need to use the environment, let's configure `kubectx`:

Get the name of the environment:

```bash
kubectx
```

Now change the name for staging:

```bash
kubectx gateway-api=<YOUR ENVIRONMENT>
```

Let's test:

```bash
kubectl get nodes
```

## Node Selector

To test de node selector lets create two jobs:

```bash
skaffold run -p ondemand
skaffold run -p spot
```

Now lte's check where this pods are running:

```bash
kubectl get pod $(kubectl get pods --no-headers -o custom-columns=":metadata.name") -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

The output will me somthing like this:

```text
NAME                NODE
pi-ondemand-abcdx   gke-gke-spot-ondemand-node-pool-1234a567-90b1
pi-spot-abcdx       gke-gke-spot-spot-node-pool-ab123cde-fghi
```

This was possible because the spot job configuration has an option that choose the node:

```yaml
nodeSelector:
  cloud.google.com/gke-spot: "true"
```

Delete the old jobs after the test:

```bash
skaffold delete -p ondemand
skaffold delete -p spot
```

## Affinity, Taints, and Tolerations

To test de node affinity lets create an php application:

```bash
skaffold run -p web
```

Now lte's check where this pods are running:

```bash
kubectl get pod $(kubectl get pods --no-headers -o custom-columns=":metadata.name") -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

The output will me somthing like this:

```text
NAME                          NODE
php-apache-1234ab5c67-d89ef   gke-gke-spot-ondemand-node-pool-1234a567-90b1
```

Before we continue let's talk about Taints and Toleration. When you submit a workload to run in a cluster, the scheduler determines where to place the Pods associated with the workload. The scheduler is free to place a Pod on any node that satisfies the Pod's CPU, memory, and custom resource requirements.

If your cluster runs a variety of workloads, you might want to exercise some control over which workloads can run on a particular pool of nodes.

A node taint lets you mark a node so that the scheduler avoids or prevents using it for certain Pods. A complementary feature, tolerations, lets you designate Pods that can be used on "tainted" nodes.

Taints and tolerations work together to ensure that Pods are not scheduled onto inappropriate nodes.

| Effect | Description |
|-|-|
| NoSchedule | Pods that do not tolerate this taint are not scheduled on the node; existing Pods are not evicted from the node. |
| PreferNoSchedule | Kubernetes avoids scheduling Pods that do not tolerate this taint onto the node. |
| NoExecute | The Pod is evicted from the node if it is already running on the node, and is not scheduled onto the node if it is not yet running on the node. |

In this test the deployment was configured to run in both node pools:

```yaml
tolerations:
- key: ondemand-node-pool
  operator: Equal
  value: "true"
  effect: PreferNoSchedule
- key: spot-node-pool
  operator: Equal
  value: "true"
  effect: NoSchedule
```

Now let's execute a load test to check the [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) scaling new containers:

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

To see the HPA execute:

```bash
kubectl get hpa
```

And let's check where the pods are runiing:

```bash
kubectl get pod $(kubectl get pods --no-headers -o custom-columns=":metadata.name") -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

The example of output is:

```text
NAME                          NODE
load-generator                gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-5479cc7b64-49m4d   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-5479cc7b64-bq56b   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-5479cc7b64-f94sj   gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-5479cc7b64-h7fsl   gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-5479cc7b64-hrmm6   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-5479cc7b64-srjkh   gke-gke-spot-spot-node-pool-ab123cde-fghi
```

Now you can stop the load test with `Ctrl+C`.

To test the node affinity we need to delete the actual test:

```bash
skaffold delete -p web
```

Let's test the node affinity:

```bash
skaffold run -p required
```

In this example we will apply a node affinity that is required:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: cloud.google.com/gke-spot
          operator: In
          values:
          - "true"
```

If the node pool doesn't have this key, the pod can't running. Let's execute the load test again:

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

The example output:

```text
load-generator                gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-79874b5fb8-2qvgc   <none>
php-apache-79874b5fb8-4r5vf   <none>
php-apache-79874b5fb8-hsqq2   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-79874b5fb8-jzd47   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-79874b5fb8-strd8   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-79874b5fb8-t7npf   <none>
php-apache-79874b5fb8-w7ngn   gke-gke-spot-spot-node-pool-ab123cde-fghi
```

The `<none>` status are because the node pool with spot it's full and the [NAP (node auto-provisioning)](https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-provisioning) was configured to scale maximum two nodes. Because of this the pods are not running. Stop the load test (press `Ctrl+C`) and let's delete this deployment.

```bash
skaffold delete -p required
```

Now we will test the affinity with preferred option:

```bash
skaffold run -p preferred
```

Now the `.yaml` file was configures with this option:

```yaml
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        - key: cloud.google.com/gke-spot
          operator: In
          values:
          - "true"
```

This configuration does the kubernetes try first to use node pool with spot, but if will not possible choose other type of node pool. Let's try:

Excute the load test again:

```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

Tehe example output:

```text
NAME                          NODE
load-generator                gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-669d6dc5f7-bwdqs   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-669d6dc5f7-f4flw   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-669d6dc5f7-lk4nv   gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-669d6dc5f7-qkvnw   gke-gke-spot-ondemand-node-pool-1234a567-90b1
php-apache-669d6dc5f7-scw56   gke-gke-spot-spot-node-pool-ab123cde-fghi
php-apache-669d6dc5f7-wtsmd   gke-gke-spot-spot-node-pool-ab123cde-fghi
```

Now kubernetes schedule the pods to run preferred in Spot VMs but when was not possible it scheduled in OnDemand VMs.

Now that you tested, you can stop the load test and delete the deployment:

```bash
skaffold delete -p preferred
```

## Clean

To clean the infrastructure:

```bash
cd terraform
terraform destroy
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

- **Claick Oliveira** - *Initial work* - [claick-oliveira](https://github.com/claick-oliveira)

See also the list of [contributors](https://github.com/claick-oliveira/gke-spot/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License - see the [LICENSE](LICENSE) file for details
