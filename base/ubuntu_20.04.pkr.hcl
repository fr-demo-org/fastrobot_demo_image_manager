# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.

variable "buildtime" {
  type    = string
  default = "{{isotime \"2006-01-02-1504\"}}"
}

variable "codename" {
  type    = string
  default = "focal"
}

variable "device" {
  type    = string
  default = "/dev/xvdf"
}

variable "fs_type" {
  type    = string
  default = "ext4"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "volume_size" {
  type    = string
  default = "8"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebssurrogate" "ubuntu_seed_builder" {
  ami_description = "Ubuntu Focal (20.04) Seed"
  ami_name        = "ubuntu-20.04-amd64-server-seed-${var.buildtime}"
  ami_regions     = ["us-west-2"]
  ami_root_device {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    source_device_name    = "${var.device}"
    volume_size           = "${var.volume_size}"
    volume_type           = "gp2"
  }
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  ena_support                 = "true"
  instance_type               = "t2.small"
  launch_block_device_mappings {
    delete_on_termination = false
    device_name           = "${var.device}"
    volume_size           = "${var.volume_size}"
    volume_type           = "gp2"
  }
  region = "${var.region}"
  run_tags = {
    Name = "Packer_Builder - Ubuntu 20.04 Seed"
  }
  run_volume_tags = {
    Name = "Packer_Builder - Ubuntu 20.04 Seed"
  }
//  security_group_filter {
//    filters = {
//      "tag:Name" = "packer"
//    }
//  }
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_pty      = true
  ssh_timeout  = "5m"
  ssh_username = "ubuntu"
  subnet_id = "subnet-ba5f48d8"
  tags = {
    BuildTime = "${var.buildtime}"
    Name      = "Ubuntu Focal (20.04) Seed"
  }
  vpc_filter {     # select the default VPC for now
    filters = {
      #cidr       = "172.19.0.0/16"
      isDefault  = "true"
      #"tag:Name" = "infra-global-staging"
    }
  }
}

build {
  description = "Ubuntu 20.04 Seed Image Builder "

  sources = ["source.amazon-ebssurrogate.ubuntu_seed_builder"]

  provisioner "file" {
    destination = "/tmp/sources.list"
    source      = "files/sources-u20.04-us-west-2.list"
  }
  provisioner "file" {
    destination = "/tmp/ebsnvme-id"
    source      = "files/ebsnvme-id"
  }
  provisioner "file" {
    destination = "/tmp/70-ec2-nvme-devices.rules"
    source      = "files/70-ec2-nvme-devices.rules"
  }
  provisioner "file" {
    destination = "/tmp/05-logging.cfg"
    source      = "files/05-logging.cfg"
  }
  provisioner "file" {
    destination = "/tmp/10-growpart.cfg"
    source      = "files/10-growpart.cfg"
  }
  provisioner "file" {
    destination = "/tmp/cloud.cfg"
    source      = "files/cloud.cfg"
  }
  provisioner "file" {
    destination = "/tmp"
    source      = "chroot-scripts"
  }
  provisioner "file" {
    destination = "/tmp/chroot-bootstrap.sh"
    source      = "scripts/chroot-bootstrap.sh"
  }

  #could not parse template for following block: "template: generated:3:43: executing \"generated\" at <.Vars>: can't evaluate field Vars in type struct { HTTPIP string; HTTPPort string }"
  provisioner "shell" {
    environment_vars    = ["FS_TYPE=ext4", "DEVICE=/dev/xvdf", "CODENAME=focal"]
    execute_command     = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script              = "scripts/surrogate-bootstrap.sh"
    skip_clean          = true
    start_retry_timeout = "5m"
  }
}
