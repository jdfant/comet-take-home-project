# Comet Take-Home Project
### Intended Audience:
*This document is designed for minimally technical users who need to perform a Terraform and Helm-based deployment on Amazon EKS leveraging Git Hooks.  
It provides step-by-step instructions and explanations to ensure users can follow along without requiring prior expertise in AWS cloud infrastructure, Kubernetes, or deployment automation.*  

*Please direct all questions to jd@jdfant.com*

## Goals
* Create a new repository with all necessary Infrastructure-as-Code components  
* Setup CI/CD tooling the repository  
* Demonstrate familiarity with Helm Charts  
* Demonstrate familiarity with Terraform  
* Demonstrate technical communication skills towards a minimally technical
audience  

## Workflow
* Terraform and/or Helm Chart Code changes are pushed to a dev branch, in the github repo.
* When a `git push` has been performed in the dev branch, the terraform or helm github action is triggered, depending on the changed contents. The github actions output will be generated to ensure everything looks correct. 
* Once the github actions jobs successfully completes, the Pull Request will be marked as `"Ready for Review"`. It is then fine to create a Pull github Request (PR).
* When the PR has been approved, the dev branch will be merged to the main branch, deploying all related code.
* Users can then follow the generated AWS Ingress URL to test that the deployment was successful. Instructions have also been provided to test connectivity between the nginx instance and the deployed postgresql instance from the Helm Sub-Chart.
---
### *NOTE:* *This code has NOT been deployed to a real account as it would be too expensive for this project*  
#### *terraform init and plan should complete with zero errors. A successful terraform apply is not guaranteed*  
#### *The Helm chart has been well tested and will function correctly if deployed into a local (non-AWS) kubernetes cluster*  
---  
## Instructions  
### Configure AWS Access
* Make sure you are configured to access an AWS account. For AWS *user accounts*, configuring 2 files will be necessary:  
*(Reach out to your AWS administrator if you do not know the correct values)*

`.aws/config:`   
```
[default]
region = us-west-2
```  
`.aws/credentials:`  
```
[default]
aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXX
```  
* If you are using SSO/SAML/OIDC methods for authorization, like Okta, Duo, Auth0, Jumpcloud, etc., then you probably already have access.  
*(Reach out to your AWS administrator for clarification or assistance)*

* Make sure that the `aws cli` tool is installed and test access to an AWS account.
  * Follow the official instructions to install the `aws cli` according to your platform:
    * https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  * After the `aws cli` tool has been installed. Test access to your AWS account.
    * Executing `aws sts get-caller-identity` should report back your 'UserID', 'Account', and your user 'ARN'.  

### Clone Github Repo, create and change to a 'dev' branch
* If you have created Github SSH Keys:
  * Execute: `git clone git@github.com:jdfant/comet-take-home-project.git`
* If you have not created a Github SSH Key:
  * Execute: `git clone https://github.com/jdfant/comet-take-home-project.git`  
* Navigate to the 'comet-take-home-project' directory and execute: `git checkout -b dev` or `git switch -c dev`. It should report that you have switched to a new branch, dev. 
### Adjust the terraform configuration, push the dev branch to github, and create a Pull Request
* Within the `comet-take-home-project` directory, navigate to the `terraform/eks` directory.  
  * Open the `local.tf` file in your favorite text editor. Only 2 fields will need to be changed and they are at the very top of the file.
    * Replace the `region` and `account` variables to match your AWS environment. Nothing else will need to be changed for this project.
* Now push the new branch to github create a Pull Request (PR) for this.
   * Execute: `git add -A`, then commit the repo with a note, `git commit -m "fix: updating account and region in local.tf"`
   * A remote 'dev' branch does not exist, use `git push --set-upstream origin dev` to push the newly committed code to the new 'dev' branch.
   * Pushing the dev branch will trigger a `terraform init` and `terraform plan`.
   * Monitor the github actions 'job' by selecting the `Actions` tab at the top of the page of the `comet-take-home-project` repo. Then select the `Workflow Run` you want to monitor. You will see a graph of individual jobs and their dependencies. To view a job's log, click the job. From there, you can view the output from individual steps.
