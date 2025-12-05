---
title: Building and Hosting a static website from a Raspberry Pi using Docker Swarm
date: 2025-12-05 12:00:00 +/-TTTT
categories: [Homelab]
tags: [homelab, hosting, docker, jekyll, cicd, cloudflare]     # TAG names should always be lowercase
---

This website is currently hosted across a cluster of Raspberry Pi's using Docker Swarm hosted on-prem in my little homelab.

### Tech Stack:
- Frontend
    - Jekyll generated static site using the Chirpy theme
- Backend
    - Nginx Docker Containers replicated across a swarm
    - Networked together with a load balancer and routed though Cloudflare

### Automations:
Deployment to the swarm is automated using an Ansible playbook and a github action is used to build a docker image when the main branch of the websites repo is pushed too.

### Why:
The main reason behind this project was to learn more about docker swarm in terms of self hosting and scalability whilst also getting to grips with Cloudflare and Github CI/CD pipelines for a project idea that I have coming up. In the future this service might be migrated to a cloud based cluster as I host more of my services publically.

#### Code for this project is available on my [Github](https://github.com/Spectre7651/Blueprints-Cloudforest1)