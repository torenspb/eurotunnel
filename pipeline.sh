clear
echo 'Starting pipeline...'
echo '=============================================================='
echo 'Generating a key-pair'
echo '-----------------------------------'
yes | ssh-keygen -f centoskey -N '' -C ''
echo '=============================================================='
echo 'Applying terraform configuration'
echo '-----------------------------------'
export TF_VAR_FILE="variables.json"
terraform apply -var-file="$TF_VAR_FILE"
echo '=============================================================='
echo 'Done!'
echo '=============================================================='
