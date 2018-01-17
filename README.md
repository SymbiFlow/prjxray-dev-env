# Standardized development environment for prjxray

* Based on Ubuntu 16.04LTS (Xenial)
* C++ and Python tools required to build prjxray sources
* Vivado Design Edition

# How to build

You'll need to download a full installer (.tar.gz ~20GB in size) of
[Vivado](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2017-2.html)
directly from Xilinx due to redistribution restrictions.  Once you have a copy,
it needs to be available to Docker via a URL.  A simple solution is to launch a
Python SimpleHTTPServer in the same directory as the installer tar.gz:

```
$ python -m SimpleHTTPServer
Serving HTTP on 0.0.0.0 port 8000 ...
```

Now you can build the container:

```
docker build --build-arg VIVADO_URL='http://localhost:8000/Xilinx_Vivado_SDK_2017.2_0616_1.tar.gz' -t my_image .
```

This will take 20+ minutes.

# Usage

Commands run via 'docker run' will be run as a non-root user.  The UID of that
user can be changed via the LOCAL\_USER\_ID environment variable:

```
docker run -it -e LOCAL_USER_ID=`id -u` /bin/bash
```

This is especially important if you bind mount a volume with -v.  The above
command will change the UID inside the container to match the UID running the
docker command.  Typically this will allow you to access files in bind mounts
without issue.
