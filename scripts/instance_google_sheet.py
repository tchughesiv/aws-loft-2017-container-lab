#!/usr/bin/python

# Used this resources to build this simple script
# https://boto3.readthedocs.io/en/latest/guide/ec2-example-managing-instances.html
# http://gspread.readthedocs.io/en/latest/
# https://www.twilio.com/blog/2017/02/an-easy-way-to-read-and-write-to-a-google-spreadsheet-in-python.html


from __future__ import print_function
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import boto3


def main():
    ec2 = boto3.client('ec2')

    filters = [{'Name':'tag:lab_type', 'Values':["loft-lab"]}]
    instances = ec2.describe_instances(Filters=filters)


    scope = ['https://spreadsheets.google.com/feeds']
    creds = ServiceAccountCredentials.from_json_keyfile_name('/home/jcallen/client_secret.json', scope)
    client = gspread.authorize(creds)

    sheet = client.open("aws-loft").sheet1

    row = ["Student ID", "Public URL", "Public IP Address", "Claimed By"]

    sheet.delete_row(1)
    sheet.insert_row(row, 1)

    row_count = 2

    for r in instances['Reservations']:
        for i in r['Instances']:
            for t in i['Tags']:
                if t['Key'] == 'Name':
                    if 'spare' in t['Value']:
                        student_id = t['Value']
                    else:
                        student_id = t['Value'].split('-')[-1]

            print(i['PublicDnsName'])
            print(i['PublicIpAddress'])

            row = [student_id, i['PublicDnsName'], i['PublicIpAddress']]
            sheet.delete_row(row_count)
            sheet.insert_row(row, row_count)
            row_count = row_count + 1


if __name__ == '__main__':
    main()