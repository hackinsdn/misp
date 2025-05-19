# MISP @ HackInSDN

This repo contains information about the integration of MISP into HackInSDN. MISP is an open source Threat Intelligence platform widely used for collecting, storing, distributing and sharing cyber security indicators and threats (more information: https://www.misp-project.org). HackInSDN is a framework for training and experimenting in computer networks and cyber security utilizing programmable testbed infrastructure (more information: https://hackinsdn.ufba.br/en/). HackInSDN combines the utilization of MISP with many other tools to provide unique and enriched experience while using the platform for learning or running experiments.

## Getting Started

MISP can be executed on the HackInSDN platform in many ways:

1. (Recommended) Fully integrated with Mininet-Sec and Dashboard HackInSDN through cybersecurity labs and experiments running on Kubernetes: MISP is defined along with the Mininet-Sec topology.

2. Standalone execution running on docker containers, Kubernetes cluster or virtual machines to be (optionally) integrated with other HackInSDN modules like Security Monitoring (using Zeek or Suricata), Anomaly Detection, Containment/IPS, etc.

3. Partially integrated into labs and experiments running on Kubernetes: you run a Pod for MISP defined outside Mininet-Sec.

To simplify the process, we provide a Docker image with MISP installed (based on https://github.com/MISP/misp-docker) and all customizations developed at HackInSDN project.

To run HackInSDN MISP docker:
```
docker pull hackinsdn/misp
docker run -p 8443:443 -d --name misp hackinsdn/misp
```

The default credentials are:
- Username: admin@localhost
- Password: hackinsdn

You will notice that there is an organization already created named "HackInSDN", some standard feeds will also be pre-enabled and PyMISP along with other useful tools and modules will be pre-installed. Finally, a few scripts developed by HackInSDN will be available at `/opt/scripts-hackinsdn`.

An example of a topology file for Mininet-Sec using HackInSDN MISP can be found in [topology-mnsec.yaml](./topology-mnsec.yaml).

## Install MISP manually and apply customizations

Please refer to this [documentation on Installing MISP and applying customizations](./INSTALL-MANUALLY.md).

## References

- https://github.com/MISP/misp-docker