* Once the github actions jobs successfully completes, the Pull Request will be marked as `"Ready for Review"`.
* When the Pull Request has been approved to merge to the main branch, this triggers the same exact github actions jobs that the initial push to dev performed. Except this time, `terraform apply` will be executed that will initiate building a complete AWS EKS Cluster. In this example, a 'dependent' job will run first that creates an S3 Bucket and DynamoDB tables for storing the terraform state file.  
*For this project, the state file for this terraform S3/DynamoDB build will be retained in github. This is not ideal nor secure*  
### Trigger the Helm Github Action Workflow
* There is really nothing to edit for the helm 'hello world' application deployment. In order to trigger the helm github action, I have created a file named, `trigger-file`. Just edit that file in any way, then repeat the "Now push the new branch to github create a Pull Request (PR) for this" section from above to initiate the helm deployment to the new EKS Cluster.  

## Testing deployed components and services
* The `kubectl` tool will need to be installed for the next steps.
  * Follow these instructions to install `kubectl`, according to your platform. https://kubernetes.io/docs/tasks/tools/#kubectl
* After the AWS EKS cluster has been created, you will need to setup kubectl in order to access any resources.
* In your terminal, execute the aws cli tool to create a configuration file for accessing the kubernetes cluster:
  * `aws eks update-kubeconfig --region your_region --name jd-fant-comet-project`
#### Test access to the cluster:
  * `kubectl cluster-info`
    * This should display the addresses of the control plane and other items.
* Once kubernetes access has been established, connect to the postgres pod from the nginx pod.  
*The postgresql 'helm subchart' is just there to prove postgresql functions and accessible.*
#### Test that the "Hello World" website has been deployed.
  * Executing `kubectl get service -n jd-helloworld -o jsonpath='{.items[*].status.loadBalancer.ingress[0].hostname}` will reveal the 'AWS Ingress URL'.
    * Open a web browser and go to the URL from the output of the above command. Example `http://my-ingress-1234567890.us-west-2.elb.amazonaws.com`.
    * If the "Hello World" page opens, this test is successful.
#### Test access to postgresql from the nginx pod:
  * `kubectl exec -n jd-helloworld -it $(kubectl get pods -n jd-helloworld -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep nginx) -- psql -h $(kubectl get services -n jd-helloworld | awk '/postgres/ && FNR == 3 {print $3}') -U testuser -d testdb`
  * This will prompt you for a password.  
    * Password is: `testpass`
  * If the above command is successful, you will enter the `postgresql interactive terminal` and will see:
    * `testdb=>`
  * Type: `\q` to exit the postgresql terminal. Testing pod to pod communications is complete.

## Congratulations!
* Terraform has created a complete AWS EKS cluster and the application has been deployed by Helm.  
* Testing has been verified that the deployments were successful.

## Repo Structure
```
├── README.md
├── github-actions
│   ├── README.md
│   ├── actions
│   │   ├── helm
│   │   │   └── action.yml
│   │   └── terraform
│   │       └── action.yml
│   └── workflows
│       ├── helm.yml
│       └── terraform.yml
├── helm
│   ├── README.md
│   └── helloworld
│       ├── Chart.lock
│       ├── Chart.yaml
│       ├── charts
│       │   └── postgresql-16.0.6.tgz
│       ├── templates
│       │   ├── NOTES.txt
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── hpa.yaml
│       │   ├── ingress.yaml
│       │   ├── service.yaml
│       │   ├── serviceaccount.yaml
│       │   └── tests
│       │       └── test-connection.yaml
│       ├── trigger-file
│       └── values.yaml
└── terraform
    ├── eks
    │   ├── README.md
    │   ├── eks_cluster.tf
    │   ├── example.tfstate
    │   ├── local.tf
    │   ├── output.tf
    │   ├── providers.tf
    │   └── vpc.tf
    └── remote_backend
        ├── README.md
        ├── backend.tf
        ├── local.tf
        ├── main.tf
        └── modules
            └── remote_backend
                ├── README.md
                ├── dynamo-locking
                │   ├── README.md
                │   ├── dynamo_locking.tf
                │   ├── outputs.tf
                │   └── variables.tf
                └── s3-remote-backend
                    ├── README.md
                    ├── outputs.tf
                    ├── policy.tf
                    ├── policy_data.tf
                    ├── s3_remote.tf
                    └── variables.tf