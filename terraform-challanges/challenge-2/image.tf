# Required Docker images resources

#Webserver docker image

resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path = "./lamp_stack/php_httpd"
    label = {
      challenge: "second"
    }
  }
}

# Maria DB docker image

resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path  = "./lamp_stack/custom_db"
    label = {
      challenge: "second"
    }
  }
}

# Create a Private network

resource "docker_network" "private_network" {
  name = "my_network"
  attachable = true
  labels {
    label = "challenge"
    value = "second"
  }
}

# Create a Volume for maria DB

resource "docker_volume" "mariadb_volume" {
  name=  "mariadb-volume"
}