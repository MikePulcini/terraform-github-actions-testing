provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "dynamodb-table-test1" {
  name           = "Test123"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "TweetId"

  attribute {
    name = "TweetId"
    type = "S"
  }

  tags = {
    TestTag = "TestVal"
  }
}
