# Cloud-Infra-K8s-Security

Use [draw.io](https://www.draw.io/) to open [Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Architecture)  and [Security](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/tree/master/Security)


## Samples


### Basic CI/CD Workflow and Architecture

![Architecture](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/cicd-workflow.png)


### Security Layer Overview for Encryption and Decryption

![KMS-overview](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/KMS-overview.png)


### Envelope Encryption and High Security

Envelope Encryption is an approach/process used within many applications to encrypt data. A request is sent to the KMS to generate a data key based on one of the master keys. KMS returns a data key, which usually contains both the plain text version and the encrypted version of the data key.



![KMS-Workflow](https://github.com/akhilrajmailbox/Cloud-Infra-K8s-Security/blob/master/Snapshots/KMS-Workflow.png)
