variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
  default     = "ecs"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "default_backend_image" {
  type        = "string"
  default     = "cloudposse/default-backend:0.1.2"
  description = "ECS default (bootstrap) image"
}

variable "github_oauth_token" {
  type        = "string"
  description = "GitHub Oauth token. If not provided the token is looked up from SSM."
  default     = ""
}

variable "github_oauth_token_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup GitHub OAuth token if not provided"
  default     = ""
}

variable "enabled" {
  type        = "string"
  default     = "false"
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
}

variable "build_timeout" {
  default     = 5
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
}

variable "branch" {
  type        = "string"
  default     = "master"
  description = "Atlantis branch of the GitHub repository, _e.g._ `master`"
}

variable "repo_name" {
  type        = "string"
  description = "GitHub repository name of the atlantis to be built and deployed to ECS."
}

variable "repo_owner" {
  type        = "string"
  description = "GitHub organization containing the Atlantis repository"
}

variable "atlantis_repo_config" {
  type        = "string"
  description = "Path to atlantis config file"
  default     = "atlantis.yaml"
}

variable "atlantis_repo_whitelist" {
  type        = "list"
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  default     = []
}

variable "healthcheck_path" {
  type        = "string"
  description = "Healthcheck path"
  default     = "/healthz"
}

variable "chamber_format" {
  default     = "/%s/%s"
  description = "Format to store parameters in SSM, for consumption with chamber"
}

variable "chamber_service" {
  default     = "atlantis"
  description = "SSM parameter service name for use with chamber. This is used in chamber_format where /$chamber_service/$parameter would be the default."
}

variable "desired_count" {
  type        = "string"
  description = "Atlantis desired number of tasks"
  default     = "1"
}

variable "short_name" {
  description = "Alantis Short DNS name (E.g. `atlantis`)"
  default     = "atlantis"
}

variable "hostname" {
  type        = "string"
  description = "Atlantis URL"
  default     = ""
}

variable "atlantis_allow_repo_config" {
  type        = "string"
  description = "Allow Atlantis to use atlantis.yaml"
  default     = "true"
}

variable "atlantis_gh_user" {
  type        = "string"
  description = "Atlantis GitHub user"
}

variable "atlantis_gh_team_whitelist" {
  type        = "string"
  description = "Atlantis GitHub team whitelist"
  default     = ""
}

variable "atlantis_gh_webhook_secret" {
  type        = "string"
  description = "Atlantis GitHub webhook secret"
  default     = ""
}

variable "atlantis_log_level" {
  type        = "string"
  description = "Atlantis log level"
  default     = "info"
}

variable "atlantis_port" {
  type        = "string"
  description = "Atlantis container port"
  default     = "4141"
}

variable "atlantis_wake_word" {
  type        = "string"
  description = "Wake world for Atlantis"
  default     = "atlantis"
}

variable "atlantis_webhook_format" {
  type        = "string"
  default     = "https://%s/events"
  description = "Template for the Atlantis webhook URL which is populated with the hostname"
}

variable "autoscaling_min_capacity" {
  type        = "string"
  description = "Atlantis minimum tasks to run"
  default     = "1"
}

variable "autoscaling_max_capacity" {
  type        = "string"
  description = "Atlantis maximum tasks to run"
  default     = "1"
}

variable "container_cpu" {
  type        = "string"
  description = "Atlantis CPUs per task"
  default     = "256"
}

variable "container_memory" {
  type        = "string"
  description = "Atlantis memory per task"
  default     = "512"
}

variable "policy_arn" {
  type        = "string"
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = "Permission to grant to atlantis server"
}

variable "kms_key_id" {
  type        = "string"
  default     = ""
  description = "KMS key ID used to encrypt SSM SecureString parameters"
}

variable "webhook_secret_length" {
  default     = 32
  description = "GitHub webhook secret length"
}

variable "webhook_events" {
  type        = "list"
  description = "A list of events which should trigger the webhook."

  default = [
    "issue_comment",
    "pull_request",
    "pull_request_review",
    "pull_request_review_comment",
    "push",
  ]
}

variable "ssh_private_key_name" {
  type        = "string"
  default     = "atlantis_ssh_private_key"
  description = "Atlantis SSH private key name"
}

variable "ssh_public_key_name" {
  type        = "string"
  default     = "atlantis_ssh_public_key"
  description = "Atlantis SSH public key name"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID for the ECS Cluster"
}

variable "alb_listener_arns" {
  type        = "list"
  description = "A list of ALB listener ARNs"
}

variable "alb_ingress_paths" {
  type        = "list"
  default     = ["/*"]
  description = "Path pattern to match (a maximum of 1 can be defined), at least one of hosts or paths must be set"
}

variable "alb_name" {
  type        = "string"
  description = "The Name of the ALB"
}

variable "alb_arn_suffix" {
  type        = "string"
  description = "The ARN suffix of the ALB"
}

variable "alb_target_group_alarms_alarm_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an ALARM state from any other state."
  default     = []
}

variable "alb_target_group_alarms_ok_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an OK state from any other state."
  default     = []
}

variable "alb_target_group_alarms_insufficient_data_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an INSUFFICIENT_DATA state from any other state."
  default     = []
}

variable "alb_dns_name" {
  type        = "string"
  description = "DNS name of ALB"
}

variable "alb_zone_id" {
  type        = "string"
  description = "The ID of the zone in which ALB is provisioned"
}

variable "ecs_cluster_name" {
  type        = "string"
  description = "Name of the ECS cluster to deploy Atlantis"
}

variable "ecs_cluster_arn" {
  type        = "string"
  description = "ARN of the ECS cluster to deploy Atlantis"
}

variable "security_group_ids" {
  type        = "list"
  default     = []
  description = "Additional Security Group IDs to allow into ECS Service."
}

variable "private_subnet_ids" {
  type        = "list"
  default     = []
  description = "The private subnet IDs"
}

variable "region" {
  type        = "string"
  description = "AWS Region for Atlantis deployment"
  default     = "us-west-2"
}

variable "domain_name" {
  type        = "string"
  description = "A domain name for which the certificate should be issued"
}

variable "parent_zone_id" {
  type = "string"
  description = "The zone ID of the `domain_name`. Leave blank and it will be looked up using the `domain_name`. Define it to avoid cold-start problems."
  default = ""
}

variable "overwrite_ssm_parameter" {
  type        = "string"
  default     = "true"
  description = "Whether to overwrite an existing SSM parameter"
}
