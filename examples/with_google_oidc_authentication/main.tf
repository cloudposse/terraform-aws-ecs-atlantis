provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.4"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  cidr_block = "172.16.0.0/16"
}

data "aws_availability_zones" "available" {}

locals {
  availability_zones = "${slice(data.aws_availability_zones.available.names, 0, 2)}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.3.6"
  availability_zones  = "${local.availability_zones}"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "alb" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.2.6"
  name                      = "${var.name}"
  namespace                 = "${var.namespace}"
  stage                     = "${var.stage}"
  attributes                = ["${compact(concat(var.attributes, list("alb")))}"]
  vpc_id                    = "${module.vpc.vpc_id}"
  ip_address_type           = "ipv4"
  subnet_ids                = ["${module.subnets.public_subnet_ids}"]
  security_group_ids        = ["${module.vpc.vpc_default_security_group_id}"]
  access_logs_region        = "${var.region}"
  https_enabled             = "true"
  http_ingress_cidr_blocks  = ["0.0.0.0/0"]
  https_ingress_cidr_blocks = ["0.0.0.0/0"]
  certificate_arn           = "${var.certificate_arn}"
  health_check_interval     = "60"
}

module "ecs_cluster_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
}

# ECS Cluster (needed even if using FARGATE launch type)
resource "aws_ecs_cluster" "default" {
  name = "${module.ecs_cluster_label.id}"
}

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.4"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  cidr_block = "172.16.0.0/16"
}

data "aws_availability_zones" "available" {}

locals {
  availability_zones = "${slice(data.aws_availability_zones.available.names, 0, 2)}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.3.6"
  availability_zones  = "${local.availability_zones}"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "alb" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.2.6"
  name                      = "${var.name}"
  namespace                 = "${var.namespace}"
  stage                     = "${var.stage}"
  attributes                = ["${compact(concat(var.attributes, list("alb")))}"]
  vpc_id                    = "${module.vpc.vpc_id}"
  ip_address_type           = "ipv4"
  subnet_ids                = ["${module.subnets.public_subnet_ids}"]
  security_group_ids        = ["${module.vpc.vpc_default_security_group_id}"]
  access_logs_region        = "${var.region}"
  https_enabled             = "true"
  http_ingress_cidr_blocks  = ["0.0.0.0/0"]
  https_ingress_cidr_blocks = ["0.0.0.0/0"]
  certificate_arn           = "${var.certificate_arn}"
  health_check_interval     = "60"
}

module "ecs_cluster_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
}

# ECS Cluster (needed even if using FARGATE launch type)
resource "aws_ecs_cluster" "default" {
  name = "${module.ecs_cluster_label.id}"
}

module "atlantis" {
  source    = "../.."
  enabled   = "true"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  region    = "${var.region}"
  stage     = "${var.stage}"

  atlantis_gh_team_whitelist = "${var.atlantis_gh_team_whitelist}"
  atlantis_gh_user           = "${var.atlantis_gh_user}"
  atlantis_repo_whitelist    = ["${var.atlantis_repo_whitelist}"]

  alb_arn_suffix = "${module.alb.alb_arn_suffix}"
  alb_dns_name   = "${module.alb.alb_dns_name}"
  alb_name       = "${module.alb.alb_name}"
  alb_zone_id    = "${module.alb.alb_zone_id}"

  container_cpu    = "${var.atlantis_container_cpu}"
  container_memory = "${var.atlantis_container_memory}"

  branch             = "${var.atlantis_branch}"
  parent_zone_id     = "${var.parent_zone_id}"
  ecs_cluster_arn    = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name   = "${aws_ecs_cluster.default.name}"
  repo_name          = "${var.atlantis_repo_name}"
  repo_owner         = "${var.atlantis_repo_owner}"
  private_subnet_ids = ["${module.subnets.private_subnet_ids}"]
  security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  vpc_id             = "${module.vpc.vpc_id}"

  # NOTE: Cognito and OIDC authentication only supported on HTTPS endpoints; here we provide `https_listener_arn` from ALB
  alb_listener_arns       = ["${module.alb.https_listener_arn}"]
  alb_listener_arns_count = 1

  authentication_enabled = "true"

  # https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
  authentication_action = {
    type = "authenticate-oidc"

    authenticate_oidc = [{
      # Use this URL to create a Google OAuth 2.0 Client and obtain the Client ID and Client Secret: https://console.developers.google.com/apis/credentials
      client_id     = "${var.google_oidc_client_id}"
      client_secret = "${var.google_oidc_client_secret}"

      # Use this URL to get Google Auth endpoints: https://accounts.google.com/.well-known/openid-configuration
      issuer                 = "https://accounts.google.com"
      authorization_endpoint = "https://accounts.google.com/o/oauth2/v2/auth"
      token_endpoint         = "https://oauth2.googleapis.com/token"
      user_info_endpoint     = "https://openidconnect.googleapis.com/v1/userinfo"
    }]
  }
}
