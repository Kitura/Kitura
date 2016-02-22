![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

**A Swift Web Framework and HTTP Server**

![Build Status](https://travis-ci.com/IBM-Swift/Kitura.svg?token=HbPXgFCvQeph5JZPCbdW&branch=master)
![Build Status](https://travis-ci.com/IBM-Swift/Kitura.svg?token=HbPXgFCvQeph5JZPCbdW&branch=develop)
![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Swift 2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Summary

[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Kitura is a web framework and web server that is created for web services written in Swift.

## Features:

- URL routing (GET, POST, PUT, DELETE)
- URL parameters
- Static file serving
- JSON parsing
- Pluggable middleware

## Installation (OS X)

1. Clone this repository:

 `git clone https://github.com/IBM-Swift/Kitura`

2. Install [Homebrew](http://brew.sh/):

 `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3. Install the necessary dependencies:

 `brew install http-parser`, `brew install pcre2`, `brew install curl`, and `brew install hiredis`

4. Download and install the latest Swift compiler.

 Make sure the latest Swift compiler is installed https://swift.org/download/. After installing it, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

5. Grab the Swift package dependencies using Swift Package Manager

 In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

6. Build Kitura and Kitura Sample

 Then run `make` to build the helper libraries, Kitura framework, and the sample program.

7. Run KituraSample:

 You can run the sample program which located in: `<path-to-repo>/.build/debug`. From the project root, execute the `./.build/debug/KituraSample` command from a terminal window. You should see a message that says "Listening on port 8090".

## Installation (Linux)

1. Install the following system linux libraries:

 `sudo apt-get install libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev`

2. Install the latest [Swift compiler for Linux](https://swift.org/download/).

 Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your .bashrc file (for further information on .bashrc and .bash_profile see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

3. Clone the patched libdispatch library:

 `git clone -b opaque-pointer git://github.com/seabaylea/swift-corelibs-libdispatch`

4. Build and install the patched libdispatch library:

 Please note that the complete instructions for building and installing this library are found [here](https://github.com/seabaylea/swift-corelibs-libdispatch/blob/opaque-pointer/INSTALL). Though, all you need to do is just this: `cd swift-corelibs-libdispatch && sh ./autogen.sh && ./configure && make && sudo make install`

5. Install modulemap on the system:

  Add a modulemap file for the libdispatch library to the following folder: `/usr/local/include/dispatch`. You can simply copy the contents of the following map module file in [module.modulemap](https://github.com/IBM-Swift/Kitura/blob/master/Sources/Modulemaps/module.modulemap).

6. Compile and install PCRE2:

 Download the [pcre2](http://ftp.exim.org/pub/pcre/pcre2-10.20.tar.gz) source code. Unpack the tar. Run ./configure && make && sudo make install. This will place the necessary headers and libraries into /usr/local/include and /user/local/libs.

7. Download the Kitura dependencies with Swift Package Manager:

 In the root directory of this project run `swift build` to copy the dependencies. **Note the build process itself will fail!**

8. Build the helper modules:

 On the root folder of the Kitura repo, run `make` to build the helper libraries, Kitura framework, and the sample program.

9. Set the dynamic library loading path:

 In order to run the sample, first you need to point to the shared libraries that have been built by running `export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH`

10. Run the sample program:

 `<path_to_kitura_repo>./.build/debug/KituraSample`. You should see a message that says "Listening on port 8090".

## Usage
Let's write our first Kitura-based Web Application written in Swift!

1) First we need to create a new project directory

```bash
mkdir myFirstProject
```

2) Next we need to go in an initialize this project as a new Swift package project

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

3) Now we need to add Kitura as a dependency for your project (Package.swift):

```swift
import PackageDescription

let package = Package(
    name: "myFirstProject",

    dependencies: [
 		.Package(url: "https://github.com/IBM-Swift/Kitura-router.git", majorVersion: 0),
	]

)
```

4) Now we can issue a `swift build` command to to download the dependencies.

 Because Swift Package Manager does not compile C code, expect this step to fail because of a linker error.

```bash
swift build
```

5) Copy the Makefile.client from KituraNet to your project as Makefile:

```bash
cp Packages/Kitura-net-0.2.0/Makefile-client Makefile
```

6) Import the modules in your code:

```swift
import KituraRouter
import KituraNet
import KituraSys
```
7) Add a router and a path:

```swift
let router = Router()

router.get("/") {
	request, response, next in

	response.status(HttpStatusCode.OK).send("Hello, World!")

	next()
}
```

8) Create and start a HTTPServer:

```swift
let server = HttpServer.listen(8090, delegate: router)
Server.run()
```

9) Sources/main.swift file should now look like this:

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

10) Run make

```
make
```

11) Now run your new web application

```
.build/debug/myFirstProject
```

12) Open your browser at [http://localhost:8090](http://localhost:8090)

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
