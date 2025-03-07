# SSM 설정
# Jenkins IAM 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "PROFECT-Jenkins-Profile"
  role = "PROFECT-Jenkins-Role"
}

# Others IAM 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "private_server_profile" {
  name = "PROFECT-Private-Profile"
  role = "PROFECT_Private_Role"
}