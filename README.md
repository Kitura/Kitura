# Phoenix

[![Build Status](https://travis.innovate.ibm.com/ibmswift/Phoenix.svg?token=ePBWPJTgR2KYCeTsit1a&branch=develop)](https://travis.innovate.ibm.com/ibmswift/Phoenix)

Phoenix is a Swift server library that is created for use with the [Swift Package Manager](https://swift.org/package-manager/).

## Installation (OS X - El Capitan)

1. Clone this repository

2. Install homebrew installation if you do not already have it
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3. Run `brew install http-parser`, `brew install pcre2`, `brew install curl`, and `brew install hiredis`

4. Make sure the latest Swift compiler is installed https://swift.org/download/. After installing it, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

5. In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

6. Then run `make` to build the helper libraries, Phoenix framework, and the sample program.

    If you encounter errors in the 'make' build, then make sure you have the latest build of Swift Package Manager:
    
    1. In a separate directory from the Phoenix project, clone the master branch for the Swift Package Manager: `git clone -b master https://github.com/apple/swift-package-manager.git`
    
    2. Execute the following command: `./swift-package-manager/Utilities/bootstrap --prefix <path-to-swift-installation>/usr install`

    *"&lt;path-to-swift-installation&gt;" refers to where you have Swift installed, for example /Library/Developer/Toolchains/swift-latest.xctoolchain (this is the same as $PATH above).  Swift should be at least Swift version 2.2.  You can check the Swift version by executing `swift -v` command in a terminal window.*

7. You can run the sample program which located in: `<path-to-repo>/.build/debug`. From the project root, execute the `./.build/debug/sample` command from a terminal window. You should see a message that says "Listening on port 8090".

## Installation (Linux) ***work in progress***

1. If you choose to set up a virtual machine on your development system, you can download and install [Virtual Box]( https://www.virtualbox.org/wiki/Downloads). If you are installing natively on Linux, skip to step 4.

2. Download the ISO image for [Ubuntu 15.10](http://www.ubuntu.com/download/desktop).

3. Create a virtual machine that uses the Ubuntu ISO image. The following links provide further details on how to do this:

  * [How to create a VM](https://docs.oracle.com/cd/E26217_01/E26796/html/qs-create-vm.html)
  * [How to install Ubuntu on a VirtualBox client](http://askubuntu.com/questions/64915/how-do-i-install-ubuntu-on-a-virtualbox-client-from-an-iso-image)

4. Install the following system linux libraries: `sudo apt-get install libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev libcurl4-gnutls-dev`

5. Install the latest [Swift compiler for Linux](https://swift.org/download/). Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your .bashrc file (for further information on .bashrc and .bash_profile see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

6. Clone the patched libdispatch library: `git clone -b opaque-pointer git://github.com/seabaylea/swift-corelibs-libdispatch`

7. Build and install the patched libdispatch library. Please note that the complete instructions for building and installing this library are found [here](https://github.com/apple/swift-corelibs-libdispatch/blob/master/INSTALL). Though, all you need to do is just this: `cd swift-corelibs-libdispatch && sh ./autogen.sh && ./configure && make && sudo make install`

8. Add a modulemap file for the libdispatch library to the following folder: `/usr/local/include/dispatch`. You can simply copy the contents of the following map module file in [module.modulemap](https://github.ibm.com/ibmswift/IncludeChanges/blob/master/include-dispatch/module.modulemap).

9. Download the [pcre2](http://ftp.exim.org/pub/pcre/pcre2-10.20.tar.gz) source code. Unpack the tar. Run ./configure && make && sudo make install. This will place the necessary headers and libraries into /usr/local/include and /user/local/libs.

10. In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

11. On the root folder of the Phoenix repo, run `make` to build the helper libraries, Phoenix framework, and the sample program.

12. In order to run the sample, first you need to point to the shared libraries that have been built by running `export LD_LIBRARY_PATH=<path_to_phoenix_repo>/build:<path_to_phoenix_repo>/Packages/PhoenixHttpParserHelper-<version>:<path_to_phoenix_repo>/Packages/PhoenixCurlHelpers-<version>:/usr/local/lib:$LD_LIBRARY_PATH`

13. Run the sample program: `<path_to_phoenix_repo>./.build/debug/sample`. You should see a message that says "Listening on port 8090".
