# Firefly Workflows Examples
Firefly Workflows examples for every CI tool.

## Terraform Commands
### Init
```
terraform init >& init.log
```

### Plan
```yaml
terraform plan -json -out=plan.tmp > plan_log.jsonl && terraform show -json plan.tmp > plan_output.json && terraform show plan.tmp > plan_output_raw.log
```

### Apply
```
terraform apply -auto-approve -json > apply_log.jsonl
```

## FireflyCI
Download the relevant CLI for your operating system using the links below:

#### MacOS
- **MacOS ARM:** [fireflyci_Darwin_arm64.tar.gz](https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Darwin_arm64.tar.gz)
- **MacOS x86:** [fireflyci_Darwin_x86_64.tar.gz](https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Darwin_x86_64.tar.gz)

#### Linux
- **Linux ARM:** [fireflyci_Linux_arm64.tar.gz](https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Linux_arm64.tar.gz)
- **Linux x86:** [fireflyci_Linux_x86_64.tar.gz](https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Linux_x86_64.tar.gz)

#### Microsoft Windows
- **Windows x86:** [fireflyci_Windows_x86_64.zip](https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Windows_x86_64.zip)

### Using cURL

Download the CLI using the cURL commands below:

```sh
curl -O https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Linux_x86_64.tar.gz
tar -xf fireflyci_Linux_x86_64.tar.gz
chmod a+x fireflyci
```

### Docker Image
The CLI is available as a Docker image:

```
public.ecr.aws/firefly/fireflyci:latest
```

### FireflyCI Inputs
Authenticate using your Firefly keys with the following methods:
* With the `configure` command set a profile.
* Using the `--access-key` and `--secret-key` arguments.
* Using the `FIREFLY_ACCESS_KEY` and `FIREFLY_SECRET_KEY` environment variables.
Choose the method that best suits your workflow for authenticating the FireflyCI.

#### Post Plan
```
Flags:
      --config-file string                 Path to the config file (YAML)
  -h, --help                               help for post-plan
  -i, --init-log-file string               Path to the init log file
  -f, --plan-file string                   Path to the plan file to scan
  -l, --plan-output-json-log-file string   Path to the plan output log file in json lines format
      --plan-output-raw-log-file string    Path to the raw plan output log file
  -r, --redact                             Redact plan file data (default true)
      --repository string                  Full repository name, will be filled automatically if running from a CI/CD pipeline
  -o, --show-only-relevant                 Will show only relevant misconfigurations
  -t, --timeout int                        Timeout in seconds for the scan to complete (only relevant when --wait is set) (default 180)
      --wait                               Waits for the scans to finish and checks if there are any misconfigurations (same as --config-file with empty file)
  -w, --workspace string                   Workspace identifier

Global Flags:
  -a, --access-key string   Access key (will be prompted for if not provided)
      --ignore-errors       Exit with a success code even though errors are encountered
      --pretty              Pretty-print JSON output
  -p, --profile string      Profile to use (default "default")
  -s, --secret-key string   Secret key (will be prompted for if not provided)
      --server-url string   FireflyCI API URL (default "https://prodapi.gofirefly.io/api")
```

#### Post Apply
```
Flags:
  -f, --apply-log-file string   Path to the apply log file
  -h, --help                    help for post-apply
  -r, --redact                  Redact the apply log file data (default true)
      --repository string       Full repository name, will be filled automatically if running from a CI/CD pipeline
  -t, --timeout int             Timeout in seconds for the post apply task to complete (only relevant when --wait is set) (default 180)
      --wait                    Waits for the scans to finish
  -w, --workspace string        Workspace name

Global Flags:
  -a, --access-key string   Access key (will be prompted for if not provided)
      --ignore-errors       Exit with a success code even though errors are encountered
      --pretty              Pretty-print JSON output
  -p, --profile string      Profile to use (default "default")
  -s, --secret-key string   Secret key (will be prompted for if not provided)
      --server-url string   FireflyCI API URL (default "https://prodapi.gofirefly.io/api")
```

## CI Tools

The Firefly workflow agent uses environment variables to gather information during the run. When running the agent as docker, we have to pass more envs to the docker so it can get the information.
Here are all the environment variables for each CI tool. Add this to the docker commands:

### GitLab
```
-e CI_SERVER_URL -e CI_DEFAULT_BRANCH -e CI_COMMIT_BRANCH -e CI_MERGE_REQUEST_SOURCE_BRANCH_NAME -e CI_PROJECT_PATH -e CI_PROJECT_URL -e CI_COMMIT_AUTHOR -e GITLAB_USER_NAME -e CI_COMMIT_SHA -e CI_JOB_NAME -e CI_PIPELINE_ID -e CI_PIPELINE_URL -e CI_RUNNER_VERSION -e CI_MERGE_REQUEST_IID -e CI_MERGE_REQUEST_TITLE -e CI_COMMIT_TITLE
```

