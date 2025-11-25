# docker-wraps-open-ssh-module
Implements module open ssh for docker wraps environment.

## Usage
Add `docker-wraps-open-ssh-module` to as submodule to your project:
```bash
git submodule add https://github.com/RomaTk/docker-wraps-open-ssh-module.git modules/<name-you-like>
```

## Wraps:
After that you will have the following wraps available:
- `open-ssh-get-latest-version`
- `open-ssh-download-without-configs`
- `open-ssh-download-with-configs`
- `open-ssh-install`
- `open-ssh-keys-work-basic`
- `open-ssh-keys-work-interactive`
- `open-ssh-create-sshd-user`
- `open-ssh-add-public-keys`
- `open-ssh-sshd-basic`
- `open-ssh-sshd-interactive`
- `open-ssh-connect-via-ssh-basic`
- `open-ssh-connect-via-ssh-interactive`


## Creating keys
You can create ssh keys using `open-ssh-keys-work-interactive` wrap. Or using `open-ssh-keys-work-basic` wrap if you want to provide all parameters in advance.

There you can specify within `open-ssh-keys-work-basic` wrap which folder is going to be used for creating keys and which folder will be used to store created keys.
```bash
source ./env-scripts/open-ssh/keys-work/make-keys-folder.sh && main "./secrets" "open-ssh/keys"
```
And volume 
```JSON
{
    "destination": "/working-env/open-ssh/keys-work/basic/keys",
    "source": "./secrets/open-ssh/keys"
}
```

## Adding users to sshd
Based on created keys you can create sshd users using `open-ssh-keys-work-basic` wrap. You can use `open-ssh-add-public-keys` wrap to add public keys to authorized keys of created users.
You need to specify what folder contains created keys, so public keys will be added to corresponding users.
```bash
source ./env-scripts/open-ssh/public-keys-add/move-files-to-config.sh && main "./secrets/open-ssh/keys" "./dockers/open-ssh"
```
## Running sshd server
You can run sshd server using `open-ssh-sshd-interactive` wrap or `open-ssh-sshd-basic` wrap.
You can specify which port to use, by defult: `-p 2222:22`.

## Connecting via ssh
You can connect to sshd server using `open-ssh-connect-via-ssh-interactive` wrap or `open-ssh-connect-via-ssh-basic` wrap.
You need to specify which folder contains created keys, so private keys will be used to connect to corresponding users.
```JSON
{
    "destination": "/working-env/open-ssh/connect-via-ssh/basic/keys",
    "source": "./secrets/open-ssh/keys"
}
```
And also `--network=host` is used by default, but you can modify it as you need.


## Installing Open SSH

You can specify which version of open ssh you want to use by modifying `build.run.before` in `open-ssh-install` wrap. Within:
```bash
source ./env-scripts/open-ssh/install/prepare-before-build.sh && main "<VERSION>" "linux" "./dockers/open-ssh"
```
if no version is specified, latest stable version will be used.

## Requirements

To use you need to have modules:
- https://github.com/RomaTk/docker-wraps-secrets-work-module.git
    - To implement `input-secrets` wrap, but you can create your own way to provide secrets.
- https://github.com/RomaTk/docker-wraps-ubuntu-module.git
    - To implement:
        - `ubuntu-wget-install`
        - `ubuntu-jq-install`
        - `ubuntu-with-latest-packages`
        - `ubuntu-gnupg-install`
        - `ubuntu-user-work`
        - `ubuntu-iproute2-install`
        - `ubuntu-expect-install`
        
        , but you can create your own way

