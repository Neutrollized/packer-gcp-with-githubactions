# README

Building Google Cloud VM images using Packer and GitHub Actions



## EXTRA - Using Credentials JSON
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
