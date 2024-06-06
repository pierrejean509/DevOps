Working with ETCDCTL

etcdctl is a command line client for etcd.

In all our Kubernetes Hands-on labs, the ETCD key-value database is deployed as a static pod on the master. The version used is v3.

To make use of etcdctl for tasks such as back up and restore, make sure that you set the ETCDCTL_API to 3.

You can do this by exporting the variable ETCDCTL_API prior to using the etcdctl client. This can be done as follows:

export ETCDCTL_API=3

To see all the options for a specific sub-command, make use of the -h or --help flag.

For example, if you want to take a snapshot of etcd, use:

etcdctl snapshot save -h and keep a note of the mandatory global options.

Since our ETCD database is TLS-Enabled, the following options are mandatory:

--cacert                                                verify certificates of TLS-enabled secure servers using this CA bundle

--cert                                                    identify secure client using this TLS certificate file

--endpoints=[127.0.0.1:2379]          This is the default as ETCD is running on master node and exposed on localhost 2379.

--key                                                      identify secure client using this TLS key file

Similarly use the help option for snapshot restore to see all available options for restoring the backup.

etcdctl snapshot restore -h

For a detailed explanation on how to make use of the etcdctl command line tool and work with the -h flags, check out the solution video for the Backup and Restore Lab.


---------------------------------------
Exemple:

In this exercise, you will get to work with multiple kubernetes clusters where we will practice 
backing up and restoring the ETCD database.

You will notice that, you are logged in to the student-node (instead of the controlplane).
The student-node has the kubectl client and has access to all the Kubernetes clusters that are 
configured for this exercise. Lets start by exploring the student-node and the clusters it has access to.

-How many clusters are defined in the kubeconfig on the student-node?

You can make use of the kubectl config command.

You can view the complete kubeconfig by running: kubectl config view

-How many nodes (both controlplane and worker) are part of cluster1?

Make sure to switch the context to cluster1: kubectl config use-context cluster1
and then type: kubectl get nodes

-You can SSH to all the nodes (of both clusters) from the student-node

for exemple:  
student-node ~ ➜  ssh cluster1-controlplane
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1086-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

cluster1-controlplane ~ ➜ 


-How is ETCD configured for cluster1?

Remember, you can access the clusters from student-node using the kubectl tool. 
You can also ssh to the cluster nodes from the student-node.

Make sure to switch the context to cluster1:
kubectl confug use-context cluster1
output: Switched to context "cluster1"

Then type: kubectl get po -n kube-system, to see a list of all pods
output:
NAME                                            READY   STATUS    RESTARTS      AGE
coredns-6d4b75cb6d-4tgkn                        1/1     Running   0             91m
coredns-6d4b75cb6d-jqzg9                        1/1     Running   0             91m
etcd-cluster1-controlplane                      1/1     Running   0             92m
kube-apiserver-cluster1-controlplane            1/1     Running   0             92m
kube-controller-manager-cluster1-controlplane   1/1     Running   0             92m
kube-proxy-7qc8c                                1/1     Running   0             91m
kube-proxy-c52t4                                1/1     Running   0             91m
kube-scheduler-cluster1-controlplane            1/1     Running   0             92m
weave-net-7gzkv                                 2/2     Running   1 (91m ago)   91m
weave-net-8wb4r                                 2/2     Running   0             91m

If there is a etcd pod in the list, that means we are using stacked etcd.  The etcd 
is running on the controlplane node itself.

or you can describe the kube-aipserver pod:
kubectl describe po kube-apiserver-cluster1-controlplane -n kube-ystem
You will see the etcd-server use the internal ip address like this
etcd-server=https://127.0.0.1:2379

- Whats is the default data directory used for the ETCD datastore in cluster2?
This cluster uses an External ETCD topology

ssh in the etcd-server
command: ssh etcd-server
output: Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1106-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

etcd-server ~ ➜ 
 now type: ps -ef | -i etcd
output: etcd         842       1  0 17:33 ?        00:01:43 /usr/local/bin/etcd --name etcd-server --data-dir=/var/lib/etcd-data --cert-file=/etc/etcd/pki/etcd.pem --key-file=/etc/etcd/pki/etcd-key.pem --peer-cert-file=/etc/etcd/pki/etcd.pem --peer-key-file=/etc/etcd/pki/etcd-key.pem --trusted-ca-file=/etc/etcd/pki/ca.pem --peer-trusted-ca-file=/etc/etcd/pki/ca.pem --peer-client-cert-auth --client-cert-auth --initial-advertise-peer-urls https://192.34.229.12:2380 --listen-peer-urls https://192.34.229.12:2380 --advertise-client-urls https://192.34.229.12:2379 --listen-client-urls https://192.34.229.12:2379,https://127.0.0.1:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster etcd-server=https://192.34.229.12:2380 --initial-cluster-state new
root        1300     990  0 19:43 pts/0    00:00:00 grep -i etcd
 

- How many nodes are part of the ETCD cluster that etcd-server is a part of?

To do that, we have to check the mnembers of the closter 
command: ETCDCTL_API=3 etcdctl \
 --endpoints=https://127.0.0.1:2379 \
 --cacert=/etc/etcd/pki/ca.pem \
 --cert=/etc/etcd/pki/etcd.pem \
 --key=/etc/etcd/pki/etcd-key.pem \
  member list

output:
ETCDCTL_API=3 etcdctl \
 --endpoints=https://127.0.0.1:2379 \
 --cacert=/etc/etcd/pki/ca.pem \
 --cert=/etc/etcd/pki/etcd.pem \
 --key=/etc/etcd/pki/etcd-key.pem \
  member list
f0f805fc97008de5, started, etcd-server, https://10.1.218.3:2380, https://10.1.218.3:2379, false

etcd-server ~ ➜


































