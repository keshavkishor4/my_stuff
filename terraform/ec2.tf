//Creating Provider
provider "aws" {
    region = "us-east-1"
}
 
//Creating VPC in AWS and proving CIDR
resource "aws_vpc" "mysql" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
 
    enable_dns_hostnames = true
    enable_dns_support = true
 
    tags = {
        Name = "MYSQL_VPC"
    }
}
 
//Creating Internet Gateway and proving VPC ID
resource "aws_internet_gateway" "mysql_gw" {
    vpc_id = aws_vpc.mysql.id
 
    tags = {
        Name = "MYSQL_GW"
    }
}
 
//Creating Route Table and route all ipv4 traffic from GW
resource "aws_route_table" "mysql_route" {
    vpc_id = aws_vpc.mysql.id
 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mysql_gw.id
    }
 
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.mysql_gw.id
    }
 
    tags = {
        Name = "MYSQL_Route"
    }
}
 
//Creating Subnet with CIDR and VPC ID
resource "aws_subnet" "mysql_sub1" {
    vpc_id = aws_vpc.mysql.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "MYSQL_subnet"
    }
}
 

//Assosiate Subnet with Route Table
resource "aws_route_table_association" "mysql_sub_route" {
    subnet_id = aws_subnet.mysql_sub1.id
    route_table_id = aws_route_table.mysql_route.id
}
 
//Create Security Group to allow port 22,80,443
resource "aws_security_group" "mysql_sg" {
    name = "allow_traffic"
    description = "Allow inbound traffic"
    vpc_id = aws_vpc.mysql.id
 
    ingress {
        description = "HTTPS Traffic"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        description = "HTTP Traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        description = "HTTP Traffic"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        description = "HTTP Traffic"
        from_port = 8443
        to_port = 8443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        description = "SSH Traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    tags = {
        Name = "mysql_SG"
    }
}
 
//Create network interface with ip
resource "aws_network_interface" "mysql_dispatcher_ni" {
    subnet_id = aws_subnet.mysql_sub1.id
    security_groups = [aws_security_group.mysql_sg.id]
}
 

//Assign elastic ip to dispatcher
resource "aws_eip" "mysql_dispatcher_eip" {
    vpc = true
    instance = aws_instance.mysql_dispatcher.id
    network_interface = aws_network_interface.mysql_dispatcher_ni.id
    depends_on = [aws_internet_gateway.mysql_gw]
    //associate_with_private_ip = "${element(aws_network_interface.private_ips,2)}"
}
 

//Create Ec2 instance
resource "aws_instance" "mysql_dispatcher" {
    ami = "ami-04bf6dcdc9ab498ca"
    instance_type = "t2.large"
    availability_zone = "us-east-1a"
 
    key_name = "mysql_key"
 
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.mysql_dispatcher_ni.id
    }
 
    root_block_device {
      volume_type = "gp2"
      volume_size = 30
    }
 
    tags = {
        Name = "Mysql_Dispatcher"
    }
}
 