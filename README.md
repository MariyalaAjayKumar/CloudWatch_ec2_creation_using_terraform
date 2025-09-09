cloud watch:
1.cloud watch overview we have all the services for alarms we can see all our aws services here.
2.in the dashboard we can see lot of graphs. to check our aws services performance levels and application peroformance levels.
3.we can create our own graphs for our services in our dashboard according to our view.
4.the log group is a collection of the log streams.(from multiple EC2 instances)
5.the log stream is a specific single resource.(like from lambda trigger.from one instance.)
6.the log events is a individual events which occured from multiple instances.
lamda function:
1.the lamda function is server less function means ,we are not taking for rent or buying any server,just it will run automatically with the code.
2.the lamda will trigger when any of thing will happen properly.like in s3 bucket any image is added it will trigger,so any action happens on any of aws services the lamda function will trigger.
What is Anomaly Detection?
Anomaly detection is the process of identifying unusual patterns, deviations, or outliers in data that do not conform to expected behavior. It is widely used in monitoring, security, fraud detection, and predictive maintenance.

top 25 most recents
fields @timestamp,@message | sort @timestamp desc | limit 25
fields: the fields which you need to seeon the logs
sort: to filter in asc or desc
dedup : to make unique no duplication

fields @timestamp, server, severity, message 
| sort @timestamp asc 
| dedup server

project:
1.ireland (eu-west-1) region.
auto scalling means:
the ec2 instances will be increased when it needs more,else it will decrease when it dont need.it will adjust automatically according to usage.
aws re:invent 2024:
 - Sarang kamble
 aws management console-- visual update
 Analytics:
 Sagemaker Lake house: which is stored data in the table.
 express brokers fro amazon MSK (for kafka)
 Database cdc with amazon data firehose
 Sure! Let's go step by step in detail.

---

## **Overview**
This Terraform script will:
1. **Create an S3 Bucket** – A simple AWS S3 bucket where you can upload files.
2. **Create an SNS Topic** – A notification system to send alerts when something happens.
3. **Subscribe an Email to SNS** – This email will receive alerts.
4. **Create a CloudWatch Alarm** – The alarm will monitor the S3 bucket size.
5. **Trigger the Alarm** – When the S3 bucket exceeds **100MB**, an email notification will be sent.

---

## **Step-by-Step Breakdown of Terraform Code**

### **1️⃣ Provider Configuration**
```hcl
provider "aws" {
  region = "us-east-1"
}
```
- This tells Terraform to use **AWS** as the cloud provider.
- The **region** is set to `us-east-1`, but you can change it to your preferred AWS region.

---

### **2️⃣ Create an S3 Bucket**
```hcl
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-cloudwatch-bucket"
}
```
- This creates an **S3 bucket** named `"my-example-cloudwatch-bucket"`.
- S3 is a storage service where you can upload and store files.

---

### **3️⃣ Create an SNS Topic**
```hcl
resource "aws_sns_topic" "alarm_topic" {
  name = "s3-bucket-size-alarm-topic"
}
```
- **SNS (Simple Notification Service)** is used to send notifications.
- This creates an SNS topic named `"s3-bucket-size-alarm-topic"`.

---

### **4️⃣ Subscribe an Email to SNS**
```hcl
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}
```
- This subscribes an **email address** to the SNS topic.
- Change `"your-email@example.com"` to **your actual email**.
- AWS will **send a confirmation email**, and you need to **click the link** to confirm.

---

### **5️⃣ Create a CloudWatch Alarm**
```hcl
resource "aws_cloudwatch_metric_alarm" "s3_size_alarm" {
  alarm_name          = "S3-Bucket-Size-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400  # 1 day
  statistic           = "Average"
  threshold           = 100000000  # 100MB (100 * 1024 * 1024)
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    BucketName = aws_s3_bucket.example_bucket.bucket
    StorageType = "StandardStorage"
  }
}
```
- **What does this do?**
  - Creates a **CloudWatch Alarm** named `"S3-Bucket-Size-Alarm"`.
  - **Monitors the S3 bucket size** (`BucketSizeBytes` metric).
  - **Triggers an alarm when the size exceeds 100MB** (`100 * 1024 * 1024`).
  - **Sends an SNS notification** when the alarm triggers.

