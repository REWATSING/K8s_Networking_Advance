```markdown
# 🚀 3-Node Kubernetes Cluster on AWS with Calico (BGP) using Terraform & Ansible

This repo provisions a 3-node Kubernetes cluster (1 master, 2 workers) on AWS in a **single availability zone** using **Terraform** and **Ansible**. The cluster uses **Calico** for networking with **BGP** enabled.

---

## 🔧 Stack Used

- **Terraform**: Infrastructure provisioning (VPC, EC2, networking, etc.)
- **AWS EC2**: Ubuntu 22.04 LTS nodes (1 master + 2 workers)
- **Ansible**: Bootstraps the cluster and installs Kubernetes + Calico
- **Calico**: CNI plugin with BGP mode enabled

---

## 🗂️ Folder Structure

```

terraform-k8s-bgp-calico/
├── main.tf                 # All infrastructure code
├── ansible/
│   ├── inventory.ini       # Grouped inventory: master & workers
│   └── k8s-setup.yml       # Ansible playbook for full K8s setup
├── README.md               # You're reading it!

````

---

## 🏗️ Infrastructure Overview (Terraform)

- **VPC**: `172.16.0.0/16`
- **Subnet**: `172.16.1.0/24` (in `us-east-1a`)
- **Internet Gateway + Route Table**
- **Security Group**:
  - Allow SSH (port 22) from anywhere
  - Allow all TCP/UDP within cluster (self-referencing)
- **EC2 Instances**:
  - Master: `172.16.1.10`
  - Worker 1: `172.16.1.11`
  - Worker 2: `172.16.1.12`
  - Type: `t2.medium`
  - OS: Ubuntu 22.04 LTS
- **SSH Key**: Uses `~/.ssh/id_rsa.pub`

---

## 🚀 Usage Guide

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/terraform-k8s-bgp-calico.git
cd terraform-k8s-bgp-calico
````

---

### 2. Provision Infrastructure with Terraform

Make sure AWS credentials are configured (`aws configure`) and Terraform is installed.

```bash
terraform init
terraform apply
```

Once done, note down the public IPs from AWS or Terraform output.

---

### 3. Configure Ansible Inventory

Edit `ansible/inventory.ini`:

```ini
[master]
172.16.1.10 ansible_host=<public-ip-of-master>

[workers]
172.16.1.11 ansible_host=<public-ip-of-worker-1>
172.16.1.12 ansible_host=<public-ip-of-worker-2>

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

### 4. Bootstrap Kubernetes Cluster

Run the Ansible playbook:

```bash
cd ansible
ansible-playbook -i inventory.ini k8s-setup.yml
```

This will:

* Disable swap
* Install containerd
* Install kubelet, kubeadm, kubectl
* Initialize control plane
* Install Calico
* Join worker nodes to the master

---

## ✅ Verification

After Ansible completes, SSH into the master and run:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

Expected output:

```
NAME            STATUS   ROLES           AGE   VERSION
k8s-master      Ready    control-plane   5m    v1.29.x
k8s-worker-1    Ready    <none>          4m    v1.29.x
k8s-worker-2    Ready    <none>          4m    v1.29.x
```

---

## 🧼 Cleanup

To destroy all AWS resources:

```bash
terraform destroy
```

---

## 📌 Notes

* Pod CIDR used: `192.168.0.0/16` (required by Calico)
* All nodes get public IPs for simplicity (lab setup)
* Use Bastion host and private subnets for production
* Calico manifest: [GitHub Calico v3.27.0](https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml)

---

## 📚 References

* [Terraform AWS Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Kubernetes Setup with Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
* [Calico BGP Docs](https://docs.tigera.io/calico/latest/networking/bgp/bgp)

---

## 👨‍💻 Author

**Vishnu Das** — DevOps Engineer
📧 [your-email@example.com](mailto:your-email@example.com)
🔗 GitHub: [github.com/yourusername](https://github.com/yourusername)

---

## 🏁 Next Steps

* Add external BGP peering (FRRouting or physical router)
* Integrate with EKS and use Calico in managed Kubernetes
* Add Helm support and deploy sample apps

```