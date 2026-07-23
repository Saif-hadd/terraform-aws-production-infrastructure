# Contributing to Demo Platform

First off, thank you for considering contributing to Demo Platform! It's people like you that make this a great reference project for the community.

## Ways to Contribute

- Report bugs by opening an issue
- Suggest new features or improvements
- Improve documentation
- Submit pull requests with fixes or enhancements
- Add screenshots of the platform in action

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes following the guidelines below
4. Run local validation (see below)
5. Commit using a clear message (see Conventional Commits below)
6. Open a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/<your-username>/demo-platform.git
cd demo-platform

# Install Terraform (>= 1.14)
terraform version

# Validate Terraform formatting
terraform fmt -recursive -check

# Validate a specific environment
cd environments/dev
terraform init -backend=false
terraform validate
```

## Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```text
<type>(<scope>): <description>

feat(eks): add spot node group support
fix(vpc): correct private subnet tagging
docs(security): add IRSA hardening guide
chore: update provider versions
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Terraform Guidelines

- Run `terraform fmt -recursive` before committing
- Pin all module and provider versions
- Every new variable must have a `description`, `type`, and sensible `default`
- Never commit secrets, credentials, or real account IDs
- Use kebab-case for AWS resource names and snake_case for Terraform variables
- Keep modules single-responsibility — no Helm or Kubernetes manifests in Terraform modules
- One state file per environment, never shared

## Documentation Guidelines

- Keep the README concise; put deep dives in `docs/`
- Use diagrams in `assets/` and reference them in docs
- Test all code blocks and commands before submitting
- Use American English for consistency

## Pull Request Process

1. Ensure your branch is up to date with `main`
2. Fill out the pull request template
3. Link any related issues
4. Wait for CI checks to pass
5. Address review feedback

## Code of Conduct

By participating in this project you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).
