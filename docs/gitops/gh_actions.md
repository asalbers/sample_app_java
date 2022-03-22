# Github Actions overview

## Github CI 

## Deployment pipeline

Actions used [k8s-deploy](https://github.com/azure/k8s-deploy)


Creating the sp used in the deployment phase

```sh
az ad sp create-for-rbac --name "aa-github-sp" --sdk-auth --role contributor --scopes /subscriptions/<subscription>/resourcegroups/<resource group>/providers/Microsoft.ContainerService/managedClusters/<cluster name>
```

Deployment repo structure

