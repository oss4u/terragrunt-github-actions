#!/bin/bash

function installTerrascan {
  if [[ "${tsVersion}" == "latest" ]]; then
    echo "Checking the latest version of TerraScan"
    latestURL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/accurics/terrascan/releases/latest)
    tsVersion=${latestURL##*/}
    tsVersion=echo "${tsVersion}" | sed s/^v//

    if [[ -z "${tsVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi
  
  url="https://github.com/accurics/terrascan/releases/download/v${tsVersion}/terrascan_${tsVersion}_Linux_x86_64.tar.gz"

  echo "Downloading TerraScan v${tsVersion}"
  echo "URL: ${url}"
  curl -s -S -L -o /tmp/terrascan_${tsVersion}.zip ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download TerraScan v${tsVersion}"
    exit 1
  fi
  echo "Successfully downloaded TerraScan v${tsVersion}"

  echo "Unzipping TerraScan v${tfVersion}"
  ls -l /tmp/terra*
  unzip -d /usr/local/bin /tmp/terrascan_${tsVersion}.zip &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip TerraScan v${tsVersion}"
    exit 1
  fi
  echo "Successfully unzipped TerraScan v${tsVersion}"
}