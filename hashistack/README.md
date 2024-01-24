# README 

## Why use `wget` to pull the binaries?  Why not just install from HashiCorp's apt repository?
I wanted to be able to specify a version and unfortunately some of the versions in apt will have a release number attached to it, but you wouldn't know that until you actually did the install and I want to be able to consistently pull a binary without having to trial & error the actual version + release number.

- sample Consul version query output:
```
$ sudo apt-cache policy consul
consul:
  Installed: (none)
  Candidate: 1.12.2-1
  Version table:
     1.12.2-1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.12.1-1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.12.0-1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.6-1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.5-1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.4 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.3 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.2 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.1-2 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
     1.11.1 500
        500 https://apt.releases.hashicorp.com focal/main amd64 Packages
```


### NOTE
- Due to the way images are organized in GCP, each type of image will be in its own `image_family`, so you will need a separate `variables.pkr.hcl` file for each type of build.


## Vault image
The reason I called the image a "base" image and not server is because I also use this image as a Vault agent when I'm studying for my [Vault Operations Professional](https://www.hashicorp.com/certification/vault-operations-professional) cert (and I use my [serverless Vault](https://github.com/Neutrollized/hashicorp-vault-with-cloud-run) as the Vault server).

### NOTE
- After you provision your server make a copy of the `vault_server.hcl.sample` or `vault_agent.hcl.sample` config (whichever applies in your case) and rename it as `vault.hcl` as that's the file name the `vault.service` file is expecting.
- The included Vault server and agent configs are just samples.  Delete and modify stanzas as it fits your setup/use case.
