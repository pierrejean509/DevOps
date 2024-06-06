# DevOps

# AWS Infrastructure as Code with Terraform

This repository contains Terraform code to set up a basic infrastructure on AWS. The components included in this setup are:

- A Virtual Private Cloud (VPC)
- Three EC2 instances (one control plane and two worker nodes)
- One Subnet
- One Security Group
- One Route Table
- One Route Table Association
- One Internet Gateway

## Table of Contents

- [Overview](#overview)
- [Components](#components)
  - [VPC](#vpc)
  - [Subnet](#subnet)
  - [Security Group](#security-group)
  - [Route Table](#route-table)
  - [Route Table Association](#route-table-association)
  - [Internet Gateway](#internet-gateway)
  - [EC2 Instances](#ec2-instances)
- [Usage](#usage)
- [Diagram](#diagram)

## Overview

This Terraform configuration will create a secure and efficient environment on AWS, consisting of a VPC with an associated subnet, security group, route table, route table association, internet gateway, and three EC2 instances (one control plane and two worker nodes).

## Components

### VPC

File: `vpc.tf`

Defines a Virtual Private Cloud (VPC) which isolates the infrastructure within a virtual network specific to your AWS account.

### Subnet

File: `subnet.tf`

Defines a subnet within the VPC, allowing resources to be grouped and managed within a smaller segment of the VPC.

### Security Group

File: `security-group.tf`

Defines a security group to control inbound and outbound traffic to the EC2 instances, enhancing the security of the infrastructure.

### Route Table

File: `route-table.tf`

Defines a route table for the VPC, which is used to determine how traffic is directed within the VPC.

### Route Table Association

File: `route-table-association.tf`

Associates the created route table with the subnet, ensuring that the routing rules apply to the subnet.

### Internet Gateway

File: `internet-gateway.tf`

Defines an internet gateway to allow the VPC to connect to the internet.

### EC2 Instances

File: Defined within `main.tf` or separate files for each instance.

Creates three EC2 instances: one for the control plane and two for the worker nodes. These instances are the computational resources that will perform tasks within the VPC.

## Usage

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/your-repo.git
    cd your-repo
    ```

2. Initialize Terraform:
    ```sh
    terraform init
    ```

3. Plan the infrastructure changes:
    ```sh
    terraform plan
    ```

4. Apply the infrastructure changes:
    ```sh
    terraform apply
    ```

5. To destroy the infrastructure:
    ```sh
    terraform destroy
    ```

## Diagram

Below is a graphical representation of the infrastructure:

![Infrastructure Diagram](infrastructure-diagram.png)

## Diagram

```mermaid
graph TD
    VPC[VPC]
    Subnet[Subnet]
    SecurityGroup[Security Group]
    RouteTable[Route Table]
    InternetGateway[Internet Gateway]
    ControlPlane[EC2 Instance - Control Plane]
    WorkerNode1[EC2 Instance - Worker Node 1]
    WorkerNode2[EC2 Instance - Worker Node 2]
    RouteTableAssociation[Route Table Association]
    
    VPC --> Subnet
    VPC --> SecurityGroup
    VPC --> RouteTable
    VPC --> InternetGateway
    Subnet --> ControlPlane
    Subnet --> WorkerNode1
    Subnet --> WorkerNode2
    RouteTable --> RouteTableAssociation
    RouteTableAssociation --> Subnet
    SecurityGroup --> ControlPlane
    SecurityGroup --> WorkerNode1
    SecurityGroup --> WorkerNode2
    InternetGateway --> RouteTable
