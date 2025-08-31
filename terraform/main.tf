terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}

# 1. Pobranie obrazu Dockera
resource "docker_image" "sshd" {
  name = "rastasheep/ubuntu-sshd:latest"
}

# 2. Tworzymy kontener (nasza VM)
resource "docker_container" "vm" {
  name  = "vm1"
  image = docker_image.sshd.name

  # Port SSH
  ports {
    internal = 22
    external = 2222
  }

  # Port HTTP (nginx)
  ports {
    internal = 80
    external = 8080
  }
}

# 3. Generowanie inventory dla Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ip   = "127.0.0.1"
    port = 2222
  })

  filename = "${path.module}/../ansib
