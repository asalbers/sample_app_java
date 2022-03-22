# Github Actions overview

## Github CI 

Actions used [build and push](https://github.com/marketplace/actions/build-and-push-docker-images)

[conditionals](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idif)

## Deployment pipeline

Actions used [k8s-deploy](https://github.com/azure/k8s-deploy)

Deployment repo structure

```sh
├── apps
│   ├── dev
│   │   └── dev.yaml
│   ├── helm
│   │   └── sample_java_app
│   │       ├── Chart.yaml
│   │       ├── templates
│   │       │   ├── _helpers.tpl
│   │       │   ├── deployment.yaml
│   │       │   ├── service.yaml
│   │       │   └── tests
│   │       │       └── test-connection.yaml
│   │       └── values.yaml
│   └── test
│       └── test.yaml
├── clusters
|
└── infra
```

```
name: Build and Push Docker Image

on:
  push:
    branches:
      - 'main'
      - 'dev'
      - 'test'
      
jobs:
  docker_build_prod:
    runs-on: ubuntu-latest
    steps:
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to Azure Container Registry
        uses: docker/login-action@v1 
        with:
          registry: aalabconreg.azurecr.io
          username: ${{ secrets.ACR_USER }}
          password: ${{ secrets.ACR_TOKEN }}
      -
        name: Build and push
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: |
            aalabconreg.azurecr.io/sample_java_app:latest
            aalabconreg.azurecr.io/sample_java_app:1.0.0

  docker_build_dev:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/dev'
    steps:
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to Azure Container Registry
        uses: docker/login-action@v1 
        with:
          registry: aalabconreg.azurecr.io
          username: ${{ secrets.ACR_USER }}
          password: ${{ secrets.ACR_TOKEN }}
      -
        name: Build and push
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: |
            aalabconreg.azurecr.io/sample_java_app:dev

  docker_build_test:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/test'
    steps:
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to Azure Container Registry
        uses: docker/login-action@v1 
        with:
          registry: aalabconreg.azurecr.io
          username: ${{ secrets.ACR_USER }}
          password: ${{ secrets.ACR_TOKEN }}
      -
        name: Build and push
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: |
            aalabconreg.azurecr.io/sample_java_app:test


```

### Creating the sp used in the deployment phase

```sh
az ad sp create-for-rbac --name "aa-github-sp" --sdk-auth --role contributor --scopes /subscriptions/<subscription>/resourcegroups/<resource group>/providers/Microsoft.ContainerService/managedClusters/<cluster name>
```

### Creating Actions workflow

create the sub folders in the repo using .github/workflows

```sh
name: deploy to aks 

on:
  push:
    branches:
      - 'main'

jobs:
  deploy_test:
    name: deploys to the production namespace
    runs-on: ubuntu-latest

    steps:
      - uses: Azure/aks-set-context@v1
        with:
          creds: "${{ secrets.AZURE_CREDENTIALS }}"
          cluster-name: AATestk8s
          resource-group: AALabRGk8s
      - uses: Azure/k8s-create-secret@v1.1
        with:
          container-registry-url: aalabconreg.azurecr.io
          container-registry-username: "${{ secrets.ACR_USERNAME }}"
          container-registry-password: "${{ secrets.ACR_PASSWORD }}"
          secret-name: acr-k8s-secret

      - uses: Azure/k8s-deploy@v1.4
        with:
          namespace: test
          action: deploy
          manifests: |
            apps/test/test.yml
          images: |
            aalabconreg.azurecr.io/sample_java_app:test
          imagepullsecrets: |
            acr-k8s-secret

  deploy_dev:
    name: deploys to the dev namespace
    runs-on: ubuntu-latest

    steps:
      - uses: Azure/aks-set-context@v1
        with:
          creds: "${{ secrets.AZURE_CREDENTIALS }}"
          cluster-name: AATestk8s
          resource-group: AALabRGk8s
      - uses: Azure/k8s-create-secret@v1.1
        with:
          container-registry-url: aalabconreg.azurecr.io
          container-registry-username: "${{ secrets.ACR_USERNAME }}"
          container-registry-password: "${{ secrets.ACR_PASSWORD }}"
          secret-name: acr-k8s-secret

      - uses: Azure/k8s-deploy@v1.4
        with:
          namespace: dev
          action: deploy
          manifests: |
            apps/dev/dev.yml
          images: |
            aalabconreg.azurecr.io/sample_java_app:dev
          imagepullsecrets: |
            acr-k8s-secret
```
