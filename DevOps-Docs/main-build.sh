#!/bin/bash
namespace_options=""
export K8S_NAMESPACE_REAL=$K8S_NAMESPACE
if [[ ! -z "${K8S_NAMESPACE}" ]] && [[ -d  ../secure-node-box ]] && [[ ! -z "${DEPLOY_ENV}" ]] ; then
  namespace_options="--namespace=$K8S_NAMESPACE"
  echo $namespace_options
  echo "secure-node-box present"

export VERSION_PERSIST=10
export repo_project_input=$DEPLOY_MODULE_NAME
export NPM_TOKEN="03dsgfewg-dsfdsfgvds-sdgvsdgv-dsgvds"

#######################################
echo "_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-"
echo "Module Build is : $DEPLOY_MODULE_NAME"
echo "_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-"

cat << EOF
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
DEVOPS_NOTICE ::

Mandatory Variables :

    K8S_NAMESPACE       =   Namespace Configuration
    VERSION_PERSIST     =   Howmany Docker Image and Tag version need to persist
    DEPLOY_ENV          =   To change the login credentilas for different GCP Projects
    DEPLOY_MODULE_NAME  =   Choose the module/full deplopyment for jenkins build

Optional Variables :

    RECONFIGURE_ENV     =   Reconfigure environment in kubernetes ConfigMap
    ROLLING_IMG_NO      =   Rolling back to previous Docker Image Version

DevOps Variables :

    REDEPLOY_MYSQL      =   Recreate Mysql databases with schema from respective repo_project
    REDEPLOY_REDIS      =   Redeploying Redis
    INSECURE            =   DevOps Secrets
    NO_IMG_DEL          =   DevOps Secrets

_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
EOF


#######################################
function repo_project_selection() {
   if [[ $DEPLOY_MODULE_NAME == full_deployment ]]; then
     repo_projects=(
        "module-1"
        "module-2"
        "module-3")
   else
     repo_projects=(
         "$repo_project_input")
   fi

   for repo_project in ${repo_projects[@]}; do
     echo "These repo_projects are deploying : $repo_project"
   done
}



#######################################
function login() {
  git config --global user.email "jenkins@mymail.com"
  git config --global user.name "Jenkins"

  if [[ $DEPLOY_ENV == production ]] ; then
      export AWS_ECR_ENDPOINT=000000000000.dkr.ecr.us-east-1.amazonaws.com
      #aws eks update-kubeconfig --name --region us-east-1 production-prod-cluster
      $(aws ecr get-login --no-include-email --region us-east-1)
  elif [[ $DEPLOY_ENV == development ]] ; then
      export AWS_ECR_ENDPOINT=000000000000.dkr.ecr.us-east-1.amazonaws.com
      #aws eks update-kubeconfig --name --region us-east-1 production-dev-cluster
      $(aws ecr get-login --no-include-email --region us-east-1)
  else
    echo "DEVOPS_NOTICE :: No DEPLOY_ENV matches"
    exit 1
  fi
}


#######################################
function initial_env() {
  # jenkins and console variables
  find $WORKSPACE -name *.sh -exec chmod a+x {} \;
  export P_W_D=$PWD ; cd $WORKSPACE/secure-node-box
  chmod 744 conf/${K8S_NAMESPACE}/initial.sh
  source ./conf/${K8S_NAMESPACE}/initial.sh
  echo "sourcing the initial.sh done"
  env | grep _replicas

  # Entrypoint for all modules
  if [[ -f conf/${K8S_NAMESPACE}/BackBone.sh ]] ; then
    chmod 744 conf/${K8S_NAMESPACE}/BackBone.sh
    source ./conf/${K8S_NAMESPACE}/BackBone.sh
    echo "sourcing the BackBone.sh done"
    env | grep _backbone
  else
    echo "DEVOPS_NOTICE :: BackBone file is missing......!"
  fi
  cd $P_W_D
}


