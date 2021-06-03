/*
Terraform variables that should be configured from the user.
Variable 1: prefix 
--description: string text var to distinguish infrastructure from development to production resours
--values accepted: [production, development]

Variable 2: output_path
--description: the path to write ssh private key and public ip address to local machine where the terraform apply is executed
--values accepted: any valid path except the root folder. Root folder is not adviced because terraform will need sudo access.

Variable 3: vm_connection_script_path
--description: the path folder where the vm_connection.sh script exists. This script is downloaded along with cloned git repository.
--values accepted: a valid path
*/
prefix = "cicd"