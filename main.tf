variable "public_key" {
	type = string
}

terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "=4.18.0"
		}
	}
}

provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "oa_vpc" {
	cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "oa_public_subnet" {
	vpc_id = aws_vpc.oa_vpc.id
	cidr_block = "10.0.0.0/24"
}

resource "aws_network_acl" "oa_nacl" {
	vpc_id = aws_vpc.oa_vpc.id
        subnet_ids = [aws_subnet.oa_public_subnet.id]	

	egress {
		protocol = -1
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	ingress {
		protocol = -1
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}
	tags = {
		Name = "oa_nacl"
	}
}

resource "aws_internet_gateway" "oa_igw" {
	vpc_id = aws_vpc.oa_vpc.id

	tags = {
		Name = "oa_igw"
	}
}

resource "aws_route_table" "oa_rt" {
	vpc_id = aws_vpc.oa_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.oa_igw.id
	}

	tags = {
		Name = "oa_rt"
	}
}

resource "aws_route_table_association" "oa_rt_link" {
	subnet_id = aws_subnet.oa_public_subnet.id
	route_table_id = aws_route_table.oa_rt.id
}

resource "aws_security_group" "oa_sg" {
	name = "OA security group"
	description = "onboarding assignment"
	vpc_id = aws_vpc.oa_vpc.id

	ingress {
		description = "SSH access"
		from_port = 0
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
		Name = "OA Security group"
	}
}

resource "aws_network_interface" "oa_nic" {
	subnet_id = aws_subnet.oa_public_subnet.id
	private_ips = ["10.0.0.5"]
	security_groups = [aws_security_group.oa_sg.id]
}

resource "aws_key_pair" "oa_kp" {
	key_name = "oa_key"
	public_key = var.public_key
}

resource "aws_eip" "oa_eip" {
	network_interface = aws_network_interface.oa_nic.id
	associate_with_private_ip = "10.0.0.5"
	
	tags = {
		Name = "OA EIP"
	}
}

resource "aws_instance" "oa_vm" {
	ami = "ami-09d56f8956ab235b3"
	instance_type = "t2.micro"

	network_interface {
		network_interface_id = aws_network_interface.oa_nic.id
		device_index = 0
	}
	key_name = "oa_key"
	tags = {
		Name = "OA VM"
	}
}

output "instance_ip_addr" {
	value = aws_instance.oa_vm.public_ip
}
