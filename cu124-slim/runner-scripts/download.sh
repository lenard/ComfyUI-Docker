#!/bin/bash

set -euo pipefail

# Note: the "${BASH_REMATCH[2]}" here is REPO_NAME
# from [https://example.com/somebody/REPO_NAME.git] or [git@example.com:somebody/REPO_NAME.git]
function clone_or_pull () {
    if [[ $1 =~ ^(.*[/:])(.*)(\.git)$ ]] || [[ $1 =~ ^(http.*\/)(.*)$ ]]; then
        echo "${BASH_REMATCH[2]}" ;
        set +e ;
            git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$1" \
                || git -C "${BASH_REMATCH[2]}" pull --ff-only ;
        set -e ;
    else
        echo "[ERROR] Invalid URL: $1" ;
        return 1 ;
    fi ;
}


echo "########################################"
echo "[INFO] Downloading ComfyUI & Manager..."
echo "########################################"

set +e
cd /root
git clone https://github.com/comfyanonymous/ComfyUI.git temp
# ComfyUI dir already exists... so we want to try and turn it into a git repo
mv ./temp/.git /root/ComfyUI/.git
rm -rf temp
cd /root/ComfyUI
# Using stable version (has a release tag)
git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"
set -e


echo "########################################"
echo "[INFO] Downloading Custom Nodes..."
echo "########################################"

cd /root/ComfyUI/custom_nodes
clone_or_pull https://github.com/ltdrdata/ComfyUI-Manager.git

# Workspace
clone_or_pull https://github.com/crystian/ComfyUI-Crystools.git
clone_or_pull https://github.com/crystian/ComfyUI-Crystools-save.git

# General
clone_or_pull https://github.com/cubiq/ComfyUI_essentials
clone_or_pull https://github.com/yolain/ComfyUI-Easy-Use
clone_or_pull https://github.com/jags111/efficiency-nodes-comfyui
clone_or_pull https://github.com/kijai/ComfyUI-KJNodes
clone_or_pull https://github.com/WASasquatch/was-node-suite-comfyui

# Control
clone_or_pull https://github.com/cubiq/ComfyUI_IPAdapter_plus
clone_or_pull https://github.com/kijai/ComfyUI-Florence2
clone_or_pull https://github.com/Gourieff/ComfyUI-ReActor
clone_or_pull https://github.com/1038lab/ComfyUI-RMBG

# Video
clone_or_pull https://github.com/melMass/comfy_mtb.git


echo "########################################"
echo "[INFO] Downloading Models..."
echo "########################################"

# Models
cd /root/ComfyUI/models
aria2c \
  --input-file=/runner-scripts/download-models.txt \
  --allow-overwrite=false \
  --auto-file-renaming=false \
  --continue=true \
  --max-connection-per-server=5


# Finish
touch /root/.download-complete
