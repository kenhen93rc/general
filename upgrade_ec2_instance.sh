#!/usr/bin/env bash
#$1 is the aws tag name value
ssh $user@$1 sudo service cb-enterprise stop
ID=`aws --region=us-east-1 ec2 describe-instances --filters "Name=tag:Name,Values=$1" --output text | grep INSTANCES | awk '{print $8}'`
aws --region us-east-1 ec2 stop-instances --instance-ids $ID

while loop
#waiting to stop
aws --region=us-east-1 ec2 describe-instances --filters "Name=tag:Name,Values=$1" --output text | grep STATE | awk '{print $3}'| awk 'NR == 1'

aws --region=us-east-1 ec2 modify-instance-attribute --instance-id $ID --instance_type "{\"Value\": \"r4.4xlage\"}"

aws --region=us-east-1 ec2 start-instances --instance-ids $ID

while loop
#waiting to start
aws --region=us-east-1 ec2 describe-instances --filters "Name=tag:Name,Values=$1" --output text | grep STATE | awk '{print $3}'| awk 'NR == 1'

ssh $user@$1 sudo service cb-enterprise start

while loop
ssh $user@$1 sudo cb-enterprise status
#return if exit code is not 0