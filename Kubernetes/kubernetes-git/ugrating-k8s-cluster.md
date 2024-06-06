ugrading a kuberbetes cluster (Master node & worker nodes) from v1.11 to v.1.13:

Master Node

commands:

1- kubeadm upgrade plan:  This command give you information about current version and availabel versions and also give the commands to upgrade

2-  kubeadm upgrade apply v1.13.4:  This command is to upgrade the cluster.  you must upgrade the kubeadm tools itself before upgrading the cluster.

foe exemple.  we want to go from v1.11 to v1.13.  First we need to go to v1.12.

3- apt-get upgrade -y kubeadm=1.12.0-00:  To upgrade the kubeadm tool to version v1.12, then upgrade the cluster

4- kubeadm upgrade apply v1.12.0:  to upgrade the cluster
this command pulls the necesary images and upgrades the cluster components. when complete, the controlplane controler components are now at 1.12.

The next step is to upgrade the kubelets.

5- apt-get upgrade -y kubelet=1.12.0-00:  To upgrade the kubelet in the master node.


Worker Node

We need to move the workloads from the the first worker node to the other node.

6- kubectl drain node01:  This command allows to safely terminate all the pods from a node and reschedules them in the other nodes, it also cordons the node and marks it unschedulable, that way no new pods are schedule in it.  

Then upgrade the kubeadm and the kubelet packages on the worker node, as we did on the master node.

apt-get upgrade -y kubeadm=1.12.0-00:  To upgrade the kubeadm
apt-get upgrade -y kubelet=1.12.0-00: To upgrade the kubelet
kubeadm upgrade node config --kubelet-version v1.12.0: Upgrade the node configuration for the new kubelet version

Then restart the kubelet service.

systemctl restart kubelet:  To restart the kubelet system

Now we need to unmark the node01 to make it schedulable

kubectl uncordon node01:  To make the node01 schedulable again

We do the same process for all the worker nodes










