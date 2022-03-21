# GitOps

## Installation and Setup

### Required tools
[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
[Flux CLI](https://fluxcd.io/docs/installation/)
[Kubectl CLI](https://kubernetes.io/docs/tasks/tools/)

### Setup 
verify that the flux cli is working correctly by running the pre check commands

```sh
flux check --pre
```

Need to create a Personal access token in github to setup the repository for access to the cli

### Bootstrapping the repository
<details>
    <summary></summary>
</details>

```sh
export GITHUB_TOKEN=<your-personal-access-token>export GITHUB_USER=<your-github-username> GITHUB_REPO=<repo name>

```

<details>
    <summary>Additional bootstrap options</summary>
    
    Personal or Org and Team Access: Combination of --personal (Boolean) --owner (string) and --team(string) flag. Set owner to $GITHUB_USER and $GITHUB_TOKEN will be pulled automatically 

    Private or Public Repo: --private (Boolean) 

    Branch and/or Path: --branch string and --path safeRelativePath 

    Repository Name: --repository which can be existing one or new one 
</details>


```sh
flux bootstrap github \--owner=$GITHUB_USER \--repository=$GITHUB_REPO \--branch=main \--path=./clusters/$CLUSTER_NAME \--personal
```



```sh
flux bootstrap github \--owner=$GITHUB_USER \--repository=sample_app_java \--branch=main \--path=./clusters/$CLUSTER_NAME \--personal
► connecting to github.com
► cloning branch "main" from Git repository "https://github.com/asalbers/sample_app_java.git"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ committed sync manifests to "main" ("93d2684d1b0b09e8081e163a88faa4d75f8758a4")
► pushing component manifests to "https://github.com/asalbers/sample_app_java.git"
✔ installed components
✔ reconciled components
► determining if source secret "flux-system/flux-system" exists
► generating source secret
✔ public key:  
✔ configured deploy key "flux-system-main-flux-system-./clusters" for "https://github.com/asalbers/sample_app_java"
► applying source secret "flux-system/flux-system"
✔ reconciled source secret
I0316 15:14:47.774682     777 request.go:665] Waited for 1.164725179s due to client-side throttling, not priority and fairness, request: GET:
► generating sync manifests
✔ generated sync manifests
✔ committed sync manifests to "main" ("995c6954afa64a5e1afd4a8a93efc7bebe169769")
► pushing sync manifests to "https://github.com/asalbers/sample_app_java.git"
► applying sync manifests
✔ reconciled sync configuration
◎ waiting for Kustomization "flux-system/flux-system" to be reconciled
✔ Kustomization reconciled successfully
► confirming components are healthy
✔ helm-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ all components are healthy
```

### Creating app source and manifests

The command below should be ran in the repo that will contain the deployments

```sh
flux create source git demo \--url=https://github.com/$GITHUB_USER/$GITHUB_REPO \--branch=main \--interval=30s \--export > ./clusters/$CLUSTER_NAME/demo-source.yaml
```

