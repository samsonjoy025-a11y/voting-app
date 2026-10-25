# Voting App — DevOps Capstone

A hands-on DevOps project focused on building, securing, deploying, and operating a distributed application using Docker, Kubernetes, Helm, Terraform, and GitHub Actions.

This project extends the open-source [Example Voting App](https://github.com/dockersamples/example-voting-app) to demonstrate container security, CI/CD automation, Kubernetes deployment, and Infrastructure as Code.

## Project Goals

- **Containerization:** Build and run application services using Docker.
- **Container security:** Apply non-root execution and `.dockerignore` best practices.
- **CI/CD:** Build, scan, and publish container images using GitHub Actions and Trivy.
- **Kubernetes:** Deploy and manage application workloads using Helm.
- **Infrastructure as Code:** Define AWS EKS infrastructure with Terraform.
- **Operational resilience:** Practise Helm rollback and infrastructure recreation.

## Project Status

The local application, container security improvements, CI/CD image publishing, and local Kubernetes deployment have been implemented and tested.

The following items remain outstanding:

- A verified demonstration of a deliberate bad Helm release followed by rollback.
- Automated Kubernetes deployment through GitHub Actions.
- AWS EKS provisioning, destruction, and recreation using Terraform.

This README distinguishes verified work from outstanding tasks so the project's progress is clear and reproducible.

## Architecture

![Voting App architecture](architecture.excalidraw.png)

The application consists of five main components:

- **Vote:** A Python web application that accepts votes.
- **Redis:** A queue that temporarily holds incoming votes.
- **Worker:** A .NET service that processes votes and stores the results.
- **PostgreSQL:** A database that stores vote data.
- **Result:** A Node.js web application that displays the results.

## Prerequisites

To run the application locally, install:

- [Docker Desktop](https://www.docker.com/products/docker-desktop), including Docker Compose.
- Git, to clone and manage the repository.

For the Kubernetes and infrastructure sections, you may also need:

- kubectl
- Helm
- Minikube or another Kubernetes cluster
- Terraform
- AWS CLI and an AWS account for real EKS provisioning

## Run Locally with Docker Compose

From the repository root, build and start the application:

```bash
docker compose up --build
```

Open the application in your browser:

- **Voting interface:** [http://localhost:8080](http://localhost:8080)
- **Results interface:** [http://localhost:8081](http://localhost:8081)

Cast a vote and check that the results page updates.

To stop the application, press `Ctrl+C`. To remove the containers and networks, run:

```bash
docker compose down
```

## Container Security

Container security improvements include:

- Running application services as non-root users where configured.
- Using a `.dockerignore` file to exclude unnecessary build-context files.
- Reviewing individual Dockerfiles and their base images.

Check each service's Dockerfile to verify its specific configuration.

## GitHub Actions CI/CD

The workflow is located at `.github/workflows/ci-cd.yml`.

The workflow currently:

1. Validates the Docker Compose configuration.
2. Builds the vote, result, and worker container images.
3. Scans the images with Trivy for critical vulnerabilities.
4. Publishes commit-SHA-tagged images to GitHub Container Registry (GHCR) on push events.

### Current limitations

- Trivy is configured to report critical findings without failing the workflow solely because findings are present.
- Compose validation does not replace automated application tests.
- The workflow builds, scans, and publishes images; it does not yet deploy the application automatically to Kubernetes.

## Kubernetes Deployment with Helm

The Helm chart is located in `helm/voting-app/`. It defines the vote, result, worker, Redis, and PostgreSQL workloads.

### Validate the chart

From the repository root, run:

```bash
helm lint helm/voting-app
```

### Install or upgrade the application

Ensure your current Kubernetes context points to the intended cluster, then run:

```bash
helm upgrade --install voting-app helm/voting-app
```

### Check the deployment

Inspect the release and Kubernetes workloads:

```bash
helm status voting-app
helm history voting-app
kubectl get deployments
kubectl get pods
```

Confirm that the deployments are ready and the pods are running before testing the application.

### Roll back a release

First, inspect the release history:

```bash
helm history voting-app
```

Identify the revision you intend to restore, then replace `REVISION_NUMBER` with that revision:

```bash
helm rollback voting-app REVISION_NUMBER
```

Verify the result:

```bash
helm status voting-app
helm history voting-app
kubectl get deployments
kubectl get pods
```

A deliberate bad-release-and-rollback demonstration still needs to be verified and documented with evidence. Do not assume a particular revision is the correct rollback target without checking the release history.

## Infrastructure as Code: AWS EKS

The `terraform/` directory contains Terraform configuration for an Amazon EKS cluster, IAM roles, and a managed worker-node group using the AWS default VPC.

### Initialize Terraform

From the repository root:

```bash
terraform -chdir=terraform init -backend=false
```

### Check formatting

```bash
terraform -chdir=terraform fmt -check
```

### Validate the configuration

```bash
terraform -chdir=terraform validate
```

### Review the proposed infrastructure

When AWS credentials and the required permissions are available, run:

```bash
terraform -chdir=terraform plan
```

Review the proposed changes before creating any infrastructure.

**Cost warning:** Amazon EKS control-plane resources and worker nodes can incur charges. Do not apply the configuration until you have reviewed and approved the resources and expected costs. No real AWS cluster should be assumed to exist until provisioning has been completed and verified.

### Current infrastructure status

Terraform formatting and configuration validation have passed. AWS authentication, real cluster provisioning, destruction, and recreation remain pending AWS account access.

## Capstone Completion Checklist

- [x] Run the application locally and test voting and results.
- [x] Implement container security improvements.
- [x] Build, scan, and publish container images through GitHub Actions.
- [x] Validate the Helm chart.
- [x] Deploy the application to local Kubernetes and verify workload health.
- [x] Include an architecture diagram.
- [ ] Demonstrate a deliberate bad Helm release and verify rollback.
- [ ] Implement and test automated Kubernetes deployment through CI/CD.
- [ ] Provision an AWS EKS cluster using Terraform.
- [ ] Demonstrate Terraform destroy and recreation against AWS.
- [ ] Review the final README and repository for accidental secrets before submission.

## Original Project

This project builds on the open-source [Example Voting App](https://github.com/dockersamples/example-voting-app), which demonstrates a distributed application using multiple services and technologies.

The DevOps work in this repository focuses on extending that application with container security, CI/CD, Kubernetes deployment, and infrastructure automation.