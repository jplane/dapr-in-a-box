#!/usr/bin/env bash

# ------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# ------------------------------------------------------------

# Daprd location
: ${DAPRD_INSTALL_DIR:="/usr/local/bin"}

# sudo is required to copy binary to DAPRD_INSTALL_DIR for linux
: ${USE_SUDO:="false"}

# Http request CLI
DAPR_HTTP_REQUEST_CLI=curl

# GitHub Organization and repo name to download release
GITHUB_ORG=dapr
GITHUB_REPO=dapr

# Dapr CLI filename
DAPRD_FILENAME=daprd

DAPRD_FILE="${DAPRD_INSTALL_DIR}/${DAPRD_FILENAME}"

getSystemInfo() {
    ARCH=$(uname -m)
    case $ARCH in
        armv7*) ARCH="arm";;
        aarch64) ARCH="arm64";;
        x86_64) ARCH="amd64";;
    esac

    OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')

    # Most linux distro needs root permission to copy the file to /usr/local/bin
    if [ "$OS" == "linux" ] && [ "$DAPRD_INSTALL_DIR" == "/usr/local/bin" ]; then
        USE_SUDO="true"
    fi
}

verifySupported() {
    local supported=(darwin-amd64 linux-amd64 linux-arm linux-arm64)
    local current_osarch="${OS}-${ARCH}"

    for osarch in "${supported[@]}"; do
        if [ "$osarch" == "$current_osarch" ]; then
            echo "Your system is ${OS}_${ARCH}"
            return
        fi
    done

    echo "No prebuilt binary for ${current_osarch}"
    exit 1
}

runAsRoot() {
    local CMD="$*"

    if [ $EUID -ne 0 -a $USE_SUDO = "true" ]; then
        CMD="sudo $CMD"
    fi

    $CMD
}

checkHttpRequestCLI() {
    if type "curl" > /dev/null; then
        DAPR_HTTP_REQUEST_CLI=curl
    elif type "wget" > /dev/null; then
        DAPR_HTTP_REQUEST_CLI=wget
    else
        echo "Either curl or wget is required"
        exit 1
    fi
}

checkExistingDapr() {
    if [ -f "$DAPRD_FILE" ]; then
        echo -e "\nDaprd is detected:"
        $DAPRD_FILE --version
        echo -e "Reinstalling Daprd - ${DAPRD_FILE}...\n"
    else
        echo -e "Installing Daprd...\n"
    fi
}

getLatestRelease() {
    local daprdReleaseUrl="https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/releases"
    local latest_release=""

    if [ "$DAPRD_HTTP_REQUEST_CLI" == "curl" ]; then
        latest_release=$(curl -s $daprdReleaseUrl | grep \"tag_name\" | grep -v rc | awk 'NR==1{print $2}' |  sed -n 's/\"\(.*\)\",/\1/p')
    else
        latest_release=$(wget -q --header="Accept: application/json" -O - $daprdReleaseUrl | grep \"tag_name\" | grep -v rc | awk 'NR==1{print $2}' |  sed -n 's/\"\(.*\)\",/\1/p')
    fi

    ret_val=$latest_release
}

downloadFile() {
    LATEST_RELEASE_TAG=$1

    DAPRD_ARTIFACT="${DAPRD_FILENAME}_${OS}_${ARCH}.tar.gz"
    DOWNLOAD_BASE="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/releases/download"
    DOWNLOAD_URL="${DOWNLOAD_BASE}/${LATEST_RELEASE_TAG}/${DAPRD_ARTIFACT}"

    # Create the temp directory
    DAPRD_TMP_ROOT=$(mktemp -dt dapr-install-XXXXXX)
    ARTIFACT_TMP_FILE="$DAPRD_TMP_ROOT/$DAPRD_ARTIFACT"

    echo "Downloading $DOWNLOAD_URL ..."
    if [ "$DAPRD_HTTP_REQUEST_CLI" == "curl" ]; then
        curl -SsL "$DOWNLOAD_URL" -o "$ARTIFACT_TMP_FILE"
    else
        wget -q -O "$ARTIFACT_TMP_FILE" "$DOWNLOAD_URL"
    fi

    if [ ! -f "$ARTIFACT_TMP_FILE" ]; then
        echo "failed to download $DOWNLOAD_URL ..."
        exit 1
    fi
}

installFile() {
    tar xf "$ARTIFACT_TMP_FILE" -C "$DAPRD_TMP_ROOT"
    local tmp_root_daprd="$DAPRD_TMP_ROOT/$DAPRD_FILENAME"

    if [ ! -f "$tmp_root_daprd" ]; then
        echo "Failed to unpack Daprd executable."
        exit 1
    fi

    chmod o+x $tmp_root_daprd
    runAsRoot cp "$tmp_root_daprd" "$DAPRD_INSTALL_DIR"

    if [ -f "$DAPRD_FILE" ]; then
        echo "$DAPRD_FILENAME installed into $DAPRD_INSTALL_DIR successfully."

        $DAPRD_FILE --version
    else 
        echo "Failed to install $DAPRD_FILENAME"
        exit 1
    fi
}

fail_trap() {
    result=$?
    if [ "$result" != "0" ]; then
        echo "Failed to install Daprd"
        echo "For support, go to https://dapr.io"
    fi
    cleanup
    exit $result
}

cleanup() {
    if [[ -d "${DAPRD_TMP_ROOT:-}" ]]; then
        rm -rf "$DAPRD_TMP_ROOT"
    fi
}

installCompleted() {
    echo -e "\nTo get started with Dapr, please visit https://github.com/dapr/docs/tree/master/getting-started"
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
trap "fail_trap" EXIT

getSystemInfo
verifySupported
checkExistingDapr
checkHttpRequestCLI

getLatestRelease
downloadFile $ret_val
installFile
cleanup

installCompleted