
## Creating NGINX Plus Docker Image
### Prerequisites
- Docker installation
- Docker Hub account (NGINX Open Source)
- nginx-repo.crt and nginx-repo.key files, Dockerfile for Docker image creation (NGINX Plus)

- To generate an NGINX image
[nginx:stable]
or
[nginxplus]

Create the Docker build context, or a Dockerfile:
[Dockerfile]

- Launch an instance of NGINX running in a container and using the default NGINX configuration with the following command:

$ docker run --name ncav0 -p 80:80 -d nginx:stable

We are now at container version 0

- Verify that the container was created and is running with the docker ps command:

$ docker ps

## Creating NGINX Docker Image
- Create the Docker build context, or a Dockerfile
[ncav1.Dockerfile]

- Create a Docker image, for example, nginx-ws-app (note the final period in the command)

$ docker build --no-cache -t nginx-ws-appv1 .

- Verify that the nginx-ws-app container is up and running with the docker ps command:

$ docker images nginx-ws-appv1

- Create a container based on this image, for example, nca("nginx-container-app") container:

$ docker run --name ncav1 -p 80:80 -d nginx-ws-appv1

- Verify that the ncav1 container is up and running with the docker ps command:

$ docker ps

## Maintaining Content and Configuration Files on the Docker Host
- Mount nginx content and configuration files and define the volume for the image with the Dockerfile:

$ docker run --name ncav1 --mount type=bind,source=/var/www,target=/usr/share/nginx/html,readonly --mount source=/var/nginx/conf,target=/etc/nginx/conf,readonly -p 80:80 -d nginx:stable

## Copying Content and Configuration Files from the Docker Host
- A simple way to copy the files is to create a Dockerfile with commands that are run during generation of a new Docker image based on the NGINX image
[ncav2.Dockerfile]
- Create the new NGINX image by running the following command:

$ docker build -t nginx-ws-appv2 .

- Create a container ncav2 based on the nginx-ws-appv2 image:

- Create an NGINX container ncav3 based on the nginx-ws-appv1 image:

$ docker run --name nginx-container02 -p 80:80 -d mynginx_imagev2
 

## Maintaining Content and Configuration Files in the Container 
- As SSH cannot be used to access the NGINX container, to edit the content or configuration files directly you need to create a helper container
[ncav3.Dockerfile]

- Create the new NGINX image by running the following command:
  
$ docker build -t nginx-ws-appv3 .

- Create an NGINX container ncav3 based on the nginx-ws-appv3 image:

$ docker run --name ncav3 -p 80:80 -d nginx-ws-appv3

- Start a helper container ncav3 that has a shell, providing access the content and configuration directories of the nginx-ws-appv3 container we just created:

$ docker run -i -t --volumes-from ncav3 --name nginx-ws-appv3 debian /bin/bash

- To regain shell access to a running container, run this command:

$ docker attach nginx-ws-appv3

- Finaly Build the latest stable version of the Container
[ncavStable.Dockerfile]
- Create the new NGINX image by running the following command:
  
$ docker build -t nginx-ws-appv4 .

- Create an NGINX container ncavStable based on the nginx-ws-appv4 image:

$ docker run --name ncavStable -p 80:80 -d nginx-ws-appv4

### Exposing pods to the cluster 
-  Create an nginx Pod
[nginx_v1_deployment.yaml]

- This makes it accessible from any node in your cluster. Check the nodes the Pod is running on:

$ kubectl apply -f ./nginx_v1_deployment.yaml
$ kubectl get pods -l run=ws-app -o wide

- Check your pods' IPs:

$ kubectl get pods -l run=ws-app -o yaml | grep podIP


#### Creating a Service 
- You can create a Service for your 2 nginx replicas with kubectl expose:

$ kubectl expose deployment/ws-app
$ service/ws-app

- This is equivalent to kubectl apply -f the following yaml:
[nginx-svc.yaml]

$ kubectl apply -f nginx-svc.yaml
$ kubectl get svc ws-app
$ kubectl describe svc ws-app
$ kubectl get ep ws-app

#### Accessing the Service
- Using Environment Variables:
  
  $ kubectl exec ws-app-3800858182-jr4a2 -- printenv | grep SERVICE

#### Scaling the application by increasing the replica count
- We will do this by increasing the number of Pods in our Deployment by applying a new YAML file. This YAML file sets replicas to 3

#### Scaling The Service

- We can do this the right way by killing the 2 Pods and waiting for the Deployment to recreate them. This time around the Service exists before the replicas. This will give you scheduler-level Service spreading of your Pods:

  $ kubectl scale deployment my-nginx --replicas=0; kubectl scale deployment my-nginx --replicas=2;
  $ kubectl get pods -l run=my-nginx -o wide

You may notice that the pods have different names, since they are killed and recreated.

#### Securing the Service 
##### Requirements:
- Go
- Make Tools

$ make keys KEY=/tmp/nginx.key CERT=/tmp/nginx.crt
$ kubectl create secret tls nginxsecret --key /tmp/nginx.key --cert /tmp/nginx.crt
$ kubectl get secrets

- And also the configmap:

$ kubectl create configmap nginxconfigmap --from-file=default.conf
$ kubectl get configmaps

- Following are the manual steps to follow in case you run into problems running make (on windows for example):

- Create a public private key pair
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /d/tmp/nginx.key -out /d/tmp/nginx.crt -subj "/CN=my-nginx/O=my-nginx"

- Convert the keys to base64 encoding
$ cat /d/tmp/nginx.crt | base64
$ cat /d/tmp/nginx.key | base64

- Now create the secrets using the file:

- kubectl apply -f nginxsecrets.yaml
- kubectl get secrets

#### Upgrading The Application
- We'll modify our nginx replicas to start an https server using the certificate in the secret, and the Service, to expose both ports (80 and 443):
[nginx_v2_deployment.yaml]

- Now run: 

$ kubectl edit deployment.v1.apps/nginx-ws-app

Alternately, You can run:
$ kubectl set image deployment/nginx-ws-app nginx=nginx:1.16.1 --record

[nginx_secure.yaml]

$ kubectl edit deployment.v1.apps/nginx-ws-svc




- Best practice is to deploy it as one template
[nginx-secure-wsapp]

- Each container has access to the keys through a volume mounted at /etc/nginx/ssl. This is setup before the nginx server is started.

$ kubectl delete deployments,svc ws-app; kubectl create -f ./nginx-secure-wsapp.yaml

At this point you can reach the nginx server from any node.

$ kubectl get pods -o yaml | grep -i podip
$ kubectl exec my-nginx-3800858182-e9ihh -- printenv | grep SERVICE
podIP: <SOME_IP_ADDRESS>
$ node $ curl -k https://<SOME_IP_ADDRESS>

- Note how we supplied the -k parameter to curl in the last step, this is because we don't know anything about the pods running nginx at certificate generation time, so we have to tell curl to ignore the CName mismatch

$ kubectl apply -f ./curlpod.yaml
$ kubectl get pods -l app=curlpod

### Exposing the Service 
- Kubernetes supports two ways of doing this: NodePorts and LoadBalancers:
- The Service created in the last section will use LoadBalancer

$ kubectl get nodes -o yaml | grep ExternalIP -C 1
$ kubectl get svc my-nginx
$ kubectl describe service my-nginx
