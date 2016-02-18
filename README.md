# Kitura

[![Build Status](https://travis-ci.com/IBM-Swift/Kitura.svg?token=HbPXgFCvQeph5JZPCbdW&branch=master)](https://travis-ci.com/IBM-Swift/Kitura/)

Kitura is a Swift server library that is created for use with the [Swift Package Manager](https://swift.org/package-manager/).

## Installation (OS X - El Capitan)

1. Clone this repository

2. Install homebrew installation if you do not already have it
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3. Run `brew install http-parser`, `brew install pcre2`, `brew install curl`, and `brew install hiredis`

4. Make sure the latest Swift compiler is installed https://swift.org/download/. After installing it, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

5. In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

6. Then run `make` to build the helper libraries, Kitura framework, and the sample program.

7. You can run the sample program which located in: `<path-to-repo>/.build/debug`. From the project root, execute the `./.build/debug/KituraSample` command from a terminal window. You should see a message that says "Listening on port 8090".

## Installation (Linux)

### Setting up a VM (optional)

1. If you choose to set up a virtual machine on your development system, you can download and install [Virtual Box]( https://www.virtualbox.org/wiki/Downloads). If you are installing natively on Linux, skip to step 4.

2. Download the ISO image for [Ubuntu 15.10](http://www.ubuntu.com/download/desktop).

3. Create a virtual machine that uses the Ubuntu ISO image. The following links provide further details on how to do this:

  * [How to create a VM](https://docs.oracle.com/cd/E26217_01/E26796/html/qs-create-vm.html)
  * [How to install Ubuntu on a VirtualBox client](http://askubuntu.com/questions/64915/how-do-i-install-ubuntu-on-a-virtualbox-client-from-an-iso-image)

### Configuring dependencies and installation

1. Install the following system linux libraries: `sudo apt-get install libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev`

2. Install the latest [Swift compiler for Linux](https://swift.org/download/). Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your .bashrc file (for further information on .bashrc and .bash_profile see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

3. Clone the patched libdispatch library: `git clone -b opaque-pointer git://github.com/seabaylea/swift-corelibs-libdispatch`

4. Build and install the patched libdispatch library. Please note that the complete instructions for building and installing this library are found [here](https://github.com/seabaylea/swift-corelibs-libdispatch/blob/opaque-pointer/INSTALL). Though, all you need to do is just this: `cd swift-corelibs-libdispatch && sh ./autogen.sh && ./configure && make && sudo make install`

5. Add a modulemap file for the libdispatch library to the following folder: `/usr/local/include/dispatch`. You can simply copy the contents of the following map module file in [module.modulemap](https://github.com/IBM-Swift/Kitura/blob/master/Sources/Modulemaps/module.modulemap).

6. Download the [pcre2](http://ftp.exim.org/pub/pcre/pcre2-10.20.tar.gz) source code. Unpack the tar. Run ./configure && make && sudo make install. This will place the necessary headers and libraries into /usr/local/include and /user/local/libs.

7. In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

8. On the root folder of the Kitura repo, run `make` to build the helper libraries, Kitura framework, and the sample program.

9. In order to run the sample, first you need to point to the shared libraries that have been built by running `export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH`

10. Run the sample program: `<path_to_kitura_repo>./.build/debug/KituraSample`. You should see a message that says "Listening on port 8090".
