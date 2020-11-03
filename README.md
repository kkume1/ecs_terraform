## Terraform による、AWS ECS環境の構築スクリプト

#### 概要
##### このスクリプトは、AWS ECS(Fargate)をマルチAZで構築するTerraformスクリプトです。

---
構成図
![aws構成図](https://user-images.githubusercontent.com/30540542/98032856-f8cb6780-1e57-11eb-8865-7a1fef3b8038.jpg)
---

- マルチAZ環境/パブリック・プライベートサブネット環境
- ALBによるロードバランシング
- Natゲートウェイを設置し、プライベートサブネットにECSを構築
- コンテナのログはCloudwatch Log に出力
---
- ECRの構築、及びdockerイメージのデプロイは、本スクリプトでは記述しておりません。事前に準備が必要です。
- コンテナイメージのCI/CDはCircleCIを使用しております。「nginx-sample」リポジトリを参照ください。
