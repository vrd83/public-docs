export REGISTRY_URL=$(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT)/$(GCP_REPO_NAME)/
export CONTAINER_IMAGE=$(GCP_CLOUD_RUN_SERVICE)
export CONTAINER_NAME=$(REGISTRY_URL)$(CONTAINER_IMAGE)

help:                           ## Show this help.
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | tr -d '##' | tr -d '$$'

docker-gcp-auth:                ## GCP Docker auth helper
	@gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

docker-build:                   ## Build the docker container locally with latest tag.
	@docker build -t $(CONTAINER_NAME) .

docker-login:                   ## Login to GCP Artifactory
	@gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

docker-run:                     ## Run the Docker container locally on port 8081.
	@docker run --name=$(GCP_CLOUD_RUN_SERVICE) -p 8081:80 -d $(CONTAINER_NAME)

docker-stop:                    ## Stop the local running container
	@docker stop $(GCP_CLOUD_RUN_SERVICE) || (echo "Container is not running $(GCP_CLOUD_RUN_SERVICE)"; exit 0)

git:                            ## Stage, commit and push all changes to main. Example usage: 'make git m="commit msg"'
	git add -A
	git commit -m "$m"
	git push -u origin main

cloud-run-publish-patch:        ## Build and tag both Docker image and Git as patch release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-patch

cloud-run-publish-minor:        ## Build and tag both Docker image and Git as minor release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-minor

cloud-run-publish-major:        ## Build and tag both Docker image and Git as major release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-major