# Infrastructure as Code
What this project does
* use virtualbox to provision VMs automatically
* use ansible to provision docker swarm nodes
* install software stacks (e.g. log, monitoring stack, etc.)

## How to provision
* create virtual machines (i.e. VMs)
    + edit .env accordingly
        - set the VMs username and password
        - set VMs hardware config (e.g. number of cpus and memory size)
    + edit inventory.ini accordingly
        - add/remove docker manager and worker nodes accordingly
        - define the hostname for each docker node
        - note: no need to set the ansible_host for now
    + create VMs
        - invoke "set -a; source .env; set +a" to set the environment variables
        - invoke "make create-vm" to create the VMs accordingly to inventory.ini
        - wait till installation done (approximately 10~15 minutes)
        - once done, login and invoke "ip addr" to get the VM's ip address
* provision docker swarm nodes
    + edit inventory.ini accordingly
        - update docker manager and worker nodes' ansible_host (i.e. VM's ip address) and ansible_user
    + provision docker swarm
        - invoke "set -a; source .env; set +a" to set the environment variables
        - invoke "make provision" to provision docker swarm accordingly to inventory.ini
        - will prompt you for the password of
            1) username password
            2) sudo password
        - provision one VM alone takes approximately 10~15 minutes
* config ssh config file
    + to ssh to VMs passwordlessly with hostname instead of ip address (e.g. "ssh user@manager-1")
    + when provision done, invoke "make ssh-config >> ~/.ssh/config"
    + be noted that this will modify host user's "$HOME/.ssh/config"

## How to use
* add VMs
    + update inventory.ini accordingly
    + invoke "set -a; source .env; set +a"
    + invoke "make create-vm"
    + wait installation done, update ip address in inventory.ini accordingly
    + invoke "make provision"
    + wait provision done, update "~/.ssh/config" accordingly
* remove VMs
    + docker demote if the target node is a manager (e.g. "docker node demote NODE" in manager node)
    + docker drain the target node (e.g. "docker node update --availability drain NODE" in manager node)
    + docker leave the swarm (e.g. "docker swarm leave" in the target node)
    + docker remove the docker node (e.g. "docker node rm NODE" in manager node)
    + remove VMs in inventory.ini accordingly
    + remove VMs in "~/.ssh/config" accordingly
    + delete the VM from virtualbox (e.g. "VBoxManage unregistervm --delete VM")
* power on the VMs
    + invoke "make on"
* power off the VMs
    + invoke "make off"

## Vagrant
* try many things to login with username "user" but fail; seems vagrant created vm must login with "vagrant" only
* so, drop the idea to use vagrant; instead, use VBoxManage to create VMs and unattended install CentOS7

## Issues
* CentOS fail to yum update
    + occasionally, upon fresh installation, fail to "sudo yum upgrade" with error "Error: requested datatype primary not available"
    + this happen intermittently with different installations
    + don't know how to fix it
    + quick solution is to delete the VM and create another one
* "meta" module must be run unconditionally
    + "meta" module cannot be used with "when" nore in "handlers"
    + i.e. must run "meta" module unconditionally
* occasionally stuck in upgrade all packages
    + upon invoking "make provision", VM occasionally stuck in upgrade all packages
    + waited for > 1 hour and failed

## Reference
* vagrant
    + [Create multiple virtual machine with one Vagrantfile](https://sharadchhetri.com/create-multiple-virtual-machine-with-one-vagrantfile/)
    + [Ansible Vagrant Example – Introduction to Ansible Vagrant](https://www.middlewareinventory.com/blog/vagrant-ansible-example/)
* virtualbox
    + [Chapter 8. VBoxManage](https://www.virtualbox.org/manual/ch08.html)
    + [How to create a VirtualBox VM from command line](https://andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/)
    + [How to Automate Virtual Machine Installation on VirtualBox](https://kifarunix.com/how-to-automate-virtual-machine-installation-on-virtualbox/)
    + [Guide for VirtualBox VM unattended installation](https://blogs.oracle.com/virtualization/post/guide-for-virtualbox-vm-unattended-installation)
* ansible
    + [Ansible AD HOC Command Examples – Ansible Cheat Sheet](https://www.middlewareinventory.com/blog/ansible-ad-hoc-commands/)
    + [Ansible Playbook Examples – Sample Ansible Playbooks](https://www.middlewareinventory.com/blog/ansible-playbook-example/)
    + [Ansible 101](https://medium.com/@denot/ansible-101-d6dc9f86df0a)
    + [Ansible In Action](https://medium.com/@ahmadfarag/ansible-in-action-f2f17706931)
    + [Deploying Docker Swarm with Ansible](https://medium.com/@cantrobot/deploying-docker-swarm-with-ansible-a991c1028427)
    + [ansible-docker-swarm](https://github.com/ruanbekker/ansible-docker-swarm)
    + [How to launch and manage Docker through Ansible playbook](https://www.linkedin.com/pulse/how-launch-manage-docker-through-ansible-playbook-abhishek-biswas)
    + [Discovering variables: facts and magic variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html)
    + [All about Ansible loops with examples](https://debugfactor.com/all-about-ansible-loops-with-examples/)
* docker plugin: Loki
    + [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
    + [running loki and grafana on docker swarm](https://drailing.net/2020/06/running-loki-and-grafana-on-docker-swarm/)
