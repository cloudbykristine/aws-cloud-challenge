import json
import boto3

from decimal import Decimal

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('crc-table')

    try:
        # Increment countOfViews, initializing to 0 if it doesn't exist
        response = table.update_item(
            Key={
                'id': 'cloudbykristine'
                },
            UpdateExpression="SET countOfViews = if_not_exists(countOfViews, :start) + :inc",
            ExpressionAttributeValues={
                ':inc': 1, 
                ':start': 0
                },
            ReturnValues="UPDATED_NEW"
        )
        # Return the updated count
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps(response['Attributes'], default=decimal_default)
        }
    except Exception as e:
        # Handle errors
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }
