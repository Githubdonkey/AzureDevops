#!/bin/bash
logger ${imagename} 4 hour shutdown initiated
shutdown -P +20
sudo yum update -y
sudo yum install -y amazon-efs-utils
sudo mkdir /efs
sudo mount -t efs fs-b2750631:/ /efs