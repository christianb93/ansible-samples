################################################################################
# Create a droplet                                                             #
# We will use the following defaults                                           #
# name "myDroplet"                                                             #
# region "fra1"                                                                #
# size "s-1vcpu-1gb"                                                           #
# sshKeyName "do_k8s"                                                          #
# Usage:                                                                       #
# ./create_droplet.sh -n <name> -r <region> -s <size> -k <keyname>  -t <token> #
################################################################################


name="myDroplet"
region="fra1"
size="s-1vcpu-1gb"
sshKeyName="do_k8s"


#
# Parse parameters
#
while getopts t:n:r:s:k:h option
do
  case "${option}"
    in
      n) name=${OPTARG};;
      r) region=${OPTARG};;
      s) size=${OPTARG};;
      h) echo "Usage: ./create_droplet.sh -n <name> -r <region> -s <size> -k <keyname> -t <token>"; exit;;
      k) sshKeyName=${OPTARG};;
      t) bearerToken=${OPTARG};;
  esac
done

echo "Creating droplet $name of type $size in region $region"
echo "Using bearer token $bearerToken and ssh key $sshKeyName"


#
# Get the ID of the SSH key
#
sshKeyId=$(curl -s -X GET "https://api.digitalocean.com/v2/account/keys/" \
	-H "Authorization: Bearer $bearerToken" \
	-H "Content-Type: application/json" \
        | jq -r "select(.ssh_keys[].name=\"$sshKeyName\") .ssh_keys[0].id")
echo "Using ssh key ID $sshKeyId"


#
# Create a new droplet and store its ID in the variable id
#
id=$(curl -s -X POST "https://api.digitalocean.com/v2/droplets" \
	-d "{\"name\":\"$name\",\"region\":\"$region\",\"size\":\"$size\",\"image\":\"ubuntu-18-04-x64\", \"ssh_keys\":[ $sshKeyId ]}" \
	-H "Authorization: Bearer $bearerToken" \
	-H "Content-Type: application/json" \
        | jq -r '.droplet.id')
echo "Iniated creation of droplet $id"

#
# Get the status of the droplet and wait until it is active
#
echo "Waiting for completion of request"
status=X
while [ "$status" != "active" ];
do
sleep 5
status=$(curl -s -X GET "https://api.digitalocean.com/v2/droplets/$id" \
	-H "Authorization: Bearer $bearerToken" \
	-H "Content-Type: application/json" \
        | jq -r '.droplet.status')
echo "Droplet is currently in status $status"
done

# Get the first public IP address
#
ip=$(curl -s -X GET "https://api.digitalocean.com/v2/droplets/$id" \
        -H "Authorization: Bearer $bearerToken"\
        -H "Content-Type: application/json" | jq -r '.droplet.networks.v4 | select(.[].type="public")[0].ip_address')
ip=$(echo $ip | awk '{print $1}')
echo "Newly created droplet has public IP $ip"

# Finally we create a repository file if it does not yet exist
if [ ! -f "hosts.ini" ]; then
  echo "Creating repository file"
  echo "[servers]" > hosts.ini
fi
# and append IP address
echo $ip >> hosts.ini



