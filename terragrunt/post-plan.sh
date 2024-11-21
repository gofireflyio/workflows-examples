#!/bin/bash
set -euo pipefail

# Check if project name argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <project_name>"
    echo "Example: $0 myproject"
    exit 1
fi

PROJECT_NAME="$1"

# Download and setup Firefly CLI if not already present
if [ ! -f "./fireflyci" ]; then
    echo "Downloading Firefly CLI..."
    curl -O https://gofirefly-prod-iac-ci-cli-binaries.s3.amazonaws.com/fireflyci/latest/fireflyci_Linux_x86_64.tar.gz
    tar -xf fireflyci_Linux_x86_64.tar.gz
    chmod a+x fireflyci
fi

# Base directories
OUTPUTS_DIR="/tmp/outputs"

# Process each tfplan.tfplan file
find "$OUTPUTS_DIR" -type f -name "tfplan.tfplan" | while read -r plan_file; do
    project_dir=$(dirname "$plan_file")
    relative_path=${project_dir#$OUTPUTS_DIR/}
    
    echo "Processing $relative_path..."
    
    # Create output files in the same directory
    plan_output_json="$project_dir/plan_output.json"
    plan_output_raw="$project_dir/plan_output_raw.log"
    plan_log="$project_dir/plan_log.jsonl"
    
    # Generate the required outputs
    echo "Generating plan outputs for $relative_path..."
    terraform show -json "$plan_file" > "$plan_output_json"
    terraform show "$plan_file" > "$plan_output_raw"
    
    # Create workspace name based on project name and relative path
    workspace_name="${PROJECT_NAME}-${relative_path//\//-}"
    
    echo "Sending to Firefly workspace: $workspace_name"
    
    # Send to Firefly
    ./fireflyci post-plan \
        -l "$plan_log" \
        -f "$plan_output_json" \
        --plan-output-raw-log-file "$plan_output_raw" \
        --workspace "$workspace_name"
    
    echo "Completed processing $relative_path"
done
