# terraform-aws-practice
# Terraform AWS Practice

This repository contains a personal learning project focused on
Infrastructure as Code (IaC) using Terraform and AWS.

The goal of this project is to deepen my understanding of
cloud infrastructure design, high availability concepts,
and disaster recovery (DR) considerations through hands-on implementation.

---

## Purpose

- Practice Terraform fundamentals (init / plan / apply)
- Understand state management and backend concepts
- Implement a private-only AWS architecture
- Explore Multi-AZ and DR design concepts

This project is part of my transition from traditional infrastructure
experience toward cloud-native infrastructure design.

---

## Architecture Concept

This project assumes a hypothetical financial system scenario
with the following constraints:

- No public internet exposure
- Private-only VPC design
- Multi-AZ redundancy
- DR awareness (Primary / Secondary concept)

### Current Implementation Scope

The current implementation focuses on:

- VPC creation
- Private subnets distributed across multiple Availability Zones
- Stable resource management using `for_each`

Future extensions may include:

- Security group refinement
- VPC endpoints
- Backend migration to S3 + DynamoDB
- Cross-region DR configuration

---

## Design Considerations

### 1. Private-Only Architecture

All resources are deployed in private subnets.
The design assumes closed-network connectivity
(e.g., Direct Connect or VPN).

### 2. Multi-AZ Awareness

Subnets are explicitly mapped to Availability Zones
to better understand availability design patterns.

### 3. Stable Resource Identity

`for_each` is used instead of `count`
to reduce unintended resource recreation
caused by ordering changes.

### 4. DR Philosophy (Conceptual)

Although not fully implemented yet,
the design considers:

- Secondary region standby strategy
- Human-controlled failover
- Infrastructure reproducibility via code

The focus is on understanding design thinking,
rather than building a production-ready system.

---

## Repository Structure

terraform-aws-practice/

├── main.tf

├── providers.tf

├── variables.tf

├── terraform.tfvars

├── outputs.tf

└── README.md

---

## Note

This repository is for educational and interview preparation purposes only.
No real customer or production information is included.



