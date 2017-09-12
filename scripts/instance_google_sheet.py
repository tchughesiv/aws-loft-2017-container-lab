#!/usr/bin/python

# Used this resources to build this simple script
# https://boto3.readthedocs.io/en/latest/guide/ec2-example-managing-instances.html
# https://pygsheets.readthedocs.io/en/latest/


# This library below was extremely slow removed for pygsheets
# http://gspread.readthedocs.io/en/latest/
# https://www.twilio.com/blog/2017/02/an-easy-way-to-read-and-write-to-a-google-spreadsheet-in-python.html


from __future__ import print_function
import pygsheets
import boto3
import os
import time

def main():
    ec2 = boto3.client('ec2')

    filters = [{'Name':'tag:lab_type', 'Values':["loft-lab"],'Name': 'instance-state-name', 'Values': ['running']}]
    instances = ec2.describe_instances(Filters=filters)
    gc = pygsheets.authorize(service_file='%s/nycawsloft-af8212519288.json' % os.environ['HOME'])

    row = ["Student ID", "Public URL", "Public IP Address", "Claimed By"]

    sht = gc.open("NYC AWS Loft Instances")
    wks = sht.worksheet('index', 0)

    wks.update_row(1, values=row)

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

            # Sleep is required otherwise the script will hit the API limit

            time.sleep(0.5)

            wks.update_row(row_count, values=row)

            row_count = row_count + 1


if __name__ == '__main__':
    main()
