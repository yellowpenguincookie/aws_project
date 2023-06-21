#VPC 정보를 가져오는 곳
data "terraform_remote_state" "aws04_vpc" {
    backend = "s3"
    config = {
                #vpc는 현재 aws00 하나밖에 없기에 이거 사용해야함. 
        bucket  = "aws00-terraform-state"
        key     = "infra/network/vpc/terraform.tfstate"
        region  = "ap-northeast-2"
    }
}
