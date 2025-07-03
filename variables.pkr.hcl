// Disk partitions
variable "efi_size" {
  type    = string
  default = "500M"
}

variable "root_size" {
  type    = string
  default = "70G"
}

variable "swap_size" {
  type    = string
  default = "8G"
}

// Archlinux settings
variable "timezone" {
  type = string
}

variable "locale" {
  type    = string
  default = "en_US.UTF-8"
}

variable "hostname" {
  type = string
}

variable "root_password" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

// Packer settings
variable "efi_firmware_code" {
  type    = string
  default = "/usr/share/OVMF/OVMF_CODE_4M.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "/usr/share/OVMF/OVMF_VARS_4M.fd"
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}
