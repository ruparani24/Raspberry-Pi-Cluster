# 🏗️ Pi-hole on K3s Raspberry Pi Cluster 🚀  

This project sets up **Pi-hole** in a **K3s-powered Raspberry Pi cluster**, acting as a **network-wide ad blocker** while utilizing lightweight Kubernetes.  

## 🌟 Features  
✅ Deploy **Pi-hole** using Helm on a K3s Raspberry Pi Cluster  
✅ Manage DNS filtering across all connected devices  
✅ Load balancing and fault tolerance with multiple worker nodes  
✅ Kubernetes-based **scalability** and **easy maintenance**  
✅ Minimal hardware footprint using Raspberry Pi 4 devices  

---

## 🛠️ Prerequisites  
1️⃣ **4 Raspberry Pis (1 Master + 3 Worker Nodes)** running **Raspberry Pi OS Lite (32-bit)**  
2️⃣ **Static IP setup** for the Raspberry Pi nodes  
3️⃣ **SSH enabled** for remote access  
4️⃣ **K3s installed and configured** on all nodes  
5️⃣ **Helm installed** on the master node  

---

## 🖥️ 1️⃣ Raspberry Pi Initial Setup  

### **A. Flash Raspberry Pi OS Lite (32-bit) onto the microSD card**  
Use **Raspberry Pi Imager** or **balenaEtcher** to flash the OS.  

### **B. Enable SSH and Set Up Configuration**  
Once the OS is flashed, mount the `boot` partition on your PC and do the following:  

#### Enable SSH:  
```bash
touch ssh
```

#### Set Static IP in `cmdline.txt`  
Modify `cmdline.txt` (for each Pi) to ensure a static IP:  
```ini
cgroup_memory=1 cgroup_enable=memory ip=<NODE_IP>::192.168.1.1:255.255.255.0:rpiname:eth0:off
```
Example for **Master Node (192.168.1.43)**:  
```ini
cgroup_memory=1 cgroup_enable=memory ip=192.168.1.43::192.168.1.1:255.255.255.0:rpi-master:eth0:off
```
Worker nodes (`192.168.1.44`, `192.168.1.45`, `192.168.1.46`) should have their respective IPs.  

#### Modify `config.txt` for better performance  
Add these lines to `config.txt`:  
```ini
arm_64bit=1
gpu_mem=16
```

#### Boot the Raspberry Pi and SSH into it:  
```bash
ssh pi@192.168.1.43
```

---

## 🚀 2️⃣ Setting Up K3s Cluster  

### **📌 On the Master Node (`192.168.1.43`)**  
```bash
curl -sfL https://get.k3s.io | sh - 
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```
Retrieve the K3s token:  
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

### **📌 On Each Worker Node (`192.168.1.44`, `192.168.1.45`, `192.168.1.46`)**  
```bash
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.1.43:6443" K3S_TOKEN="<TOKEN_HERE>" sh -
```

Verify all nodes are joined:  
```bash
kubectl get nodes
```

---

## 🚀 3️⃣ Installing Helm on the Master Node  
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

---

## 🚀 4️⃣ Deploying Pi-hole Using Helm  

### **A. Add the Pi-hole Helm Repository**  
```bash
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
```

### **B. Create a Namespace for Pi-hole**  
```bash
kubectl create namespace pihole
```

### **C. Deploy Pi-hole with Helm**  
```bash
helm install pihole mojo2600/pihole --namespace pihole \
  --set service.type=NodePort \
  --set service.nodePort=31771 \
  --set DNS1="8.8.8.8" \
  --set DNS2="8.8.4.4"
```

---

## 🌍 5️⃣ Accessing Pi-hole Web Interface  
After installation, access Pi-hole at:  
➡️ [http://192.168.1.43:31771/admin/](http://192.168.1.43:31771/admin/)  

To retrieve/reset your Pi-hole admin password:  
```bash
kubectl exec -it $(kubectl get pod -n pihole -l app.kubernetes.io/name=pihole -o jsonpath="{.items[0].metadata.name}") -n pihole -- pihole -a -p
```

---

## ⚙️ 6️⃣ Configuring Pi-hole on Your Network  

### **A. Device-by-Device Setup**  
Manually set the **DNS server** to `192.168.1.43` in your network settings.  

### **B. Router-Level Setup**  
Change your **router's DHCP DNS settings** to `192.168.1.43` for whole-network ad blocking.  

---

## 📌 Future Enhancements  
📌 Integrate **Prometheus + Grafana** for monitoring  
📌 Add redundancy with **multiple Pi-hole replicas**  
📌 Set up **auto-scaling** based on traffic  
