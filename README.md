# PulseInfra

[![Terraform CI](https://github.com/robertogonzalez-dev/PulseInfra/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/robertogonzalez-dev/PulseInfra/actions/workflows/terraform-ci.yml)

**Infrastructure as code for running [PulseForecast](https://github.com/robertogonzalez-dev/PulseForecast) on AWS.** This repo holds the Terraform modules, keyless CI/CD from GitHub Actions, zero-downtime rolling deploys with automatic rollback, and cost guardrails.

## Architecture

```text
                  GitHub Actions ──(OIDC, no stored keys)──> IAM role
                        │ build + push                              │ terraform apply
                        ▼                                           ▼
 Internet ──> ALB :80 ──> Target group ──> ECS Fargate (Spot) tasks ──> CloudWatch Logs
              (public SG)                  (SG: only from ALB)           + 5xx alarm
                                           │  pulls image                + CPU autoscaling 1–2
                                           ▼
                                   ECR (scan on push, keep last 5)

  VPC 10.20.0.0/16 · 2 public subnets across AZs · no NAT gateway
  Remote state: S3 (versioned, encrypted, native lockfile) · AWS Budget alert
```

## What this demonstrates
- **Reusable Terraform modules** (`network`, `ecr`, `ecs-service`) composed per environment (`envs/dev`)
- **Remote state** in S3 with Terraform 1.10+ native locking (no DynamoDB table)
- **Keyless CI/CD:** GitHub OIDC federation into a repo-scoped IAM role
- **Safe deploys:** image tags tied to commit SHAs (immutable ECR tags), an ECS deployment circuit breaker with rollback, and a post-deploy smoke test
- **Pipeline quality gates:** `fmt`, `validate`, `tflint` and a Trivy IaC scan on every PR, with `terraform plan` posted as a PR comment
- **Cost awareness:** Fargate Spot, no NAT gateway, short log retention, ECR lifecycle rules, a monthly budget alert, and a one-click destroy workflow

## Cost
While it's running, dev costs about **$20/month**: roughly $16 for the ALB plus a few dollars for one 0.5 vCPU / 1 GB Spot task. Run the **Destroy** workflow when you're not demoing; the S3 state and ECR images cost pennies.

## Setup

### 1. Bootstrap (once, from your machine)
Requires Terraform ≥ 1.10 and AWS CLI credentials for your account.

```bash
cd terraform/bootstrap
terraform init
terraform apply -var "alert_email=you@example.com"
```

Save the outputs as **repository variables** (Settings → Secrets and variables → Actions → Variables):

| Variable | Value |
|---|---|
| `AWS_ROLE_ARN` | `github_actions_role_arn` output |
| `TF_STATE_BUCKET` | `state_bucket` output |
| `AWS_REGION` | `us-east-1` (optional) |

Create a GitHub **environment** named `dev`. You can optionally add yourself as a required reviewer.

### 2. Deploy
Actions → **Deploy** → Run workflow. It builds PulseForecast from `main`, pushes to ECR, applies Terraform and smoke-tests the live URL. The URL appears in the run summary.

### 3. Tear down
Actions → **Destroy**, then type `destroy-dev`.

<details>
<summary>Running Terraform locally</summary>

```bash
cd terraform/envs/dev
cp backend.hcl.example backend.hcl   # fill in the bucket
terraform init -backend-config=backend.hcl
terraform plan -var image_tag=<sha-in-ecr>
```
</details>

## Layout
```text
terraform/
  bootstrap/            state bucket, GitHub OIDC role, budget (local state, applied once)
  modules/network/      VPC, public subnets, IGW, routes
  modules/ecr/          image registry + lifecycle policy
  modules/ecs-service/  ALB, security groups, IAM, ECS cluster/service, autoscaling, alarms
  envs/dev/             composes the modules; S3 backend
.github/workflows/      terraform-ci (PR checks + plan), deploy, destroy
```

See [docs/SCOPE.md](docs/SCOPE.md) for milestones and the hardening roadmap.
