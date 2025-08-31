terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

provider "docker" {}
provider "local" {}

# Obraz z działającym SSH
resource "docker_image" "sshd" {
  name = "rastasheep/ubuntu-sshd:18.04"
}

# Kontener "VM"
resource "docker_container" "vm" {
  name  = "ansible_target"
  image = docker_image.sshd.latest

  # SSH: 22 -> 2222
  ports {
    internal = 22
    external = 2222
  }

  # HTTP: 80 -> 8080
  ports {
    internal = 80
    external = 8080
  }
}

# Inventory dla Ansible
resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ssh_port = docker_container.vm.ports[0].external
  })
  filename = "${path.module}/../ansible/hosts"
}
