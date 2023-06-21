#VPC 정보를 가져오는 곳
data "terraform_remote_state" "aws04_vpc" {
    backend = "s3"
    config = {
        bucket  = "aws00-terraform-state"
        key     = "infra/network/vpc/terraform.tfstate"
        region  = "ap-northeast-2"
    }
}
