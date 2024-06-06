Kubernetes - Create your own k8s cluster step by step

1- Connect to the 3 instances via ssh. Go to Amazon AWS, ec2, instances. Select the instance you want to connect to
   and click to connect.  Remember you need a key pair created. Run the following 2 commands on your terminal.
   - chmod 400 "cluster-k8s.pem"
   - ssh -i "cluster-k8s.pem" ubuntu@54.197.4.219

   One you connect to your instances, run:
   - sudo apt-get update
   - sudo apt-get upgrade

2- Now you have updated our servers, the step up the hostname for all of them:
   first we gonna start our controlplane by running:
     sudo hostnamectl set-hostname k8s-control
   Do the same for the workers: 
     sudo hostnamectl set-hostname k8s-worker1
     sudo hostnamectl set-hostname k8s-worker2

3- The next step, we need to setup our "add these hosts" to our machines. Run:
     sudo nano /etc/hosts
     
   Enter the host IP of each node on each server:
     10.0.2.198 k8s-control
     10.0.2.94 k8s-worker1
     10.0.2.125 k8s-worker2
     
 4- Next step is unable some labraries. Run:
    cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
    > overlay
    > br_netfilter
    > EOF 
    and press ENTER
    
    Now we have olerlay and netfilter available on our control. We need to do the same on each nodes.
    
 5- The next step is to restart our system services so these modules are loaded. Run:
    sudo modprobe overlay
    sudo modprobe br_netfilter
    
 6- Next step is to enable some networking configurations so kubernetes is unable to take 
    full advantage of them and we gonna unable them, so whenever the server run, it will be
    able to execute it. On the control, Run:
    cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    > net.bridge.bridge-nf-call-iptables=1
    > net.ipv4.ip_forward=1
    > net.bridge.bridge-nf-call-ip6tables=1
    > EOF
    
    Do the same on the workers as well.
    
    Now sign out to the servers and connect again, you gonna see the hostname of
    the servers has changed.
    
7- Install containerd by installing Docker.
   lets first install some dependencies:
   sudo apt-get update
   sudo apt-get install curl
   sudo apt-get install ca-certificates
   sudo apt-get install gnupg
   
   Installing Containerd via APT Docker Repository:
   
   Run the following command to create a new directory and download the GPG key for the Docker repository.
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   
   Add the Docker repository to your system using the below command:
   echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  Now run the following apt command to update and refresh the package index for your Ubuntu system. Then, 
  install the package "containerd.io" as the Containerd Container Runtime. The installation will automatically begin:
  sudo apt update
  sudo apt install containerd.io
  
  After installation is finished, start and enable the "containerd" service using the below systemctl command:
  sudo systemctl start containerd
  sudo systemctl enable containerd
  
  Then, check and verify the "containerd" service using the following command. You should see the "containerd" 
  service is active and running:
  sudo systemctl status containerd
  
8-  Next, you will generate a new config file for the Containerd Container Runtime.

  Run the following command to backend the default configuration provides by the Docker repository. Then, generate a new 
  configuration file using the "containerd" command as below:
  sudo mv etc/containerd/config.toml etc/containerd/config.toml.orig
  containerd config default | sudo tee /etc/containerd/config.toml
  
9-  Now run the command below to enable the "SystemdCgroup" for the Containerd:
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

10- Next, you will also need to install the CNI (Container Network Interface) plugin for the Containerd installation via 
    the APT Docker repository.

   Run the wget command below to download the CNI plugin:
   wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
   
11- Now create a new directory "/opt/cni/bin" using the below command. Then, extract the CNI plugin via the tar command as below:
    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
    
12- Lastly, run the command below to restart the Containerd service and apply new changes:
    sudo systemctl restart containerd
    
13- Now install Kubeadm, Kubelet and Kubectl:
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    sudo mkdir -p /etc/apt/keyrings/
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl

   
14- Now add the configuration for containerd. Run:
    sudo containerd config default | sudo tee /etc/containerd/config.toml
   
15- Now in order tu utilize Kubernetes, we need to turn off the swipe off which comes by default enable in linux.
   lets do it on the 3 servers. Run:
   sudo systemctl restart containerd
   sudo swapoff -a
     
    
16- The following will be running on the master node only:
  sudo kubeadm init
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl get nodes
  kubectl get pods --all-namespaces
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
  kubectl get pods --all-namespaces
  kubectl get nodes
  
17- Create a token on the control node:
    kubeadm token create --print-join-command
  
Output: kubeadm join 10.0.2.138:6443 --token rherb0.g7p9mj2gxidlrqiw --discovery-token-ca-cert-hash sha256:9de3232f55405985a630a1715e0f8544c88a2f7d1e480a36f06668ef497b0930

18- Now on each worker nodes, Run:
    sudo sysctl --system
    kubeadm join 10.0.2.138:6443 --token rherb0.g7p9mj2gxidlrqiw --discovery-token-ca-cert-hash sha256:9de3232f55405985a630a1715e0f8544c88a2f7d1e480a36f06668ef497b0930


   
   

   





     
