#!/bin/bash
export Command_Usage="Usage: ./script-bucket-cmk-user.sh -e [Environment] -m [ModuleName]"


#######################################
function Get_Environment_Name() {
    if [[ -z $Environment ]]; then
cat << EOF
WARING
Choose the Environment

$Command_Usage
----------------------------
development
----------------------------
production
----------------------------
EOF
		exit 0
    else
		export Environment_Name=$Environment
	fi
}


#######################################
function Get_Module_Name() {
	Get_Environment_Name
    if [[ -z $ModuleName ]]; then
cat << EOF
WARING
Choose the ModuleName

$Command_Usage
----------------------------
full_modules
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
		export Module_Name=$ModuleName
	fi
}


#######################################
function Production_Modules() {
   Get_Module_Name
   if [[ $Module_Name == full_modules ]]; then
     modules_name=(
        "module-1"
        "module-2"
        "module-3")
   else
     modules_name=(
         "$Module_Name")
   fi

   for module_name in ${modules_name[@]}; do
     echo "These module_name are Configuring : $module_name"
   done
}



#######################################
function Cft_Create() {
   Production_Modules
   for module_name in ${modules_name[@]}; do
		aws cloudformation create-stack --stack-name $Environment_Name-$module_name \
		--template-body file://bucket-cmk-user.json --parameters \
		ParameterKey=Environment,ParameterValue=$Environment_Name \
		ParameterKey=Modulename,ParameterValue=$module_name \
		--capabilities CAPABILITY_NAMED_IAM
	done
}






while getopts ":e:m:" opt
   do
     case $opt in
        e ) Environment=$OPTARG;;
        m ) ModuleName=$OPTARG;;
     esac
done




Cft_Create

