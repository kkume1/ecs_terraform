# AWS を利用することを明示
provider "aws" {
    # リージョンを設定
    region = "ap-northeast-1"
}

# 自身の AWS ACCOUNT_IDの取得
data "aws_caller_identity" "myaccount" {}

