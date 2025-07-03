packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }

    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "qemu" "archlinux" {
  vm_name  = "archlinux-packer"
  headless = true

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  boot_wait         = "3s"
  boot_key_interval = "150ms"
  boot_command = [
    "<enter><wait50>",
    "curl -sO http://{{ .HTTPIP }}:{{ .HTTPPort }}/ssh_user.sh<enter><wait>",
    "chmod +x ssh_user.sh<enter><wait>",
    "./ssh_user.sh ${var.username} ${var.password}<enter><wait>"
  ]

  efi_boot          = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars

  memory         = 2048
  cpus           = 2
  disk_size      = "20G"
  disk_interface = "virtio"

  format           = "qcow2"
  output_directory = "output"
  http_directory   = "http"

  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "5m"

  shutdown_command = "echo '${var.password}' | sudo -S shutdown -P now"
}

build {
  name    = "archlinux"
  sources = ["source.qemu.archlinux"]

  provisioner "shell" {
    environment_vars = [
      "EFI_SIZE=${var.efi_size}",
      "ROOT_SIZE=${var.root_size}",
      "SWAP_SIZE=${var.swap_size}",
    ]
    script = "./scripts/setup_disk.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "HOSTNAME=${var.hostname}",
      "TIMEZONE=${var.timezone}",
      "LOCALE=${var.locale}",
      "USERNAME=${var.username}",
      "PASSWORD=${var.password}",
      "ROOT_PASSWORD=${var.root_password}"
    ]
    script            = "./scripts/base_installation.sh"
    expect_disconnect = true
  }

  provisioner "ansible-local" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = [
      "--user", var.username,
      "--extra-vars", "ansible_become_pass=${var.password}"
    ]
  }
}
