import json
import boto3
import uuid
from datetime import datetime

#Dynamo client initialization
dynamoClient = boto3.client("dynamodb")

def lambda_handler(event, context):
    # fetching connectionId from event
  #  try:
    connectionId=event["requestContext"].get("connectionId")
  
    #Fetch and Verify if connection is present in database
    resWebSocketDb = dynamoClient.get_item(TableName='webSocketDb', Key={'connectionId': {'S':connectionId}})
    print("Fetched data from webSocketDb -> connectionId")
    
    if len(resWebSocketDb) != 0:
        print(resWebSocketDb)
        #Websocket Db based variable assignments
        Item = resWebSocketDb['Item']
        meetingId = Item["meetingId"]['S']
        username = Item["username"]['S']
        imgURL = Item["imgURL"]['S'] 
        print(meetingId + " " + username)
        
        
        #Request based variable assignments
        msg = json.loads(event["body"])
        timeStamp = datetime.now().timestamp()
        print("object recieved from participant \n\n")
        print(msg)
        speaker = msg["speakerName"]
        remarks = msg["remarks"]
        transcripts = msg["transcriptData"] 
        #tech / non-tech
        remarkType = msg["remarkType"]
        
        if "roundId" in msg:
            roundId = msg["roundId"]
        else:
            roundId = None
       
        
        if roundId is None:
            #check if an round in progress, if yes, then assign that round if here, else round id stays null
            resScanForRoundId = dynamoClient.scan(TableName="clientFeedbackDb")
            print(resScanForRoundId)
            for obj in resScanForRoundId["Items"]:
                if "feedbackStatus" in obj and obj["feedbackStatus"]["S"] == "inProgress" and obj["remarkType"]["S"] == remarkType: 
                    roundId = obj["roundId"]["S"]

            print(roundId)
        if remarks:
            first_remark = remarks.pop()  
            if roundId is None:
                #Generate new roundId. It may not necessarily be put into use
                roundId = str(uuid.uuid4())
                print("First feedback to be put in db \n\n")
                record_data = meetingId, roundId, speaker, username, first_remark, timeStamp, remarkType, transcripts, imgURL
                add_new_client_feedback_record(record_data) 
            else:
                print("Other than First feedback to be put in db \n\n")
                record_data = meetingId, roundId, speaker, username, first_remark, timeStamp, remarkType, transcripts, imgURL
                update_client_feedback_record(record_data, True)
            
            for remark in remarks:
                record_data = meetingId, roundId, speaker, username, remark, timeStamp, remarkType, transcripts, imgURL
                update_client_feedback_record(record_data, False)
                
            

    return {
        'statusCode': 200,
        'body': json.dumps('On message executed ')
    }
    # except:
    #     print("Error occured while adding/updating clientFeedback entries")
           
def post_message(connectionId, msg):
    gateway_resp = gatewayapi.post_to_connection(ConnectionId=connectionId,
                                                 Data=json.dumps({"message": msg}))

def add_new_client_feedback_record(record_data):
    meetingId, roundId, speaker, username, remark, timeStamp, remarkType, transcripts, imgURL = record_data
    #initialize new data for db
    print(record_data)
    print("\n record data above \n")
    newTranscriptData = []
    for transcript in transcripts:
        newTranscriptData.append(
            {"S":
                str(
                    {
                        "participantName": username, 
                        "timestamp": transcript["timestamp"],
                        "text": transcript["text"],
                        "imgURL": imgURL
                    }    
                )
            }
        )
    print(newTranscriptData)
    newFeedbackData = {"S": 
        str(
            {
        		"participantName": username ,
        		"remark": remark ,
        		"timeStamp": timeStamp 
        	}
        )
    } 
    dynamoClient.put_item(
        TableName="clientFeedbackDb",
        Item={
            "meetingId": { "S": meetingId },
            "roundId": { "S": roundId },
            "speakerName": { "S": speaker },
            "remarkType": { "S": remarkType },
            "feedbackStatus": {"S": "inProgress"},
            "feedbackData": {"L": [newFeedbackData]},
            "transcriptionData": {"L" : newTranscriptData}
        }
    )

    print("Push recieved remark in clientFeedback")

    #Start wait timer after 1st request is put in DB
    eastern_time = datetime.now().strftime("%H_%M_%S")
    stateMachineData =  meetingId, speaker, eastern_time, timeStamp, roundId, remarkType
    start_state_machine(stateMachineData)

    #Send requests to other clients
    send_client_requests(record_data)
    
