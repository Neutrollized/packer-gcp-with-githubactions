[![Packer Build](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml/badge.svg)](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml)

# HashiCorp Packer & GCP with GitHub Actions

- building Google Cloud VM images using Packer and GitHub Actions
- authentication handled by [Workload Identity Federation (WIF)](https://cloud.google.com/iam/docs/workload-identity-federation)

[Medium: Getting started with HashiCorp Packer on Google Cloud Platform](https://medium.com/@glen.yu/getting-started-with-hashicorp-packer-on-google-cloud-platform-a36bfeffbfa9)

## Setup

### 0 - Fork this repo


### 1 - WIF Pool & GitHub Provider
Terraform code for setting up required GCP service accounts and WIF can be found [here](./terraform)


### 2 - Update GitHub Workflow YAML
You will need to update the `WIF_PROVIDER` and `WIF_SERVICE_ACCOUNT` env vars in the [packer.yaml](.github/workflow/packer.yaml) accordingly for your GCP project and WIF Pool configuration

#### NOTE - You can get the `WIF_PROVIDER` with the following `gcloud` command (provider ID = *github* in my example): 
```console
gcloud iam workload-identity-pools providers describe ${WIF_PROVIDER_ID} \
    --location global \
    --workload-identity-pool ${WIF_POOL_ID} \
    --format='get(name)'
```

#### NOTE - I used GitHub's CLI tool, [`gh`](https://github.com/cli/cli) to [set secrets](https://cli.github.com/manual/gh_secret_set) via command line


### 3 - Push your commit!
Check the **Actions** tab and watch it go


#### NOTE - Using Credentials JSON
While not the recommended method of authenticating to Google Cloud, you can generate a credentials JSON key file and paste its contents into a GitHub repo secret:
```
jobs:
    [...]

    steps:
      [...]

      - name: 'Authenticate to Google Cloud'
        id: 'auth'
        uses: 'google-github-actions/auth@v1'
        with:
          credentials_json: '${{ secrets.GCP_CREDENTIALS_JSON }}'

      [...]
```


## Run Locally
If you wish to run this locally without using GitHub Actions, you can do the following:

- authenticate using user application default creds
```console
gcloud auth application-default login
```

```console
PKR_VAR_access_token='xxxxxxxxxxxxx' packer build -var 'project_id=myproject-123' -var-file=variables.pkrvars.hcl base_docker.pkr.hcl`
```

**NOTE**: obtain access_token with `gcloud auth print-access-token`