#######################################
function cdn_data() {
  export WEB_DISTRIBUTION_ID=""
  export ADMIN_DISTRIBUTION_ID=""
  if [[ $K8S_NAMESPACE ==  production-prod ]]; then
    export WEB_DISTRIBUTION_ID="000000000000"
    export ADMIN_DISTRIBUTION_ID="000000000000"
  elif [[ $K8S_NAMESPACE ==  production-stage ]]; then
    export WEB_DISTRIBUTION_ID="000000000000"
    export ADMIN_DISTRIBUTION_ID="000000000000"
  elif [[ $K8S_NAMESPACE ==  production-develop ]]; then
    export WEB_DISTRIBUTION_ID="000000000000"
    export ADMIN_DISTRIBUTION_ID="000000000000"
  elif [[ $K8S_NAMESPACE ==  production-test ]]; then
    export WEB_DISTRIBUTION_ID="000000000000"
    export ADMIN_DISTRIBUTION_ID="000000000000"
  else
    export WEB_DISTRIBUTION_ID="Invalid"
    export ADMIN_DISTRIBUTION_ID="Invalid"
  fi
}


#######################################
function setup_env() {
  # kubernetes pods variables
  export P_W_D=$PWD ; cd $WORKSPACE/secure-node-box
  if [ "$RECONFIGURE_ENV" = true ] ; then

      if [[ -f conf/${K8S_NAMESPACE}/ConfigMap/production-common-ConfigMap.yaml ]]; then
        kubectl $namespace_options apply -f conf/${K8S_NAMESPACE}/ConfigMap/production-common-ConfigMap.yaml
      else
        echo "DEVOPS_NOTICE :: production-common-ConfigMap.yaml not found for ${K8S_NAMESPACE}"
      fi

      for repo_project in ${repo_projects[@]}; do
        export repo_project=$repo_project
        echo "DEVOPS_NOTICE :: Reconfiguring Kubernetes ConfigMap for $repo_project"

        if [[ -f conf/${K8S_NAMESPACE}/ConfigMap/$repo_project-ConfigMap.yaml ]]; then
          echo "DEVOPS_NOTICE :: Environment variables Configuration for $repo_project in ${K8S_NAMESPACE} namespace found"
          envsubst < conf/${K8S_NAMESPACE}/ConfigMap/$repo_project-ConfigMap.yaml    |    kubectl $namespace_options apply -f -
        else
          echo "DEVOPS_NOTICE :: $repo_project-ConfigMap.yaml not found for ${K8S_NAMESPACE}"
        fi

        if [[ -d conf/${K8S_NAMESPACE}/FromFiles/$repo_project ]]; then
            kubectl $namespace_options delete configmap $repo_project --wait
            kubectl $namespace_options create configmap $repo_project --from-file=conf/${K8S_NAMESPACE}/FromFiles/$repo_project
        fi
      done
  else
      echo "DEVOPS_NOTICE :: Kubernetes ConfigMap will not update for this build"
  fi

  for repo_project in ${repo_projects[@]}; do
    export repo_project=$repo_project
    if [[ -f conf/${K8S_NAMESPACE}/JenkinsEnv/production-common.sh ]] ; then
        source conf/${K8S_NAMESPACE}/JenkinsEnv/production-common.sh
    else
        echo "DEVOPS_NOTICE :: production-common.sh not found for ${K8S_NAMESPACE}"
    fi
    if [[ -f conf/${K8S_NAMESPACE}/JenkinsEnv/$repo_project.sh ]] ; then
        echo "JenkinsEnv updating for $repo_project with $repo_project.sh and production-common.sh"
        source conf/${K8S_NAMESPACE}/JenkinsEnv/$repo_project.sh
    else
        echo "DEVOPS_NOTICE :: $repo_project.sh not found for ${K8S_NAMESPACE}"
    fi
  done

  cd $P_W_D
}


#######################################
function show_env() {
  echo ""
  echo "DEVOPS_NOTICE :: The environmental variables from cicd repo :: "
  echo ""

  env
}


