# module "compute" {
#   source                     = "./modules/ec2_instance"
#   pub_honeypot_subnet_id     = module.network.pub_honeypot_subnet_id
#   honeypot_security_group_id = module.network.pub_honeypot_subnet_id
#   instance_type              = var.instance_type
#   key_pair_name              = var.key_pair_name
# }

module "network" {
  source                 = "./modules/network"
  vpc_cidr_block         = var.vpc_cidr_block
  pub_subnet_cidr_block  = var.pub_subnet_cidr_block
  priv_subnet_cidr_block = var.priv_subnet_cidr_block
  ingress_port           = var.ingress_port
  AZs                    = var.AZs
  private_ips_nic        = var.private_ips_nic
}

module "eks" {
  source                     = "./modules/eks"
  pub_honeypot_subnet_id     = module.network.pub_honeypot_subnet_id
  honeypot_security_group_id = module.network.honeypot_security_group_id
  instance_type              = var.instance_type
  no_of_nodes                = var.no_of_nodes
  key_pair_name              = var.key_pair_name
}