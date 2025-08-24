
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.numAZs)

  tags = {
    TFName     = var.name
    GithubRepo = "chiller-iac"
    GithubOrg  = "lago-morph"
  }
}
