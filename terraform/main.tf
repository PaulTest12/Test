terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}

resource "docker_image" "sshd" {
  name = "rastasheep/ubuntu-sshd:latest"
}

resource "docker_container" "vm" {
  name  = "vm1"
  image = docker_image.sshd.name

  ports {
    internal = 22
    external = 2222
  }

  ports {
    internal = 80
    external = 8080
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ip   = "127.0.0.1"
    port = 2222
  })

  filename = "${path.module}/../ansible/hosts"
}
