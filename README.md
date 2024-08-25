# Cloud Resume Challenge

This project is part of the Cloud Resume Challenge, authored by Forrest Brazeal, which aims to demonstrate cloud skills by deploying a personal resume website using various cloud services.
I used AWS services for this project, but can also be adapted to GCP and Azure.
This README provides an overview of the project and key components used.

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

The Cloud Resume Challenge is a comprehensive project that involves:
1. Creating and styling a resume website.
2. Deploying the website on a cloud service.
3. Connecting the website to a serverless backend to count visitors.
4. Implementing continuous integration and continuous deployment (CI/CD) pipelines.
5. Utilizing Terraform as an IaC tool to manage the backend.

## Architecture

![Architecture Diagram](cloud-resume-architecture.png)

The architecture of this project includes:
- **Frontend:** A static website hosted on Amazon S3 and served through Amazon CloudFront.
- **Backend:** An API Gateway endpoint integrated with AWS Lambda and DynamoDB to track visitor counts.
- **CI/CD:** GitHub Actions for automated testing and deployment.
- **IaC:** Backend infrastructure managed using Terraform (Lambda, API GW, DynamoDB)

<img width="456" alt="image" src="https://github.com/user-attachments/assets/c3703cba-34f1-46f5-8b4d-d624b405697d">

## Prerequisites

Before you begin, ensure you have the following:
- An AWS account with appropriate permissions.
- Basic knowledge of HTML, CSS, and JavaScript.
- Familiarity with AWS services such as S3, Lambda, API Gateway, and DynamoDB.
- Installed tools: AWS CLI, Terraform, Git, and Python.

## Technologies Used

- **Frontend:**
  - HTML, CSS, JavaScript
  - Amazon S3
  - Amazon CloudFront
- **Backend:**
  - AWS Lambda
  - Amazon API Gateway
  - Amazon DynamoDB
- **CI/CD:**
  - GitHub Actions
- **Infrastructure as Code:**
  - Terraform

## Contributing
Contributions are welcome! Please create a pull request or open an issue for any changes or improvements.

