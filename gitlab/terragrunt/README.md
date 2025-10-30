# Firefly + Terragrunt (GitLab) — Executive Summary

## What this adds
- **Automated post-processing** of Terragrunt logs after plan/apply using the Firefly CI agent.
- **Per-module reporting** (e.g., `vpc`, `database`) to Firefly for visibility, drift, and analytics.

## How it works (high level)
1. Terragrunt wrapper creates logs per module during `plan`/`apply`.
2. Post-plan and post-apply jobs run the Firefly agent to upload those logs.
3. Firefly Cloud ingests, analyzes, and tracks changes per module/workspace.

## Pipeline changes (new stages + jobs)
- New stages: `post-plan`, `post-apply`.
- Example jobs: `post_plan_vpc`, `post_plan_database`, `post_apply_vpc`, `post_apply_database`.
- Post-plan jobs run after `plan_all` succeeds; post-apply jobs run after `apply_all` succeeds and are skipped if `apply_all` isn’t triggered.

## Prerequisites
- GitLab CI/CD variables:
  - `FIREFLY_ACCESS_KEY` (protected, masked)
  - `FIREFLY_SECRET_KEY` (protected, masked)
- `TERRAGRUNT_VERSION` set in CI (used for accurate reporting by the agent).

## Agent bootstrap (in CI)
Minimal example (already included in the base template):

```yaml
image: alpine:latest
before_script:
  - apk add --no-cache curl
  - curl -O https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Linux_x86_64.tar.gz
  - tar -xf fireflyci_Linux_x86_64.tar.gz
  - chmod +x fireflyci && mv fireflyci /usr/local/bin/
```

For Docker image entrypoint-based runs, ensure:

```yaml
image:
  name: public.ecr.aws/firefly/fireflyci:vX.Y.Z
  entrypoint: ["/bin/sh", "-c"]
```

## Commands executed by jobs
- Post-Plan (per module):
```bash
fireflyci post-plan \
  -l plan_log.jsonl \
  -f plan_output.json \
  -i init_log.jsonl \
  --plan-output-raw-log-file plan_output_raw.log \
  --workspace "${CI_PROJECT_NAME}" \
  --environment "<module_name>" \
  --terragrunt-version "${TERRAGRUNT_VERSION}" \
  --server-url "https://api-env3.dev.firefly.ai/api" \
  --access-key "${FIREFLY_ACCESS_KEY}" \
  --secret-key "${FIREFLY_SECRET_KEY}"
```

- Post-Apply (per module):
```bash
fireflyci post-apply \
  -f apply_log.jsonl \
  --workspace "${CI_PROJECT_NAME}" \
  --environment "<module_name>" \
  --terragrunt-version "${TERRAGRUNT_VERSION}" \
  --server-url "https://api-env3.dev.firefly.ai/api" \
  --access-key "${FIREFLY_ACCESS_KEY}" \
  --secret-key "${FIREFLY_SECRET_KEY}"
```

## Module scope
- Each module (e.g., `vpc`, `database`) is processed and tagged independently via `--environment <module>` for granular tracking.

## Configuration knobs
- **Workspace name**: defaults to `CI_PROJECT_NAME`; override with `--workspace "my-workspace"`.
- **Add modules**: copy existing post-plan/post-apply job pattern, set module dir and `--environment`.
- **Dynamic modules**: optional "discover-and-loop" job that processes all module directories with logs.

## Troubleshooting at a glance
- Missing credentials → set `FIREFLY_ACCESS_KEY`/`FIREFLY_SECRET_KEY` (protected + masked).
- `fireflyci` not found → ensure binary is downloaded in `before_script` or image provides it.
- `unknown command 'sh'` → set image `entrypoint: ["/bin/sh", "-c"]`.
- No logs found → verify `plan_all`/`apply_all` succeeded and artifacts/dependencies are wired.
- Terragrunt version shows `unknown` → ensure `TERRAGRUNT_VERSION` is defined in CI.

## Security & networking
- Keep credentials masked/protected; runner must reach Firefly API over HTTPS.
- Logs may include sensitive data; restrict access appropriately.

## Value
- Centralized visibility, drift detection, analytics, compliance, alerting, and environment-level tagging for Terragrunt changes.


