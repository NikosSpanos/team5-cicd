vm_ipaddress=$(terraform output -json | jq -r '.output_public_ip.value')
firefox --new-tab $vm_ipaddress:8080
echo "Successfully opened jenkins environment"
