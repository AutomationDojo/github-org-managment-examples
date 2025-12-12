locals {
  environment = yamldecode(file("${path.root}/configs/org.yaml"))
}