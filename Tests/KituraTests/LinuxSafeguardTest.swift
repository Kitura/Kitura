/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// An extra test case to ensure that all other test cases include all of their
// tests in their respective `allTests` variable. This is to ensure that the
// same number of unit tests are executed on Linux as there are on OSX.
//
// Code adapted from https://oleb.net/blog/2017/03/keeping-xctest-in-sync/


/* Removing for now.
 
 Causes compiler crash:
 ```
 property and getter have mismatched types: 'XCTestSuite' vs. 'Self'
 0  swift                    0x0000000104809d08 llvm::sys::PrintStackTrace(llvm::raw_ostream&) + 40
 1  swift                    0x0000000104808c66 llvm::sys::RunSignalHandlers() + 86
 2  swift                    0x000000010480a2ce SignalHandler(int) + 366
 3  libsystem_platform.dylib 0x00007fffa6f85b3a _sigtramp + 26
 4  libsystem_platform.dylib 0x00000001079f5551 _sigtramp + 1621555761
 5  libsystem_c.dylib        0x00007fffa6e0a420 abort + 129
 6  swift                    0x00000001026ebdab (anonymous namespace)::Verifier::verifyChecked(swift::VarDecl*) + 1547
 7  swift                    0x00000001026e2c23 (anonymous namespace)::Verifier::walkToDeclPost(swift::Decl*) + 3059
 8  swift                    0x00000001026ed164 (anonymous namespace)::Traversal::doIt(swift::Decl*) + 388
 9  swift                    0x00000001026ecfcb swift::Decl::walk(swift::ASTWalker&) + 27
 10 swift                    0x00000001026dc6cd swift::verify(swift::Decl*) + 157
 11 swift                    0x00000001023d88d8 swift::ClangImporter::verifyAllModules() + 472
 12 swift                    0x000000010266eec9 swift::ASTContext::verifyAllLoadedModules() const + 57
 13 swift                    0x000000010265cfde swift::performTypeChecking(swift::SourceFile&, swift::TopLevelContext&, swift::OptionSet<swift::TypeCheckingFlags, unsigned int>, unsigned int, unsigned int, unsigned int, unsigned int) + 2158
 14 swift                    0x00000001021b133a swift::CompilerInstance::performSema() + 3834
 15 swift                    0x00000001017b32ea performCompile(swift::CompilerInstance&, swift::CompilerInvocation&, llvm::ArrayRef<char const*>, int&, swift::FrontendObserver*, swift::UnifiedStatsReporter*) + 1450
 16 swift                    0x00000001017b1e56 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) + 3494
 17 swift                    0x0000000101773a30 main + 3312
 18 libdyld.dylib            0x00007fffa6d76235 start + 1
 19 libdyld.dylib            0x0000000000000045 start + 1495834129
 Stack dump:
 0.    Program arguments: /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2017-07-10-a.xctoolchain/usr/bin/swift -frontend -c /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/FileServerTests.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/Helpers/BadCookieWritingMiddleware.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/Helpers/EchoWebApp.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/Helpers/HelloWorldWebApp.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/Helpers/TestResponseResolver.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/Helpers/UUIDGeneratorWebApp.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/K2SpikeTests.swift -primary-file /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/LinuxSafeguardTest.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/ParameterParsingTests.swift /Users/carlbrown/IBMSwift/Kitura/Tests/KituraTests/RouterTests.swift -target x86_64-apple-macosx10.10 -enable-objc-interop -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk -I /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Products/Debug -F /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Products/Debug -F /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -g -module-cache-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/ModuleCache -swift-version 4 -enforce-exclusivity=checked -D SWIFT_PACKAGE -D Xcode -serialize-debugging-options -serialize-debugging-options -Xcc -fmodule-map-file=/Users/carlbrown/IBMSwift/Kitura/.build/checkouts/CHTTPParser.git-4187859997338157208/Sources/CHTTPParser/include/module.modulemap -Xcc -I/Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/swift-overrides.hmap -Xcc -I/Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Products/Debug/include -Xcc -I/Users/carlbrown/IBMSwift/Kitura/.build/checkouts/CHTTPParser.git-4187859997338157208/Sources/CHTTPParser/include -Xcc -I/Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/DerivedSources/x86_64 -Xcc -I/Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/DerivedSources -Xcc -working-directory/Users/carlbrown/IBMSwift/Kitura -emit-module-doc-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest~partial.swiftdoc -serialize-diagnostics-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest.dia -Onone -module-name KituraTests -emit-module-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest~partial.swiftmodule -emit-dependencies-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest.d -emit-reference-dependencies-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest.swiftdeps -o /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Build/Intermediates.noindex/Kitura.build/Debug/KituraTests.build/Objects-normal/x86_64/LinuxSafeguardTest.o -index-store-path /Users/carlbrown/Library/Developer/Xcode/DerivedData/Kitura-alnidwdnzikpcneusfhvwlgenwfa/Index/DataStore -index-system-modules

 ```

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import XCTest

    class LinuxSafeguardTest: XCTestCase {
        func testLinuxTestSuiteIncludesAllTests() {
            var linuxCount: Int
            var darwinCount: Int

            // FileServerTests
            linuxCount = FileServerTests.allTests.count
            darwinCount = Int(FileServerTests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from FileServerTests.allTests")

            // KituraTests
            linuxCount = KituraTests.allTests.count
            darwinCount = Int(KituraTests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from KituraTests.allTests")

            // ParameterParsingTests
            linuxCount = ParameterParsingTests.allTests.count
            darwinCount = Int(ParameterParsingTests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ParameterParsingTests.allTests")

            // RouterTests
            linuxCount = RouterTests.allTests.count
            darwinCount = Int(RouterTests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from RouterTests.allTests")
        }
    }
#endif
 */
