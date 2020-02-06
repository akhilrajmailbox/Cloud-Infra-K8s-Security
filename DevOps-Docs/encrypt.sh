 #!/bin/bash
export Command_Usage="Usage: ./encrypt.sh -o [OPTION...] -b [AWS_Bucket] -e [environment] -m [module]"

if brew list | grep gnu-sed >/dev/null; then
 echo "gnu-sed is already installed"
 shopt -s expand_aliases
 source ~/.bash_profile
else
 brew install gnu-sed
 echo "alias sed=gsed" >> ~/.bash_profile
 shopt -s expand_aliases
 source ~/.bash_profile
fi


#######################################
function Get_Bucket() {
   if [[ -z $AWS_Bucket ]]; then
cat << EOF
WARING
Choose the AWS_Bucket

$Command_Usage
----------------------------
development
----------------------------
production
----------------------------
EOF
		exit 0
	else
		export BUCKET_PREFIX=$AWS_Bucket
	fi

	if [[ $AWS_Bucket == production ]]; then
		KMS_LOCATION="us-east-1"
	elif [[ $AWS_Bucket == development ]]; then
		KMS_LOCATION="us-east-1"
	fi
	echo "Choosing KMS_LOCATION : $KMS_LOCATION for $AWS_Bucket"
}


#######################################
function Get_Env() {
    Get_Bucket
    if [[ -z $environment ]]; then
cat << EOF
WARING
Choose the environment

$Command_Usage
----------------------------
project1-develop
----------------------------
project1-test
----------------------------
project1-stage
----------------------------
project1-prod
----------------------------
EOF
		exit 0
	fi
}


#######################################
function Get_Module() {
	Get_Env
    if [[ -z $module ]]; then
cat << EOF
WARING
Choose the Module

$Command_Usage

----------------------------
module-1
----------------------------
module-2
----------------------------
module-3
----------------------------
EOF
		exit 0
	else
		export repo_project=$module
		export KMS_CMK=$module
		echo "Using module $repo_project"
	fi
}


#######################################
function Get_cipher() {
	mkdir -p secure-data/$environment/$repo_project || echo "Directory already there"
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project
	aws s3 cp s3://$BUCKET_PREFIX-$repo_project-dek/ciphertext_blob_$environment-$repo_project.enc .
	cd $P_W_D
}


#######################################
function Get_key() {
	if [[ -f  secure-data/$environment/$repo_project/ciphertext_blob_$environment-$repo_project.enc ]]; then
		export P_W_D=$PWD ; cd secure-data/$environment/$repo_project

        aws kms decrypt \
            --ciphertext-blob fileb://ciphertext_blob_$environment-$repo_project.enc \
            --query Plaintext --output text --region $KMS_LOCATION | base64 --decode > KEY_$environment-$repo_project.dec

    	rm -rf ciphertext_blob_$environment-$repo_project.enc
    	cd $P_W_D
    else
    	echo "ciphertext file is missing :: ciphertext_blob_$environment-$repo_project.enc"
    	exit 0
    fi
}


#######################################
function Create_key() {
	mkdir -p secure-data/$environment/$repo_project || echo "Directory already there"
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project

    # Create a data key
    aws kms generate-data-key --key-id alias/$KMS_CMK --key-spec AES_256 --region $KMS_LOCATION > data_key.json
    # Storing the CipherTextBlob
    sed -nr 's/^.*"CiphertextBlob":\s*"(.*?)".*$/\1/p' data_key.json | base64 --decode > ciphertext_blob_$environment-$repo_project.enc
    # extract the plaintext key
    sed -nr 's/^.*"Plaintext":\s*"(.*?)".*$/\1/p' data_key.json | base64 --decode > KEY_$environment-$repo_project.dec
    # delete the key
    rm -rf data_key.json
    
    cd $P_W_D
}


#######################################
function Get_data() {
	mkdir -p secure-data/$environment/$repo_project || echo "Directory already there"
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project
	aws s3 cp s3://$BUCKET_PREFIX-$repo_project-data/DATA_$environment-$repo_project.enc .
	cd $P_W_D
}


#######################################
function Decrypt_data() {
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project
	openssl enc -in DATA_$environment-$repo_project.enc -out DATA_$environment-$repo_project.dec -d -aes256 -kfile KEY_$environment-$repo_project.dec
	rm -rf DATA_$environment-$repo_project.enc
	cd $P_W_D
}





