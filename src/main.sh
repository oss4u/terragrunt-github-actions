#!/bin/bash
scriptDir=$(dirname ${0})

mkdir -p ~/.ssh
echo "Host *" > ~/.ssh/config
echo "	StrictHostKeyChecking no" >> ~/.ssh/config

function stripColors {
  echo "${1}" | sed 's/\x1b\[[0-9;]*m//g'
}

function hasPrefix {
  case ${2} in
    "${1}"*)
      true
      ;;
    *)
      false
      ;;
  esac
}

function parseInputs {
  # Required inputs
  if [ "${INPUT_TF_ACTIONS_VERSION}" != "" ]; then
    tfVersion=${INPUT_TF_ACTIONS_VERSION}
  else
    echo "Input terraform_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_TG_ACTIONS_VERSION}" != "" ]; then
    tgVersion=${INPUT_TG_ACTIONS_VERSION}
  else
    echo "Input terragrunt_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_TS_ACTIONS_VERSION}" != "" ]; then
    tsVersion=${INPUT_TS_ACTIONS_VERSION}
  else
    echo "Input terrascan_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_TF_ACTIONS_SUBCOMMAND}" != "" ]; then
    tfSubcommand=${INPUT_TF_ACTIONS_SUBCOMMAND}
  else
    echo "Input terraform_subcommand cannot be empty"
    exit 1
  fi

  # Optional inputs
  tfWorkingDir="."
  if [[ -n "${INPUT_TF_ACTIONS_WORKING_DIR}" ]]; then
    tfWorkingDir=${INPUT_TF_ACTIONS_WORKING_DIR}
  fi

  tfBinary="terragrunt"
  if [[ -n "${INPUT_TF_ACTIONS_BINARY}" ]]; then
    tfBinary=${INPUT_TF_ACTIONS_BINARY}
  fi

  tfComment=0
  if [ "${INPUT_TF_ACTIONS_COMMENT}" == "1" ] || [ "${INPUT_TF_ACTIONS_COMMENT}" == "true" ]; then
    tfComment=1
  fi

  tfCLICredentialsHostname=""
  if [ "${INPUT_TF_ACTIONS_CLI_CREDENTIALS_HOSTNAME}" != "" ]; then
    tfCLICredentialsHostname=${INPUT_TF_ACTIONS_CLI_CREDENTIALS_HOSTNAME}
  fi

  tfCLICredentialsToken=""
  if [ "${INPUT_TF_ACTIONS_CLI_CREDENTIALS_TOKEN}" != "" ]; then
    tfCLICredentialsToken=${INPUT_TF_ACTIONS_CLI_CREDENTIALS_TOKEN}
  fi

  tfFmtWrite=0
  if [ "${INPUT_TF_ACTIONS_FMT_WRITE}" == "1" ] || [ "${INPUT_TF_ACTIONS_FMT_WRITE}" == "true" ]; then
    tfFmtWrite=1
  fi

  tfWorkspace="default"
  if [ -n "${TF_WORKSPACE}" ]; then
    tfWorkspace="${TF_WORKSPACE}"
  fi
}

function configureCLICredentials {
  if [[ ! -f "${HOME}/.terraformrc" ]] && [[ "${tfCLICredentialsToken}" != "" ]]; then
    cat > ${HOME}/.terraformrc << EOF
credentials "${tfCLICredentialsHostname}" {
  token = "${tfCLICredentialsToken}"
}
EOF
  fi
}

source ${scriptDir}/install_terragrunt.sh
source ${scriptDir}/install_terraform.sh
source ${scriptDir}/install_terrascan.sh


function main {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/terragrunt_fmt.sh
  source ${scriptDir}/terragrunt_init.sh
  source ${scriptDir}/terragrunt_run-all_init.sh
  source ${scriptDir}/terragrunt_run-all_validate.sh
  source ${scriptDir}/terragrunt_run-all_plan.sh
  source ${scriptDir}/terragrunt_run-all_apply.sh
  source ${scriptDir}/terragrunt_output.sh
  source ${scriptDir}/terragrunt_import.sh
  source ${scriptDir}/terragrunt_taint.sh
  source ${scriptDir}/terragrunt_destroy.sh

  parseInputs
  configureCLICredentials
  installTerraform
  installTerragrunt
  installTerrascan
  cd ${GITHUB_WORKSPACE}/${tfWorkingDir}

  case "${tfSubcommand}" in
    fmt)
      # installTerragrunt
      terragruntFmt ${*}
      ;;
    init)
      # installTerragrunt
      terragruntInit ${*}
      ;;
    init-all)
      # installTerragrunt
      terragruntRunAllInit ${*}
      ;;
    validate)
      # installTerragrunt
      terragruntValidate ${*}
      ;;
    validate-all)
      # installTerragrunt
      terragruntRunAllValidate ${*}
      ;;
    plan)
      # installTerragrunt
      terragruntPlan ${tfSubcommand} ${*}
      ;;
    plan-all)
      # installTerragrunt
      terragruntRunAllPlan ${tfSubcommand} ${*}
      ;;
    apply)
      # installTerragrunt
      terragruntApply ${tfSubcommand} ${*}
      ;;
    apply-all)
      # installTerragrunt
      terragruntRunAllApply ${tfSubcommand} ${*}
      ;;
    output)
      # installTerragrunt
      terragruntOutput ${*}
      ;;
    import)
      # installTerragrunt
      terragruntImport ${*}
      ;;
    taint)
      # installTerragrunt
      terragruntTaint ${*}
      ;;
    destroy)
      # installTerragrunt
      terragruntDestroy ${*}
      ;;
    *)
      echo "Error: Must provide a valid value for terragrunt_subcommand"
      exit 1
      ;;
  esac
}

main "${*}"
