terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

# 1. Pobranie obrazu z Docker Hub
resource "docker_image" "sshd" {
  name = "rastasheep/ubuntu-sshd:latest"
}

# 2. Tworzymy kontener (VM)
resource "docker_container" "vm" {
  name  = "vm1"
  image = docker_image.sshd.name   # Używamy .name, NIE .latest

  ports {
    internal = 22   # SSH wewnątrz kontenera
    external = 2222 # Na hoście łączysz się po 2222
  }
}

# 3. Generujemy inventory dla Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ip = "127.0.0.1"
    port = 2222
  })

  filename = "${path.module}/../ansible/hosts"
}

[web]
vm1 ansible_host=${ip} ansible_port=${port} ansible_user=root ansible_ssh_pass=root

