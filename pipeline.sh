clear
echo 'Starting pipeline...'
echo '=============================================================='
echo 'Generating a key-pair'
echo '-----------------------------------'
yes | ssh-keygen -f centoskey -N '' -C ''
echo '=============================================================='
echo 'Applying terraform configuration'
echo '-----------------------------------'
terraform apply -var-file="variables.json"
echo '=============================================================='
echo 'Done!'
echo '=============================================================='
