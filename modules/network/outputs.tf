output pub_honeypot_subnet_id {
    description = "public subnet id"
    value = "${aws_subnet.pub_honeypot_subnet.* .id}"
}

output honeypot_security_group_id {
    description = "honeypot security group id"
    value = aws_security_group.honeypot_security_group.id
}