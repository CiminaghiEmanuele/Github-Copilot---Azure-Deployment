---
description: "Use when editing GitHub Actions, OIDC authentication, preview workflows and deployment approvals."
applyTo: ".github/workflows/*.yml"
---

# Delivery Metix

- Pin actions to complete commit SHAs and update them through reviewed PRs.
- Set `contents: read` and grant `id-token: write` only to authenticated jobs.
- Never grant Azure credentials to PR build jobs or run PR scripts inside authenticated jobs.
- Pass workflow inputs through environment variables; never interpolate untrusted input into shell code.
- Preview uses `ProviderNoRbac` and an identity without resource write permissions. Do not replace it with Contributor to resolve an error.
- Restrict authenticated workflows to the trusted main workflow definition and protect environments outside YAML.
- Deploy only after a successful preview and an environment approval. Use the exact compiled artifact and verify commit, subscription and resource group.
- Keep deployments incremental and serialized by target environment. Incremental does not mean non-destructive.
- Do not create client secrets, automatically approve environments or deploy from `pull_request` events.