export REGISTRY_URL=$(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT)/$(GCP_REPO_NAME)/
export CONTAINER_IMAGE=$(GCP_CLOUD_RUN_SERVICE)
export CONTAINER_NAME=$(REGISTRY_URL)$(CONTAINER_IMAGE)

help:                           ## Show this help.
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | tr -d '##' | tr -d '$$'

docker-gcp-auth:                ## GCP Docker auth helper
	@gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

docker-build:                   ## Build the container locally with latest tag.
	@docker build -t $(CONTAINER_NAME) .

docker-run:                     ## Run the container locally on port 8081.
	@docker run --name=$(GCP_CLOUD_RUN_SERVICE) -p 8081:80 -d $(CONTAINER_NAME)

docker-stop:                    ## Stop the local running container
	@docker stop $(GCP_CLOUD_RUN_SERVICE) || (echo "Container is not running $(GCP_CLOUD_RUN_SERVICE)"; exit 0)

docker-remove:                  ## Remove the container
	@docker rm $(GCP_CLOUD_RUN_SERVICE)

docker-refresh:                 ## Stop, remove, rebuild and run the container locally.
	@$(MAKE) --no-print-directory docker-stop 
	@$(MAKE) --no-print-directory docker-remove
	@$(MAKE) --no-print-directory docker-build
	@$(MAKE) --no-print-directory docker-run

git:                            ## Stage, commit and push all changes to main. Example usage: 'make git m="commit msg"'
	git add -A
	git commit -m "$m"
	git push

cloud-run-publish-patch:        ## Build and tag both Docker image and Git as patch release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-patch

cloud-run-publish-minor:        ## Build and tag both Docker image and Git as minor release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-minor

cloud-run-publish-major:        ## Build and tag both Docker image and Git as major release. Push to container repository and update Cloud Run service.
	@$(MAKE) --no-print-directory docker-build
	@bash ./workflow_helper.sh release-major