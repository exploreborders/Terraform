#!/bin/bash

# Setup script for Terraform remote backend
# Creates S3 bucket and DynamoDB table for state management

set -e

# Configuration
BUCKET_NAME="terraform-state-bucket-$(date +%Y%m%d-%H%M%S)"
TABLE_NAME="terraform-state-lock"
REGION="us-east-1"

echo "Setting up Terraform remote backend..."
echo "Region: $REGION"
echo "Bucket: $BUCKET_NAME"
echo "Table: $TABLE_NAME"
echo

# Create S3 bucket
echo "Creating S3 bucket..."
aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "S3 bucket created and configured."

# Create DynamoDB table
echo "Creating DynamoDB table..."
aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "DynamoDB table created."

# Wait for table to be active
echo "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"

echo
echo "✅ Backend setup complete!"
echo
echo "Update your terraform.tfvars with these values:"
echo "state_bucket_name = \"$BUCKET_NAME\""
echo "lock_table_name = \"$TABLE_NAME\""
echo
echo "You can now initialize Terraform with remote backend."