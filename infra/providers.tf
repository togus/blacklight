# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "tobbe-1262"
  region      = "europe-west1-c"
}