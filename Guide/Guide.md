
<h1>installation Guide</h1><br />


<h2>AWS Services Minimal Configuration</h2><br />
=================================================

## Before Proceeding: We'll Be verifying the next tools are installed:
awscliv1, awscliv2, aws-authenticator


<h2>Creating & Managing The IAM User</h2><br />
================================================

### Step One: 
we'll Creating a User(Recommended: Non-Root) for lab purpurses only, Named LabAdmin.

### Step Two: 
- By Finding & Applying The Role name "arn:aws:iam::aws:policy/AdministratorAccess" To your 
awscli/console Well Grant our User The minimun Prevliges & Roles for the upcoming Tasks:

- Creating an EC2 Instance
- Connecting to our Instances and apply changes via ssh
- Creating an EKS Cluster
- Monitor & Manage our VPC 
- Manage our Storage
- Monitor 3rd Party applications

You could also Apply this Prevliges by running a policy.json file

- If You're Using a console: Copy & Past your User.csv details
- If Your Using The aws cli: Extract it to a hiddden location

### Step Three : We Proceed by configuring our user's identity

### StepFour : 
- Run the following command in your terminal followed by your details:
- 
$ aws configure 
AWS Access Key ID [****************_nSm]: MY_AWS_Access_Key_ID_NUMBER
AWS Secret Access Key [****************NIr2]: MY_AWS_Secret_Access_Key_MUMBER
Default region name [MY_REGION]:
Default output format [Default_OUTPUT]:

### Step Five : 
- verify your IAM user access:
 
$ aws iam get-account-summary
you can add ">> my_user_account-summary.json/yaml" to extract into a local file

Deploying an EC2 Instace
#### Before Proceeding: We'll Be validating we have the next tools:

- kubectle
- eksctl

### Step One : 
- launch The Free Ties Amazon Linux2

$ aws ec2 run-instances --image-id 'ami-xxxxxxxx' --count 1 --instance-type t2.micro --key-name 'MyKeyPair' --security-group-ids 'sg-903004f8' --subnet-id 'subnet-6e7f829e'

### Step Two : 
- Add Tag to your Device:

$ aws ec2 create-tags --resources i-5203422c --tags Key=Name,Value=MyInstance_Name

### Step Three : 
- Extract your KeyPair: 

$ aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem

### Step Four: 
- Use the following command to set the permissions of your private key file so that 
only you can read it:

$ chmod 600 my-key-pair.pem

#### Now That Our EC2 is up & running we are ready to connect to it via ssh using our key-pair

### Step Five : 
- Run The Following Command:

$  ssh -i "my_key_pair.pem" my_ec2-user@my_ec2_instace_id.my_aws_zone.compute.amazonaws.com

- And then run the Following Commands:

$ sudo yum update

- In the command line window, check the AWS CLI version:

$ aws --version

- Download v2:

$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

- Unzip the file:

$ unzip awscliv2.zip

- See where the current AWS CLI is installed:

$ which aws
/usr/bin/aws

Update it:

$ sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/bin/aws-cli --update

- You can now run: /usr/bin/aws --version

$ aws --version
aws-cli/2.2.20 Python/3.8.8 Linux/4.14.232-177.418.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off

### Step Six : 
- Configure the CLI

$ aws configure
- For AWS Access Key ID, paste in the access key ID you copied earlier.
- For AWS Secret Access Key, paste in the secret access key you copied earlier.
- For Default region name, enter eu-west-1.
- For Default output format, enter json.

### Step Seven : 
Download kubectl

$ curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl

- Apply execute permissions to the binary:

$ chmod +x ./kubectl

- Copy the binary to a directory in your path:

$ mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

- Ensure kubectl is installed:

$ kubectl version --short --client
Client Version: v1.20.4-eks-6b7464

### Step Eight : 
Download eksctl

$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

- Move the extracted binary to /usr/bin:

$ sudo mv /tmp/eksctl /usr/bin

