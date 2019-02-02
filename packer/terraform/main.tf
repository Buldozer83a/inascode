provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"

  # определение загрузочного диска
  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  tags = ["reddit-app"]

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "*********:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с тегом …
  target_tags = ["reddit-app"]
}
