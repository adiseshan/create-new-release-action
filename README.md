# create-new-release-action

This action publishes a new release for the given repository. 

There are 2 modes based on the optional input `INPUT_TAG_NAME`.

- If specified and executed manually, new input tag will be used to publish new version.
- If not specified or if the specified tag does not exist, then a new tag will be created.

## Pre-requisites

- actions/checkout should be invoked so that the repository is clone and available in the workspace.
- A runner with `gh` and `awk` installed. Recommened to use runner-image [adiseshan/gh:v2.37.0](https://hub.docker.com/repository/docker/adiseshan/gh/general)


# What's new

Please refer to the [release page](https://github.com/adiseshan/create-new-release-action/releases/latest) for the latest release notes.

# Usage

<!-- start usage -->
```yaml
# Pre-requisite to release a new version.
- uses: actions/checkout@v3
  with:
    fetch-depth: 1

- name: create new release
  id: create-new-release
  uses: adiseshan/create-new-release-action@v1
  with:
    # Optional. In case of GHE. eg., github.ghe-internal-xx.com
    # Default: github.com
    INPUT_GITHUB_HOSTNAME: github.ghe-internal-xx.com
    # Secret PAT with `repo` priviledge
    # [Learn more about creating and using encrypted secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)
    INPUT_GITHUB_TOKEN: ${{ secrets.BOT_GITHUB_TOKEN }}
    # The branch or reference used to create release
    INPUT_GIT_REF: ${{ github.ref_name }}
    # The branch used to create. For eg., master.
    INPUT_TAG_NAME: ${{ github.event.inputs.TAG_NAME || '' }}
```
<!-- end usage -->

# Examples 

## Example 1


```yaml
name: create new release

on:
  push:
    branches:
      - master
  workflow_dispatch:
    inputs:
      TAG_NAME:
        description: 'tag name. If empty, new version will be auto calculated.'

permissions:
  contents: write

jobs:
  create-new-release:
    runs-on: ubuntu-latest
    container: 
      image: adiseshan/gh:v2.37.0
      credentials:
        username: ${{ secrets.DOCKER_USER }}
        password: ${{ secrets.DOCKER_TOKEN }}
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 1

      - name: create new release
        id: create-new-release
        uses: adiseshan/create-new-release-action@v1
        with:
          INPUT_GITHUB_HOSTNAME: github.com
          INPUT_GITHUB_TOKEN: ${{ secrets.BOT_GITHUB_TOKEN }}
          INPUT_GIT_REF: ${{ github.ref_name }}
          INPUT_TAG_NAME: ${{ github.event.inputs.TAG_NAME || '' }}
```
