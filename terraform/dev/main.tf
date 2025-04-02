module "aws-infra" {
    source      = "../aws-infra"
    project     = var.project
    environment = var.environment
  
}