# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "tobbe-1262"
  region      = "europe-west1-c"
}

# Create a new instance
resource "google_compute_instance" "consul" {
    count = "${var.servers}"

    name = "consul-${count.index}"

    machine_type = "n1-standard-1"
    zone = "europe-west1-c"
    tags = ["${var.tag_name}"]

    disk {
        image = "centos-6-v20160301"
    }

    // Local SSD disk
    disk {
        type = "local-ssd"
        scratch = true
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        ssh-keys = "tobias:${file(\"~/.ssh/gce.pub\")}"
    }

    connection {
        user     = "tobias"
        private_key = "${file(\"~/.ssh/gce\")}"
    }

    provisioner "file" {
        source      = "scripts/rhel_upstart.conf"
        destination = "/tmp/upstart.conf"
    }

   provisioner "remote-exec" {
        inline = [
            "echo ${var.servers} > /tmp/consul-server-count",
            "echo ${google_compute_instance.consul.0.network_interface.0.address} > /tmp/consul-server-addr",
        ]
    }

    provisioner "remote-exec" {
        scripts = [
            "scripts/install.sh",
            "scripts/service.sh",
            "scripts/iptables.sh",
        ]
    }
}

resource "google_compute_firewall" "consul_ingress" {
    name = "consul-internal-access"
    network = "default"

    allow {
        protocol = "tcp"
        ports = [
            "8300", # Server RPC
            "8301", # Serf LAN
            "8302", # Serf WAN
            "8400", # RPC
        ]
    }

    source_tags = ["${var.tag_name}"]
    target_tags = ["${var.tag_name}"]
}

resource "google_compute_firewall" "consul_access" {
    name = "consul-external-access"
    network = "default"

    allow {
        protocol = "tcp"
        ports = [
            "8500", # REST HTTP
        ]
    }

    source_ranges = ["85.224.0.0/13"]
    target_tags = ["${var.tag_name}"]
}