- Get the version of eksctl:

$ eksctl version
0.57.0

## Provision an EKS Cluster

In This Example we will demonstrate how to provision an AWS Stack Using Three Great Tools:
- AWS CloudFormation
- Terraform & Ansible

#### Objectives:

- Launching & Setting an EC2 Instace that will help us during the EKS Cluster provisioning
- Use S3API As our Backend Service 
- Create a VPC with 3 AZ(or more), Including Subnets and Rules
- Launch a Route53 Domain Hosted Zones and Connect it to our Cluster using Terraform
- Autoscale Our Cluster Using Nginx LoadBalancer and Ansible playbook
- Run Jenkins Piplines to deploy a custom Docker Image that contains a web application
- Perform a HighAvailability Tests on Our App using Kubernetes 
- Monitoring our Cluster Using Prometheus & Grafana 

## Deploy an EKS Cluster using CloudFormation for creating the stack
--------------------------------------------

### Step One : 
- Provision an EKS cluster with three worker nodes in eu-west-1

$ eksctl create cluster --name ekscluster --version 1.20 --region eu-west-1 --zones=eu-west-1a,eu-west-1b,eu-west-1c --ssh-access --nodegroup-name standard-workers --node-type t3.micro --nodes 3 --nodes-min 2 --nodes-max 4 --managed

- In the AWS Management Console, navigate to CloudFormation and take a look at what???s going on there

### Step Two : 

- By using our Console or Terminal we can view how CloudFormation provision the eks cluster Stack in the background
- Select the ekscluster stack (this is our control plane) Click Events, so you can see all the resources that are being created
- In the CLI, check the cluster:

$ eksctl get cluster

- Enable it to connect to our cluster:

$ aws eks update-kubeconfig --name dev --region us-east-1

## Automate a EKS Cluster deployment Using Terraform & Ansible

### Step One : 
- Applying Source Directory Terraform Files & Run the Folllowing Commands:

$ terrafom Validate

- Correct your Code in case of syntax errors

### Step Two : launch The Cluster From using TerraformCli

$ terrafom init

$ terrafom plan

$ terrafom Apply

## Dockerizing Our Appliction 

- Open The "Docker" Directory and clone our app:

$ git clone https://github.com/adamkeinan/weather-api.git

- Initialize it:

$ git Init

- Create an empty file called Dockerfile:

$ touch Dockerfile

- Apply your Dockerfile settings from the "Docker" directory
- Alternatively, We can launch it from the cli:

$ docker build . -t weather-app --build-arg NODE_VERSION=14.7-alpine3.14 \ 
> --build-arg ENV NODE_ENV=production \
> --build-arg WORKDIR weather-api \ 
> --build-arg COPY /weather-api/package.json /weather-api \
> --build-arg COPY /weather-api/package-lock.json /weather-api \
> --build-arg RUN npm install \
> --build-arg COPY . /weather-api \
> --build-arg EXPOSE 8081 \
> --build-arg ENV PORT 3005 \
> --build-arg CMD node npm-start

- Your image will now be listed by Docker:

$ docker images

- Run the image

$ docker run -p 3005:8081 -d <your username>/weather-app

- Get container ID

$ docker ps

- Print app output

$ docker logs <container id>

- Now you can call your app using curl:

$ curl -i localhost:3005

- Now that we fetched Our repository, we are able to tag our docker image

$ adam@ubuntu-dsk-1:~/repositories/ctsolution/Docker$ docker tag f6829c9b8412 adamkeinan/weather-app

- Verify that the image contains the current tag that you used

$ docker images
REPOSITORY                    TAG                  IMAGE ID       CREATED         SIZE
adamkeinan/weather-app        latest               f6829c9b8412   6 minutes ago   118MB
node                          14.17.3-alpine3.14   4c6ef524cd6d   8 days ago      118MB
httpd                         2.4                  30287d899656   3 weeks ago     138MB

- And now we will tag it with our current version

