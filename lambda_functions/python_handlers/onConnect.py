import json
import boto3

dynamoClient = boto3.client('dynamodb')

def lambda_handler(event, context):
    # TODO implement
    connectionId = event["requestContext"].get("connectionId")
    msg = json.loads(event["body"])
    meetingId = msg["meetingId"]
    username = msg["username"]
    imgURL = msg["imgURL"]
    
    record_data = meetingId, username
    delete_already_existing_connection(record_data)
    # Put Item in webSocketDb table
    dynamoClient.put_item(
        TableName='webSocketDb',
        Item={
            'connectionId': {'S': connectionId},
            'meetingId':{'S': meetingId},
            'username': {'S': username},
            'imgURL': {'S': imgURL}
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps('connection id = ' + connectionId )
    }
    
def delete_already_existing_connection(record_data):
    meetingId, username = record_data

    response = dynamoClient.scan(
        TableName="webSocketDb"
    )             
    print("Get list of connections wrt meetingId")
    items = response['Items']
    print(items)
    
    for res in items:
        if res['username']['S'] == username and res['meetingId']['S'] == meetingId: 
            updateFeedbackTableResp = dynamoClient.delete_item(
                TableName='webSocketDb',
                Key={
                    'connectionId': {"S": res['connectionId']['S']}
                }
            )