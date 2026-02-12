---
title: Ansible and Git Repos
date: 2026-02-12 12:50:00 +/-TTTT
categories: [Automation, SideProject]
tags: [ansible, cicd, automation, git, github]     # TAG names should always be lowercase
---

As a part of my Full Stack Dev module this semester I was required to link my GitHub Account to a cloud hosting provider to host the projects. Normally I would host this on my own cluster because I'm 'too' security conscious I didn’t want to give this provider I had never heard of my access token for GitHub

Therefore, I had the idea to use a proxy account, and one of my Homelab servers to proxy the commits across and keep my account secure.

And as always, I could have copied this manually but...

![Desktop View](../assets/postMedia/2026-02-08/canItBeAutomatedMeme.webp){: width="640" height="480" }
_Can It Be Automated Meme_

So, I used Ansible to pull sync and push the changes bidirectionally between the repos using Unison to sync them

#### This post explores how that playbook works and why it's such an overkill solution for a basic problem.

> This is a solution to my specific problem and will not work for everyone!
{: .prompt-warning }
---
### The Playbook
This playbook installs, sets-up and executes the sync using unison.

``` YAML
  vars:
    repo_dirs:
      - /example/myRepo
      - /example/proxyRepo
        ...
```
This vars section sets the repo vars for what directories need to be synced and they should be entered in the format myRepo then proxyRepo so in this example ```/example/myRepo``` will be synced with ```/example/proxyRepo``` and vice versa.

``` YAML
 tasks:
  - name: Ensure Unison is installed
    ansible.builtin.apt:
      name: unison
      state: present
  - name: Ensure ~/.unison directory exists
    ansible.builtin.file:
      path: ~/.unison
      state: directory
```
This next bit ensures that Unison is installed and its config directory exists.

> This will be updated to support other package managers at some point!
{: .prompt-info }

``` YAML
  - name: Ensure sync files are in place
    ansible.builtin.template:
      src: "{{ item.src }}"
      dest: "{{ item.dest }}"
    with_items:
      - src: templates/examplesync.prf.j2
        dest: ~/.unison/examplesync
```
This uses ansible's built-in templating engine to ensure that the unison sync is correctly configured

```
root = /example/myRepo
root = /example/proxyRepo

ignore = Name .git

auto = true
batch = true
prefer = newer
```
This code in the ```examplesync.prf.j2``` file sets up the sync parameters and sets it up for git and automatic transfer - perfect for ansible

``` YAML
  - name: (Git) Stash local changes
    ansible.builtin.shell: git stash
    args:
      chdir: "{{ item }}"
    loop: "{{ repo_dirs }}"
    ignore_errors: true
    register: stash_result

  - name: (Git) Git Pull repos
    ansible.builtin.shell: |
      git pull
    args:
      chdir: "{{ item }}"
    loop: "{{ repo_dirs }}"

  - name: (Git) Apply Stashed Changes
    ansible.builtin.shell: git stash pop
    args:
      chdir: "{{ item }}"
    loop: "{{ repo_dirs }}"
    register: pop1_result
    changed_when: false
    failed_when: false
    when: stash_result.results[0].stdout == "No local changes to save"
```
This next part effectively pulls the latest changes from the remotes and updates them locally - using stash and pull from git

``` YAML
  - name: Sync the directories
    ansible.builtin.shell:
      cmd: unison {{ item.set }}
    with_items: 
      - set: playgroundsync
      - set: assignmentsync
  
  - name: (Git) Push the repos
    ansible.builtin.shell: |
      git add -A
      git commit -m "Automated commit by Ansible"
      git push
    args:
      chdir: "{{ item }}"
    loop: "{{ repo_dirs }}"
```
This last part is where the magic happens. Unison syncs the two GitHub repos preferring the newest changes to files and then commits and pushes to the two remotes.

### Now to sync the two remotes I simply run
``` ansible-playbook -i inventory main.yaml```
And after about 10 seconds they are perfectly in sync.
### Results

This project results in two perfectly in sync repo's meaning that no matter what repo I modify they will sync to the other.

However, this will probably not work if both repos receive changes and then have to merge as there is not git checking meaning there is a high change the repos won't combine well.

I also made this script with the idea that I would be the only person changing the sources however it demonstrates how Ansible is a versatile tool which along with my Homelab infrastructure allows me to keep a little more secure and learn some really powerful tools.


