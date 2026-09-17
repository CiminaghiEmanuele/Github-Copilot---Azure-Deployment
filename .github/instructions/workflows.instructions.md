---
description: "Use when editing GitHub Actions, OIDC authentication, preview workflows and deployment approvals."
applyTo: ".github/workflows/*.yml"
---

# Delivery Azure

- One customer/workload per repository. Validate the goal and protected CUSTOMER_CODE binding before Azure login.
- The reference goal cannot be provisioned. Bind the customer code and goal hash to the same artifact, commit and Azure target that the reviewer approved.
- Authenticated preview must use the goal validator and schema from the trusted workflow commit, not candidate scripts or schemas from a PR.
- Register new automated verification suites only together with reviewed pipeline wiring and negative tests; never execute a command supplied by the goal JSON.
- Pin actions to complete commit SHAs and update them through reviewed PRs.
- Set `contents: read` and grant `id-token: write` only to authenticated jobs.
- Never grant Azure credentials to PR build jobs or run PR scripts inside authenticated jobs.
- Pass workflow inputs through environment variables; never interpolate untrusted input into shell code.
- Preview uses `ProviderNoRbac` and an identity without resource write permissions. Do not replace it with Contributor to resolve an error.
- Restrict authenticated workflows to the trusted main workflow definition and protect environments outside YAML.
- Deploy only after a successful preview and an environment approval. Use the exact compiled artifact and verify commit, subscription and resource group.
- Keep deployments incremental and serialized by target environment. Incremental does not mean non-destructive.
- Do not create client secrets, automatically approve environments or deploy from `pull_request` events.