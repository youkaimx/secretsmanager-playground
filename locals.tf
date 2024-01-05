locals {
  default_tags = {
    Management    = "Terraform"
    Owner         = "RJVE"
    Project       = "Test for work"
    Project_Short = "${var.project_short_name}"
  }
}