- **Key Fields Explained:**
  - `comparison_operator = "GreaterThanThreshold"` → Triggers when size **exceeds** the threshold.
  - `evaluation_periods  = 1` → Checks the condition once before triggering.
  - `metric_name = "BucketSizeBytes"` → Monitors S3 bucket size.
  - `namespace = "AWS/S3"` → The AWS service being monitored.
  - `threshold = 100000000` → 100MB limit before alarm triggers.
  - `alarm_actions = [aws_sns_topic.alarm_topic.arn]` → Sends a notification.

---

### **6️⃣ Output the Resources Created**
```hcl
output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.example_bucket.bucket
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.alarm_topic.arn
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch Alarm Name"
  value       = aws_cloudwatch_metric_alarm.s3_size_alarm.alarm_name
}
```
- This **prints useful details** after running Terraform.
- When you run Terraform, it will output:
  - **S3 Bucket Name**
  - **SNS Topic ARN**
  - **CloudWatch Alarm Name**

---

## **Step-by-Step Execution in AWS CLI**
Now, let's deploy this in AWS.

### ✅ **1. Initialize Terraform**
```sh
terraform init
```
- This downloads all necessary Terraform modules.

### ✅ **2. Preview Changes**
```sh
terraform plan
```
- This **checks what Terraform will create**.

### ✅ **3. Apply the Configuration**
```sh
terraform apply -auto-approve
```
- This **creates all AWS resources** automatically.

---

## **What Happens Next?**
1. **Terraform Creates Resources:**
   - An **S3 bucket**.
   - An **SNS topic**.
   - An **email subscription** (you need to confirm it).
   - A **CloudWatch alarm** for bucket size.

2. **You Confirm the SNS Email Subscription:**
   - Check your email 📧.
   - Click the **confirmation link** to start receiving alerts.

3. **Test the Alarm:**
   - Upload files to your S3 bucket until **it exceeds 100MB**.
   - CloudWatch will detect the size increase.
   - The alarm **triggers** and sends an email notification.

---

## **Cleanup (If You Want to Delete Everything)**
If you want to remove all AWS resources:
```sh
terraform destroy -auto-approve
```
- This **deletes everything** Terraform created.

---

## **Summary**
| Component  | Purpose |
|------------|---------|
| **S3 Bucket** | Stores files and is monitored by CloudWatch |
| **SNS Topic** | Sends notifications when an alarm triggers |
| **Email Subscription** | Receives CloudWatch alerts |
| **CloudWatch Alarm** | Triggers when the S3 bucket exceeds 100MB |

---

## **Next Steps**
🚀 **Try modifying the alarm** to monitor different services like:
- **CPU usage of an EC2 instance**.
- **Latency of an API Gateway**.
- **Memory usage of a Lambda function**.

Let me know if you need help! 😊

sso_start_url = 
sso_region = 
sso_account_id = 
sso_role_name = ReadOnlyAccessPlus
output = json
region = eu-west-1

"VpcId": "vpc-07976204d36059302"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-07976204d36059302" --query "Subnets[*].SubnetId"
bnets[*].SubnetId"
[
    "subnet-0e79fad65a09fb8de",
    "subnet-0e2bc1dad412cc86d",
    "subnet-022c157d4bb730097",
    "subnet-0559ca71a0f1fa1dd",
    "subnet-09ebce86db7a2e7da",
    "subnet-01bd2be800c62b372",
    "subnet-0aa14cbc5fa735436",
    "subnet-04c55b5dcbecb2f91"
]

aws ec2 describe-subnets --region eu-west-1 --profile SandboxAdministratorAccess-144749282232

terraform init
terraform validate
terraform plan
terraform apply
aws sso login --profile SandboxAdministratorAccess-144749282232
aws ec2 describe-vpcs --region eu-west-1
aws sts get-caller-identity --profile SandboxAdministratorAccess-144749282232
aws ec2 describe-key-pairs --key-names testing
aws configure list-profiles
aws ec2 describe-subnets --region eu-west-1 --profile SandboxAdministratorAccess-14474928
