# PulseInfra: scope and milestones

## Goal
Show production-style cloud delivery: infrastructure as code, keyless CI/CD, safe deploys, observability and cost control. It deploys PulseForecast, so the portfolio tells one connected story: **data platform (CommercePulse) → ML model (PulseForecast) → cloud deployment (PulseInfra)**. Scope is roughly 3 weekends.

## Definition of done
- [x] Modules for network, ECR and ECS service; dev environment; S3 remote state
- [x] GitHub OIDC role, deploy and destroy workflows, PR checks with plan comments
- [ ] Bootstrap applied and the first deploy green, with a screenshot of `/docs` on the live URL in the README
- [ ] Architecture diagram image (draw.io or Excalidraw) in the README
- [ ] Short write-up: "What I'd change for production" (see hardening below)

## Milestones
1. **Weekend 1.** Install Terraform, apply the bootstrap, run the first deploy and fix whatever breaks. Real debugging stories make good interview material.
2. **Weekend 2.** Trigger a deploy from PulseForecast's CI with `repository_dispatch` so an app merge deploys automatically. Add a CloudWatch dashboard (requests, latency p95, 5xx, CPU and memory) as code.
3. **Weekend 3.** Add a `prod` environment that reuses the modules with different sizing, and gate it behind a manual approval.

## Hardening (documented trade-offs, deliberately deferred for cost)
| Now (dev) | Production |
|---|---|
| HTTP on port 80 | ACM certificate with an HTTPS listener and an HTTP→HTTPS redirect; Route 53 domain |
| Tasks in public subnets, no NAT | Private subnets with VPC endpoints (ECR, S3, Logs) or a NAT gateway |
| `PowerUserAccess` for the CI role | Least-privilege policy scoped to project ARNs; a separate plan role (read-only) and apply role |
| Fargate Spot | On-demand base capacity plus Spot for burst |
| No WAF | AWS WAF managed rule sets on the ALB |
| Trivy findings reported only | Fail the build on HIGH/CRITICAL after triage (`.trivyignore` for accepted risks) |
