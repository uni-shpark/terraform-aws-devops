terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "uni-shpark"
    workspaces {
      name = "terraform-aws-devops"
    }
  }
}
