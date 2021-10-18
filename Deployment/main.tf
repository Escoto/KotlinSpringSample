
locals {
  region   = "europe-west3"
  project  = "gke-deplyment-example"
  vpc_name = "gke-example-vpc"
}

provider "google" {
  region  = local.region
  project = local.project
  version = "3.88.0"
}

resource "google_compute_network" "gke_vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "${local.vpc_name}-subnet"
  ip_cidr_range            = "10.10.0.0/20"
  network                  = google_compute_network.gke_vpc.self_link
  region                   = local.region
  private_ip_google_access = true
}

resource "google_container_cluster" "gke_cluster" {
  name               = "example-gke-cluster"
  location           = local.region // Making it regional
  initial_node_count = 1
  network            = google_compute_network.gke_vpc.name
  subnetwork         = google_compute_subnetwork.gke_subnet.name
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  version = "1.10.0"
  host    = google_container_cluster.gke_cluster.endpoint
  token   = data.google_client_config.provider.access_token
  client_certificate = base64decode(
    google_container_cluster.gke_cluster.master_auth[0].client_certificate,
  )
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate,
  )
  client_key = base64decode(google_container_cluster.gke_cluster.master_auth[0].client_key)
}

resource "google_compute_address" "public_lb_ip" {
  name   = "ghost-lb-ip"
  region = local.region
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app"
  }

  spec {
    selector = {
      run = "app"
    }

    session_affinity = "None"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.public_lb_ip.address
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"

    labels = {
      run = "app"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        run = "app"
      }
    }

    template {
      metadata {
        name = "app"
        labels = {
          run = "app"
        }
      }

      spec {
        container {
          image = "escoto/kotlinresthello"
          name  = "app"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

output "public_url" {
  value = "http://${google_compute_address.public_lb_ip.address}"
}
