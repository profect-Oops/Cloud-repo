# Cloud-repo
<아키텍처 사진>

## 🌐 인프라 구축 및 관리
> IaC(Terraform, Ansible) 도구를 활용한 인프라 구축과 유지보수

1. 네트워크 설계
- 고가용성
- 확장성
- 안정성

3. 리소스 분배
   |서브넷 유형|배치된 리소스|역할|
   |------|----------|------|
   |Public Subnet|ALB(Application Load Balancer), NLB(Network Load Balancer), NAT Gateway, Jenkins|외부 접근이 필요한 리소스 배치 및 트래픽 라우팅|
   |Private Subnet|애플리케이션 서버(Spring), AI 서버(Python, airflow), RDS(MySQL), Redis, 모니터링(Prometheus, Grafana, Loki), ArgoCD, NginX Ingress Controller|주요 애플리케이션 및 데이터 보관 (보안 강화)|


---
