# Image
FROM node:18-bullseye 

# Setting the working directory
WORKDIR /app

# Installing Angular
RUN npm install -g @angular/cli

# Copying the site files
COPY anguar-site/ /app

# Installing dependencies
RUN npm install

# Starting the app
CMD ["npm", "start"]
