#!/bin/bash
NOW=$(date +"%m-%d-%y-%H-%M")

git add .
git commit -m $NOW
git push