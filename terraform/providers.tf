#Defining multiple providers using "alias" parameter
provider "aws" {
  profile = var.profile
  region  = var.region-master
  alias   = "region-master"
}