#######################################
function mysql_import() {
 if [ "$REDEPLOY_MYSQL" = true ] ; then
    echo "Recreating MYSQL databases"
    mysql_datas=(
      "database_1"
      "database_2"
      "database_3")

    for repo_project in ${repo_projects[@]}; do
      for mysql_data in ${mysql_datas[@]}; do
          if [[ -f ../$repo_project/$mysql_data.sql ]] ; then
            echo "DEVOPS_NOTICE :: $mysql_data.sql file is there...."
            mysql -u $DEV_MYSQL_USER -h $DEV_MYSQL_HOST -p$DEV_MYSQL_PASS -e "drop database $mysql_data" > /dev/null && echo "database $mysql_data deleted.." || echo "No database found with name $mysql_data"
            mysql -u $DEV_MYSQL_USER -h $DEV_MYSQL_HOST -p$DEV_MYSQL_PASS < ../$repo_project/$mysql_data.sql;
          else
            echo "DEVOPS_NOTICE :: $mysql_data.sql file not found...."
          fi
      done
    done
 else
   echo "DEVOPS_NOTICE :: No need to Recreate MYSQL databases"
 fi
}


#######################################
function version_manage() {

      export P_W_D=$PWD ; cd $WORKSPACE/secure-node-box
      if [[ -d version/$repo_project/$K8S_NAMESPACE ]]; then
        echo "DEVOPS_NOTICE :: version for $repo_project in $K8S_NAMESPACE namespace is exist"
      else
        echo "DEVOPS_NOTICE :: creating version files for $repo_project in $K8S_NAMESPACE namespace"
        mkdir -p version/$repo_project/$K8S_NAMESPACE
        echo "# Don't edit the VERSION file manually" > version/$repo_project/$K8S_NAMESPACE/VERSION
        echo "1.0.0" >> version/$repo_project/$K8S_NAMESPACE/VERSION
      fi

      cd version/$repo_project/$K8S_NAMESPACE/
      docker run --rm -v "$PWD":/app akhilrajmailbox/bump PATCH &> /dev/null

      PATCH_CURRENT_VERSION=$(cat VERSION | tail -1 | cut -d "." -f3)
      PATCH_UPTO_VERSION=$(expr $PATCH_CURRENT_VERSION - $VERSION_PERSIST)
      export CURRENT_VERSION=1.0.$PATCH_CURRENT_VERSION
      export UPTO_VERSION=1.0.$PATCH_UPTO_VERSION
      export version=$CURRENT_VERSION

      echo "DEVOPS_NOTICE :: Current Version is : $version"
      echo "DEVOPS_NOTICE :: Older Version : $UPTO_VERSION will get deleted"
      cd $P_W_D
}


#######################################
function get_version() {
			if [[ $1 == "create" ]] ; then
				echo "DEVOPS_NOTICE :: bumping up version for $repo_project under environment : $K8S_NAMESPACE"
        version_manage
      else
        echo "DEVOPS_NOTICE :: Using existing Docker image for $repo_project under environment : $K8S_NAMESPACE"
      fi

      export P_W_D=$PWD ; cd $WORKSPACE/secure-node-box
      if [[ ! -z "$ROLLING_IMG_NO" ]] ; then
        if [[ $ROLLING_IMG_NO == "custom" ]] ; then
          echo "DEVOPS_NOTICE :: CUSTEM_VERSION is specified, Choosing Docker image version > $ROLLING_IMG_NO"
          export version=$ROLLING_IMG_NO
        else
          echo "The Rolling Image number is : $ROLLING_IMG_NO "
          echo "The Image Version saving in docker registry is : $VERSION_PERSIST "

          if [[ $ROLLING_IMG_NO -gt $VERSION_PERSIST ]] ; then
            echo "DEVOPS_NOTICE :: The Rolling Image number (ROLLING_IMG_NO) can't be greater than The Image Version saving in docker registry"
            exit 0
          else
            cd version/$repo_project/$K8S_NAMESPACE/
            GET_PATCH_CURRENT_VER=$(cat VERSION | tail -1 | cut -d "." -f3)
            GET_PATCH_UPDATE_VER=$(expr $GET_PATCH_CURRENT_VER - $ROLLING_IMG_NO)
            export GET_CURRENT_VER=1.0.$GET_PATCH_UPDATE_VER
            export version=$GET_CURRENT_VER
            echo "The latest Image version is : $(cat VERSION | tail -1)"
            echo "The Image version is being deploying : $version"
          fi
        fi
      else
        export version=$(cat version/$repo_project/$K8S_NAMESPACE/VERSION | tail -1)
        echo "DEVOPS_NOTICE :: The Image version is being deploying : $version"
      fi
    cd $P_W_D
}


