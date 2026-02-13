# Single Node Kubernetes Cluster Setup (Ubuntu 22.04)

This repository provides a **fully automated Bash script** to install and configure a **Single Node Kubernetes Cluster** from scratch using `kubeadm` on **Ubuntu 22.04**.

It is designed for **students and beginners** who want a **reliable, reproducible, and industry-aligned** Kubernetes setup without manual errors.

---

## 📌 Features

✔ Automated Kubernetes installation  
✔ Secure repository configuration (GPG-based)  
✔ Docker + Containerd setup  
✔ systemd cgroup configuration  
✔ Calico CNI networking  
✔ Single-node workload support  
✔ Production-style cluster bootstrap  
✔ Zero manual configuration after launch  

---

## 🖥️ System Requirements

| Requirement | Minimum |
|-------------|----------|
| OS | Ubuntu 22.04 LTS |
| RAM | 8 GB |
| CPU | 2 Cores |
| Storage | 30 GB |
| Virtualization | VMware / VirtualBox / Bare Metal |
| Internet | Required |

> ⚠️ This script must be run on a **fresh Ubuntu installation**.

---

## 📁 Repository Structure

```
kubernetes-single-node/
│
├── install-k8s-single-node.sh   # Main automation script
├── README.md                   # Documentation
└── screenshots/                # (Optional) Setup screenshots
```

---

## ⚙️ What This Script Installs

The script automatically configures:

- Docker Engine
- containerd runtime
- Kubernetes Components:
  - kubelet
  - kubeadm
  - kubectl
- Calico Network Plugin
- Linux Kernel Networking
- kubeconfig for kubectl

---

## 🧠 Architecture (Single Node Cluster)

```
+--------------------------------+
|        Ubuntu 22.04 VM         |
|                                |
|  +--------------------------+  |
|  |     Control Plane        |  |
|  |  (API, Scheduler, etcd)  |  |
|  +--------------------------+  |
|                                |
|  +--------------------------+  |
|  |      Worker Node         |  |
|  |   (Pods, Services)       |  |
|  +--------------------------+  |
|                                |
+--------------------------------+
```

> Both **control-plane and worker roles** run on the same machine.

---

## 🚀 Installation Guide

### 1️⃣ Clone Repository

```bash
git clone <your-repo-url>
cd kubernetes-single-node
```

---

### 2️⃣ Run as Root

```bash
sudo -i
```

---

### 3️⃣ Make Script Executable

```bash
chmod +x install-k8s-single-node.sh
```

---

### 4️⃣ Run Installation Script

```bash
./install-k8s-single-node.sh
```

⏳ Installation Time: **10–20 minutes** (depends on internet speed)

---

## ✅ Verification Steps

After installation completes:

### Check Node Status

```bash
kubectl get nodes
```

Expected:

```
STATUS: Ready
```

---

### Check System Pods

```bash
kubectl get pods -n kube-system
```

All pods should be `Running`.

---

## 🌐 Deploy Test Application

Test your cluster with NGINX:

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=NodePort --port=80
kubectl get svc
```

Get Node IP:

```bash
ip a
```

Open in browser:

```
http://<NODE-IP>:<NODE-PORT>
```

You should see:

> Welcome to nginx!

---

## 🔧 Configuration Details

### Disable Swap

Kubernetes requires swap to be disabled.  
The script permanently disables swap.

---

### Container Runtime

Configured with:

```
SystemdCgroup = true
```

Required for kubelet compatibility.

---

### Networking

Uses **Calico CNI** with:

```
192.168.0.0/16
```

Pod CIDR.

---

### Node Taint Removal

For single-node clusters, the control-plane taint is removed to allow workload scheduling.

---

## 🛠️ Common Issues & Fixes

### ❌ Pod Pending

Cause: Control-plane taint or DiskPressure

Fix:

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

Check disk:

```bash
df -h /
```

---

### ❌ Node NotReady

Cause: CNI not ready

Fix:

```bash
kubectl get pods -n kube-system
```

Ensure Calico pods are running.

---

### ❌ kubeadm Init Fails

Cause: Swap enabled

Fix:

```bash
swapoff -a
```

---

## ♻️ Reset / Uninstall Cluster

To completely reset:

```bash
kubeadm reset -f
rm -rf ~/.kube
systemctl restart docker containerd
```

---

## 📚 Learning Outcomes

By using this project, you will learn:

✔ Kubernetes architecture  
✔ kubeadm bootstrapping  
✔ CNI networking  
✔ Container runtime configuration  
✔ Node scheduling  
✔ Service exposure  
✔ Cluster troubleshooting  

---

## 📈 Use in Resume / Portfolio

Example resume entry:

> Automated Kubernetes single-node cluster provisioning using Bash and kubeadm on Ubuntu 22.04, including Docker, containerd, Calico networking, and production-style configuration.

---

## 🤝 Contributing

Pull requests are welcome.

Steps:

1. Fork repository
2. Create feature branch
3. Commit changes
4. Submit PR

---

## 📜 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgements

- Kubernetes Community
- CNCF
- Docker Inc.
- Calico Project

---

## 📬 Contact

Maintained by: **<Your Name>**

GitHub: **<your-github-profile>**

---

⭐ If this repository helped you, please star it!