$ docker tag adamkeinan/weather-app weatherapp:v1
REPOSITORY                    TAG                  IMAGE ID       CREATED          SIZE
weatherapp                    v1                   f6829c9b8412   13 minutes ago   118MB
adamkeinan/weather-app        latest               f6829c9b8412   13 minutes ago   118MB

- Finnaly, we will push it to our registry with a new version: 

$ docker push adamkeinan/weather-app:v1.0
Using default tag: latest
The push refers to repository [docker.io/adamkeinan/weather-app]

#### And our file is successfuly pushed to adamkeinan/weather-app:latest

## Deoloy a Microservice on your EKS Cluster

### Step One: 
- Deploying a Microservice

- create a separate namespace for the app:

$ kubectl create namespace aws-app

- Deploy the app to the cluster:

$ kubectl -n aws-app create -f ~/ctsolution/K8s/descriptors/

- Check the status of the application's pods:

$ kubectl get pods -n aws-app

- You should be able to reach the app from your browser using the Kube master node's public IP:

$ http://$kube_master_public_ip:30080

- Edit the deployment descriptor

- Scale up the PostgressDB deployment to two replicas instead of just one

$ kubectl edit deployment postgressdb -n aws-app

You should see some YAML describing the deployment object.
Under spec:, look for the line that says replicas: 1 and change it to replicas: 2.

- Save and exit.

- Check the status of the deployment with:
$ kubectl get deployment postgressdb -n aws-app
After a few moments, the number of available replicas should be 2.

### Step Two: 
- Merging Our Changes With the remote server

- Connect to the server via ssh

$ ssh user@server_ip_address

- Enter the cloned git repo directory

$ cd ctsolution

- Run the following command to fetch any changes

$ git remote -v 
origin  https://github.com/adamkeinan/ctsolution.git (fetch)
origin  https://github.com/adamkeinan/ctsolution.git (push)

$ git remote add upstream https://github.com/MY_GIT_USERNAME/ctsolution.git

- Fetch your changes from the repo

$ git fetch upstream  
remote: Enumerating objects: 30, done.
remote: Counting objects: 100% (30/30), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 27 (delta 2), reused 27 (delta 2), pack-reused 0
Unpacking objects: 100% (27/27), 9.95 KiB | 254.00 KiB/s, done.
From https://github.com/adamkeinan/ctsolution
 * [new branch]      main       -> upstream/main

- Now move youre changes and localize it

$ git checkout main
$ git merge upstream/main

## Deploy Our Web Appliction on The EKS Cluster

### Step One : 
- Install Git

$ eksctl get cluster
NAME            REGION          EKSCTL CREATED
ekscluster      eu-west-1       True

### Step Two : 
- Enable it to connect to our cluster

$ aws eks update-kubeconfig --name dev --region eu-west-1

### Step Three: 
- Fork our resource files https://github.com/culture-trip/weather-api

### Step Four : 

- Clone The Newly Forked Git Directory

$ git clone https://github.com/adamkeinan/weather-api.git

### Step Five : 

- Deploy Our LoadBalancer
- Take a look at the deployment file:

$ cat /k8s/deployments/nginx-deployment.yaml 

- Take a look at the service file:
$ cat /k8s/services/nginx-svc.yaml

- Create the service
$ kubectl apply -f /k8s/services/nginx-svc.yaml

- Check its status:
$ kubectl get service

- Copy the external IP of the load balancer, and paste it into a text file, as we'll need it in a minute.

- Create the deployment:
$ kubectl apply -f /k8s/deployments/nginx-deployment.yaml

- Check its status:
$ kubectl get deployment

- View the pods:
$ kubectl get pod

- View the ReplicaSets:
$ kubectl get rs

- View the nodes:
$ kubectl get node

### Step Six : 

- Access the application using the load balancer, replacing <LOAD_BALANCER_EXTERNAL_IP> with the IP you copied earlier:

$ curl "<LOAD_BALANCER_EXTERNAL_IP>"

