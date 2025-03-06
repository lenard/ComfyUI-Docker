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

cd /root/ComfyUI/custom_nodes
clone_or_pull https://github.com/ltdrdata/ComfyUI-Manager.git


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



echo "########################################"
echo "[INFO] Downloading Custom Nodes..."
echo "########################################"

cd /root/ComfyUI/custom_nodes
git clone https://github.com/WASasquatch/was-node-suite-comfyui && cd was-node-suite-comfyui && ( pip install -r requirements.txt || true )
git clone https://github.com/melMass/comfy_mtb && cd comfy_mtb && ( pip install -r requirements.txt || true )
git clone https://github.com/1038lab/ComfyUI-RMBG && cd ComfyUI-RMBG && ( pip install -r requirements.txt || true )
git clone https://github.com/kijai/ComfyUI-KJNodes && cd ComfyUI-KJNodes && ( pip install -r requirements.txt || true )
git clone https://github.com/jags111/efficiency-nodes-comfyui && cd efficiency-nodes-comfyui && ( pip install -r requirements.txt || true )
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && cd ComfyUI_IPAdapter_plus && ( pip install -r requirements.txt || true )
git clone https://github.com/kijai/ComfyUI-Florence2 && cd ComfyUI-Florence2 && ( pip install -r requirements.txt || true ) 
git clone https://github.com/yolain/ComfyUI-Easy-Use && cd ComfyUI-Easy-Use && ( pip install -r requirements.txt || true )



# Finish
touch /root/.download-complete
