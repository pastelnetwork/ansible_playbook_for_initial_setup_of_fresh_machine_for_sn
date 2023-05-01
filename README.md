# Automated Setup of a Fresh Machine for Use as a Pastel Supernode
This ansible playbook works in concert with the `automatic_sn_setup.sh` bash script (also included in this repo) to automate as much of the initial configuration as possible for a new Pastel Supernode (SN) on a dedicated fresh Ubuntu 22.04+ instance.

## Prerequisites

To use this script, you need:

1. An Ubuntu server (tested on Ubuntu 22.10) with SSH access. It should have a static IP address, and a minimum of 8 CPU cores, 16gb of RAM, and a 1tb+ SSD/NVME drive.
2. SSH access to the server with the 'ubuntu' user


## Features

- Installs essential system packages and tools
- Sets up passwordless sudo for the created user
- Configures SSH authorized keys for the created user
- Sets up and configures Anaconda Python
- Installs oh-my-zsh and powerlevel10k theme
- Configures tmux with custom settings
- Installs and configures various plugins and tools (e.g., zsh-autosuggestions, Zoxide, mcfly, tmux plugin manager, Rust)
- Downloads and installs Pastelup and configures Pastel Supernode


## Usage

Follow these steps to set up your Ubuntu server using this script:

1. SSH into your Ubuntu server as the 'ubuntu' user:

```bash
ssh ubuntu@<your-server-ip>
```

2. Run the setup script using the following one-liner:

```bash
curl -sSL https://github.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn/automatic_sn_setup.sh | bash
```
