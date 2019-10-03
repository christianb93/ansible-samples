#############################################
# Create an instance on EC2 and add the     #
# IP address to hosts.ini                   #
# Assumes that you have the aws CLI         #
# installed and in your path and that       #
# the CLI is set up with a proper IAM       #
# user                                      #
# CAUTION: this script will use the default #
# security group and open the SSH port for  #
# incoming TCP connections from 0.0.0.0/0!  #
# This might raise an error if the rule     #
# already exists which we ignore            #
#############################################

sshKeyName="ansibleTest"

#
# Parse parameters
#
while getopts t:n:r:s:k:h option
do
  case "${option}"
    in
      h) echo "Usage: ./create_ec2_instance.sh -k <keyname> "; exit;;
      k) sshKeyName=${OPTARG};;
  esac
done

#
# Get the AMI ID of the latest Amazon Linux image for EBS backed instances
#
amiID=$(aws ec2 describe-images \
    --owners amazon \
      --filters 'Name=name,Values=amzn-ami-hvm-????.??.?.????????-x86_64-ebs' 'Name=state,Values=available' \
      --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')

echo "Using AMI-ID $amiID and SSH key $sshKeyName"

#
# Create a new instance
#
instanceID=$(aws ec2 run-instances \
    --image-id $amiID \
    --count 1\
    --instance-type t2.micro \
    --key-name $sshKeyName | jq -r '.Instances[0].InstanceId')

echo "Created instance $instanceID, now waiting for instance to come up"

#
# Wait for instance to be running
#
state="pending"
while [ ! "$state" == "running" ];
do
    echo "Instance state is $state"
    sleep 10
    state=$(aws ec2 describe-instance-status --instance-ids=$instanceID  | jq -r '.InstanceStatuses[0].InstanceState.Name')
done

#
# and wait until completion of reachability check
#
echo "Giving server two minutes to complete all checks"
sleep 120
systemStatus="initializing"
while [ ! "$systemStatus" == "ok" ];
do
    echo "System status is $systemStatus"
    sleep 20
    systemStatus=$(aws ec2 describe-instance-status --instance-ids=$instanceID  | jq -r '.InstanceStatuses[0].SystemStatus.Status')
done


#
# Now get IP address
#
ip=$(aws ec2 describe-instances --instance-ids=$instanceID | jq -r '.Reservations[0].Instances[0].PublicIpAddress')
echo "Newly created machine has public IP address $ip"

#
# and add it to hosts.ini, creating the file if if does not yet exist
#
if [ ! -f "hosts.ini" ]; then
  echo "Creating repository file"
  echo "[servers]" > hosts.ini
fi
echo $ip >> hosts.ini

#
# Now get security group ID
#
securityGroupID=$(aws ec2 describe-instances --instance-ids=$instanceID | jq -r '.Reservations[0].Instances[0].SecurityGroups[0].GroupId')
#
# and allow incoming SSH traffic
#
echo "Allowing incoming SSH traffic for security group $securityGroupID"
aws ec2 authorize-security-group-ingress \
    --group-id $securityGroupID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 2>/dev/null
