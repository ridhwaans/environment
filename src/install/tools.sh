#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

if [ "$ADJUSTED_ID" = "mac" ]; then
  run_brew_command_as_target_user tap aws/tap
  run_brew_command_as_target_user tap hashicorp/tap
  run_brew_command_as_target_user upgrade

  packages=(
    gh
		awscli
    aws-sam-cli
    cfn-lint
    hashicorp/tap/terraform
    exercism
	)
	run_brew_command_as_target_user install "${packages[@]}"
else
  # Install gh-cli
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt update
  apt install -y --no-install-recommends gh

  # Install AWS CLI
  if command -v aws &> /dev/null; then
    echo "aws is installed. Version: $(aws --version)"
  else
    curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip --create-dirs -o /tmp/awscli-exe-linux-x86_64.zip && cd $(dirname $_)
    unzip awscli-exe-linux-x86_64.zip -d aws-cli
    ./aws-cli/aws/install --update
    rm -rf aws-cli
    rm -rf awscli-exe-linux-x86_64.zip
  fi

  # Install SAM CLI
  if command -v sam &> /dev/null; then
      echo "sam is installed. Version: $(sam --version)"
  else
    curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip --create-dirs -o /tmp/aws-sam-cli-linux-x86_64.zip && cd $(dirname $_)
    unzip aws-sam-cli-linux-x86_64.zip -d aws-sam-cli
    ./aws-sam-cli/install --update
    rm -rf aws-sam-cli
    rm -rf aws-sam-cli-linux-x86_64.zip
  fi

  # Install cfn-lint
  export PATH="$PATH:/usr/local/share/mise/shims"
  # python3 -m pip install -U cfn-lint

  # Install terraform
  apt install -y --no-install-recommends gpg lsb-release
  wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
  apt update
  apt install -y --no-install-recommends terraform

  # Install exercism-cli
  EXERCISM_VERSION="${EXERCISMVERSION:-"latest"}"
  if command -v exercism &> /dev/null; then
      echo "exercism is installed. Version: $(exercism version)"
  else
    find_version_from_git_tags EXERCISM_VERSION https://github.com/exercism/cli
    case $(uname -m) in
      "x86_64"|"aarch64")
          arch="x86_64"
          ;;
      "arm64")
          arch="arm64"
          ;;
      *)
          echo "Unsupported cpu arch: $(uname -m)"
          exit 1
          ;;
    esac

    case $(uname -s) in
      "Linux")
          sys="linux"
          ;;
      "Darwin")
          sys="darwin"
          ;;
      *)
          echo "Unsupported system: $(uname -s)"
          exit 1
          ;;
    esac
    exercism_filename="exercism-${EXERCISM_VERSION}-${sys}-${arch}.tar.gz"
    curl -L https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/${exercism_filename} --create-dirs -o /tmp/${exercism_filename}
    tar -xzvf /tmp/${exercism_filename} -C /usr/local/bin exercism
    rm -rf /tmp/${exercism_filename}
  fi
fi

echo "Done!"
