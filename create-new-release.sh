#!/bin/bash
# Env Pre requisites
# Author: Adiseshan K
# INPUT_GITHUB_TOKEN: With read priviledges.
# INPUT_GITHUB_HOSTNAME: github.com or the GHE hostname.
# INPUT_TAG_NAME The version with which new .
# INPUT_GIT_REF branch used as git ref.
set -o pipefail

validate() {
    gh version
    awk --version
}

setup() {
    git config --global --add safe.directory "*"
    echo "${INPUT_GITHUB_TOKEN}" | gh auth login --hostname "${INPUT_GITHUB_HOSTNAME}" --git-protocol https --with-token
    git_status_check_cmd="gh auth status --hostname ${INPUT_GITHUB_HOSTNAME}"
	if ! ${git_status_check_cmd}; then
        echo "git status check failed for hostname ${INPUT_GITHUB_HOSTNAME}. "
        exit 1
    fi
}

main() {
    validate
    setup

    new_version=${INPUT_TAG_NAME}
    # if input exist: consider it as new version
    if [[ -n ${new_version} ]]; then 
        echo using the user given tag "${new_version}"
    else
        echo "trying to construct new version"
        # execute the command capture return code and output.
        current_version=$(bash -c 'gh release view --json name --jq .name; exit $?' 2>&1)
        return_code=$?

        # if return is non-zero, check if it is known errors.
        if [[ "0" -ne "${return_code}" ]]; then
            echo "E1: failed to identify current version"
            echo "output: ${current_version}"
            if [[ "release not found" == "${current_version}" ]]; then
                current_version="v1.0.-1"
            else
                exit 1
            fi
        fi
    fi

    echo "identified/framed current_version as ${current_version}"
    if [[ -n ${current_version} ]]; then
        new_version=$(awk -F. -v OFS=. '{$NF += 1 ; print}' <<< "${current_version}")
    fi

    if [[ -z ${new_version} ]]; then
        # all atempts failed to construct the new_version
        echo "E2: failed to construct new_version"
        exit 1
    fi
    echo "constructed new_version as ${new_version}"

    git_rel_create_cmd="gh release create ${new_version} --generate-notes --latest --target ${INPUT_GIT_REF}"
    echo "executing ${git_rel_create_cmd}"
	if ! ${git_rel_create_cmd}; then
        echo "command failed"
        exit 1
    fi
}

main "$@"
