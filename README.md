# public-docs
My public documentation repository hosted on GCP Cloud Run. Powered by AsciiDoc and NGINX.

## Project Overview
The motivation for this project is to serve primarily a learning opportunity for me as well as a way to share knowledge. If someone stumbles across this and finds just one thing useful then it has served it's purpose.

I'm a big fan of AsciiDoc for it's ease of use but haven't used it much and want to become more familiar with it. I also love all things GCP, Kubernetes and Knative so wanted to create a container that can be hosted on Cloud Run.

Finally, I wanted to create a Makefile that can be used as a pattern or starting point for other projects.

The blog created by this project is available here: https://docs.vaughanross.io

## Prerequisites
I have installed Docker, the gcloud sdk and authenticated to GCP. I then deployed the hello-world Cloud Run service in a region that supports custom domain mapping and created a Docker repository in GCP's Artifact Registry in the same region. I tagged the container image as version 0.0.1.

## Getting Started

I create an env file containing my configuration variables and source it. The Makefile and workflow_helper script depend on the environment variables. See below for an example.
```console
cat << EOF >> envvars/prd.env
export GCP_REGION='us-west1'
export GCP_PROJECT='public-docs-123'
export GCP_REPO_NAME='container-images'
export GCP_CLOUD_RUN_SERVICE='public-documentation'
EOF

source ./envvars/prd.env
```
## My Workflow

1. Create or update adoc files, including index.adoc if required. I use VSCode with an AsciiDoc extension.
2. Build and run the container locally.
3. Review (test) new content locally.
4. Commit changes to repo.
4. Publish to GCP Cloud Run.

I ensure that the Makefile can be used for each step of the workflow. Run 'make' to print all available options:

```bash
help:                            Show this help.
docker-gcp-auth:                 GCP Docker auth helper.
docker-build:                    Build the docker container locally with latest tag.
docker-login:                    Login to GCP Artifactory.
docker-run:                      Run the Docker container locally on port 8081.
docker-stop:                     Stop the local running container.
git:                             Stage, commit and push all changes to main. Example usage: 'make git m="commit msg"'.
cloud-run-publish-patch:         Build and tag both Docker image and Git as patch release. Push to container repository and update Cloud Run service.
cloud-run-publish-minor:         Build and tag both Docker image and Git as minor release. Push to container repository and update Cloud Run service.
cloud-run-publish-major:         Build and tag both Docker image and Git as major release. Push to container repository and update Cloud Run service.
```

## Acknowlegements

When Googling around it came as no surprise to find many like minded individuals and so rather than re-invent the wheel I have customized bits and pieces of the following to satisfy my requirements:
* https://medium.com/@dhavalmetrani/makefiles-and-docker-versioning-8c15ccc76994
* https://aerokhin.com/posts/how-setup-your-asciidoc-blog.html
* https://github.com/commandercool/asciiblog
* https://panjeh.medium.com/makefile-git-add-commit-push-github-all-in-one-command-9dcf76220f48

## References
* [Cloud Run](https://cloud.google.com/run/)
* [Cloud Run Custom Domains](https://cloud.google.com/run/docs/mapping-custom-domains)
* [Cloud Run Pricing](https://cloud.google.com/run/pricing/)
* [AsciiDoc Syntax Quick Reference](https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/)
* [AsciiDoc Writers Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/)
* [AsciiDoc User Guide](https://asciidoc.org/userguide.html)
* [draw.io Documentation](https://www.diagrams.net/doc/)
