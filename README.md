# CloudFoundry Laboratory Environment Setup

CloudFoundry Laboratory Environment Setup (using Linux)
----

If you are looking for a Windows or Mac based CF development environment your best option is the [CFDev] project.

This project was created because at this time CFDev does not run on Linux (cfdev issue [#18])

## System Requirements

- Intel Linux system (with root privileges using sudo)
- 8GB RAM
- 80 Free Disk space

It was developed/tested using Manjaro Linux, but it should run on any other modern distribution.

## Software Requirements

- git client (usually available on Linux distributions)
- BOSH CLI - https://bosh.io/docs/cli-v2-install/
- CF CLI - https://docs.cloudfoundry.org/cf-cli/install-go-cli.html
- Virtual Box - https://www.virtualbox.org/wiki/Downloads


## Install

Open a terminal.

Clone this repository

```bash
git clone https://github.com/CCSGroupInternational/cf-linux-lab-setup
cd CCSGroupInternational
```

The following scripts will create 2 VBoxes, the first is just connected during the staging, the VM that will run the BOSH(lite) director and the CF components.

```bash
scripts/bosh-lite-director-install.sh   #  Install BOSH(lite) director into a VirtualBox VM
scripts/cf-deployment-lite-install.sh   #  Install CF into the BOSH lite VM
```

# Manage the CF Environment
Once the CF Deployment is finished you can login and deploy apps using the "CF" CLI:

```bash
cf api https://api.bosh-lite.com --skip-ssl-validation
cf auth admin $(bosh int ~/workspace/cf-deployment/state/cf-deployment-vars.yml --path /cf_admin_password)
```

# Known Problems
If you shutdown or reboot the Virtual VM the BOSH(ite) environment will be lost, the recommended practice it's to suspend the VM when finishing your lab activities.

This limitation and how to fix it is docummented at [bosh-cck.md] .

# Reuse the lab
If you exit the terminal that was used for the initial install of the lab, you will need to setup the environment so that you can interact witht he BOSH/CF APIs:

```bash
source scripts/bosh_env.sh              #  Setup BOSH environment variables
```
[bosh-cck.md]: https://github.com/cloudfoundry/bosh-lite/blob/master/docs/bosh-cck.md
[CFDEV]: https://github.com/cloudfoundry-incubator/cfdev
[#18]: https://github.com/cloudfoundry-incubator/cfdev/issues/18