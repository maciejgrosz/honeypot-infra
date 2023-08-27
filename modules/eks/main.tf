resource "aws_eks_cluster" "honeypot_cluster" {
  name     = "honepot-eks-cluster"
  role_arn = aws_iam_role.honeypot_eks_cluster_role.arn
  version  = "1.27"  # Set your desired EKS version

  vpc_config {
    subnet_ids = var.pub_honeypot_subnet_id # Set your desired subnet IDs
    security_group_ids = [var.honeypot_security_group_id]

    # Set other networking configurations if required
  }

  # Set other cluster configurations if required
}

resource "aws_eks_node_group" "honeypot_node_group" {
  cluster_name    = aws_eks_cluster.honeypot_cluster.name
  node_group_name = "honeypot-node-group"
  node_role_arn   = aws_iam_role.honeypot_node_group_role.arn
  subnet_ids     = var.pub_honeypot_subnet_id
  # instance_types = [var.instance_type]
  scaling_config {
    desired_size = var.no_of_nodes
    max_size     = var.no_of_nodes
    min_size     = var.no_of_nodes
  }
  # Set other worker node configurations if required
  launch_template {
    name = aws_launch_template.honeypot_launch_template.name
    version = aws_launch_template.honeypot_launch_template.latest_version
  }
}

resource "aws_launch_template" "honeypot_launch_template" {
  name = "honeypot_launch_template"
  key_name = var.key_pair_name

  # Do I need  Network interface configuration here?
  # vpc_security_group_ids = [var.your_security_group.id, aws_eks_cluster.your-eks-cluster.vpc_config[0].cluster_security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp2"
      delete_on_termination = true
    }
  }

  image_id           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]  # Canonical owner ID
}

resource "aws_iam_role" "honeypot_eks_cluster_role" {
  name = "honeypot-eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # Set other role configurations if required
}

resource "aws_iam_policy_attachment" "attach_eks_policy" {
  name       = "attach-eks-policy"
  roles      = [aws_iam_role.honeypot_eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "honeypot_node_group_role" {
  name = "honeypot-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # Set other role configurations if required
}
# Set other networking resources if required

resource "aws_iam_policy_attachment" "attach_eks_worker_policy" {
  name       = "attach-eks-worker-policy"
  roles      = [aws_iam_role.honeypot_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "attach_ecr_readonly_policy" {
  name       = "attach-ecr-readonly-policy"
  roles      = [aws_iam_role.honeypot_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
