# WSL2 GPU Guide

Instructions for enabling GPU with Tensorflow on a WSL2 virtual machine.

Maintainer: @Avditvs (Independent)

***

## Install the latest Windows build
You first need to install the latest build of Windows (version 20145 or higher). To do so, you'll have to subscribe to the [Microsoft Windows Insider Program](https://insider.windows.com/en-us/getting-started#register)

Then, install the latest build from the Fast Ring by following the provided instructions.

## Ubuntu 18.04 running is WSL2
First, install WSL2 by following the [instructions](https://docs.microsoft.com/en-us/windows/wsl/install-win10) provided by the Microsoft documentation.  
After that you can download the Ubuntu 18.04 distribution from the Windows Store.

You should now be able to launch it from the Windows terminal or the Windows start menu.  

Finally check that the kernel version is superior than 4.19.121 with the following command `uname -r`. If not, that means that the latest windows build is not installed.

## Install the NVIDIA driver for WSL2
Using CUDA with WSL2 requires specific drivers. Install them by following [these](https://developer.nvidia.com/cuda/wsl) instructions.  

Once installed, you can make sure that the driver is working and check the version by running the command in a Windows PowerShell terminal : `nvidia-smi`

Note : You may encounter issues the 465.12, if this version is not working, revert to a previous WSL2 enabled one (460.20 for instance).

## Install the libraries
The last step is to install the libraries inside the Ubuntu 18.04 virtual machine. This can be done by running the commands below in the Ubuntu terminal.

<pre class="prettyprint lang-bsh">
# Add NVIDIA package repositories
<code class="devsite-terminal">wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.243-1_amd64.deb</code>
<code class="devsite-terminal">sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub</code>
<code class="devsite-terminal">sudo dpkg -i cuda-repo-ubuntu1804_10.1.243-1_amd64.deb</code>
<code class="devsite-terminal">sudo apt-get update</code>
<code class="devsite-terminal">wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb</code>
<code class="devsite-terminal">sudo apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb</code>
<code class="devsite-terminal">sudo apt-get update</code>

# Install development and runtime libraries (~4GB)
<code class="devsite-terminal">sudo apt-get install --no-install-recommends \
    cuda-10-1 \
    libcudnn7=7.6.5.32-1+cuda10.1  \
    libcudnn7-dev=7.6.5.32-1+cuda10.1
</code>

# Install TensorRT. Requires that libcudnn7 is installed above.
<code class="devsite-terminal">sudo apt-get install -y --no-install-recommends libnvinfer6=6.0.1-1+cuda10.1 \
    libnvinfer-dev=6.0.1-1+cuda10.1 \
    libnvinfer-plugin6=6.0.1-1+cuda10.1
</code>

#Add installation directories of libraries to this environment variable below.
<code class="devsite-terminal">export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/include:/usr/local/cuda-10.2/targets/x86_64-linux/lib"
</code>
</pre>

## Check if everything is working
You can check if the GPU is available by running the following command inside a Python terminal (in Ubuntu):  

```
import tensorflow as tf
gpus = tf.config.list_logical_devices(
    device_type='GPU'
)
print(gpus)
```