The output should be the HTML for a default Nginx web page

- In a new browser tab, navigate to the same IP, where we should then see the same Nginx web page

## Test the High Availability Features of Your EKS Cluster

- In the AWS console, on the EC2 instances page, select the three t3.micro instances
- Click Actions > Instance State > Stop.
- In the dialog, click Yes, Stop.

After a few minutes, we should see EKS launching new instances to keep our service running.

- In the CLI, check the status of our nodes:

$ kubectl get node

- Check the pods:

$ kubectl get pod

We'll see a few different statuses ??? Terminating, Running, and Pending ??? because, as the instances shut down, EKS is trying to restart the pods.

- Check the nodes again:

$ kubectl get node

We should see a new node, which we can identify by its age

- Wait a few minutes, and then check the nodes again:

$ kubectl get node

We should have one in a Ready state.

- Check the pods again:
$ kubectl get pod

We should see a couple pods are now running as well.

- Check the service status:

$ kubectl get service

- Copy the external IP listed in the output.

- Access the application using the load balancer, replacing <LOAD_BALANCER_EXTERNAL_IP> with the IP you just copied:
$ curl "<LOAD_BALANCER_EXTERNAL_IP>"

We should see the Nginx web page HTML again. (If you don't, wait a few more minutes.)

- In a new browser tab, navigate to the same IP, where we should again see the Nginx web page

- In the CLI, delete everything:

$ eksctl delete cluster EKS_CLUSTER_NAME

## Deploy a Jenkins Piplines on AWS using Terraform & Ansible

#### Setup Requirements
- We will start by ssh into our ec2_user@addrees.amazon.com

- Get The Latest Terraform binary 

$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
$ sudo yum -y install terraform
$ terraform -help

- Python3 & PIP needs to be installed on all nodes.you can verify by applyng the following commands:

$ yum -y install python3-pip
[ec2-user@ip-ADDRESS ~]$ python --version
Python 2.7.18
[ec2-user@ip-ADDRESS ~]$ python3 --version
Python 3.7.10

- Install Ansible:

$ Ansible (install via pip) # pip3 install ansible --user

- Turn your user prevlige mode to root:

$ sudo su

- Enable the Extra Packages for Enterprise Linux (EPEL) repository by running the following command

$ amazon-linux-extras install epel

- Apply the updates to the packages:

$ yum update -y

- Install Ansible, NGINX, and Git:

$ yum install ansible -y
$ yum install nginx -y
$ yum install git -y

- Install the official Ansible role from NGINX, Inc.:

$ ansible-galaxy install nginxinc.nginx

- downloading role 'nginx', owned by nginxinc
- downloading role from https://github.com/nginxinc/ansible-role-nginx/archive/0.20.0.tar.gz
- extracting nginxinc.nginx to /home/ec2-user/.ansible/roles/nginxinc.nginx
- nginxinc.nginx (0.20.0) was installed successfully

(NGINX Plus only) Copy the nginx-repo.key and nginx-repo.crt files provided by NGINX, Inc. to ~/.ssh/ngx-certs/.

#### Configure NGINX to route traffic : 
- Loctae your new aws app directory, cd into it and create an nginx and pass the configuration:

$ cd aws-app
$ vim nginx.conf

- Install Node.js and set up the Express server:

$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
$ . ~/.nvm/nvm.sh
$ nvm install node

- Choose a location for the Express server. In this example, we create a directory called server to store the relevant files

$ mkdir server && cd server
$ npm install express

When the installation completes, we'll obtain the JavaScript file that contains the code to handle the webhook request.sample named app.js that runs a weather-app and ansible-pull command to pull and run the playbook.yaml file from a GitHub repository

- jq (install via package manager) - OPTIONAL # 

$ sudo yum -y install jq

- Create an SSH key on your instance. In this example, replace with your email address

$ ssh-keygen -t rsa -b 4096 -C <your_email@example.com>

Now we'll be able to add our public key to the authorized_keys file on the remote ec2 Instance on us-east-1

$ ssh-copy-id -f us-east-1_USER@us-east-1_IP_ADDRESS

- When the key is created, run the following code:

$ eval "$(ssh-agent -s)" 

- The output looks similar to this:
$ Agent pid 1111

- Start NGINX

$ systemctl start nginx 
$ systemctl enable nginx

- Let's make a ~/hosts file which will be used as an inventory for Ansible:
[test]
52.54.142.56

[prod]
18.209.15.95

- Let's do a simple connection testing:

$ ls
$ vim hosts
$ ansible -i hosts all -m ping -u ec2-user
52.54.142.56 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
18.209.15.95 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
- Now lets Create a simple playbook called 'install_nginx.yaml' On our /terraform/ansible directory:

$ vim Install_nginx.yaml

- hosts: localhost
  become: true
  roles:
    - role: nginxinc.nginx

- wq! to save

- Run the playbook:

$ ansible-playbook install_nginx.yaml

- Now lets run our playbook

$ ansible-playbook -i hosts -s -u ec2-user aws-app.yaml

- Use the following basic configuration to listen on port 80 and route traffic to the port that the 
Express server listens to

### Set up GitHub to configure the webhook
- Log in to your GitHub account, and navigate to your repository settings > Deploy Keys
- Add the deploy key from your aws-app/.ssh public key(.pub)

- On the Webhooks tab, choose Add webhook
- Copy and paste your EC2 instance???s public IP address into the Payload URL section

This response indicates that the Express server received the request


- We'll contunue by creating our Backend service using AWS S3API

$ aws s3api create-bucket --bucket eksbackend --region eu-west-1 LocationConstraint=eu-west-1
{
    location: "/eksbackend"
}

- Copy the bucket name. Edit the backend.tf file and replace the bucket value for the bucket variable with your unique bucket name

- Now we will tag our s3 bucket

$ aws s3api put-bucket-tagging --bucket my-bucket --tagging 'TagSet=[{Key=PROD_ENV,Value=Production}]'

Configure Route 53 Public DNS
- Assuming you have a basic aws company/lab working domain, we can display the domain name:

$ aws route53 list-hosted-zones | jq -r .HostedZones[].Name | egrep "CLUSTER_NAME*"
eksclusterlab.com.
us-east-1.ekscluster.com.
eu-west-1.ekscluster.com.

- Copy the result of the previous command and edit the variables.tf file.

$ vim variables.tf 

- Navigate to the variable "dns-name" stanza and replace the text "<public-hosted-zone-ending-with-dot>" 
with the domain name we copied earlier. Be sure to include the . at the end of the domain name

- Create the key pair, pressing Enter three times after running the command to accept the defaults:

$ ssh-keygen -t rsa

Deploying the Terraform Code
- Initialize the Terraform directory you changed into to download the required provider:

$ terraform init
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.


- Ensure Terraform code is properly formatted:

$ terraform fmt

- Ensure code has proper syntax and no errors:

$ terraform validate
Success! The configuration is valid.

- See the execution plan and note the number of resources that will be created:

$ terraform plan
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Afer initiating our Cluster successfully in Two different ways its time to test our web applications

## Connecting Applications with Services Using Kubernetes 
### Objectives : 

- Deploy an nginx webserver with three replica sets for each microservice
- Deploy an pre-exiting Docker images to our pods:
  -- aws-app
  -- weather-app
- Expose our app and test their connectivity
- Upgrade the version of the weather-app in zero downtime

- Connect to your EC2 Host via ssh and navigate to the repository directory "/k8s/"
- Start by applying to "k8s" Directory. There you will see a simple nginx deployments & services yaml files.
- First, We will run a basic deployment of One replica as dev, for the initial version(1.0.0):
  
  $ 



## Conclusion

- We were able to successfully completing this hands-on lab

- Using Ansible and Terraform to manage piplines over different Availability Zones