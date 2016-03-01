![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

**A Swift Web Framework and HTTP Server**

[![Build Status](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura)
[![Build Status](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=develop)](https://travis-ci.org/IBM-Swift/Kitura)
![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Swift 2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Summary

Kitura is a web framework and web server that is created for web services written in Swift.

## Features:

- URL routing (GET, POST, PUT, DELETE)
- URL parameters
- Static file serving
- JSON parsing
- Pluggable middleware

## Swift version
The latest version of Kitura works with the DEVELOPMENT-SNAPSHOT-2016-02-25-a version of the Swift binaries. You can download this version of the Swift binaries by following this [link](https://swift.org/download/).

## Installation (Docker development environment)

1. Install [Docker](https://docs.docker.com/engine/installation/) on your development system and start a Docker session/terminal.

2. From the Docker session, pull down the `kitura-ubuntu` image from Docker Hub:

  `docker pull ibmcom/kitura-ubuntu:latest`

3. Create a Docker container using the `kitura-ubuntu` image you just downloaded:

  `docker run -i -t ibmcom/kitura-ubuntu:latest /bin/bash`

4. From within the Docker container, execute the `ci.sh` script to build Kitura and execute the test cases:

  `/root/ci.sh`

  The last output line from executing the `ci.sh` script should be similar to:

  `>> Build and execution of test cases completed (see above for results).`

5. You can now run the KituraSample executable inside the Docker container:

  `/root/Kitura/.build/debug/KituraSample`

  You should see a message that says "Listening on port 8090".

## Installation (Vagrant development environment)

1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

2. Download [Vagrant](https://www.vagrantup.com/downloads.html).

3. From the root of the Kitura folder containing the `vagrantfile`, create and configure a guest machine:

 `vagrant up`

4. SSH into the Vagrant machine:

 `vagrant ssh`

5. From the Vagrant shell, run the sample program:

 `Kitura/.build/debug/KituraSample`. You should see a message that says "Listening on port 8090".

6. As needed for development, edit the `vagrantfile` to setup [Synced Folders](https://www.vagrantup.com/docs/synced-folders/basic_usage.html) to share files between your host and guest machine.

## Installation (OS X)

1. Clone this repository:

 `git clone https://github.com/IBM-Swift/Kitura`

2. Install [Homebrew](http://brew.sh/) (if you don't already have it installed):

 `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3. Install the necessary dependencies:

 `brew install http-parser pcre2 curl hiredis`

4. Download and install the [supported Swift compiler](#swift-version).

 After installing it, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

5. Build Kitura and Kitura Sample

 `swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib`

 Homebrew by default installs libraries to `/usr/local`, if yours is different, change the path to find curl and http-parser libraries.

6. Run KituraSample:

 You can run the sample program which located in: `<path-to-repo>/.build/debug`. From the project root, execute the `./.build/debug/KituraSample` command from a terminal window. You should see a message that says "Listening on port 8090".

## Installation (Linux)

1. Install the following system linux libraries:

 `sudo apt-get install libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev`

2. Install the [supported Swift compiler](#swift-version) for Linux.

 Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your .bashrc file (for further information on .bashrc and .bash_profile see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

3. Clone the libdispatch library:

 `git clone https://github.com/apple/swift-corelibs-libdispatch.git`

4. Build and install the libdispatch library:

 Please note that the complete instructions for building and installing this library are found [here](https://github.com/apple/swift-corelibs-libdispatch/blob/master/INSTALL). Though, all you need to do is just this: `cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr && make && make install`

5. Compile and install PCRE2:

 Download the [pcre2](http://ftp.exim.org/pub/pcre/pcre2-10.20.tar.gz) source code. Unpack the tar. Run `./configure && make && sudo make install`. This will place the necessary headers and libraries into /usr/local/include and /user/local/libs.

6. Build Kitura and KituraSample

  `swift build -Xcc -fblocks`

7. Run the sample program:

 `<path_to_kitura_repo>./.build/debug/KituraSample`. You should see a message that says "Listening on port 8090".

## Usage
Let's write our first Kitura-based Web Application written in Swift!

1. First we need to create a new project directory

```bash
mkdir myFirstProject
```

2. Next we need to go in an initialize this project as a new Swift package project

```bash
cd myFirstProject
swift build --init
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

Note: For more information on the Swift Package Manager, go [here](https://swift.org/package-manager)

3. Now we need to add Kitura as a dependency for your project (Package.swift):

```swift
import PackageDescription

let package = Package(
  name: "myFirstProject",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Kitura-router.git", versions: Version(0,3,0)..<Version(0,4,0)),
  ]
)
```

4. Import the modules in your code:

```swift
import KituraRouter
import KituraNet
import KituraSys
```
5. Add a router and a path:

```swift
let router = Router()

router.get("/") {
  request, response, next in
  response.status(HttpStatusCode.OK).send("Hello, World!")
  next()
}
```

6. Create and start a HTTPServer:

```swift
let server = HttpServer.listen(8090, delegate: router)
Server.run()
```

7. Sources/main.swift file should now look like this:

```swift
import KituraRouter
import KituraNet
import KituraSys

let router = Router()

router.get("/") {
request, response, next in

	response.status(HttpStatusCode.OK).send("Hello, World!")

	next()
}

let server = HttpServer.listen(8090, delegate: router)
Server.run()
```

8. Compile your application:

  - Mac OS X: `swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib`
  - Linux:  `swift build -Xcc -fblocks`

9. Now run your new web application:

```
.build/debug/myFirstProject
```

10. Open your browser at [http://localhost:8090](http://localhost:8090)

## Kitura Wiki
Feel free to visit our [Wiki](https://github.com/IBM-Swift/Kitura/wiki/Kitura-Wiki) (which, btw, is in very early stages).

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
