# Create a new instances
resource "google_compute_instance" "mysql" {
    count = "${var.mysql_servers}"

    name = "mysql-${count.index}"

    machine_type = "n1-standard-1"
    zone = "europe-west1-c"
    tags = ["${var.tag_name}", "${var.tag_name_mysql}"]

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
        source      = "scripts"
        destination = "/tmp"
    }

    provisioner "remote-exec" {
        inline = [
            "echo ${count.index} > /tmp/mysql-server-count",
            "sed -i -e 's/\\&ADDRESS/${google_compute_instance.mysql.0.network_interface.0.address}/g' /tmp/scripts/slave.sql",
            "echo ${google_compute_instance.consul.0.network_interface.0.address} > /tmp/consul-server-addr",
            "sudo sh /tmp/scripts/mysql.sh",
        ]
    }
}

