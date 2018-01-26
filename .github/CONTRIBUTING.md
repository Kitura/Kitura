# Contributing to Kitura

We love contributions to the Kitura project and request you follow the guidelines below. If you have any questions, or need any help, contact us on [Slack](http://swift-at-ibm-slack.mybluemix.net/).

 - [Getting Started](#getting-started)
 - [Pull Requests](#pull-requests)
 - [Coding Style](#coding-style)
 - [Contributor License Agreement](#contributor-license-agreement)
 - [Asking Questions](#asking-questions)
 - [Reporting issues](#reporting-issues)
 - [Additional Resources](#additional-resources)


## Getting Started

Please follow the [Kitura coding standards](https://github.com/IBM-Swift/Kitura/blob/master/Documentation/CodeConventions.md); this keeps the source code tidy and allows [Swift Lint](https://github.com/realm/SwiftLint) to work with the project.

**First time contributing?** We have created the label ["good first issue"](https://github.com/IBM-Swift/Kitura/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) to help new members of the community get involved with Kitura quickly and effectively. These issues include documentation changes, test cases, minor bug fixes, logging, renaming and refactoring.

To get started, you will need to open a Terminal and:

1. Fork this repo and clone it onto your machine.

   `$ git clone https://github.com/YOUR_GITHUB_ID/Kitura`


2. Make changes to code, usually by tackling an issue. A list of issues can be found [here](https://github.com/IBM-Swift/Kitura/issues). If you are new to Swift or software development, look for issues labelled ["good first issue"](https://github.com/IBM-Swift/Kitura/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

   If there aren't any tagged issues, post in [Slack](http://swift-at-ibm-slack.mybluemix.net/) and the team would be happy to help you get started.

   **Tip:** If you are on macOS, Xcode can be a great way to work on Kitura. You can download the latest Xcode [here](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12). Navigate to the root of the Kitura project you cloned and then type the following command:

   `$ swift package generate-xcodeproj`

   This will generate an Xcode Project, open the .xcodeproj file with:

   `$ open *.xcodeproj`

   *Note: Xcode is macOS only, Linux users will need to use a different editor.*

3. All source code submitted requires an Apache License header at the top of the file. A Github Gist of this text can be found [here](https://gist.github.com/SwiftDevOps/141437c6861f88c959d0731bc3b16bee), just copy and paste it at the top of any new files you're submitting.

4. Ensure all tests pass with your changes by running `swift test`. If there is any new functionality introduced by your changes, new test case(s) may be required. If you need any help writing tests, contact us on [Slack](http://swift-at-ibm-slack.mybluemix.net/).

5. If the tests all pass, open a Pull Request following the guidelines below.


## Pull Requests

**Note:** Before opening a Pull Request, please run the tests using `swift test` and check they all pass.  

Kitura is a cross platform web framework that uses [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration). You may see mentions of [Travis CI](https://travis-ci.com/) in your PR and its comments. Travis is an external service we use that is automatically called on every PR, and runs the test cases on macOS and Linux to ensure every code change is cross plaform compatible.

To open a new Pull Request, the GitHub website provides the simplest experience for new users. Go to your fork of the repo and click the New pull request button. You will be presented with a page featuring base fork: and base:, then an arrow, and then head fork: compare:. Make sure compare: has **your branch** with your changes selected and base: has **master** selected. When you are ready to open the PR, click the green button at the top called Create pull request.

If this is your first PR, a bot will comment with a link to the [CLA](#contributor-license-agreement) which must be signed before we can merge your changes into master.

When opening a PR, please:

1. Create minimal differences and do not reformat the code. If you feel the codes structure needs changing, open a separate PR.
2. Check for unnecessary white space using `git diff --check` before you commit your code.
3. Ensure you follow the coding standards for the Kitura project, [linked here](https://github.com/IBM-Swift/Kitura/blob/master/Documentation/CodeConventions.md).

## Coding Style

Contributions should follow the established coding style and conventions for this project,
which are loosely based on [GitHub's Swift Style Guide](https://github.com/github/swift-style-guide). When opening a PR, try to follow the coding style of the file you're working on, and comment code that is particularly complex. Kitura contributions should follow the [Kitura Coding Standards]()

This also ensures that [Swift Lint](https://github.com/realm/SwiftLint) works on the project.

## Contributor License Agreement

In order for us to merge any of your changes into Kitura, you need to sign the Contributor License Agreement. When you open up a Pull Request for the first time, a bot will comment with a link to the CLA.

## Asking Questions

If you have any questions, message us on [Slack](http://swift-at-ibm-slack.mybluemix.net/). Comment on existing issues, or raise new ones if you discover something.

## Reporting Issues

See the [issue template](ISSUE_TEMPLATE.md). For any help, just post in our [Slack](http://swift-at-ibm-slack.mybluemix.net/).

---

### Additional Resources

* [GitHub Help - Homepage](https://help.github.com)
* [Creating a Pull Request - GitHub Help](https://help.github.com/articles/creating-a-pull-request/)