#######################################
function conf_serv_account() {
  if [[ -d ../secure-node-box/AccountKeys/$K8S_NAMESPACE/$repo_project ]]; then
    if [[ -d ../$repo_project/ ]]; then
      echo "DEVOPS_NOTICE :: Configuring service account on repo_project $repo_project outside cicd"
      cp -r ../secure-node-box/AccountKeys/$K8S_NAMESPACE/$repo_project ../$repo_project/
    else
      echo "DEVOPS_NOTICE :: Configuring service account on repo_project $repo_project within cicd"
      cp -r ../secure-node-box/AccountKeys/$K8S_NAMESPACE/$repo_project $repo_project/
      cp -r ../secure-node-box/DevOps-tools/base-img/initial_start.sh $repo_project/
    fi
  else
    echo "DEVOPS_NOTICE :: conf_serv_account can not configured, directory ../secure-node-box/AccountKeys/$K8S_NAMESPACE/$repo_project is missing"
  fi
}


#######################################
function conf_backbone() {
  chmod a+x $WORKSPACE/production-cicd/sources/modules-entrypoint.sh
  if [[ -d ../$repo_project/ ]]; then
    echo "DEVOPS_NOTICE :: Configuring PM2 Entrypoint on repo_project $repo_project outside cicd"
    cp -r $WORKSPACE/production-cicd/sources/modules-entrypoint.sh ../$repo_project/
  else
    echo "DEVOPS_NOTICE :: Configuring PM2 Entrypoint on repo_project $repo_project within cicd"
    cp -r $WORKSPACE/production-cicd/sources/modules-entrypoint.sh ../$repo_project/
  fi
}


#######################################
function build_image() {
  S3_build_precheck
  #clean up all the images
  if [[ $NO_IMG_DEL = true ]] ; then
      echo "DEVOPS_NOTICE :: NO_IMG_DEL is enabled... can not delete docker images"
  else
      docker rmi -f $(docker images -a -q)
  fi
  docker pull $AWS_ECR_ENDPOINT/base-img:latest
  for repo_project in ${repo_projects[@]}; do
    get_version create
    conf_serv_account
    conf_backbone
    echo "building repo_project $repo_project"
    cd $repo_project 
    source ./build.sh
    cd ..
  done
}



#######################################
function S3_build_precheck() {
    if [[ $K8S_NAMESPACE == production-develop ]] || [[ $K8S_NAMESPACE == production-test ]] && [[ $repo_project = production-web-exchange ]] || [[ $repo_project = production-web-admin-panel ]] ; then
        if aws s3 ls s3://$K8S_NAMESPACE-$repo_project 2>/dev/null ; then
            echo "DEVOPS_NOTICE :: $K8S_NAMESPACE-$repo_project present...!"
        else
            echo "DEVOPS_NOTICE :: The specified bucket does not exist or you don't have permission : $K8S_NAMESPACE-$repo_project"
            exit 1
        fi
    fi
}


