 aws dynamodb list-tables --region us-east-2

 aws dynamodb put-item  --table-name test_dtable  --item '{"uuid": {"S": "123asdf"}, "movie": {"S": "matrix 1"}, "director": {"S": "vatchovsky"}, "Awards": {"N": "1"}}' --region us-east-2
 aws dynamodb put-item  --table-name test_dtable  --item '{"uuid": {"S": "1234ab"}, "movie": {"S": "matrix 2"}, "director": {"S": "vatchovsky"}, "Awards": {"N": "3"}}' --region us-east-2
 aws dynamodb put-item  --table-name test_dtable  --item '{"uuid": {"S": "1235asdf"}, "movie": {"S": "matrix 3"}, "director": {"S": "vatchovsky"}, "Awards": {"N": "2"}}' --region us-east-2

