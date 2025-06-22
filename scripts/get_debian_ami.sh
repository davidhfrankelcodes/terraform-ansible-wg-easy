#!/bin/bash

DEBIAN_AMI=$(aws ec2 describe-images \
    --owners 136693071363 \
    --filters "Name=name,Values=debian-12-*" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text)

echo "Latest Debian AMI: $DEBIAN_AMI"
