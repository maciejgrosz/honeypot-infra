resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.my_eks_cluster_role.arn
  version  = "1.27"  # Set your desired EKS version

  vpc_config {
    subnet_ids = var.pub_honeypot_subnet_id # Set your desired subnet IDs

    # Set other networking configurations if required
  }

  # Set other cluster configurations if required
}

resource "aws_eks_node_group" "honeypot_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "honeypot-node-group"
  node_role_arn   = aws_iam_role.my_node_group_role.arn
  subnet_ids     = var.pub_honeypot_subnet_id
  instance_types = [var.instance_type]
  scaling_config {
    desired_size = var.no_of_nodes
    max_size     = var.no_of_nodes
    min_size     = var.no_of_nodes
  }
  # Set other worker node configurations if required
}

resource "aws_iam_role" "my_eks_cluster_role" {
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
  roles      = [aws_iam_role.my_eks_cluster_role.name]
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
  roles      = [aws_iam_role.my_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "attach_ecr_readonly_policy" {
  name       = "attach-ecr-readonly-policy"
  roles      = [aws_iam_role.my_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
