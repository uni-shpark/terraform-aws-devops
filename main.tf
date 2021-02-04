provider "aws" {
  region = var.region
}

terraform {
  required_version = "0.14.5"

  required_providers {
    aws = ">= 3.22.0"
  }
}

#####
# Vpc
#####

module "vpc" {
  source  = "app.terraform.io/uni-shpark/vpc/aws"
  version = "1.0.0"
  vpc-location                        = "Virginia"
  namespace                           = "devops"
  name                                = "vpc"
  stage                               = "cicd"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24"]
  vpc-private-subnet-cidr             = ["10.20.4.0/24","10.20.5.0/24"]
  vpc-database_subnets-cidr           = ["10.20.7.0/24","10.20.8.0/24"]
}


module "sg1" {
  source              = "./modules/terraform-aws-cidr"
  namespace           = "devops"
  stage               = "dev"
  name                = "Jenkins"
  tcp_ports           = "22,80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Jenkins"
  vpc_id              = module.vpc.vpc-id
}

module "jenkins-eip" {
  source = "./modules/terraform-aws-eip"
  name                         = "jenkins"
  instance                     = module.ec2-jenkins.id[0]
}

module "ec2-jenkins" {
  source                        = "./modules/terraform-aws-ec2"
  namespace                     = "devops"
  stage                         = "dev"
  name                          = "jenkins"
  key_name                      = "jenkins-demo"
  public_key                    = file("./secrets/jenkins-demo.pub")
  user_data                     = file("./scripts/jenkins/user-data.sh")
  instance_count                = 1
  ami                           = "ami-0a93a08544874b3b7"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 40
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

module "tomcat-eip" {
  source = "./modules/terraform-aws-eip"
  name                         = "tomcat"
  instance                     = module.ec2-tomcat.id[0]
}

module "ec2-tomcat" {
  source                        = "./modules/terraform-aws-ec2"
  namespace                     = "devops"
  stage                         = "dev"
  name                          = "tomcat"
  key_name                      = "tomcat-demo"
  public_key                    = file("./secrets/tomcat.pub")
  user_data                     = file("./scripts/tomcat/user-data.sh")
  instance_count                = 1
  ami                           = "ami-0a93a08544874b3b7"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 20
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}
