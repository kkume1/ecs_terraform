# このモジュールは、以下の処理を行う
#
# ・信頼ポリシーの定義（定義したロールはどのAWSサービスに紐づけるか）
# ・ロールの定義（信頼ポリシー含む）
# ・定義したロールにポリシーをアタッチする


variable "name" {}         # ロール名
variable "policy" {}       # アタッチするポリシー
variable "identifier" {}   # アタッチする信頼ポリシー

# 信頼ポリシー定義
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [var.identifier]
    }
  }
}

# ロール定義（信頼ポリシー含む）
resource "aws_iam_role" "default" {
  name = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# ポリシー定義（json読み込み）
resource "aws_iam_policy" "default" {
  name = var.name
  policy = var.policy
}

# ロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.default.name          # ロール
  policy_arn = aws_iam_policy.default.arn   # ポリシー
}

# 以下のプロパティから値を取得できる
output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}