#######################################
function S3_build() {
    get_version
    if [[ $K8S_NAMESPACE == production-develop ]] || [[ $K8S_NAMESPACE == production-test ]] && [[ $repo_project = production-web-exchange ]] || [[ $repo_project = production-web-admin-panel ]] ; then
        if aws s3 ls s3://$K8S_NAMESPACE-$repo_project 2>/dev/null ; then
            mkdir -p $WORKSPACE/$K8S_NAMESPACE-$repo_project
            aws s3 cp --recursive s3://$K8S_NAMESPACE-$repo_project $WORKSPACE/$K8S_NAMESPACE-$repo_project/
            if [[ -d $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp ]] ; then
                echo "BackUp Folder present....!"
            else
                mkdir $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp
                echo "Don't touch this folder" > $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp/README.md
            fi
            if [[ ! -z "$ROLLING_IMG_NO" ]] ; then
                if ls $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp/$version ; then
                  echo "DEVOPS_NOTICE :: going back to $version ...!"
                  aws s3 rm --recursive s3://$K8S_NAMESPACE-$repo_project/live
                  rm -rf $WORKSPACE/$K8S_NAMESPACE-$repo_project/live
                  cp -r $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp/$version $WORKSPACE/$K8S_NAMESPACE-$repo_project/live
                else
                  echo "DEVOPS_NOTICE :: $version not found...!"
                  exit 1
                fi
            else
                echo "DEVOPS_NOTICE :: Creating latest version : $version...!"
                if [[ -d $WORKSPACE/$repo_project/build ]] ; then
                    aws s3 rm --recursive s3://$K8S_NAMESPACE-$repo_project/live
                    rm -rf $WORKSPACE/$K8S_NAMESPACE-$repo_project/live
                    echo "DEVOPS_NOTICE :: Version $UPTO_VERSION will get deleted...!"
                    aws s3 rm --recursive s3://$K8S_NAMESPACE-$repo_project/BackUp/$UPTO_VERSION
                    rm -rf $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp/$UPTO_VERSION
                    cp -r $WORKSPACE/$repo_project/build $WORKSPACE/$K8S_NAMESPACE-$repo_project/live
                    cp -r $WORKSPACE/$K8S_NAMESPACE-$repo_project/live $WORKSPACE/$K8S_NAMESPACE-$repo_project/BackUp/$version
                else
                    echo "DEVOPS_NOTICE :: latest build for verison : $version under $WORKSPACE/$repo_project/build not found...!"
                    exit 1
                fi
            fi
            echo "DEVOPS_NOTICE :: pushing latest version to S3 : $K8S_NAMESPACE-$repo_project for module : $repo_project"
            aws s3 cp --recursive $WORKSPACE/$K8S_NAMESPACE-$repo_project s3://$K8S_NAMESPACE-$repo_project/
        else
            echo "DEVOPS_NOTICE :: The specified bucket does not exist or you don't have permission : $K8S_NAMESPACE-$repo_project"
            exit 1
        fi
    fi
}



#######################################
function deploy() {   
    for repo_project in ${repo_projects[@]}; do
      if [[ $K8S_NAMESPACE == production-develop ]] || [[ $K8S_NAMESPACE == production-test ]] && [[ $repo_project = production-web-exchange ]] || [[ $repo_project = production-web-admin-panel ]] ; then
          echo "DEVOPS_NOTICE :: Pushing live web data to S3 for $repo_project from another function"
      else
          echo "DEVOPS_NOTICE :: Creating deployment $repo_project in kubernetes namespace : $K8S_NAMESPACE"
          export repo_project=$repo_project
          export DeploymentTime=$(date +%F--%H-%M-%S--%Z)
          
          if [[ ! -z "$K8S_NAMESPACE_IMG" ]]; then
            echo "K8S_NAMESPACE_IMG is mentioned"
            export K8S_NAMESPACE_REAL=$K8S_NAMESPACE
            export K8S_NAMESPACE=$K8S_NAMESPACE_IMG
            echo "DEVOPS_NOTICE :: K8S_NAMESPACE is updated temporarily for using K8S_NAMESPACE specified docker image"
          else
            echo "DEVOPS_NOTICE :: K8S_NAMESPACE_IMG is not mentioned"
          fi
          get_version
          cd K8s-Infra
          echo "repo_project $repo_project using docker image $AWS_ECR_ENDPOINT/$K8S_NAMESPACE-$repo_project:$version"
          #ensure environment variables are replaced before creating the deployment
          echo "DEVOPS_NOTICE :: Deploying $repo_project"

            if [ "$repo_project" = production-mda-producer ] ; then

              PRODUCER_SUFFIXS=(
                "1"
                "2"
                "3"
                "4")

                  for PRODUCER_SUFFIX in ${PRODUCER_SUFFIXS[@]}; do
                    export PRODUCER_SUFFIX=$PRODUCER_SUFFIX
                    echo "DEVOPS_NOTICE :: PRODUCER_SUFFIX is $PRODUCER_SUFFIX"
                    eval unique_repo_project=$repo_project-$PRODUCER_SUFFIX
                    export unique_repo_project=$unique_repo_project
                    export LOG_ES_INDEX="$K8S_NAMESPACE_REAL-$unique_repo_project-es"

                    echo "DEVOPS_NOTICE :: LOG_ES_INDEX is : $LOG_ES_INDEX"
                    echo ""
                    envsubst < K8s-Deployment/$repo_project-deployment.yaml
                    echo ""
                    if kubectl get pods $namespace_options | grep $unique_repo_project >/dev/null ; then
                      envsubst < K8s-Deployment/$repo_project-deployment.yaml    |    kubectl $namespace_options replace -f -
                    else
                      envsubst < K8s-Deployment/$repo_project-deployment.yaml    |    kubectl $namespace_options apply -f -
                    fi
                  done

            else
                  export LOG_ES_INDEX="$K8S_NAMESPACE_REAL-$repo_project-es"
                  echo "DEVOPS_NOTICE :: LOG_ES_INDEX is : $LOG_ES_INDEX"
                  echo "DEVOPS_NOTICE :: Deployment for $repo_project available and is being deploying"
                  echo ""
                  envsubst < K8s-Deployment/$repo_project-deployment.yaml
                  echo ""
                  if kubectl get pods $namespace_options | grep $repo_project >/dev/null ; then
                    envsubst < K8s-Deployment/$repo_project-deployment.yaml    |    kubectl $namespace_options replace -f -
                  else
                    envsubst < K8s-Deployment/$repo_project-deployment.yaml    |    kubectl $namespace_options apply -f -
                  fi
            fi

            # Service Configuration for each modules 
            if kubectl get services $namespace_options | grep $repo_project >/dev/null ; then
                echo "DEVOPS_NOTICE :: Service for $repo_project available in environment : $K8S_NAMESPACE"
            else
                if [[ -f K8s-Service/$repo_project-service.yaml ]]; then
                    echo "DEVOPS_NOTICE :: Service for $repo_project is available and is being Configuring"
                    envsubst < K8s-Service/$repo_project-service.yaml
                    envsubst < K8s-Service/$repo_project-service.yaml    |    kubectl $namespace_options apply -f -
                else
                    echo "DEVOPS_NOTICE :: K8s-Service/$repo_project-service.yaml not found"
                fi
            fi

          cd ..
          if [[ ! -z "$K8S_NAMESPACE_IMG" ]]; then
            echo "DEVOPS_NOTICE :: K8S_NAMESPACE_IMG is mentioned"
            export K8S_NAMESPACE=$K8S_NAMESPACE_REAL
            echo "DEVOPS_NOTICE :: K8S_NAMESPACE is updated back to real"
            echo "DEVOPS_NOTICE :: The namespace is : $K8S_NAMESPACE"
          else
            echo "DEVOPS_NOTICE :: K8S_NAMESPACE_IMG is not mentioned"
          fi
      fi
    done
}


