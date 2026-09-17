---
description: "Use when creating or reviewing Bicep infrastructure, AVM modules and environment parameters for the il team demo."
applyTo: "infra/**/*.bicep,infra/**/*.bicepparam,bicepconfig.json"
---

# Bicep Azure

- Use the existing modules as ownership boundaries: network, monitoring, private access and services.
- Use one parameter file per environment, not copies of the infrastructure code.
- Verify AVM versions and parameter names against the published module before editing; compile immediately after changing a module contract.
- Keep stable names and deterministic uniqueness. Respect Key Vault and Storage naming limits.
- Use symbolic resource references or module outputs, not hand-built subscription paths.
- Forward tags, private endpoint subnet IDs, DNS zone IDs and diagnostic destinations explicitly.
- Do not add secrets, access policies, sample data or RBAC role assignments to the demo without an approved requirement.
- Explain why a guardrail, recommended default or documented exception applies. This pattern is not a generic production landing zone.
- Run the build and guardrail checks described in [standards](../../docs/standards.md).