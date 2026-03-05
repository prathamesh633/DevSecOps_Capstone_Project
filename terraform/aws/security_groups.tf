# ── ALB Security Group ──────────────────────────────────────────────────────
# tfsec:ignore:aws-ec2-no-public-ingress-sgr
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "alb" {
  # checkov:skip=CKV_AWS_260:Port 80 ingress required for demo
  # checkov:skip=CKV_AWS_23:Description for all rules not required for demo
  # checkov:skip=CKV_AWS_382:Egress to -1 allowed for demo
  name        = "${var.cluster_name}-alb-sg"
  description = "Allow HTTP and HTTPS from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.cluster_name}-alb-sg" }
}

# ── EKS Cluster Security Group ──────────────────────────────────────────────
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "eks_cluster" {
  # checkov:skip=CKV_AWS_23:Description for all rules not required for demo
  # checkov:skip=CKV_AWS_382:Egress to -1 allowed for demo
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow ALB to reach EKS nodes"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.cluster_name}-cluster-sg" }
}

# ── EKS Node Security Group ─────────────────────────────────────────────────
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "eks_nodes" {
  # checkov:skip=CKV_AWS_23:Description for all rules not required for demo
  # checkov:skip=CKV_AWS_382:Egress to -1 allowed for demo
  # checkov:skip=CKV2_AWS_5:Attachment warning false positive for EKS node group SG
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }
  ingress {
    description     = "Control plane to nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.cluster_name}-nodes-sg" }
}

# ── RDS Security Group ──────────────────────────────────────────────────────
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "rds" {
  # checkov:skip=CKV_AWS_23:Description for all rules not required for demo
  # checkov:skip=CKV_AWS_382:Egress to -1 allowed for demo
  name        = "${var.cluster_name}-rds-sg"
  description = "Allow PostgreSQL from EKS nodes only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.cluster_name}-rds-sg" }
}
