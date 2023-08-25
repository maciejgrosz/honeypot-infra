# resource "aws_subnet" "subnets" {
#   count = 2
#   vpc_id                  = aws_vpc.honeypot_vpc.id
#   cidr_block              = var.subnets[count.index]["cidr"]
#   availability_zone       = var.subnets[count.index]["az"]
#   tags                    = var.subnets[count.index]["tags"]
#   map_public_ip_on_launch = var.subnets[count.index]["public_ip"]
# }