# Integrating Firefly with Terragrunt Pipeline (GitHub Actions)

## Integration Steps

1. **Issue a new key pair**
   - Create a new key pair in Firefly console
   - Note down the access key and secret key

2. **Configure Secrets**
   - Store the following secrets in your GitHub repository secrets:
     ```
     FIREFLY_ACCESS_KEY=<your-access-key>
     FIREFLY_SECRET_KEY=<your-secret-key>
     ```

3. **Add Firefly IAC Wrapper Setup**
   - Add the following step after setting up Terraform/Terragrunt:
   ```yaml
   - name: Setup IAC Wrapper
     uses: gofireflyio/fireflyci/terragrunt@v0.5.153
   ```
   - This configures the Terragrunt wrapper to capture logs during plan/apply operations per subfolder.

4. **Run Terragrunt Plan with JSON Output**
   ```yaml
   - name: Terragrunt Plan
     id: plan
     run: terragrunt run-all plan -- -json -out=${{ env.PLAN_FILE_NAME }}
   ```

5. **Add Firefly Post-Plan Step (per module)**
   - Copy and update this block for each module:
   ```yaml
   - name: Firefly Post Plan - ModuleName
     uses: gofireflyio/fireflyci@v0.5.153
     with:
       command: post-plan
       environment: ModuleName
       workspace: ${{ env.WORKSPACE }}
       terragrunt-version: ${{ inputs.terragrunt_version }}
       init-log-file: ModuleName/${{ env.INIT_LOG_FILE }}
       plan-output-file: ModuleName/${{ env.PLAN_OUTPUT_FILE }}
       plan-json-log-file: ModuleName/${{ env.PLAN_JSON_LOG_FILE }}
       plan-raw-log-file: ModuleName/${{ env.PLAN_RAW_LOG_FILE }}
     env:
       FIREFLY_ACCESS_KEY: ${{ secrets.FIREFLY_ACCESS_KEY }}
       FIREFLY_SECRET_KEY: ${{ secrets.FIREFLY_SECRET_KEY }}
   ```

6. **Add Firefly Post-Apply Step (per module)**
   - Copy and update this block for each module:
   ```yaml
   - name: Firefly Post Apply - ModuleName
     if: inputs.should_apply == true && steps.apply.outcome == 'success'
     uses: gofireflyio/fireflyci@v0.5.153
     with:
       command: post-apply
       environment: ModuleName
       workspace: ${{ env.WORKSPACE }}
       terragrunt-version: ${{ inputs.terragrunt_version }}
       apply-log-file: ModuleName/${{ env.APPLY_LOG_FILE }}
     env:
       FIREFLY_ACCESS_KEY: ${{ secrets.FIREFLY_ACCESS_KEY }}
       FIREFLY_SECRET_KEY: ${{ secrets.FIREFLY_SECRET_KEY }}
   ```

## Important Notes

1. **Workspace Naming Convention**
   - Workspace defaults to `github.repository`
   - Override with `workspace: "my-workspace"` in the action input
   - Each module is tracked via `environment: <module>` for granular tracking

2. **Environment Variables**
   - Define these environment variables in your workflow:
     ```yaml
     env:
       PLAN_FILE_NAME: "tf.plan"
       WORKSPACE: ${{ github.repository }}
       INIT_LOG_FILE: "init_log.jsonl"
       PLAN_OUTPUT_FILE: "plan_output.json"
       PLAN_JSON_LOG_FILE: "plan_log.jsonl"
       PLAN_RAW_LOG_FILE: "plan_output_raw.log"
       APPLY_LOG_FILE: "apply_log.jsonl"
     ```

3. **Troubleshooting**
   - Missing credentials → set `FIREFLY_ACCESS_KEY`/`FIREFLY_SECRET_KEY` as GitHub repository secrets
   - `fireflyci` action fails → ensure action version `@v0.5.153` (or latest) is available
   - No logs found → verify Terragrunt Plan/Apply steps succeeded and log files exist in module directories
   - Terragrunt version shows `unknown` → ensure `terragrunt_version` input is defined in workflow
