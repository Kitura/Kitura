![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

**A Swift Web Framework and HTTP Server**

[![Build Status - Master](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Summary

Kitura is a web framework and web server that is created for web services written in Swift.

## Table of Contents
* [Summary](#summary)
* [Features](#features)
* [Swift version](#swift-version)
* [Installation](#installation)
  * [macOS](#macos)
  * [Ubuntu Linux](#ubuntu-linux)
  * [Docker](#docker)
  * [Vagrant](#vagrant)
* [Getting Started](#getting-started)
* [Contributing to Kitura](#contributing-to-kitura)
* [Community](#community)

## Features:

- URL routing (GET, POST, PUT, DELETE)
- URL parameters
- Static file serving
- [FastCGI Support](Documentation/FastCGI.md)
- JSON parsing
- Pluggable middleware

## Swift version
Version `0.24` of Kitura requires the **`DEVELOPMENT-SNAPSHOT-2016-06-20-a`** version of Swift 3 trunk (master). You can download this version at [swift.org](https://swift.org/download/). *Kitura is unlikely to compile with any other version of Swift.*

## Installation

* [macOS](#macos)
* [Ubuntu Linux](#ubuntu-linux)
* [Docker](#docker)
* [Vagrant](#vagrant)

### macOS

1. Install [Homebrew](http://brew.sh/) (if you don't already have it installed):

 `$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2. Install the necessary dependencies:

 `$ brew install curl`

3. Download and install [Xcode 8 beta 4](https://developer.apple.com/download/).

4. Download and install the [required Swift version](#swift-version) from `swift.org`.

 During installation if you are using the package installer make sure to select "all users" for the installation path in order for the correct toolchain version to be available for use with the terminal.

 After installation, make sure you update your `PATH` environment variable as described in the `swift.org` installation instructions (e.g. `export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH`)

4. Select the Xcode beta as your active developer directory.

 `$ sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer/`

Now you are ready to develop your first Kitura app. Check [Kitura-Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Getting Started](#getting-started).

### Ubuntu Linux

Kitura is tested on Ubuntu 14.04 LTS and Ubuntu 15.10.

1. Install the following system linux libraries:

 `$ sudo apt-get install autoconf libtool libcurl4-openssl-dev libbsd-dev libblocksruntime-dev`

2. Install the [required Swift version](#swift-version) from `swift.org`.

 Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your [.bashrc file](http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

3. Clone, build and install the libdispatch library.

 The complete instructions for building and installing this library are shown [here](https://github.com/apple/swift-corelibs-libdispatch/blob/experimental/foundation/INSTALL). For convenience, the command to compile is:

 `$ export SWIFT_HOME=<path-to-swift-toolchain>`
 
 `$ git clone --recursive -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && cd swift-corelibs-libdispatch && sh ./autogen.sh && ./configure --with-swift-toolchain=$SWIFT_HOME/usr --prefix=$SWIFT_HOME/usr && make && make install`

Now you are ready to develop your first Kitura app. Check [Kitura-Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Getting Started](#getting-started).

### Docker

1. Install [Docker](https://docs.docker.com/engine/getstarted/step_one/) on your development system.

2. Pull down the [kitura-ubuntu](https://hub.docker.com/r/ibmcom/kitura-ubuntu/) image from Docker Hub:

  `$ docker pull ibmcom/kitura-ubuntu:latest`

3. Create a Docker container using the `kitura-ubuntu` image you just downloaded and forward port 8090 on host to the container:

  `$ docker run -i -p 8090:8090 -t ibmcom/kitura-ubuntu:latest /bin/bash`

4. From within the Docker container, execute the `clone_build_kitura.sh` script to build the [Kitura-Starter-Bluemix](https://github.com/IBM-Swift/Kitura-Starter-Bluemix) sample project:

  `# /root/clone_build_kitura.sh`

  The last two output lines from executing the `clone_build_kitura.sh` script should be similar to:

  ```
  Linking .build/debug/Kitura-Starter-Bluemix
  >> Build for Kitura-Starter-Bluemix completed (see above for results).
  ```

5. You can now run the Kitura-Starter-Bluemix executable inside the Docker container:

  `# /root/start_kitura_sample.sh`

  You should see an output message that contains the string `Listening on port 8090`.

### Vagrant

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

2. Install [Vagrant](https://www.vagrantup.com/downloads.html).

3. From the root of the Kitura folder containing the `vagrantfile`, create and configure a guest machine:

 `$ vagrant up`

4. SSH into the Vagrant machine:

 `$ vagrant ssh`

5. As needed for development, edit the `vagrantfile` to setup [Synced Folders](https://www.vagrantup.com/docs/synced-folders/basic_usage.html) to share files between your host and guest machine.

Now you are ready to develop your first Kitura app. Check [Kitura-Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Getting Started](#getting-started).

## Getting Started

Let's develop your first Kitura web application!

1. First, create a new project directory.

  ```
  $ mkdir myFirstProject
  ```

2. Next, create a new Swift project using the Swift Package Manager.

  ```
  $ cd myFirstProject
  $ swift package init --type executable
  ```

  Now your directory structure under myFirstProject should look like this:
  <pre>
  myFirstProject
  ├── Package.swift
  ├── Sources
  │   └── main.swift
  └── Tests
      └── <i>empty</i>
  </pre>

  Note: For more information on the Swift Package Manager, go [here](https://swift.org/package-manager).

3. In `Package.swift`, add Kitura as a dependency for your project.

  ```swift
  import PackageDescription

  let package = Package(
      name: "myFirstProject",
      dependencies: [
          .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 0, minor: 24)
      ])
  ```

4. In `Sources/main.swift`, import the Kitura module.

  ```swift
  import Kitura
  ```

5. Add a router and a path:

  ```swift
  let router = Router()

  router.get("/") {
      request, response, next in
      response.send("Hello, World!")
      next()
  }
  ```

6. Add an HTTP server and start the Kitura framework.

  ```swift
  Kitura.addHTTPServer(onPort: 8090, with: router)
  Kitura.run()
  ```

7. Your `Sources/main.swift` file should now look like this.

  ```swift
  import Kitura

  let router = Router()

  router.get("/") {
      request, response, next in
      response.send("Hello, World!")
      next()
  }

  Kitura.addHTTPServer(onPort: 8090, with: router)
  Kitura.run()
  ```

8. Optionally, add logging.

   In the code example above, no messages from Kitura will logged. You may want to add a logger to help diagnose any problems that occur.

   Add a HeliumLogger dependency to `Package.swift`.

   ```swift
   import PackageDescription
   
   let package = Package(
       name: "myFirstProject",
       dependencies: [
           .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 0, minor: 24),
           .Package(url: "https://github.com/IBM-Swift/HeliumLogger", majorVersion: 0, minor: 13),
       ])
   ```

   Enable HeliumLogger in `Sources/main.swift`.

   ```swift
   import HeliumLogger

   HeliumLogger.use()
   ```

   Here is the finished `Sources/main.swift` file.

   ```swift
   import Kitura
   import HeliumLogger

   HeliumLogger.use()

   let router = Router()

   router.get("/") {
       request, response, next in
       response.send("Hello, World!")
       next()
   }

   Kitura.addHTTPServer(onPort: 8090, with: router)
   Kitura.run()
   ```

9. Compile your application:

  - macOS: `$ swift build`
  - Linux: `$ swift build -Xcc -fblocks`

  Or copy our [Makefile and build scripts](https://github.com/IBM-Swift/Kitura-Build/blob/master/build) to your project directory and run `make build`. You may want to customize this Makefile and use it for building, testing and running your application. For example, you can clean your build directory, refetch all the dependencies, build, test and run your application by running `make clean refetch test run`.

10. Now run your new web application:

  `$ .build/debug/myFirstProject`

11. Open your browser at [http://localhost:8090](http://localhost:8090)

## Contributing to Kitura

All improvements to Kitura are very welcome! Here's how to get started with developing Kitura itself.

1. Clone this repository.

  `$ git clone https://github.com/IBM-Swift/Kitura`

2. Build and run tests.

  `$ make test`

 ### Notes
 * Homebrew by default installs libraries to `/usr/local`, if yours is different, change the path to find the curl library, in `Kitura-Build/build/Makefile`:

   ```Makefile
   SWIFTC_FLAGS = -Xswiftc -I/usr/local/include
   LINKER_FLAGS = -Xlinker -L/usr/local/lib
   ```

You can find more info on contributing to Kitura in our [contributing guidelines](.github/CONTRIBUTING.md).

## Community

We love to talk server-side Swift, and Kitura. Join our [chat channel on Gitter](https://gitter.im/IBM-Swift/Kitura) to meet the team!
