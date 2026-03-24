---
date: 2020-03-14T00:00:00Z
tags: [prometheus]
title: Leaving the Prometheus team

---

In January 2017 I joined the company CoreOS as a test-engineer helping the
monitoring team and the [rkt container engine team](https://github.com/rkt/rkt)
write reliable software. Eventually I joined the CoreOS' monitoring team
full-time as a software engineer and ultimately was invited to be part of the
upstream [Prometheus team](https://prometheus.io/) due to my contributions to
the [Alertmanager](https://github.com/prometheus/alertmanager/) sub-project.

Over the next 2 years and 4 month I [worked a lot on
Alertmanager](https://github.com/prometheus/alertmanager/pulls?q=is%3Apr+is%3Aclosed+author%3Amxinden),
e.g. writing parts of its Elm-based UI and introducing [API
v2](https://github.com/prometheus/alertmanager/pull/1352), a bit on [Prometheus
itself](https://github.com/prometheus/prometheus/pulls?q=is%3Apr+is%3Aclosed+author%3Amxinden)
and a bunch within the overall Prometheus and Kubernetes ecosystem e.g. on
[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/issues/498).
In addition being part of the open source project enabled me to speak at many
[conferences and meetups](https://max-inden.de/talks/).

In May 2019 I left Red Hat, which had acquired CoreOS in 2018, thus I was not
working on Prometheus related topics on my day-to-day job anymore. My Prometheus
upstream contributions declined more and more over the next months. I eventually
stepped down as an [Alertmanager
maintainer](https://github.com/prometheus/alertmanager/pull/2153) in January and
now [resigned from the Prometheus
team](https://github.com/prometheus/docs/pull/1576).

From the [pull request](https://github.com/prometheus/docs/pull/1576) removing
myself from the team list:

> In no way should this imply that I am not a very big fan of Prometheus! In
> fact I just pushed for introducing native instrumentation into our main
> product, bugged people not to use a global registry, added 1000 comments on
> metric naming, pitched the power of metric-driven debugging and educated
> everyone on the danger of a cardinality explosions.
>
> I am very thankful for the last 2 years and 4 month! Thanks for including me.
> Keep up this great work.
