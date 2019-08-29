# Cloud-Infra-K8s-Security

Use [draw.io](https://www.draw.io/) to open [Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Architecture)  and [Security](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Security)


## Samples


### Basic CI/CD Workflow and Architecture

![Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/cicd-workflow.png)



    1. Developer push the  source code to GitHub
    2. Jenkins Will trigger the build by cloning the latest code from GitHub
   * Jenkins job will create the docker images with source code and bump up the image version, push to Docker registry (Copntainer Registry)
   * Jenkins job will tag the source code with exactly same version number which given for the image, push the source code back to GitHub with tag
   * Execute the kubernetes commands for redeploy the pods with latest images
   * Redeployment process will start by download the latest image from image repository
   * This steps have multiple sub-steps (7.a, 7.b, 7.c.. etc), Deployment Consuming allocated resources from Kubernetes Cluster and from outside as well.
      a. ConfigMap in Kubernetes for storing non sensitive environment variables
      * Storing Medium sensitive environment variables (encoded KMS realted variables which used for encrypt and decrypt the highly sensitive data)
      * Persistent volumes, S3 storages etc..
      * Envelop encription for hignly sensitive data such as tokens, keys, passwords etc..
   * Creating a service for communicating with pods. (Initial steps for creating ingress)
   * Creating a loadbalancer, forwarding rules, and assinging external public ip address (Ingress configuration)
   * Clients accessing the products from outside (Public)



### Security Layer Overview for Encryption and Decryption

![KMS-overview](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/KMS-overview.png)


### Envelope Encryption and High Security

Envelope Encryption is an approach/process used within many applications to encrypt data. A request is sent to the KMS to generate a data key based on one of the master keys. KMS returns a data key, which usually contains both the plain text version and the encrypted version of the data key.



![KMS-Workflow](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/KMS-Workflow.png)
