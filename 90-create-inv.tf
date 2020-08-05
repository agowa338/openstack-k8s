resource "null_resource" "ansible-inventory" {

  depends_on = [
    "openstack_compute_instance_v2.k8s-master",
    "openstack_compute_instance_v2.k8s-worker",
    "openstack_networking_port_v2.k8s-master-port",
    "openstack_networking_port_v2.k8s-worker-port",
    "openstack_networking_subnet_v2.subnet_k8s"
  ]

  # Clear inventory
  provisioner "local-exec" {
    command = "echo \"\" > inventory.ini"
  }

  ##Create Masters Inventory
  provisioner "local-exec" {
    command =  "echo \"[kube-master]\" >> inventory.ini"
  }
  provisioner "local-exec" {
    command = "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-master.*.name, openstack_compute_instance_v2.k8s-master.*.network.0.fixed_ip_v6))}\" >> inventory.ini"
  }

  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\" >> inventory.ini"
  }
  provisioner "local-exec" {
    command = "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-master.*.name, openstack_compute_instance_v2.k8s-master.*.network.0.fixed_ip_v6))}\" >> inventory.ini"
  }

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-node]\" >> inventory.ini"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-worker.*.name, openstack_compute_instance_v2.k8s-worker.*.network.0.fixed_ip_v6))}\" >> inventory.ini"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-node\nkube-master\" >> inventory.ini"
  }
}