#######################################
function mail_content() {
# Default Content :: ${FILE, path="$WORKSPACE/production-cicd/sources/mail_content.html"}
  export P_W_D=$PWD ; cd $WORKSPACE/production-cicd/sources/Jenkins-Notice
  chmod a+x jenkins_mail.sh
  source ./jenkins_mail.sh
  cd $P_W_D
}


#######################################
function version_commit() {
  if [[ $ROLLING_IMG_NO == "custom" ]] ; then
    echo "DEVOPS_NOTICE :: Version is Custom so version is not commiting to secure node box....!!!"
  else
    export P_W_D=$PWD ; cd $WORKSPACE/secure-node-box
    git status
    export CICD_BRANCH_NAME=$(git show-ref | grep $(git rev-parse HEAD) | grep remotes | grep -v HEAD | sed -e 's/.*remotes.origin.//')
    echo "DEVOPS_NOTICE :: Pushing the updated version to branch :: $CICD_BRANCH_NAME"
    for repo_project in ${repo_projects[@]}; do
      get_version
      cd $WORKSPACE/secure-node-box
      git add version/$repo_project
      git commit -m "$K8S_NAMESPACE :: Ver=$version, Branch=$CICD_BRANCH_NAME, Module=$repo_project"
      echo "DEVOPS_NOTICE :: For namespace : $K8S_NAMESPACE , Jenkins updates image version : $version on branch : $CICD_BRANCH_NAME for cosfinex module : $repo_project"
    done
    git pull origin $CICD_BRANCH_NAME
    git push origin HEAD:$CICD_BRANCH_NAME
    cd $P_W_D
  fi
}


