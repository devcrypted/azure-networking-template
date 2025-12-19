# CI/CD Pipelines

This template includes GitHub Actions workflows for a secure, automated lifecycle.

## Workflows

### 1. Pull Request Checks (`.github/workflows/pr.yaml`)

Triggered on every PR to `main`.

- **Format**: Checks `terraform fmt`.
- **Validation**: Runs `terraform validate`.
- **Linting**: Runs `tflint` for best practices.
- **Security**: Runs `tfsec` to catch misconfigurations.
- **Plan**: Generates a speculative `terraform plan`.

### 2. Production Deploy (`.github/workflows/deploy.yaml`)

Triggered on merge to `main`.

- **Environment**: Targets the `production` GitHub Environment (configure strict protection rules, e.g., manual approval).
- **Apply**: Runs `terraform apply -auto-approve`.

## Setup

1.  **Secrets**: Set the following Repository Secrets:
    - `AZURE_CLIENT_ID`
    - `AZURE_CLIENT_SECRET`
    - `AZURE_TENANT_ID`
    - `AZURE_SUBSCRIPTION_ID`
2.  **Environment**: Create an environment named `production` in GitHub Settings -> Environments and add required reviewers.
