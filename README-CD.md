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

    * I didn't save the code I removed that was used to push on Github push so just imagine that's here. *
  
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

Link to my workflow: [https://github.com/WSU-kduncan/ceg3120-cicd-JordanHenman/blob/main/.github/workflows/docker-publish.yml](https://github.com/WSU-kduncan/ceg3120-cicd-JordanHenman/blob/main/.github/workflows/docker-publish.yml)

<br>

### Testing 

The easiest way to test our process is to simply follow the previously listed steps. For instance, I did the following:

* Used the command - git tag -a v1.1.1 -m "Test"
* Pushed the tag with - git push origin v1.1.1
* Pushed the repository to Github
* Checked the Actions tab to ensure that no errors occured.
* Pulled the Docker image using docker pull - jordanhenman/henman-ceg3120:1.1.1
* Finally ran the image to ensure that it works correctly - docker run jordanhenman/henman-ceg3120:1.1.1

If everything is working correctly then there should be no errors throughout all these steps and the image should run successfully.

<br>

# Part 2



# Part 3


