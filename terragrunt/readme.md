# Integrating Firefly with Terragrunt Pipeline

## Integration Steps

1. **Issue a new key pair**
   - Create a new key pair in Firefly console
   - Note down the access key and secret key

2. **Configure Secrets**
   - Store the following secrets in your CI/CD system's secret manager:
     ```
     FIREFLY_ACCESS_KEY=<your-access-key>
     FIREFLY_SECRET_KEY=<your-secret-key>
     ```

3. **Modify Terragrunt Plan Command**
   ```bash
   # Instead of regular terragrunt run-all plan
   terragrunt plan -all --out-dir /tmp/all --json-out-dir /tmp/all
   ```

4. **Create and Run Post-Plan Processing Script**
   - Copy the post-plan.sh script into your repository.
   - Update your pipeline to run the following after the terragrunt plan:
   ```bash
   chmod +x post-plan.sh
   ./post-plan.sh myproject
   ```

6. **Set Up CI/CD Pipeline**

   Example pipeline structure:
   ```yaml
   steps:
     - name: Terragrunt Plan
       run: |
         terragrunt plan -all --out-dir /tmp/all --json-out-dir /tmp/all --non-interactive

     - name: Firefly Post-Plan
       run: |
         chmod +x post-plan.sh
         ./post-plan.sh myproject
   ```

## Important Notes

1. **Workspace Naming Convention**
   - Workspaces are automatically created based on the project directory structure
   - Forward slashes in paths are converted to hyphens
   - Example: `project-2/project-2-app1` becomes `project-2-project-2-app1`

2. **Error Handling**
   - The scripts include basic error handling with `set -euo pipefail`
   - Failed Firefly submissions for individual projects won't stop the entire process
   - Check the script output for any specific project failures

3. **Environment Variables**
   Ensure these environment variables are set in your CI/CD environment:
   - `FIREFLY_ACCESS_KEY`
   - `FIREFLY_SECRET_KEY`
