import json
import boto3
import ast
 
URL = "https://wv89q21vzh.execute-api.us-east-1.amazonaws.com/dev"
client = boto3.client("apigatewaymanagementapi", endpoint_url = URL)

def lambda_handler(payload, context):
    event = payload['Input']
    print(payload)
    dynamoClient = boto3.client("dynamodb")
    STATIC_THRESHOLD = 0.6  
    
    
    # Update the state of that feedback to completed
    updateFeedbackTableResp = dynamoClient.update_item(
        TableName='clientFeedbackDb',
        Key={
            'meetingId': {"S": event['meetingId']},
            'roundId': {"S": event['roundId']}
        },
        UpdateExpression="set feedbackStatus=:s",
        ExpressionAttributeValues={
            ':s': {"S": "completed"}
        },
    )

    # Fetch the feedback corresponding to event.meetingId and event.roundId
    feedbackItemResp = dynamoClient.get_item(
        TableName='clientFeedbackDb',
        Key={
            'meetingId': {"S": event['meetingId']},
            'roundId': {"S": event['roundId']}
        }
    )
    feedbackItem = feedbackItemResp['Item']
    
    print(feedbackItem)
    
    # Calculate the threshold wrt remarks received
    isThresholdPassed = False
    remarksPassed = []
    remarkFreq = {}
    
    #Calculate the total connections in meeting
    connectionCount = 0
    websocketConnections = dynamoClient.scan(
        TableName="webSocketDb"
    )             
    print("Get list of connections wrt meetingId")
    items = websocketConnections['Items']
    for conRes in items:
        print(conRes)
        if conRes["meetingId"]["S"] == event['meetingId']:
            connectionCount = connectionCount + 1

    sorted_transcript_list = sort_transcripts(feedbackItem['transcriptionData']['L'])
    
    for feedbackTemp in feedbackItem['feedbackData']['L']:
        print(feedbackTemp["S"])
        feedback = ast.literal_eval(feedbackTemp["S"])
        print(feedback['participantName'], feedback['remark'])
        if feedback['remark'] in remarkFreq:
            remarkFreq[feedback['remark']] += 1
        else:
            remarkFreq[feedback['remark']] = 1
    # totalFeedbacks = len(feedbackItem['feedbackData']['L'])
    remarksFailed = []
    for remark in remarkFreq:
        print(remark, remarkFreq[remark])
        if remarkFreq[remark] / (connectionCount - 1)  >= STATIC_THRESHOLD:
            isThresholdPassed = True
            remarksPassed.append(remark)
        else:
            remarksFailed.append(remark)

    # If required, fetch the clientId for the speaker and send the message to speaker
    if isThresholdPassed:
        for res in items:
            if res['username']['S'] == feedbackItem["speakerName"]['S']:
                print('found the speaker', res['username']['S'], res['connectionId']['S'])
                msg = {
                    "remarks": remarksPassed,
                    "timestamp": event["timeStamp"],
                    "remarkType": event["remarkType"],
                    "roundId": event["roundId"],
                    "transcriptData": sorted_transcript_list
                }
                URL = "https://wv89q21vzh.execute-api.us-east-1.amazonaws.com/dev"
                client = boto3.client("apigatewaymanagementapi", endpoint_url = URL)
                response = client.post_to_connection(ConnectionId=res['connectionId']['S'], Data=json.dumps(msg))
                print(response)
    else:
        print("Threshold did not pass")
    
    participant_feedback_status_return(remarksPassed, remarksFailed, feedbackItem['feedbackData']['L'], items, event)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    
def participant_feedback_status_return(remarksPassed, remarksFailed, feedbackItemList, websocketList, event):
    URL = "https://wv89q21vzh.execute-api.us-east-1.amazonaws.com/dev"
    client = boto3.client("apigatewaymanagementapi", endpoint_url = URL)
    # try:    
    for item in websocketList:
        participant_pass_fb = []
        participant_fail_fb = [] 
        for feedbackTemp in feedbackItemList:
            feedback = ast.literal_eval(feedbackTemp["S"])
            print("feedback show")
            print(feedback)
            if item["username"]["S"] == feedback["participantName"]:
                if feedback["remark"] in remarksPassed:
                    participant_pass_fb.append(feedback["remark"])
                if feedback["remark"] in remarksFailed:
                    participant_fail_fb.append(feedback["remark"]) 
        
        if participant_pass_fb:
            msg = {
                "remarks": participant_pass_fb,
                "status": "success",
                "timestamp": event["timeStamp"],
                "remarkType": event["remarkType"],
                "roundId": event["roundId"]
            }
            response = client.post_to_connection(ConnectionId=item['connectionId']['S'], Data=json.dumps(msg))
            print(response)
        if participant_fail_fb:
            msg = {
                "remarks": participant_fail_fb,
                "status": "failure",
                "timestamp": event["timeStamp"],
                "remarkType": event["remarkType"],
                "roundId": event["roundId"] 
            }
            response = client.post_to_connection(ConnectionId=item['connectionId']['S'], Data=json.dumps(msg))
            print(response)
    #except:
    #   print("failure happenned while participant response given \n\n\n\n oh noooooo  ")
    
def sort_transcripts(transcripts):
    transcript_list = []
    for transcriptTemp in transcripts:
        print(transcriptTemp["S"])
        transcript = ast.literal_eval(transcriptTemp["S"])
        transcript_list.append(transcript)
    
    print(transcript_list)
    transcript_list.sort(key=get_timestamp)
    return transcript_list
    
    
def get_timestamp(e):
  return e['timestamp']