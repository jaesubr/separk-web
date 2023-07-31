tf-backend 생성시

1. terraform init
2. terraform plan -var-file="../project.tfvars"
3. terraform apply -var-file="../project.tfvars" -auto-approve

network, app1, app2 생성시
1. terraform init  -backend-config="../backend.tfvars" 
   // backend.tfvars 파일 내용의 key값을 환경에 맞게 dev,stg,prod 수정
2. terraform plan -var-file="../project.tfvars" -var-file="env/prod.tfvars" 
   // env 하단 tfvars 파일을 환경에 맞게 dev.tfvars, stg.tfvars, prod.tfvars로 스왑
3. terraform apply -var-file="../project.tfvars" -var-file="env/prod.tfvars" -auto-approve
   // env 하단 tfvars 파일을 환경에 맞게 dev.tfvars, stg.tfvars, prod.tfvars로 스왑

환경 스왑해서 배포시에는 backend.tfvars의 key값 수정 후 디렉터리 내부의 
.terraform
.terraform.lock.hcl
두가지 디렉토리 삭제 후 상단 init, plan, apply 실행