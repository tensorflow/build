<div align="center">
  <img src="https://github.com/tensorflow/community/blob/master/sigs/logos/SIGBuild.png" width="60%"><br><br>
</div>

-----------------

[![Gitter chat](https://img.shields.io/badge/chat-on%20gitter-46bc99.svg)](https://gitter.im/tensorflow/sig-build)
[![SIG Build Forum](https://img.shields.io/badge/discuss-on%20tensorflow.org-orange)](https://groups.google.com/a/tensorflow.org/g/build)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/tensorflow/build/badge)](https://api.securityscorecards.dev/projects/github.com/tensorflow/build)

**TensorFlow SIG Build** is a community group dedicated to the TensorFlow build
process. This repository is a showcase of resources, guides, tools, and builds
contributed by the community, for the community.

## Group

### Contributing

SIG Build is a community-led open source project. As such, the project
depends on public contributions, bug-fixes, and documentation. Please
see [contribution guidelines](CONTRIBUTING.md) for a guide on how to
contribute. This project adheres to [TensorFlow's code of conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

### Community

* [Public Mailing List](https://groups.google.com/a/tensorflow.org/forum/#!forum/build)
* [SIG Monthly Meeting Notes](https://docs.google.com/document/d/10_3IQ5aF-88ADJNLF0WOpb09bZ15x-sBnRSnDHNCNr8/edit)
    * Join our mailing list and receive calendar invites to the meeting.

### License
[Apache License 2.0](LICENSE)

## Project Showcase

Want to add your own project to this list? It's easy: check out
[CONTRIBUTING.md](CONTRIBUTING.md).

### Docker

* [**TF SIG Build Dockerfiles**](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/tf_sig_build_dockerfiles):
  Standard Dockerfiles for TensorFlow builds, used internally at Google
* [**TensorFlow Runtime Dockerfiles**](tensorflow_runtime_dockerfiles):
  Simple Dockerfiles for running TensorFlow, with Jupyter variants.
* [**Manylinux 2014 Docker Images**](manylinux2014_docker_images):
  `manylinux2014` build environment for TensorFlow packages.
* [**Distroless Dockerfiles**](https://github.com/uvarc/rivanna-docker):
  Distroless ([info](https://github.com/GoogleContainerTools)) TensorFlow
  images, which are smaller than TensorFlow's official images.
* [**DevInfra Windows RBE**](devinfra_windows_rbe):
  Static snapshot of TF DevInfra's Windows Remote Build Execution images

### Language Bindings

* [**Golang Install Guide**](golang_install_guide): Documentation for installing
  the Go bindings.

### Platforms

* [**ppc64le Builds**](ppc64le_builds): Dockerfiles and wheel build scripts for
  building TF on ppc64le.
* [**Raspberry Pi Builds**](raspberry_pi_builds): TensorFlow's old official docs
  for building on Raspberry Pi. Needs an owner.
* [**WSL2 GPU Guide**](wsl2_gpu_guide): Instructions for enabling GPU with Tensorflow
  on a WSL2 virtual machine.

### WIP / Other

* [**Directory Template**](directory_template): Example short description.
* [**TF OSS Dashboard**](tf_oss_dashboard): Dashboard for all continuous
  statuses on TF GitHub Commits.
* [**Tekton CI**](tekton): perfinion's experimental directory for using Tekton 
  CI with TensorFlow

## Community Supported TensorFlow Builds

Amazing members of the TensorFlow community build, test, and package TensorFlow
on more platforms than are supported by the official TensorFlow team. Please
note that as *community* builds they are not supported by the TensorFlow team.

Want to add your own community builds to this list? It's easy: check out
[CONTRIBUTING.md](CONTRIBUTING.md).

### TensorFlow Builds

Owner | Build Type | Status | Artifacts
---: | --- | :---: | :---
AMD | **Linux AMD ROCm GPU** Nightly         | [![Build Status](http://ml-ci.amd.com:21096/job/tensorflow/job/nightly-rocmfork-develop-upstream/job/nightly-build-whl/badge/icon)](http://ml-ci.amd.com:21096/job/tensorflow/job/nightly-rocmfork-develop-upstream/job/nightly-build-whl)   | [Nightly](http://ml-ci.amd.com:21096/job/tensorflow/job/nightly-rocmfork-develop-upstream/job/nightly-build-whl/lastSuccessfulBuild/)
AMD | **Linux AMD ROCm GPU** Stable : TF 2.x | [![Build Status](http://ml-ci.amd.com:21096/job/tensorflow/job/release-rocmfork-r212-rocm-enhanced/job/release-build-whl/badge/icon)](http://ml-ci.amd.com:21096/job/tensorflow/job/release-rocmfork-r212-rocm-enhanced/job/release-build-whl/) | [Release 2.12](http://ml-ci.amd.com:21096/job/tensorflow/job/release-rocmfork-r212-rocm-enhanced/job/release-build-whl/lastSuccessfulBuild/)
AMD | **Linux AMD ROCm GPU** Stable : TF 1.x | [![Build Status](http://ml-ci.amd.com:21096/job/tf-develop-upstream-releases/job/tensorflow-upstream-rel1.15-enhanced-nightly/badge/icon)](http://ml-ci.amd.com:21096/job/tf-develop-upstream-releases/job/tensorflow-upstream-rel1.15-enhanced-nightly/)   | [Release 1.15](http://ml-ci.amd.com:21096/job/tf-develop-upstream-releases/job/tensorflow-upstream-rel1.15-enhanced-nightly/lastSuccessfulBuild/)
AMD | **Linux AMD ZenDNN Plug-in CPU** Stable : TF 2.x | No Badge | [Release 2.x](https://pypi.org/project/zentf/)
IBM | **Linux ppc64le CPU** Nightly | [![Build Status](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Build/) | [Nightly](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Nightly_Artifact/)
IBM | **Linux ppc64le CPU** Stable: TF 1.x | [![Build Status](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Release_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Release_Build/) | Release [1.15](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_CPU_Release_Build/)
IBM | **Linux ppc64le CPU** Stable: TF 2.x | [![Build Status](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_CPU_Release_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_CPU_Release_Build/) | Release [2.x](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_CPU_Release_Build/)
IBM | **Linux ppc64le GPU** Nightly | [![Build Status](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Build/) | [Nightly](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Nightly_Artifact/)
IBM | **Linux ppc64le GPU** Stable: TF 1.x | [![Build Status](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Release_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Release_Build/) | Release [1.15](https://powerci.osuosl.org/job/TensorFlow_PPC64LE_GPU_Release_Build/)
IBM | **Linux ppc64le GPU** Stable: TF 2.x | [![Build Status](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_GPU_Release_Build/badge/icon)](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_GPU_Release_Build/) | Release [2.x](https://powerci.osuosl.org/job/TensorFlow2_PPC64LE_GPU_Release_Build/)
IBM | **Linux s390x** Nightly | [![Build Status](http://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_CI/badge/icon)](http://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_CI/) | [Nightly](http://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_CI/)
IBM | **Linux s390x CPU** Stable Release | [![Build Status](http://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_Release_Build/badge/icon)](https://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_Release_Build/) | [Release](https://ibmz-ci.osuosl.org/job/TensorFlow_IBMZ_Release_Build/)
Intel | **Linux CPU with Intel oneDNN** Stable Release 1.x | No Badge | Release [1.15](https://pypi.org/project/intel-tensorflow/1.15.2/)
Intel | **Linux CPU with Intel oneDNN** Stable Release 2.x | No Badge | Release [2.x](https://pypi.org/project/intel-tensorflow/)
Intel | **Windows CPU with Intel oneDNN** Stable Release 2.x | No Badge | Release [2.x](https://pypi.org/project/intel-tensorflow/)


### TensorFlow Containers

Owner | Container Type | Status | Artifacts
---: | --- | :---: | :---
Arm | **TensorFlow AArch64 Neoverse-N1 CPU** Stable | Static | [Docker Hub](https://hub.docker.com/r/armswdev/tensorflow-arm-neoverse-n1)
AMD| **Linux ROCm GPU** Stable | Static | [Docker Hub](https://hub.docker.com/r/rocm/tensorflow)
Intel | **Linux CPU with Intel oneDNN** Stable | Static | [Docker Hub](https://hub.docker.com/r/intel/intel-optimized-tensorflow)
