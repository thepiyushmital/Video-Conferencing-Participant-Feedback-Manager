# Video-Conferencing-Participant-Feedback-Manager (Python | Aws | Terraform)

# Pre-requisites to run the project
1. An AWS account
2. AWS cli configured on terminal/cmd
3. Terraform cli configured on terminal/cmd


# To run the project
1. terraform init
2. terraform plan
3. terraform apply
    
# To view Demo of the embedded version in Avaya Spaces (React JS based UI)
https://drive.google.com/file/d/1GI6etf35l67AAWQ0XA8UF4lueQKWyRT4/view?usp=sharing

To create new routes for websocket API
- Custom routes can't start with $ 
- Predefined routes are $default, $connect, $disconnect
- Example routes: collectfeedback


Integration type: AWS_PROXY
- Without it, you wont be able to get connection ID as a part of requestContext

# API's involved

To connect to websocket api
-  wscat -c wss://<API_ID>.execute-api.us-east-1.amazonaws.com/dev

To register client and meeting
- { "action": "onconnect", "meetingId": "ADEFFESA", "username": "pmital", "imgURL": "img" }

To send fresh-feedback for speaker
- {"speakerName": "pmital", "remarkType": remarkType, "imgURL": speakerImgURL, "transcriptData": "Transcript here"}

To send response-feedback for speaker invoked by some other participant
- {"speakerName": "pmital", "roundId": "ROUND2", "remarkType": remarkType, "imgURL": speakerImgURL, "transcriptData": "Transcript here"}

# Resources:

Terraform resources: 
https://github.com/ustaxcourt/ef-cms/blob/staging/iam/terraform/environment-specific/main/lambda.tf

Websocket chat application:
https://github.com/hashicorp/terraform-provider-aws/tree/main/examples/api-gateway-websocket-chat-app

Invoke Lambda function from step function
https://nahidsaikat.com/blog/invoke-aws-lambda-from-aws-step-functions-with-terraform/


