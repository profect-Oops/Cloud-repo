# 마스터 노드 보안그룹
resource "aws_security_group" "master_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "Master_SG"

  # Worker Nodes에서 6443 포트 (Kubernetes API) 접근 허용
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = [aws_security_group.be_sg.id,
    aws_security_group.ai_sg.id,
    aws_security_group.redis_sg.id,
    aws_security_group.monitoring_sg.id] # 워커 노드에서 접근 가능
  }

  # Master ↔ Worker 간 통신 허용 (Etcd, Flannel)
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # # Flannel/Calico CNI (Overlay Network)
  # ingress {
  #   from_port   = 4789
  #   to_port     = 4789
  #   protocol    = "udp"
  #   cidr_blocks = ["10.0.0.0/16"]
  # }

  # Cluster DNS (CoreDNS)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Calico
  ingress {
    from_port   = 8285
    to_port     = 8286
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }
  
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "K8S_Master_SG" }
}

# 워커 노드 보안그룹
# 공통
resource "aws_security_group" "common_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "Common_SG"

  # 마스터 노드에서 10250 포트로 접근 (kubelet API)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
    # security_groups = [aws_security_group.master_sg.id] 의존성 충돌 생길까봐 재정의
  }

  # Calico
  ingress {
    from_port   = 8285
    to_port     = 8286
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Cluster DNS (CoreDNS)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = { Name = "Common_SG" }
}

# BE
resource "aws_security_group" "be_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "BE_Worker_SG"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id,
    aws_security_group.monitoring_sg.id] # ALB 접근, 모니터링만 허용
  }

  # RDS 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["10.0.8.0/24"] # RDS Subnet
  }

  # Redis
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks = ["10.0.6.0/24"] # Redis Subnet
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # Promtail (프로메테우스에서 promtail의 상태 체크하는 용도)
  ingress {
    from_port       = 9080
    to_port         = 9080
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }

  # # 공통 보안 그룹 추가
  # security_groups = [aws_security_group.common_sg.id]

  # 모든 노드에서 외부 인터넷 접근 가능 (필수)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "BE_Worker_SG" }
}

# AI
resource "aws_security_group" "ai_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "AI_Worker_SG"

  # 모니터링 서버(Prometheus)에서 접근 허용
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id] # 모니터링 서버만 접근 가능
  }

  # RDS 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["10.0.8.0/24"] # RDS Subnet
  }

  # Promtail (프로메테우스에서 promtail의 상태 체크하는 용도)
  ingress {
    from_port       = 9080
    to_port         = 9080
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # # 공통 보안 그룹 추가
  # security_groups = [aws_security_group.common_sg.id]

  # 모든 노드에서 외부 인터넷 접근 가능 (필수)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "AI_Worker_SG" }
}

# Redis
resource "aws_security_group" "redis_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "Redis_Worker_SG"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks = ["10.0.4.0/24"] # BE만 허용
  }

  # 모니터링 (Redis Exporter)
  ingress {
    from_port       = 9121
    to_port         = 9121
    protocol        = "tcp"
    cidr_blocks = ["10.0.7.0/24"] # Monitoring만 허용
  }

  # Promtail (프로메테우스에서 promtail의 상태 체크하는 용도)
  ingress {
    from_port       = 9080
    to_port         = 9080
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # # 공통 보안 그룹 추가
  # security_groups = [aws_security_group.common_sg.id]

  # 모든 노드에서 외부 인터넷 접근 가능 (필수)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Redis_Worker_SG" }
}

# RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "RDS_SG"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24"] # BE, AI만 허용
  }

  tags = { Name = "RDS_SG" }
}

# Monitoring
resource "aws_security_group" "monitoring_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "Monitoring_Worker_SG"

  # Prometheus
  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC 내부
  }

  # Grafana
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC 내부
  }

  # Loki
  ingress {
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC 내부
    # security_groups = [aws_security_group.be_sg.id,
    # aws_security_group.ai_sg.id, 
    # ws_security_group.redis_sg.id] # 각 서버들이 push할 수 있도록 열어줌
  }

  # # 공통 보안 그룹 추가
  # security_groups = [aws_security_group.common_sg.id]

  # 모든 노드에서 외부 인터넷 접근 가능 (필수)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Monitoring_Worker_SG" }
}

# ALB(Ingress) 보안 그룹
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.oops_vpc.id
  name   = "ALB_SG"

  # ALB는 외부에서 접근 가능해야 함
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 필요 시 제한 가능
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ALB_SG" }
}

# Jenkins 서버 보안 그룹
resource "aws_security_group" "jenkins_sg" {
  vpc_id      = aws_vpc.oops_vpc.id
  name        = "Jenkins_sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins Web UI 접근 (8080 포트)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 특정 IP로 제한 권장
  }

  # SSH 접근 (22 포트)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 특정 IP로 제한 권장
  }

  # HTTPS 접근 (443 포트, HTTPS 사용 시)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: 인터넷으로의 모든 outbound 허용 (GitHub, 패키지 설치 등)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Jenkins_sg" }
}



# AI 보안 그룹에서 Common_SG 허용
resource "aws_security_group_rule" "ai_common" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ai_sg.id
  source_security_group_id = aws_security_group.common_sg.id
}

# BE 보안 그룹에서 Common_SG 허용
resource "aws_security_group_rule" "be_common" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.be_sg.id
  source_security_group_id = aws_security_group.common_sg.id
}

# Redis 보안 그룹에서 Common_SG 허용
resource "aws_security_group_rule" "redis_common" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = aws_security_group.common_sg.id
}

# Monitoring 보안 그룹에서 Common_SG 허용
resource "aws_security_group_rule" "monitoring_common" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.common_sg.id
}
