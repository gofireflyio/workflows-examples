# Workflows Examples
Firefly Workflows examples for every CI tool.

The Firefly workflow agent uses environment variables to gather information during the run. When running the agent as docker, we have to pass more envs to the docker so it can get the information.
Here are all the environment variables for each CI tool. Add this to the docker commands:

## GitLab
```
-e CI_SERVER_URL -e CI_DEFAULT_BRANCH -e CI_COMMIT_BRANCH -e CI_MERGE_REQUEST_SOURCE_BRANCH_NAME -e CI_PROJECT_PATH -e CI_PROJECT_URL -e CI_COMMIT_AUTHOR -e GITLAB_USER_NAME -e CI_COMMIT_SHA -e CI_JOB_NAME -e CI_PIPELINE_ID -e CI_PIPELINE_URL -e CI_RUNNER_VERSION -e CI_MERGE_REQUEST_IID -e CI_MERGE_REQUEST_TITLE -e CI_COMMIT_TITLE
```

## GitHub
```
-e GITHUB_SERVER_URL -e GITHUB_REF_NAME -e GITHUB_BASE_REF -e GITHUB_HEAD_REF -e GITHUB_REPOSITORY -e GITHUB_ACTOR -e GITHUB_SHA -e GITHUB_WORKFLOW -e GITHUB_RUN_ID -e GITHUB_EVENT_PATH
```

## Atlantis
```
-e HEAD_BRANCH_NAME -e BASE_REPO_NAME -e BASE_REPO_OWNER -e USER_NAME -e HEAD_COMMIT -e REPO_REL_DIR -e PROJECT_NAME -e PULL_NUM -e PULL_URL
```

## Semaphore
```
-e SEMAPHORE_JOB_NAME -e SEMAPHORE_GIT_REPO_SLUG -e SEMAPHORE_GIT_COMMIT_RANGE -e SEMAPHORE_GIT_COMMITTER -e SEMAPHORE_WORKFLOW_TRIGGERED_BY -e SEMAPHORE_WORKFLOW_ID -e SEMAPHORE_GIT_BRANCH -e SEMAPHORE_GIT_PROVIDER -e SEMAPHORE_GIT_PR_NUMBER -e SEMAPHORE_GIT_PR_NAME -e SEMAPHORE_GIT_PR_SHA -e SEMAPHORE_ORGANIZATION_URL
```

## Azure Pipeline
```
-e BUILD_REPOSITORY_URI -e BUILD_SOURCEBRANCHNAME -e BUILD_REPOSITORY_NAME -e BUILD_SOURCEVERSIONAUTHOR -e BUILD_SOURCEVERSION -e BUILD_SOURCEVERSIONMESSAGE -e SYSTEM_STAGENAME -e BUILD_BUILDID -e BUILD_QUEUEDBY -e SYSTEM_TEAMFOUNDATIONSERVERURI -e SYSTEM_TEAMPROJECT -e AGENT_VERSION -e BUILD_REASON -e SYSTEM_PULLREQUEST_PULLREQUESTID -e SYSTEM_PULLREQUEST_SOURCE_COMMITID -e SYSTEM_PULLREQUEST_SOURCE_REPOSITORY_URI
```

## Bitbucket
```
-e BITBUCKET_BRANCH -e BITBUCKET_REPO_FULL_NAME -e BITBUCKET_GIT_HTTP_ORIGIN -e BITBUCKET_COMMIT -e BITBUCKET_BUILD_NUMBER -e BITBUCKET_PR_DESTINATION_BRANCH -e BITBUCKET_PR_DESTINATION_COMMIT -e BITBUCKET_PR_ID
```

## Jenkins
```
-e JENKINS_HOME -e GIT_URL -e GIT_BRANCH -e GIT_COMMITTER_NAME -e GIT_COMMITTER_EMAIL -e GIT_AUTHOR_NAME -e GIT_AUTHOR_EMAIL -e BUILD_USER -e GIT_COMMIT -e JOB_NAME -e BUILD_NUMBER -e JENKINS_VERSION -e BUILD_URL
```

Or you can use the docker command of Jenkins that passes all environment variables to the image.

For post-plan run:
```
docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
    sh "/app/fireflyci post-plan -l /app/jenkins/environments/aws-stag/plan_log.json -f /app/jenkins/environments/aws-stag/plan_output.json --workspace ${TF_WORKSPACE}"
}
```
For post-apply run:
```
docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
    sh "/app/fireflyci post-apply -f /app/jenkins/environments/aws-stag/apply_log.json --workspace ${TF_WORKSPACE}"
}
```
