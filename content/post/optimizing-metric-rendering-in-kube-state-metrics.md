---
date: 2019-05-22T00:00:00Z
title: Talk Optimizing Metric Rendering in kube-state-metrics
tags: [talk]
---

Kube-state-metrics exposes Prometheus metrics of the state of a given Kubernetes
cluster. The project uses the standard Prometheus client Golang library, which
is not optimized for the very specific use case of kube-state-metrics.

This talk covers different optimizations like metric caching and improved text
marshaling dividing CPU usage by a factor of 6 and memory and response time by a
factor of 3 through introducing an intelligent Prometheus metric cache in the
code hot path and optimizing memory allocations during response generation.

- [Recording](https://www.youtube.com/watch?v=dvk_-NCK1Ls)
- [Slides](/static/metric-driven-performance-optimization/slides.pdf)
- [Write-Up](/blog/2019-06-25-metric-driven-performance-optimization/)
