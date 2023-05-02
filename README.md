# Automated Setup of a Fresh Machine for Use as a Pastel Supernode
This ansible playbook (`local_version_of_fresh_vps_setup_playbook_for_new_sn.yml`) works in concert with the `automatic_sn_setup.sh` bash script (also included in this repo) to automate as much of the initial configuration as possible for a new Pastel Supernode (SN) on a dedicated fresh Ubuntu 22.04+ instance.

## Prerequisites

To use this script, you need:

1. An Ubuntu server (tested on Ubuntu 22.10) with SSH access. It should have a static IP address, and a minimum of 8 CPU cores, 16gb of RAM, and a 1tb+ SSD/NVME drive.
2. SSH access to the server with the 'root' user

## Usage

Follow these steps to set up your Ubuntu server using this script:

1. SSH into your Ubuntu server as the 'root' user:

```bash
ssh root@<your-server-ip>
```

2. Run the setup script using the following one-liner:

```bash
curl -sSL https://raw.githubusercontent.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn/master/automatic_sn_setup.sh | bash
```

## Features

- Installs essential system packages and tools
- Sets up passwordless sudo for the created user
- Configures SSH authorized keys for the created user
- Sets up and configures Anaconda Python
- Installs oh-my-zsh and powerlevel10k theme
- Configures tmux with custom settings
- Installs and configures various plugins and tools (e.g., zsh-autosuggestions, Zoxide, mcfly, tmux plugin manager, Rust)
- Downloads and installs Pastelup and configures Pastel Supernode


## Repo Contents:

_automatic_sn_setup.sh:_
1. Set environment variables for Pastel repositories and playbook names.
2. Define a function to check for dependencies and install them if not present.
3. Define a function to prompt the user for confirmation before proceeding with the script.
4. Create a setup progress file.
5. Generate a secure password for the 'ubuntu' user.
6. Create the 'ubuntu' user with the generated password and add them to the sudo group.
7. Generate an ed25519 SSH key for the 'ubuntu' user.
8. Display the content of the private key file and instruct the user how to save it.
9. Show the command to download the private key directly from the remote machine.
10. Grant password-less sudo access to the 'ubuntu' user.
11. Update package cache and install required packages (Ansible and Git).
12. Create a directory for the Ansible playbook.
13. Clone the playbook repository.
14. Create an inventory file for the local machine.
15. Run the Ansible playbook on the local machine.
16. Verify that the Ansible playbook finished correctly.
17. Install additional Rust-based utilities.
18. Display final instructions for the user to complete the SuperNode setup.

_local_version_of_fresh_vps_setup_playbook_for_new_sn.yml:_
1. Set target hosts to all and specify variables.
2. Install aptitude and update package cache.
3. Set up passwordless sudo for the created user.
4. Set authorized key for the created user.
5. Update apt and install packages not available in Ubuntu 22.10.
6. Remove dependencies that are no longer required.
7. Add Google official GPG key and Chrome signing key.
8. Add Github signing key and apt repository.
9. Add the Google Chrome repository.
10. Update apt and install required system packages.
11. Search for existing Anaconda install.
12. Download Anaconda Python if not found.
13. Install Anaconda if not found.
14. Add Anaconda to shell and init, and install scikit-learn-intelex.
15. Install oh-my-zsh.
16. Ensure the user 'ubuntu' has a zsh shell.
17. Create directory .local/bin directory.
18. Remove existing .tmux folder and tmux configurations.
19. Install custom tmux configuration and set it up.
20. Set up further tmux customizations.
21. Install powerlevel10k zsh theme and zsh-autosuggestions plugin.
22. Install mcfly.
23. Install tmux plugin manager.
24. Install Rust.
25. Download zshrc file from GitHub and save it to user's home directory.
26. Source the .zshrc file.
27. Remove old existing pastelup.
28. Download pastelup to home directory and rename it.
29. Search for existing pastel install.
30. Run pastelup install command if not found.
31. Check if the pastel.conf file has been modified.
32. Add lines to pastel.conf if not already there.

