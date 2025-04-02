import json
import requests
import boto3
import os

# Initialize S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Example API endpoint
        api_url = "https://jsonplaceholder.typicode.com/posts/1"
        
        # Make a GET request to the API
        response = requests.get(api_url)
        
        # Check if the request was successful
        if response.status_code == 200:
            # Get the data from the API response
            api_data = response.json()
            print("API Data Retrieved:", api_data)
            
            # Convert the data to a JSON string
            data_to_upload = json.dumps(api_data)
            
            # Define S3 bucket and file name
            bucket_name = os.environ['S3_BUCKET_NAME']  # Set in Lambda environment variables
            file_name = "api_data.json"
            
            # Upload the data to S3
            s3_client.put_object(
                Bucket=bucket_name,
                Key=file_name,
                Body=data_to_upload,
                ContentType='application/json'
            )
            print(f"Data successfully uploaded to S3 bucket: {bucket_name}, file: {file_name}")
        
        else:
            raise Exception(f"Failed to fetch data from API. Status Code: {response.status_code}")
    
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        raise e
