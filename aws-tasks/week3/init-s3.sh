aws s3api create-bucket --bucket db-scripts2 --region us-east-2  --create-bucket-configuration LocationConstraint=us-east-2
aws s3 cp dynamodb-script.sh s3://db-scripts2 --region us-east-2



