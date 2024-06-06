BACKUP - RESSOURCE CONFIGURATION

Accessing the api server and save all ressource configuration of all objects created on the cluster as a copy:  
kubectl get all --all-namespaces -o yaml > all-deploy-objects.yaml

BACKUP - QUERYING KUBE-APISERVER

etcd
      --advertise-client-urls=https://192.28.16.9:2379
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --client-cert-auth=true
      --data-dir=/var/lib/etcd
      --experimental-initial-corrupt-check=true
      --experimental-watch-progress-notify-interval=5s
      --initial-advertise-peer-urls=https://192.28.16.9:2380
      --initial-cluster=controlplane=https://192.28.16.9:2380
      --key-file=/etc/kubernetes/pki/etcd/server.key
      --listen-client-urls=https://127.0.0.1:2379,https://192.28.16.9:2379
      --listen-metrics-urls=http://127.0.0.1:2381
      --listen-peer-urls=https://192.28.16.9:2380
      --name=controlplane
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-client-cert-auth=true
      --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --snapshot-count=10000
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

The etcd cluster is hosted on the master node.  When configuring etcd, we specified a location
where all the data will be stored, the data directory. That is the directory that can be configured to be backedup by your backup tool.
The data directory is: --data-dir=/var/lib/etcd 

Etcd also comes with a built-in snapshot solution.  You can take a snapshot of the etcd database
by using the etcd control utility's snapshot save command
Command: ETCDCTL_API=3 etcdctl \
         snapshot save snapshot.db \
         --endpoint=https://127.0.0.1:2379 \
         --cacert=/etc/kubernetes/pki/etcd/ca.crt \
         --cert=/etc/kubernetes/pki/etcd/server.crt \
         --key=/etc/kubernetes/pki/etcd/server.key 

A snopshot file is created by the name "snapshot.db" in the current directory.  If you want it to be created in a different location, specify the full path.

You view the state of the backup using the command
Command: ETCDCTL_API=3 etcdctl \
             snapshot status snapshot.db

To restore the cluster from this backup at later point in time, first stop the kube API service by typing
Command: service kube-apiserver stop

As the retore process will require you to restart the etcd cluster and the kube-apiserver depends on it, then run the etcd controls snapshot restore command, with the path set to the backup file, which is the snapshot.db file.
command: ETCDCTL_API=3 etcdctl snapshot restore \
         --data-dir /var/lib/etcd-from-backup \
         
On runnig this command, a new data directory is created.  In this exemple, ate the location 
/var/lib/etcd-from-backup.  We then configure the etcd configuration file to use the new data directory.

etcd
      --advertise-client-urls=https://192.28.16.9:2379
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --client-cert-auth=true
      --data-dir=/var/lib/etcd-from-buckup
      --experimental-initial-corrupt-check=true
      --experimental-watch-progress-notify-interval=5s
      --initial-advertise-peer-urls=https://192.28.16.9:2380
      --initial-cluster=controlplane=https://192.28.16.9:2380
      --key-file=/etc/kubernetes/pki/etcd/server.key
      --listen-client-urls=https://127.0.0.1:2379,https://192.28.16.9:2379
      --listen-metrics-urls=http://127.0.0.1:2381
      --listen-peer-urls=https://192.28.16.9:2380
      --name=controlplane
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-client-cert-auth=true
      --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --snapshot-count=10000
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
 
Then reload the service daemon and restart the etcd service.
command:  - systemctl daemon-reload 
          - service etcd restart

Finally start the kube-apiserver service
command: service kube-apiserver start 
      

--------------------------------------
EXEMPLE

The master node in our cluster is planned for a regular maintenance reboot tonight. 
While we do not anticipate anything to go wrong, we are required to take the necessary 
backups. Take a snapshot of the ETCD database using the built-in snapshot functionality.
Store the backup file at location /opt/snapshot-pre-boot.db
      
Take a backup of the ETCD DATABASE using the built-in snapshot funcionality:

first we need 4 files:  the --cert-file=/etc/kubernetes/pki/etcd/server.crt 
the --key-file=/etc/kubernetes/pki/etcd/server.key 
the --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt and 
the --listen-client-urls or --endpoints=https://127.0.0.1:2379

Find the the definition file that used to create etcd-controlplane pod:
we konws that is created from the manifest directory: ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml as output

etcd.yaml is the file definition that we need.  lets look in that file: 
vim /etc/kubernetes/manifests/etcd.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/etcd.advertise-client-urls: https://192.30.48.3:2379
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=https://192.30.48.3:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --experimental-initial-corrupt-check=true
    - --experimental-watch-progress-notify-interval=5s
    - --initial-advertise-peer-urls=https://192.30.48.3:2380
    - --initial-cluster=controlplane=https://192.30.48.3:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --listen-client-urls=https://127.0.0.1:2379,https://192.30.48.3:2379
    - --listen-metrics-urls=http://127.0.0.1:2381
    - --listen-peer-urls=https://192.30.48.3:2380
    - --name=controlplane
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    image: registry.k8s.io/etcd:3.5.10-0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /health?exclude=NOSPACE&serializable=true
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: etcd
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /health?serializable=false
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
status: {}


Run the command: ETCDCTL_API=3 \
etcdctl snapshot save --endpoints=127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
 /opt/snapshot-pre-boot.db
 
output:  Snapshot saved at /opt/snapshot-pre-boot.db


Restore the original state of the cluster using the backup file:

What we going to do.  We have a file with the backup saved at /opt/snapshot-pre-boot.db.  We can use the etcdctl restore command to restore
a given file and restore the data to a new directory on the local host. To do that, we're going to the etcd manifest file to change the hostpath 
to the new path that we have restored the data to.

Run the command:
etcdctl snapshot restore --data-dir /var/lib/etcd-from-backup /opt/snapshot-pre-boot.db

To check the data is on the etcd-from-backup file:  ls /var/lib/etcd-from-backup
output: member

Now all we have to do is to go back to the etcd.yaml to change the hostpath 
to the new path that we have restored the data to the file, by typing:
vim /etc/kubernetes/manifests/etcd.yaml

output:

apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/etcd.advertise-client-urls: https://192.30.48.3:2379
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=https://192.30.48.3:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --experimental-initial-corrupt-check=true
    - --experimental-watch-progress-notify-interval=5s
    - --initial-advertise-peer-urls=https://192.30.48.3:2380
    - --initial-cluster=controlplane=https://192.30.48.3:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --listen-client-urls=https://127.0.0.1:2379,https://192.30.48.3:2379
    - --listen-metrics-urls=http://127.0.0.1:2381
    - --listen-peer-urls=https://192.30.48.3:2380
    - --name=controlplane
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    image: registry.k8s.io/etcd:3.5.10-0
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /health?exclude=NOSPACE&serializable=true
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: etcd
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 127.0.0.1
        path: /health?serializable=false
        port: 2381
        scheme: HTTP
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
status: {}

In line 299, we change the path /var/lib/etcd to /var/lib/etcd-from-backup and save the file (Esc:wq!) ENTER

We gonna loose access for a bit because now the etcd server is down for a short time.

After a few seconds type: kubectl get po -n kube-system 




      
      


