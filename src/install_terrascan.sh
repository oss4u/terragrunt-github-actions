#!/bin/bash

function installTerrascan {
  if [[ "${tsVersion}" == "latest" ]]; then
    echo "Checking the latest version of TerraScan"
    latestURL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/accurics/terrascan/releases/latest)
    tsVersion=${latestURL##*/}

    if [[ -z "${tsVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi
  
  tsVersion=$(echo "${tsVersion}" | sed -e "s/^v//")
  
  url="https://github.com/accurics/terrascan/releases/download/v${tsVersion}/terrascan_${tsVersion}_Linux_x86_64.tar.gz"

  echo "Downloading TerraScan v${tsVersion}"
  echo "URL: ${url}"
  curl -s -S -L -o /tmp/terrascan_${tsVersion}.tar.gz ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download TerraScan v${tsVersion}"
    exit 1
  fi
  echo "Successfully downloaded TerraScan v${tsVersion}"

  echo "Uncompress TerraScan v${tfVersion}"
  ls -l /tmp/terra*
  tar xvzf /tmp/terrascan_${tsVersion}.tar.gz terrascan &> /dev/null
  chmod +x ./terrascan
  mv ./terrascan /usr/local/bin/terrascan 
  if [ "${?}" -ne 0 ]; then
    echo "Failed to uncompress TerraScan v${tsVersion}"
    exit 1
  fi
  echo "Successfully uncompressed TerraScan v${tsVersion}"
}