#######################################
function Pull_Key() {
	if aws s3 ls s3://$BUCKET_PREFIX-$repo_project-dek/ciphertext_blob_$environment-$repo_project.enc >/dev/null ; then
		echo "Encrypted file : ciphertext_blob_$environment-$repo_project.enc in S3 Bucket :$BUCKET_PREFIX-$repo_project-dek is already available"
        Get_cipher
		Get_key
	else
		echo "Assuming that you are initializing the new KEY Encryption for new module : $module"
		Create_key
	fi
}


#######################################
function Pull_Data() {
	Pull_Key
	if aws s3 ls s3://$BUCKET_PREFIX-$repo_project-data/DATA_$environment-$repo_project.enc >/dev/null ; then
		echo "Encrypted file : DATA_$environment-$repo_project.enc in S3 Bucket : $BUCKET_PREFIX-$repo_project-data is already available"
		Get_data
		Decrypt_data
		echo "Key rotation: creating new key"
		Create_key # key rotation
	else
		echo "repo_project is not found, assuming that you are initializing the new DATA Encryption for new module : $module"
		export P_W_D=$PWD ; cd secure-data/$environment/$repo_project
		echo $PWD
		touch DATA_$environment-$repo_project.dec
cat <<EOF > DATA_$environment-$repo_project.dec
# USER_NAME="DevOps"
EOF
		echo
		echo "Add secret data which need to be encrypt in file DATA_$environment-$repo_project.dec"
		echo
		echo "Once you update the file, run the script with enc_data ARG for encrypt the data"
		cd $P_W_D
	fi
}
		

#######################################
function Encrypt_Data() {
	if [[ -f  secure-data/$environment/$repo_project/KEY_$environment-$repo_project.dec ]]; then
		export P_W_D=$PWD ; cd secure-data/$environment/$repo_project

		openssl enc -in DATA_$environment-$repo_project.dec -out DATA_$environment-$repo_project.enc -e -aes256 -kfile KEY_$environment-$repo_project.dec

    	rm -rf KEY_$environment-$repo_project.dec DATA_$environment-$repo_project.dec
		cd $P_W_D
	else
		echo "pull data before encrypt"
	fi
}


#######################################
function Push_Data() {
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project
	if [[ -f  DATA_$environment-$repo_project.enc ]]; then
		if [[ -f  ciphertext_blob_$environment-$repo_project.enc ]]; then
	        aws s3 cp  DATA_$environment-$repo_project.enc s3://$BUCKET_PREFIX-$repo_project-data/
	        aws s3 cp  ciphertext_blob_$environment-$repo_project.enc s3://$BUCKET_PREFIX-$repo_project-dek/
			rm -rf ciphertext_blob_$environment-$repo_project.enc DATA_$environment-$repo_project.enc
		else
			echo "ciphertext_blob_$environment-$repo_project.enc not found"
		fi
	else
		echo "DATA_$environment-$repo_project.enc not found"
	fi
	cd $P_W_D
}





#######################################
#######################################
#######################################
function data_service_pem_create() {
	mkdir -p secure-data/$environment/$repo_project/DATA-Key || echo "Directory DATA-Key already there"
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DATA-Key
	echo "Creating DATA passpharse for $repo_project under namespace : $environment"
	if [[ -f key.pem ]]; then
		echo "Service Account pem file already there for DATA"
	else
		openssl req -x509 -newkey rsa:4096 -keyout key.pem -out extra-key.pem -days 365 -nodes -subj '/CN=DATA-$repo_project-`date +%S%s`'
		cat extra-key.pem >> key.pem ; rm -rf extra-key.pem
	fi
	cd $P_W_D
}


#######################################
function data_service_Account_enc() {
	data_service_pem_create
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DATA-Key
	echo "Encrypting DATA Service Account for $repo_project under namespace : $environment"
	if [[ -f  enc-secret.json ]]; then
		echo "You already have an encrypted Service Account file for DATA"
	else
		if [[ -f  secret.json ]]; then
			openssl enc -in secret.json -out enc-secret.json -e -aes256 -kfile key.pem
			echo "encoding key.pem"
			base64 key.pem > enc-key.pem
		else
			echo "Service Account file : secret.json  not found"
			echo "Creating Service account file - update the file with proper values"
			touch secret.json
cat <<EOF >secret.json
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=us-east-1
EOF
			exit 0
		fi
	fi
	cd $P_W_D
}




