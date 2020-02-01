#!/bin/bash
NOW=$(date +"%m-%d-%y-%H-%M")

git add .
git commit -m $NOW
git push

aws s3 ls s3://gitdonkey/devops --recursive

aws s3 ls $BUCKET --recursive | sort

aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'

aws s3 cp manifest.json s3://gitdonkey/devops/${imagePacker}.json

KEY=`aws s3 ls s3://gitdonkey/devops --recursive | sort | tail -n 1 | awk '{print $4}'`
echo $KEY

KEY=`aws s3 ls s3://gitdonkey/devops --recursive | ls  SICFactory-Windows2016* | sort | tail -n 1 | awk '{print $4}'`

ls  SICFactory-Windows2016* |


#aws s3 cp s3://$BUCKET/$KEY ./latest-object