def update_client_feedback_record(record_data, hasTranscript):
    meetingId, roundId, speaker, username, remark, timeStamp, remarkType, transcripts, imgURL = record_data
    #initialize keyvalue
    newTranscriptData = [] 
   
    keyValue = {
        'meetingId': {
            'S': meetingId
        },
        'roundId': {
            'S': roundId
        }
    }
    #initialize new data for updation in db
    newFeedbackData = { 'S' : str(
            {
            	"participantName": username ,
            	"remark": remark ,
            	"timeStamp": timeStamp
            }
        )
    }
    
    #fetch current table value wrt keyValue
    getClientFb = dynamoClient.get_item(TableName="clientFeedbackDb", Key=keyValue)
    print(getClientFb)
    #Append to preexisting feedback data list
    getClientFb["Item"]["feedbackData"]["L"].append(newFeedbackData)
    print(getClientFb["Item"]["feedbackData"]["L"])
    updatedFeedbackValue = {'L':  getClientFb["Item"]["feedbackData"]["L"]}
    
    if hasTranscript == True:
        for transcript in transcripts:
            getClientFb["Item"]["transcriptionData"]["L"].append(
                {"S":
                    str(
                        {
                            "participantName": username, 
                            "timestamp": transcript["timestamp"],
                            "text": transcript["text"],
                            "imgURL": imgURL
                        }    
                    )
                }
            )
        print(getClientFb["Item"]["transcriptionData"]["L"])
        updatedTranscriptValue = { 'L' : getClientFb["Item"]["transcriptionData"]["L"]}
        ExpressionAttributeNamesObj = {
            '#Fb': 'feedbackData',
            "#Td":  'transcriptionData'
        }
        ExpressionAttributeValuesObj = {
            ':f': updatedFeedbackValue,
            ':t': updatedTranscriptValue
        }
        UpdateExpressionString = 'SET #Fb = :f, #Td = :t'

    else:
        ExpressionAttributeNamesObj = {
            '#Fb': 'feedbackData',
        }
        ExpressionAttributeValuesObj = {
            ':f': updatedFeedbackValue,
        }
        UpdateExpressionString = 'SET #Fb = :f'
        
        
    response = dynamoClient.update_item(
        TableName="clientFeedbackDb",
        Key=keyValue,
        ExpressionAttributeNames= ExpressionAttributeNamesObj,
        ExpressionAttributeValues= ExpressionAttributeValuesObj,
        UpdateExpression= UpdateExpressionString
    )
    
def start_state_machine(stateMachineData):
    meetingId, speaker, eastern_time, timeStamp, roundId, remarkType = stateMachineData
    stepFunctionClient = boto3.client('stepfunctions')
    
    respStep = stepFunctionClient.start_execution(
        stateMachineArn='arn:aws:states:us-east-1:654808750935:stateMachine:MyStateMachine',
        name= meetingId + speaker + eastern_time,
        input=json.dumps({'meetingId': meetingId, 'speaker': speaker, 'timeStamp': timeStamp, 'roundId': roundId, 'remarkType': remarkType})
    )
    print(" response of step function")
    print( respStep)
    
def send_client_requests(record_data):
    meetingId, roundId, speaker, username, remark, timeStamp, remarkType, transcripts, imgURL = record_data

    response = dynamoClient.scan(
        TableName="webSocketDb"
    )             
    print("Get list of connections wrt meetingId")
    items = response['Items']
    print(items)
    speakerImgURL = None
    for item in items:
        if item['username']['S'] == speaker and item['meetingId']['S'] == meetingId:
            speakerImgURL = item['imgURL']['S']
    
    for res in items:
        if res['username']['S'] != username and res['username']['S'] != speaker and res['meetingId']['S'] == meetingId: 
            URL = "https://wv89q21vzh.execute-api.us-east-1.amazonaws.com/dev"
            client = boto3.client("apigatewaymanagementapi", endpoint_url = URL)
            
            msg = {"speakerName": speaker, "duration": 20,  "roundId": roundId, "remarkType": remarkType, "imgURL": speakerImgURL}
            client.post_to_connection(ConnectionId=res["connectionId"]['S'], Data=json.dumps(msg))