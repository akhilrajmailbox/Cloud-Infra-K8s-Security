#!/bin/bash

export AWS_ECR_ENDPOINT=$AWS_ECR_ENDPOINT

function prepare_artifacts() {
    echo "preparing repo_project : $repo_project by coping artifacts"
    # cp -f Dockerfile ../../$repo_project/
    envsubst < Dockerfile > ../../$repo_project/Dockerfile
    cp -f ../../secure-node-box/version/$repo_project/$K8S_NAMESPACE/VERSION ../../$repo_project/
}

function build() {
    echo "Building docker image $AWS_ECR_ENDPOINT/$K8S_NAMESPACE-$repo_project:$version for $repo_project"
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ../../$repo_project/.npmrc
    docker build --quiet --no-cache --build-arg NPM_TOKEN=${NPM_TOKEN} ../../$repo_project -t $AWS_ECR_ENDPOINT/$K8S_NAMESPACE-$repo_project:$version
    if [[ $? -ne 0 ]] ; then
      exit 1
    fi
    echo "Creating Docker image with tag : $version"
    docker push $AWS_ECR_ENDPOINT/$K8S_NAMESPACE-$repo_project:$version
    if [[ $? -ne 0 ]] ; then
      exit 1
    fi
}


function clean_image() {
    echo "Deleting Docker image with tag : $UPTO_VERSION"
    aws ecr batch-delete-image --region us-east-1 --repository-name $K8S_NAMESPACE-$repo_project --image-ids imageTag=$UPTO_VERSION
}

function repos_tag() {
    export P_W_D=$PWD
    if [[ ! -z "$sub_repo_project" ]]; then
      echo "sub_repo_project is mentioned for this project, assuming  $sub_repo_project is the actual repository"
      cd ../../$sub_repo_project
    else
      cd  ../../$repo_project
    fi
    git tag -a "$K8S_NAMESPACE-$repo_project-$version" -m "version $K8S_NAMESPACE-$repo_project-$version"
    git push origin : $K8S_NAMESPACE-$repo_project-$version

    echo "Deleting repository with tag : $K8S_NAMESPACE-$repo_project-$UPTO_VERSION"
    git tag -d $K8S_NAMESPACE-$repo_project-$UPTO_VERSION
    git push origin :refs/tags/$K8S_NAMESPACE-$repo_project-$UPTO_VERSION
    cd $P_W_D
}

prepare_artifacts && \
build && \
clean_image
repos_tag