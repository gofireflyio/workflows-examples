#!/bin/bash
# IaC wrapper script for capturing individual module logs when invoked by terragrunt
# This script intercepts terraform/tofu commands and ensures proper log capture per subfolder
# The IAC_BINARY environment variable determines which binary to use (terraform or tofu)

set -e

# Determine which binary to use from environment variable
BINARY_NAME="${IAC_BINARY:-terraform}"  # Default to terraform if not set

# Path to the actual IaC binary
# Use which to find the actual binary, or fall back to common locations
if [ -x "/bin/${BINARY_NAME}" ]; then
  IAC_BIN="/bin/${BINARY_NAME}"
elif [ -x "/usr/bin/${BINARY_NAME}" ]; then
  IAC_BIN="/usr/bin/${BINARY_NAME}"
elif [ -x "/usr/local/bin/${BINARY_NAME}" ]; then
  IAC_BIN="/usr/local/bin/${BINARY_NAME}"
else
  # Try to find it using which
  IAC_BIN=$(which "${BINARY_NAME}" 2>/dev/null || echo "${BINARY_NAME}")
fi

# Get the command (first argument)
COMMAND="$1"

# Find the module directory (where terragrunt.hcl is located)
# Terragrunt runs IaC from .terragrunt-cache, but we want logs in the module dir
MODULE_DIR=""
if [ -n "$TERRAGRUNT_WORKING_DIR" ]; then
  MODULE_DIR="$TERRAGRUNT_WORKING_DIR"
else
  # Try to find the parent directory that contains terragrunt.hcl
  CURRENT_DIR="$PWD"
  while [ "$CURRENT_DIR" != "/" ]; do
    if [ -f "$CURRENT_DIR/../terragrunt.hcl" ]; then
      MODULE_DIR="$CURRENT_DIR/.."
      break
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
  done
fi

# If we couldn't find module dir, use current directory
if [ -z "$MODULE_DIR" ]; then
  MODULE_DIR="$PWD"
fi

# Execute IaC and capture logs based on the command
case "$COMMAND" in
  "plan")
    # Check if -json flag is present and -out flag is present
    HAS_JSON=false
    OUT_FILE=""
    PREV_ARG=""
    
    for arg in "$@"; do
      if [ "$arg" = "-json" ]; then
        HAS_JSON=true
      fi
      # Handle -out=filename format
      if [[ "$arg" == -out=* ]]; then
        OUT_FILE="${arg#-out=}"
      # Handle -out filename format (filename is in next arg)
      elif [ "$PREV_ARG" = "-out" ]; then
        OUT_FILE="$arg"
      fi
      PREV_ARG="$arg"
    done
    
    # If this is a plan with -json and -out, capture to plan_log.jsonl
    if [ "$HAS_JSON" = true ] && [ -n "$OUT_FILE" ]; then
      # Run plan and redirect output to plan_log.jsonl in the module directory
      "$IAC_BIN" "$@" 2>&1 | tee "$MODULE_DIR/plan_log.jsonl"
      EXIT_CODE=${PIPESTATUS[0]}
      
      # If plan succeeded and created a plan file, generate additional outputs
      # The plan file is in the current working directory (.terragrunt-cache)
      if [ $EXIT_CODE -eq 0 ]; then
        # Wait a moment for file system sync
        sleep 0.1
        
        if [ -f "$OUT_FILE" ]; then
          # Copy plan file to module directory
          cp "$OUT_FILE" "$MODULE_DIR/$OUT_FILE" 2>/dev/null
          
          # Generate plan_output.json (JSON format) - critical file
          if "$IAC_BIN" show -json "$OUT_FILE" > "$MODULE_DIR/plan_output.json" 2>/dev/null; then
            : # Success
          else
            # If show fails, try with the copied plan file
            "$IAC_BIN" show -json "$MODULE_DIR/$OUT_FILE" > "$MODULE_DIR/plan_output.json" 2>/dev/null || \
              echo "{\"error\": \"Failed to generate plan output\"}" > "$MODULE_DIR/plan_output.json"
          fi
          
          # Generate plan_output_raw.log (human-readable format)
          if ! "$IAC_BIN" show "$OUT_FILE" > "$MODULE_DIR/plan_output_raw.log" 2>/dev/null; then
            "$IAC_BIN" show "$MODULE_DIR/$OUT_FILE" > "$MODULE_DIR/plan_output_raw.log" 2>/dev/null || \
              echo "Failed to generate raw plan output" > "$MODULE_DIR/plan_output_raw.log"
          fi
        else
          # Plan file not found, create placeholder files
          echo "{\"error\": \"Plan file not found\"}" > "$MODULE_DIR/plan_output.json"
          echo "Plan file $OUT_FILE not found" > "$MODULE_DIR/plan_output_raw.log"
        fi
      fi
      
      exit $EXIT_CODE
    else
      # Regular plan command
      "$IAC_BIN" "$@"
    fi
    ;;
    
  "apply")
    # Check if -json flag is present
    HAS_JSON=false
    for arg in "$@"; do
      if [ "$arg" = "-json" ]; then
        HAS_JSON=true
        break
      fi
    done
    
    if [ "$HAS_JSON" = true ]; then
      # Capture JSON output to apply_log.jsonl in the module directory
      "$IAC_BIN" "$@" 2>&1 | tee "$MODULE_DIR/apply_log.jsonl"
      exit ${PIPESTATUS[0]}
    else
      "$IAC_BIN" "$@"
    fi
    ;;
    
  "destroy")
    # Check if -json flag is present
    HAS_JSON=false
    for arg in "$@"; do
      if [ "$arg" = "-json" ]; then
        HAS_JSON=true
        break
      fi
    done
    
    if [ "$HAS_JSON" = true ]; then
      # Capture JSON output to destroy_log.jsonl in the module directory
      "$IAC_BIN" "$@" 2>&1 | tee "$MODULE_DIR/destroy_log.jsonl"
      exit ${PIPESTATUS[0]}
    else
      "$IAC_BIN" "$@"
    fi
    ;;
    
  "init")
    # Capture init output in the module directory
    "$IAC_BIN" "$@" 2>&1 | tee "$MODULE_DIR/init_log.jsonl"
    exit ${PIPESTATUS[0]}
    ;;
    
  "show")
    # Show command should just pass through
    "$IAC_BIN" "$@"
    ;;
    
  *)
    # For all other commands, just execute the IaC binary
    "$IAC_BIN" "$@"
    ;;
esac


