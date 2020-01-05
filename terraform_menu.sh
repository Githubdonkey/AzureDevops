#!/bin/bash
echo "select the operation ************"
echo "  1)Terraform plan"
echo "  2)Terraform apply"
echo "  3)operation 3"
echo "  4)operation 4" 

read n
case $n in
  1) terraform plan
     echo "You chose Option 1";;
  2) echo "You chose Option 2";;
  3) echo "You chose Option 3";;
  4) echo "You chose Option 4";;
  *) echo "invalid option";;
esac