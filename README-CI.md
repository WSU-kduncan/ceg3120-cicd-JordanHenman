# Part 1

## Docker Setup

#### Installing Docker Desktop

1. Navigate to [https://www.docker.com/](https://www.docker.com/).
2. Hover over "Download Docker Desktop".
3. Select a downloader based off of your operating system.
4. Once downloaded open "Docker Desktop Installer.exe".
5. Navigate through the installer menu to install Docker Desktop.
6. Once Installed launch Docker Desktop.

#### Testing if Docker is Installed

It is recommended to use a bash shell for the next steps. A guide to installing WSL can be found here: [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)


Using WSL I check if docker is installed using the following command:

        docker --version

This command will list the current version of docker, it if lists a version then you have successfully installed docker.

My reference for installing Docker desktop: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)

My Reference for testing docker: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

## Manually Setting up a Container

To setup a Docker container for our specific use I used the following command:

        docker run -it -p 4200:4200 -v $(pwd)/angular-site:/app node:18-bullseye bash



        
docker run - Starts a new Docker container from an image.

-it - i Keeps STDIN open and t allows you to use a terminal inside of the container.

-p 4200:4200 - Maps host port 4200 to container port 4200.

-v $(pwd)/anuglar-site:/app - Mounts angular-site directory to the working directory

node:18-bullseye - The Docker image being used which is Node.js 18 on Debian Bullseye.

bash - Starts a bash shell in the container.


Once the container is running a few dependencies need installed to run the application:

                cd /app
                npm install
                npm start

## Creating a Dockerfile and Building Images

Creating a Dockerfile to automatically create containers is a simple and efficent task.

The following is my example Dockerfile that I used to create a container similar to the one we created in the previous step:

        FROM node:18-bullseye

        WORKDIR /app

        COPY angular-site/ .

        RUN npm install

        CMD ["npm", "start"]

FROM - The base image that is used for the container.

WORKDIR - The working directory inside of the container.

COPY - Copying over the site files we are going to host.

RUN - Runs the install command to install Node.js dependencies.

CMD - Runs npm start to start the Angular dev server.

## Dockerhub Repository



My DockerHub Repo:

[https://hub.docker.com/repository/docker/jordanhenman/henman-ceg3120/general](https://hub.docker.com/repository/docker/jordanhenman/henman-ceg3120/general)

# Part 2

# Part 3
