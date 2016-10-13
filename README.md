![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

**A Swift Web Framework and HTTP Server**

[![Build Status - Master](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
&nbsp;[![Slack Status](http://swift-at-ibm-slack.mybluemix.net/badge.svg)](http://swift-at-ibm-slack.mybluemix.net/)

## Summary

Kitura is a web framework and web server that is created for web services written in Swift. For more information, visit [www.kitura.io](http://www.kitura.io).

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

## Features

- URL routing (GET, POST, PUT, DELETE)
- URL parameters
- Static file serving
- [FastCGI support](https://github.com/IBM-Swift/Kitura/blob/master/Documentation/FastCGI.md)
- SSL/TLS support
- JSON parsing
- Pluggable middleware

## Swift version
Version `1.0` of Kitura requires **Swift 3.0**. *Kitura is unlikely to compile with any other version of Swift.*

## Installation

* [macOS](#macos)
* [Ubuntu Linux](#ubuntu-linux)
* [Docker](#docker)
* [Vagrant](#vagrant)

### macOS

1. Download and install [Xcode 8](https://developer.apple.com/download/).
2. There is no step 2.

Now you are ready to develop your first Kitura app. Check [Kitura-Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Getting Started](#getting-started).

> Note: if you have been using the Xcode 8 betas, you may also need to run `sudo xcode-select -r` to reset your selected developer directory.

### Ubuntu Linux

Kitura is tested on Ubuntu 14.04 LTS and Ubuntu 15.10.

1. Install the following system linux libraries:

 `$ sudo apt-get install libcurl4-openssl-dev uuid-dev`

2. Install the [required Swift version](#swift-version) from `swift.org`.

 After installing it (i.e. extracting the `.tar.gz` file), make sure you update your `PATH` environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`.

Now you are ready to develop your first Kitura app. Check [Kitura-Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Getting Started](#getting-started).

### Docker

1. Install [Docker](https://www.docker.com/products/docker) on your development system.

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

6. Visit `http://localhost:8090/` in your web browser.

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
          .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0)
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
           .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
           .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 0)
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

  `$ swift build`

  Or copy our [Makefile and build scripts](https://github.com/IBM-Swift/Package-Builder/blob/master/build) to your project directory and run `make build`. You may want to customize this Makefile and use it for building, testing and running your application. For example, you can clean your build directory, refetch all the dependencies, build, test and run your application by running `make clean refetch test run`.

10. Now run your new web application:

  `$ .build/debug/myFirstProject`

11. Open your browser at [http://localhost:8090](http://localhost:8090)

## Contributing to Kitura

All improvements to Kitura are very welcome! Here's how to get started with developing Kitura itself.

1. Clone this repository.

  `$ git clone https://github.com/IBM-Swift/Kitura`

2. Build and run tests.

  `$ make test`

You can find more info on contributing to Kitura in our [contributing guidelines](.github/CONTRIBUTING.md).

## Community

We love to talk server-side Swift, and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!
