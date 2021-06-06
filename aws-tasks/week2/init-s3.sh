aws s3api create-bucket --bucket week2-backet --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
aws s3api put-bucket-versioning --bucket week2-backet --versioning-configuration Status=Enabled --region us-east-2
aws s3 cp temp.txt s3://week2-backet/temp.txt

