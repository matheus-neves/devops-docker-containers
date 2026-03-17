# DevOps Learning Project — CI/CD & Infrastructure as Code

> A study project focused on **CI/CD** and **Terraform**. As a Frontend developer (React), I'm exploring DevOps to understand the full software delivery cycle — from code to cloud deployment.

## About the project

This repository is a **learning and experimentation environment**. The base application is a NestJS API, but the focus is on infrastructure and the delivery pipeline:

- **GitHub Actions** — CI/CD without long-lived credentials
- **Terraform** — Infrastructure as Code on AWS
- **Docker** — Multi-stage containerization
- **Amazon ECR** — Private image registry

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   GitHub        │     │   GitHub Actions │     │   AWS           │
│   (push main)   │────▶│   CI Pipeline     │────▶│   ECR           │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                  │
                                  │  OIDC (no secrets)
                                  ▼
                        ┌──────────────────┐
                        │   Terraform      │
                        │   IAM + ECR      │
                        └──────────────────┘
```

### Pipeline flow

1. **Push to `main` branch** → triggers the workflow
2. **Tests** → `yarn test` (Jest)
3. **Image build** → Docker multi-stage (Node 20 Alpine)
4. **Push to ECR** → authentication via OIDC (GitHub ↔ AWS)
5. **Tag** → commit SHA (7 characters)

## Tech stack

| Area | Technology |
|------|------------|
| **App** | NestJS, TypeScript, Node 20 |
| **CI/CD** | GitHub Actions |
| **IaC** | Terraform (AWS Provider) |
| **Container** | Docker (multi-stage build) |
| **Registry** | Amazon ECR |
| **Auth** | OIDC (OpenID Connect) — no AWS credentials stored |

## Repository structure

```
├── .github/workflows/
│   └── ci.yml              # Pipeline: test → build → push ECR
├── iac/
│   ├── main.tf              # AWS provider, region
│   ├── iam.tf               # OIDC provider, roles (ecr-role, app-runner-role)
│   └── ecr.tf               # ECR repository
├── Dockerfile               # Multi-stage build
└── src/                     # NestJS API
```

## Infrastructure (Terraform)

### Provisioned resources

- **OIDC Provider** — GitHub Actions ↔ AWS integration (trust policy by repo/branch)
- **IAM Role `ecr-role`** — Permissions for ECR push/pull + App Runner
- **IAM Role `app-runner-role`** — For future AWS App Runner deployment
- **ECR Repository** — `ecr-ci-api` with vulnerability scanning on push

### Concepts explored

- **OIDC** — Federated authentication without long-lived secrets
- **Trust policies** — Restriction via `token.actions.githubusercontent.com:sub`
- **Least privilege** — Minimum required permissions

## Running locally

### Application

```bash
yarn install
yarn run start:dev
```

### Tests

```bash
yarn test
```

### Docker (local)

```bash
docker build -t api:local .
docker run -p 3000:3000 api:local
```

## Infrastructure (Terraform)

```bash
cd iac
terraform init
terraform plan
terraform apply
```

**Prerequisites:** AWS CLI configured, credentials with permission to create IAM and ECR.

## CI configuration

For the pipeline to work, configure in GitHub:

1. **Secret `AWS_ROLE_ARN`** — ARN of the `ecr-role` (for GitHub Actions: build, push, deploy)
2. **Secret `AWS_APP_RUNNER_ACCESS_ROLE_ARN`** — ARN of the `app-runner-role` (for App Runner to pull images from ECR)
3. **Trust policy** — Repository and branch must match the `token.actions.githubusercontent.com:sub` condition in `iam.tf`

## Next steps (learning roadmap)

- [ ] AWS App Runner for automatic deployment
- [ ] Terraform remote backend (S3 + DynamoDB)
- [ ] Multi-environment (staging/prod)
- [ ] Observability (CloudWatch, X-Ray)

---

**Note:** This is a learning project. The NestJS application serves as the base; the focus is on CI/CD and IaC.