#######################################
function dek_service_pem_create() {
	mkdir -p secure-data/$environment/$repo_project/DEK-Key || echo "Directory DEK-Key already there"
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DEK-Key
	echo "Creating DEK passpharse for $repo_project under namespace : $environment"
	if [[ -f key.pem ]]; then
		echo "Service Account pem file already there for DEK"
	else
		openssl req -x509 -newkey rsa:4096 -keyout key.pem -out extra-key.pem -days 365 -nodes -subj '/CN=DEK-$repo_project-`date +%S%s`'
		cat extra-key.pem >> key.pem ; rm -rf extra-key.pem
	fi
	cd $P_W_D
}


#######################################
function dek_service_Account_enc() {
	dek_service_pem_create
	export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DEK-Key
	echo "Encrypting DEK Service Account for $repo_project under namespace : $environment"
	if [[ -f  enc-secret.json ]]; then
		echo "You already have an encrypted Service Account file for DEK"
	else
		if [[ -f  secret.json ]]; then
			openssl enc -in secret.json -out enc-secret.json -e -aes256 -kfile key.pem
			echo "encoding key.pem"
			base64 key.pem > enc-key.pem
		else
			echo "Service Account file : secret.json  not found"
			echo "Creating Service account file - update the file with proper values"
			touch secret.json
cat <<EOF >secret.json
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=us-east-1
EOF
			exit 0
		fi
	fi
	cd $P_W_D
}



#######################################
function cp_service_Account() {
	dest_location=../AccountKeys/$environment/$repo_project
	if [[ ! -z $dest_location ]]; then
		mkdir -p $dest_location/{DEK-Key,DATA-Key} || echo "key and data folders already available"
		if [[ -f  $dest_location/DEK-Key/enc-secret.json ]]; then
			echo "enc-secret.json file already in destination"
		else
			export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DEK-Key
			echo "copying encrypted DEK Service Account for $repo_project under namespace : $environment"
			echo "destination : $dest_location/DEK-Key"
			cp -r enc-secret.json $P_W_D/$dest_location/DEK-Key/
			cd $P_W_D
		fi
		###################
		if [[ -f  $dest_location/DATA-Key/enc-secret.json ]]; then
			echo "enc-secret.json file already in destination"
		else
			export P_W_D=$PWD ; cd secure-data/$environment/$repo_project/DATA-Key
			echo "copying encrypted DATA Service Account for $repo_project under namespace : $environment"
			echo "destination : $dest_location/DATA-Key"
			cp -r enc-secret.json $P_W_D/$dest_location/DATA-Key/
			cd $P_W_D
		fi
	else
		echo "Destination for data is not mentioned..."
	fi
}




while getopts ":o:b:e:m:" opt
   do
     case $opt in
        o ) option=$OPTARG;;
 		b ) AWS_Bucket=$OPTARG;;
        e ) environment=$OPTARG;;
        m ) module=$OPTARG;;
     esac
done




if [[ $option = pull ]]; then
	Get_Module
	Pull_Data
elif [[ $option = encrypt ]]; then
	Get_Module
	Encrypt_Data
elif [[ $option = push ]]; then
	Get_Module
	Push_Data
elif [[ $option = data-srv ]]; then
	Get_Module
	data_service_Account_enc
elif [[ $option = dek-srv ]]; then
	Get_Module
	dek_service_Account_enc
elif [[ $option = cp-srv ]]; then
	Get_Module
	cp_service_Account
else
	echo "$Command_Usage"
cat << EOF
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

Main modes of operation:

   pull 		: 	Pull the encrypted data and DEK from S3 Bucket if exist otherwise will create and Decrypt the downloaded data
   encrypt 		: 	Encrypt the updated data
   push 		: 	Push the encrypted data and DEK to S3 Bucket
   data-srv		:	Service Account encryption for DATA
   dek-srv		:	Service Account encryption for DEK
   cp-srv		:	Copy the encrypted Service account to destination
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
EOF
fi