### GitHub
```
-e GITHUB_SERVER_URL -e GITHUB_REF_NAME -e GITHUB_BASE_REF -e GITHUB_HEAD_REF -e GITHUB_REPOSITORY -e GITHUB_ACTOR -e GITHUB_SHA -e GITHUB_WORKFLOW -e GITHUB_RUN_ID -e GITHUB_EVENT_PATH
```

### Atlantis
```
-e HEAD_BRANCH_NAME -e BASE_REPO_NAME -e BASE_REPO_OWNER -e USER_NAME -e HEAD_COMMIT -e REPO_REL_DIR -e PROJECT_NAME -e PULL_NUM -e PULL_URL
```

### Semaphore
```
-e SEMAPHORE_JOB_NAME -e SEMAPHORE_GIT_REPO_SLUG -e SEMAPHORE_GIT_COMMIT_RANGE -e SEMAPHORE_GIT_COMMITTER -e SEMAPHORE_WORKFLOW_TRIGGERED_BY -e SEMAPHORE_WORKFLOW_ID -e SEMAPHORE_GIT_BRANCH -e SEMAPHORE_GIT_PROVIDER -e SEMAPHORE_GIT_PR_NUMBER -e SEMAPHORE_GIT_PR_NAME -e SEMAPHORE_GIT_PR_SHA -e SEMAPHORE_ORGANIZATION_URL
```

### Azure Pipeline
```
-e BUILD_REPOSITORY_URI -e BUILD_SOURCEBRANCHNAME -e BUILD_REPOSITORY_NAME -e BUILD_SOURCEVERSIONAUTHOR -e BUILD_SOURCEVERSION -e BUILD_SOURCEVERSIONMESSAGE -e SYSTEM_STAGENAME -e BUILD_BUILDID -e BUILD_QUEUEDBY -e SYSTEM_TEAMFOUNDATIONSERVERURI -e SYSTEM_TEAMPROJECT -e AGENT_VERSION -e BUILD_REASON -e SYSTEM_PULLREQUEST_PULLREQUESTID -e SYSTEM_PULLREQUEST_SOURCE_COMMITID -e SYSTEM_PULLREQUEST_SOURCE_REPOSITORY_URI
```

### Bitbucket
```
-e BITBUCKET_BRANCH -e BITBUCKET_REPO_FULL_NAME -e BITBUCKET_GIT_HTTP_ORIGIN -e BITBUCKET_COMMIT -e BITBUCKET_BUILD_NUMBER -e BITBUCKET_PR_DESTINATION_BRANCH -e BITBUCKET_PR_DESTINATION_COMMIT -e BITBUCKET_PR_ID
```

### Jenkins
```
-e JENKINS_HOME -e GIT_URL -e GIT_BRANCH -e GIT_COMMITTER_NAME -e GIT_COMMITTER_EMAIL -e GIT_AUTHOR_NAME -e GIT_AUTHOR_EMAIL -e BUILD_USER -e GIT_COMMIT -e JOB_NAME -e BUILD_NUMBER -e JENKINS_VERSION -e BUILD_URL
```

### Env0
```
-e ENV0_ENVIRONMENT_ID -e ENV0_PROJECT_ID -e ENV0_TEMPLATE_REPOSITORY -e ENV0_TEMPLATE_REVISION -e ENV0_DEPLOYER_NAME -e ENV0_DEPLOYER_EMAIL -e ENV0_VCS_PROVIDER -e ENV0_PR_AUTHOR -e ENV0_PR_NUMBER -e ENV0_COMMIT_HASH -e ENV0_DEPLOYMENT_LOG_ID
```

Or you can use the docker command of Jenkins that passes all environment variables to the image.

For post-plan run:
```
docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
    sh "/app/fireflyci post-plan -l /app/jenkins/environments/aws-stag/plan_log.jsonl -f /app/jenkins/environments/aws-stag/plan_output.json -i /app/jenkins/environments/aws-stag/init.log --plan-output-raw-log-file /app/jenkins/environments/aws-stag/plan_output_raw.log --workspace ${TF_WORKSPACE}"
}
```
For post-apply run:
```
docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
    sh "/app/fireflyci post-apply -f /app/jenkins/environments/aws-stag/apply_log.jsonl --workspace ${TF_WORKSPACE}"
}
```
