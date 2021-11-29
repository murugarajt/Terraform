resource "google_compute_subnetwork" "subnet" {
    name = var.subnet-name
    ip_cidr_range = "10.1.152.0/21"
    region = var.region
    network = var.network-name
}


resource "google_compute_instance" "vm"{
    name = var.vmname
    machine_type = "e2-small"
    zone = var.zone
    boot_disk {
        initialize_params{
            image = "debian-cloud/debian-9"
        }
    
    }
    network_interface{
        network = var.network-name
        subnetwork = var.subnet-name
        access_config {
          
        }
    }
    tags = ["web"]


}

