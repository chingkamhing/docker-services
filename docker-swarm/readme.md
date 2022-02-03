# Infrastructure as Code

## How to deploy
* edit inventory.ini accordingly

## Vagrant
* try many things to login with username "user" but fail; seems vagrant created vm must login with "vagrant" only
* so, drop the idea to use vagrant; instead, use VBoxManage to create VMs and manually install CentOS7

## VirtualBox

## Ansible

## Issues
* CentOS fail to yum update
    + occasionally, upon fresh installation, fail to "sudo yum upgrade" with error "Error: requested datatype primary not available"
    + this happen intermittently with different installations
    + don't know how to fix it
    + quick solution is to delete the VM and create another one
* "meta" module must be run unconditionally
    + "meta" module cannot be used with "when" nore in "handlers"
    + i.e. must run "meta" module unconditionally

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
