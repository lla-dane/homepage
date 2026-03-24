---
date: 2017-10-22T00:00:00Z
title: Talk Self-healing Kubernetes
tags: [tech, talk]
---
What If Component xxx Dies? Introducing Self-Healing Kubernetes

Kubernetes promises healing your application on all kinds of failure scenarios,
but why not self-heal Kubernetes itself? 

This talk introduces self-hosted Kubernetes (K8s inside itself) to autonomously
recover from failure scenarios with the help of e.g. itself, systemd and
checkpointing. We will ask and answer questions like “What happens when xxx
dies”. The theory will be followed by a demo on a live cluster showcasing what
happens when we kill central Kubernetes components, like the API-Server. Let’s
see how well Kubernetes recovers.

- [Slides](/static/self-healing-k8s.pdf)
- [Recording](https://media.ccc.de/v/ASG2017-137-what_if_component_xxx_dies_introducing_self-healing_kubernetes)
