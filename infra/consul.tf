# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "tobbe-1262"
  region      = "europe-west1-c"
}

# Create a new instance
resource "google_compute_instance" "default" {
    name = "test"
    machine_type = "n1-standard-1"
    zone = "europe-west1-c"
    tags = ["kaka", "data"]

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
        foo = "bar"
    }

    metadata_startup_script = "echo hi > /test.txt"

}
