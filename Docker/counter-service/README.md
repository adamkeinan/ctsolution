# counter-service
This is a simple web server which counts the amount of POST requests it served, and return it on every GET request it gets
- ### You may want to test this locally on your machine first. This can be done by building the image:

$ docker build -t adamakeinan/counter-service

- ### And then run the container from the image:


$ docker run -d -p 5000:5000 adamakeinan/counter-service

- ### Then, you can confirm that the API is working by issuing an HTTP request (using any client). In this lab, we’re using curl:

$ curl localhost:5000{"message":"Hello World!"}

- ### Let’s apply this configuration to our cluster: kubectl apply -f counter-service.yaml

$ kubectl apply -f counter-service.yaml

- ### We can test our setup so far by issuing an HTTP request to the IP address of any of our cluster nodes on port 32001:

$ curl 35.223.240.101:32001

{"message":"Hello World!"}