# Required Docker container resources

# Docker container for webServer

resource "docker_container" "php-httpd" {
  name  = "webserver"
  image = docker_image.php-httpd-image.name   // associate previously created webServer docker image resources
  hostname = "php-httpd"
  ports {
    internal = 80
    external = 80
    ip = "0.0.0.0"
  }
  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced {
    name = docker_network.private_network.name    // associate previously created  docker private network resources
  }
  volumes {
   container_path = "/var/www/html"                                                        // Volume mapping for host and container path
   host_path = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
  }
}

# Docker container for DB Admin Dashboard

resource "docker_container" "phpmyadmin" {
  name  = "db_dashboard"
  image = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"
  links = [ docker_container.mariadb.name ]    // established link based connectivity with mariDB container [Depricated]
  ports {
    internal = 80
    external = 8081
    ip = "0.0.0.0"
  }
  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced { 
    name = docker_network.private_network.name        // associate previously created  docker private network resources
  }
  
  depends_on = [ docker_container.mariadb ]           // set explicit dependency with MariaDB docker container
}

# Docker container for mariaDB

resource "docker_container" "mariadb" {
  name  = "db"
  image = docker_image.mariadb-image.name      // associate previously created maria Db docker image resources
  hostname = "db"
  env = (["MYSQL_ROOT_PASSWORD=1234", "MYSQL_DATABASE=simple-website"])
  ports {
    internal = 3306
    external = 3306
    ip = "0.0.0.0"
  }
  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced {
    name = docker_network.private_network.name       // associate previously created  docker private network resources
  }
  volumes {
   container_path = "/var/lib/mysql"
   volume_name = docker_volume.mariadb_volume.name    // associate previously created  docker volume resources
  }
}