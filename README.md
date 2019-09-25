# Cloud-Infra-K8s-Security

Use [draw.io](https://www.draw.io/) to open [Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Architecture)  and [Security](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Security)


## Samples

![Network](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/network.png)


1. public subnet : The pods and ingress which can be communicate from outside
2. private subnet : The pods  getting deploy on this network
3. backend subnet : The backend servers such as (Database servers, dependent servers) are being deploying on this network
4. reserved subnet : for future use (need to add this network while creating Kubernetes cluster)

![Subnet-Configuration](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/subnet-conf.png)

### Basic CI/CD Workflow and Architecture

![Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/cicd-workflow.png)

### Steps :

1. Developer push the  source code to GitHub
2. Jenkins Will trigger the build by cloning the latest code from GitHub
3. Jenkins job will create the docker images with source code and bump up the image version, push to Docker registry (Container Registry)
4. Jenkins job will tag the source code with exactly same version number which given for the image, push the source code back to GitHub with tag
5. Execute the Kubernetes commands for redeploy the pods with latest images
6. Redeployment process will start by download the latest image from image repository
7. This steps have multiple sub-steps (7.a, 7.b, 7.c.. etc), Deployment Consuming allocated resources from Kubernetes Cluster and from outside as well.
    1. ConfigMap in Kubernetes for storing non sensitive environment variables
    2. Storing Medium sensitive environment variables (encoded KMS related variables which used for encrypt and decrypt the highly sensitive data)
    3. Persistent volumes, S3 storages etc..
    4. Envelop encryption for highly sensitive data such as tokens, keys, passwords etc..
8. Creating a service for communicating with pods. (Initial steps for creating ingress)
9. Creating a load balancer, forwarding rules, and assigning external public ip address (Ingress configuration)
10. Clients accessing the products from outside (Public)



### Security Layer Overview for Encryption and Decryption

![KMS-overview](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/subnet-conf.png)


### Envelope Encryption and High Security

Envelope Encryption is an approach/process used within many applications to encrypt data. A request is sent to the KMS to generate a data key based on one of the master keys. KMS returns a data key, which usually contains both the plain text version and the encrypted version of the data key.

![KMS-Workflow](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/KMS-Workflow.png)

### Steps :

1. Download The Service Account Details (Creds) from GitHub Organization
2. With that Service Account, will download the Encrypted DEK (Data Encryption Key) from S3 Bucket
3. Each module have its own docker images
4. Each service account has its own KEK (Key Encryption Key) in S3 KMS, service account can access its own key not any other key.
5. By using the kms key, the DEK will decrypt to plain text with help of service Account
6. One piece of KEK is getting stored in Kubernetes cluster where all services are running, each services have its own second piece of data in Kubernetes the pod will fetch the second piece of password from cluster
7. The plain DEK not enough for decrypt the sensitive data, Actual DEK is sum of KEK and second piece of data from kubernetes
8. This actual DEK will decrypt the sensitive info inside docker container.

