# 마스터 노드
resource "aws_instance" "master_node" {
  ami           = "ami-024ea438ab0376a47" # Ubuntu 또는 Amazon Linux 2
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_subnet_1.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.master_sg.id]
  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name  # IAM 연결

  # user_data = <<-EOF
  #   #!/bin/bash
  #   set -e

  #   # 1 패키지 업데이트 및 쿠버네티스 설치
  #   apt-get update && apt-get install -y apt-transport-https curl
  #   curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  #   echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  #   apt-get update && apt-get install -y kubelet kubeadm kubectl docker.io
  #   systemctl enable docker && systemctl start docker
  #   systemctl enable kubelet && systemctl start kubelet

  #   # 2 마스터 노드 초기화
  #   kubeadm init --pod-network-cidr=192.168.0.0/16

  #   # 3 kubectl 설정
  #   mkdir -p $HOME/.kube
  #   cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  #   chown $(id -u):$(id -g) $HOME/.kube/config

  #   # 4 Calico 네트워크 플러그인 적용
  #   kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

  #   # 5 워커 노드 조인을 위한 명령어 생성
  #   kubeadm token create --print-join-command > /home/ubuntu/join_command.sh
  # EOF

  tags = {
    Name = "K8S_Master"
    Role = "Master"
  }
}

# 워커 노드 1 - BE
resource "aws_instance" "be_node" {
  ami           = "ami-024ea438ab0376a47"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_subnet_2.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.be_sg.id]
  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name  # IAM 연결

  # 스팟 인스턴스 설정
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent" # 요청 유형: 지속적
      instance_interruption_behavior = "stop"    # 인터럽트 시 중지
    }
  }

  # EBS 볼륨 설정 (중지 후에도 유지)
  root_block_device {
    delete_on_termination = false
  }

  tags = {
    Name = "BE_Worker_Node"
    Role = "Worker"
  }
}

# 워커 노드 2 - AI
resource "aws_instance" "ai_node" {
  ami           = "ami-024ea438ab0376a47"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_subnet_3.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.ai_sg.id]
  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name  # IAM 연결

  # 스팟 인스턴스 설정
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent" # 요청 유형: 지속적
      instance_interruption_behavior = "stop"    # 인터럽트 시 중지
    }
  }

  # EBS 볼륨 설정 (중지 후에도 유지)
  root_block_device {
    delete_on_termination = false
  }

  tags = {
    Name = "AI_Worker_Node"
    Role = "Worker"
  }
}

# 워커 노드 3 - Redis
resource "aws_instance" "redis_node" {
  ami           = "ami-024ea438ab0376a47"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_subnet_4.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.redis_sg.id]
  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name  # IAM 연결

  # 스팟 인스턴스 설정
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent" # 요청 유형: 지속적
      instance_interruption_behavior = "stop"    # 인터럽트 시 중지
    }
  }

  # EBS 볼륨 설정 (중지 후에도 유지)
  root_block_device {
    delete_on_termination = false
  }

  tags = {
    Name = "Redis_Worker_Node"
    Role = "Worker"
  }
}

# 워커 노드 4 - Monitoring
resource "aws_instance" "monitoring_node" {
  ami           = "ami-024ea438ab0376a47"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_subnet_5.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.monitoring_sg.id]
  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name  # IAM 연결

  # 스팟 인스턴스 설정
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent" # 요청 유형: 지속적
      instance_interruption_behavior = "stop"    # 인터럽트 시 중지
    }
  }

  # EBS 볼륨 설정 (중지 후에도 유지)
  root_block_device {
    delete_on_termination = false
  }

  tags = {
    Name = "Monitoring_Worker_Node"
    Role = "Worker"
  }
}

# EC2 Instances
resource "aws_instance" "jenkins_server" {
  ami           = "ami-024ea438ab0376a47"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public_subnet_c.id
  key_name      = "PROFECT_OOPS!"
  security_groups = [aws_security_group.jenkins_sg.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name  # IAM 연결
	
	# 스팟 인스턴스 설정
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent" # 요청 유형: 지속적
      instance_interruption_behavior = "stop"    # 인터럽트 시 중지
    }
  }
	
  tags = {
    Name = "Jenkins_Server"
  }
}

# RDS Instance (비용 최소화 설정)
resource "aws_db_instance" "oops_rds" {
  identifier             = "oops-mysql-db"
  allocated_storage      = 20                   # 프리티어: 20GB까지 무료
  storage_type           = "gp2"                # 범용 SSD (프리티어 포함)
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"        # 프리티어 인스턴스
  username               = "oops_team"
  password               = "oops_pass1"         # 실사용시 변수 적용 권장
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = false                # 단일 AZ로 비용 절감
  availability_zone      = "ap-northeast-2c"    # 특정 AZ 선택
  publicly_accessible    = false                # 외부 접근 차단
  storage_encrypted      = true
  backup_retention_period = 0                   # 자동 백업 비활성화
  skip_final_snapshot    = true                 # 삭제 시 최종 스냅샷 생략
  deletion_protection    = false                # 필요 시 삭제 가능

  tags = {
    Name = "OOPS_RDS"
  }
}