#######################################
function cdn_invalidation() {
  cdn_data
  for repo_project in ${repo_projects[@]}; do
    if [[ $repo_project == production-web-exchange ]] ; then
      aws cloudfront create-invalidation --distribution-id $WEB_DISTRIBUTION_ID --paths "/*"
    elif [[ $repo_project == production-web-admin-panel ]] ; then
      aws cloudfront create-invalidation --distribution-id $ADMIN_DISTRIBUTION_ID --paths "/*"
      echo "DEVOPS_NOTICE :: Building $repo_project, Successfully performed the Cloudfront invalidation"
    else
      echo "DEVOPS_NOTICE :: repo_project is not production-web-exchange or production-web-admin-panel, avoding the task :: Cloudfront invalidation"
    fi
  done
}



#######################################
function Job_Exec() {
    if [[ ! -z $API_USER ]] && [[ ! -z $API_KEY ]] && [[ ! -z $JOB_TOKEN ]] ; then
        for repo_project in ${repo_projects[@]}; do
            NO_IMG_DEL=true
            DEPLOY_MODULE_NAME=$repo_project
            echo "DEVOPS_NOTICE :: This repo_project is being deploying as new jenkins job : $repo_project"
            curl -d "NO_IMG_DEL=$NO_IMG_DEL&K8S_NAMESPACE=$K8S_NAMESPACE&REDEPLOY_MYSQL=$REDEPLOY_MYSQL&REDEPLOY_REDIS=$REDEPLOY_REDIS&RECONFIGURE_ENV=$RECONFIGURE_ENV&ROLLING_IMG_NO=$ROLLING_IMG_NO&DEPLOY_ENV=$DEPLOY_ENV&DEPLOY_MODULE_NAME=$DEPLOY_MODULE_NAME&INSECURE=$INSECURE&CONFIGMAP_ONLY=$CONFIGMAP_ONLY" \
                --user $API_USER:$API_KEY \
                -X POST $JOB_URL/buildWithParameters?token=$JOB_TOKEN
        done
    else
        echo "API_USER and/or API_KEY and/or JOB_TOKEN is/are missing....!"
        exit 1
    fi


JOB_STATUS_URL=${JOB_URL}/lastBuild/api/json
JENKINS_RETURN_CODE=0

# Poll every thirty seconds until the build is finished
while [ $JENKINS_RETURN_CODE -eq 0 ]
do
    sleep 10
    # Grep will return 0 while the build is running:
    curl --silent  --user $API_USER:$API_KEY $JOB_STATUS_URL | grep result\":null > /dev/null
    JENKINS_RETURN_CODE=$?
done

echo Build finished
}


#######################################
#######################################

if [[ $K8S_NAMESPACE == production-stage ]] || [[ $K8S_NAMESPACE == production-stage-mda ]] ; then
        if [[ $DEPLOY_MODULE_NAME == full_deployment ]] ; then
            repo_project_selection && \
            Job_Exec
        else
            if [[ ! -z "$ROLLING_IMG_NO" ]] ; then
                repo_project_selection && \
                login && \
                initial_env && \
                setup_env && \
                show_env && \
                mail_content
            else
                repo_project_selection && \
                login && \
                initial_env && \
                setup_env && \
                show_env && \
                build_image && \
                mail_content && \
                version_commit
            fi
        fi
else
        if [[ $DEPLOY_MODULE_NAME == full_deployment ]] && [[ $CONFIGMAP_ONLY = false ]] ; then
            repo_project_selection && \
            Job_Exec
        else
            if [[ ! -z "$ROLLING_IMG_NO" ]] && [[ $CONFIGMAP_ONLY = false ]] ; then
                repo_project_selection && \
                login && \
                initial_env && \
                setup_env && \
                show_env && \
                S3_build && \
                # mysql_import && \
                deploy && \
                cdn_invalidation && \
                mail_content
            elif [[ $CONFIGMAP_ONLY = true ]] ; then
                repo_project_selection && \
                login && \
                setup_env
            else
                repo_project_selection && \
                login && \
                initial_env && \
                setup_env && \
                show_env && \
                build_image && \
                S3_build && \
                # mysql_import && \
                deploy && \
                cdn_invalidation && \
                mail_content && \
                version_commit
            fi
        fi
fi

else
  echo "K8S_NAMESPACE, DEPLOY_ENV and secure-node-box need to provide"
  echo "task aborting.....!"
  exit 1
fi
