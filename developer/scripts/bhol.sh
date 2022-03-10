#!/bin/bash

function replace_json_field {
    tmpfile=/tmp/tmp.json
    cp $1 $tmpfile
    jq "$2 |= \"$3\"" $tmpfile > $1
    rm "$tmpfile"
}

# Check if SUFFIX envvar exists
if [[ -z "558288" ]]; then
    echo "Please set the MCW_SUFFIX environment variable to a unique three character string."
    exit 1
fi

if [[ -z "mar-ekm" ]]; then
    echo "Please set the MCW_GITHUB_USERNAME environment variable to your Github Username"
    exit 1
fi

if [[ -z "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" ]]; then
    echo "Please set the MCW_GITHUB_TOKEN environment variable to your Github Token"
    exit 1
fi

if [[ -z "${MCW_GITHUB_URL}" ]]; then
    MCW_GITHUB_URL=https://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@github.com/mar-ekm/Fabmedical.git
fi

git config --global user.email "contact@martinekman.com"
git config --global user.name "mar-ekm"

cp -R ~/MCW-Cloud-native-applications/Hands-on\ lab/lab-files/developer ~/Fabmedical
cd ~/Fabmedical
git init
git remote add origin https://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@github.com/mar-ekm/Fabmedical.git

git config --global --unset credential.helper
git config --global credential.helper store

# Configuring github workflows
cd ~/Fabmedical
sed -i "s/\[SUFFIX\]/558288/g" ~/Fabmedical/.github/workflows/content-init.yml
sed -i "s/\[SUFFIX\]/558288/g" ~/Fabmedical/.github/workflows/content-api.yml
sed -i "s/\[SUFFIX\]/558288/g" ~/Fabmedical/.github/workflows/content-web.yml

# Commit changes
git add .
git commit -m "Initial Commit"

# Get ACR credentials and add them as secrets to Github
ACR_CREDENTIALS=$(az acr credential show -n fabmedical558288)
ACR_USERNAME=$(jq -r -n '$input.username' --argjson input "$ACR_CREDENTIALS")
ACR_PASSWORD=$(jq -r -n '$input.passwords[0].value' --argjson input "$ACR_CREDENTIALS")

GITHUB_TOKEN=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
cd ~/Fabmedical
echo $GITHUB_TOKEN | gh auth login --with-token
gh secret set ACR_USERNAME -b "$ACR_USERNAME"
gh secret set ACR_PASSWORD -b "$ACR_PASSWORD" 

# Committing repository
cd ~/Fabmedical
git branch -m master main
git push -u origin main
