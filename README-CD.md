# Continuous Deployment

The goal of this project is to implement a fully automated deployement pipeline where pushing new code to GitHub creates a newly tagged Docker image which is deployed automatically to a live server.

# Part 1

## Using Tags

### Manually Generating Tags

The easiest way to see tags in a git repository is by using the following command:

    git tag

<br>

You can next create a tag with the following command:

    git tag -a (Instert tag name here) -m "Message you want to add."

-a - Annotated tag which stores metadata for the tag.

-m - Message you can include with the tag.

<br>

You can then push the tag to GitHub using this command:

    git push origin (Name of Tag)
<br>

### Semantic Versioning

My workflow only runs once a version tag is pushed to the repository.

The flow is as follows:

1. Checks out the repo.
2. Extracts the version metadata.
3. Logs into DockerHub using my secrets.
4. Builds the Docker image.
5. Lastly, pushes the image with latest, major, and major.minor tags.

<br>

Several changes had to be made to my previous workflow version to get this flow to work properly. 

* All the code involved in pushing the image whenever the repo was pushed was removed.

    *I didn't save the code I removed that was used to push the Docker image on Github push so just imagine that's here.*
  
* Code was added that extracted the metadata from the tag to be inserted into Docker.

      - name: Extract metadata for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: jordanhenman/henman-ceg3120
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
            type=raw,value=latest
  
* Build and push Docker image was updated to tag the image with the metadata.

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}

<br>

The only change that needs made if using another repo would be to change the images: jordanhenman/henman-ceg3120 to your DockerHub repo name.

        images: (insert Docker repo here)

<br>

Link to my workflow: [https://github.com/WSU-kduncan/ceg3120-cicd-JordanHenman/blob/main/.github/workflows/docker-publish.yml](https://github.com/WSU-kduncan/ceg3120-cicd-JordanHenman/blob/main/.github/workflows/docker-publish.yml)

<br>

### Testing 

The easiest way to test our process is to simply follow the previously listed steps. For instance, I did the following:

* Used the command - git tag -a v1.1 -m "Test"
* Pushed the tag with - git push origin v1.1
* Pushed the repository to Github
* Checked the Actions tab to ensure that no errors occured.
* Pulled the Docker image using docker pull - jordanhenman/henman-ceg3120:1.1
* Finally ran the image to ensure that it works correctly - docker run jordanhenman/henman-ceg3120:1.1

If everything is working correctly then there should be no errors throughout all these steps and the image should run successfully.

<br>

# Part 2

### EC2 Instance Details

The following is the specs I used when creating my EC2 instance:

* Instance Type: t2.medium with 2 CPU cores and 4 GB RAM.
* Volume Size: 30 GB.
* AMI: Ubuntu 20.04 LTS

My security group configuration is as follows:

* Inbound traffic on:
    * Port 22 - SSH
    * Port 80 - App
    * Port 9000 - Webhook 
* Outbound traffic on:
    * All ports 

<br>

### Installing & Testing Docker

Installing Docker on your EC2 is extremely easy.

    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo usermod -aG docker $USER

You can confirm docker successfully installed with this command:

    docker --version
    docker run hello-word

You can double check that docker is configured correctly by running your current Docker image from DockerHub.

    docker pull (your dockerhub username)/(image name):latest
    docker run -d -p 80:80 (your dockerhub username)/(image name):latest

If everything is configured correctly you should see your website in HTML using:

    curl localhost

<br>

### Bash Scripting

A bash script needs created that will refresh the Docker image.

    #!/bin/bash
    CONTAINER_NAME=my-angular-app
    IMAGE=your-dockerhub-username/your-image-name:latest
    
    docker pull $IMAGE
    docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
    docker run -d --name $CONTAINER_NAME -p 80:80 $IMAGE

This bash script needs to be executable for it to properly function.

    chmod +x refresh-container.sh

### Installing & Configuring Webhooks

Webhook needs installed on the EC2 instance.

    sudo apt instal webhook

Next a .json file needs configured to create a hook definition.

    [
      {
        "id": "deploy-container",
        "execute-command": "/home/ec2-user/deployment/refresh-container.sh",
        "command-working-directory": "/home/ec2-user",
        "pass-arguments-to-command": [],
        "trigger-rule": {
          "match": {
            "type": "value",
            "value": "supersecret",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature"
            }
          }
        }
      }
    ]

Lastly the webhook needs to be ran:

    webhook -hooks /home/ubuntu/deployment/hooks.json -port 9000

To test if your webhook is working successfully you can run the following command:

    curl -H "X-Hub-Secret: (Insert your secret)" http://(EC2 IP):9000/hooks/deploy

Once this is done you must configure your GitHub repository with a webhook by going into your repo settings and selecting webhooks.

You must enter the payload URL:

    http://(EC2 IP):9000/hooks/deploy

Your choosen secret:

    X-Hub-Secret: (Insert your secret)

And lastly choose when this webhook should be activated, I choose on tag creation.

<br>

### Autostarting Your Webhook

The final configuration your EC2 machine needs is a service file used to autostart webhook whenever the instance is turned on.

An example of my service file is as shown:

    [Unit]
    Description=Webhook Listener
    After=network.target
    
    [Service]
    ExecStart=/usr/local/bin/webhook -hooks /home/ubuntu/deployment/hooks.json -port 9000 -verbose
    Restart=always
    User=ec2-user
    
    [Install]
    WantedBy=multi-user.target

Next the service file needs configured to run on EC2 start:
    
    sudo cp deployment/webhook.service /etc/systemd/system/
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable webhook
    sudo systemctl start webhook

<br>

# Part 3

### Project Goal

** Goal stated before Part 1 **

### Tools Used

Tools Used:
* GitHub
* Docker
* DockerHub
* EC2 Instance
* Webhook

### Project Diagram



### Resources

* [https://github.com/adnanh/webhook](https://github.com/adnanh/webhook)
* [https://docs.github.com/en/actions](https://docs.github.com/en/actions)

