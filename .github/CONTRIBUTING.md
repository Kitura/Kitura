# Contributing to Kitura

This document contains information and guidelines about making contributions. For help, contact us on [Slack](http://swift-at-ibm-slack.mybluemix.net/).

We love contributions to the Kitura project, but request you follow the guidelines below.

 - [Getting Started](#getting-started)
 - [Pull Requests](#pull-requests)
 - [Coding Style](#coding-style)
 - [Contributor License Agreement](#contributor-license-agreement)
 - [Asking Questions](#asking-questions)
 - [Reporting issues](#reporting-issues)
 - [Additional Resources](#additional-resources)


## Getting Started

Please ensure you follow [the Kitura coding standards](https://github.com/IBM-Swift/Kitura/blob/master/Documentation/CodeConventions.md). This keeps the source code tidy, and allows [Swift Lint]((https://github.com/realm/SwiftLint)) to work with the project.

**If you are new:** We have created the label ["good starting issue"](https://github.com/IBM-Swift/Kitura/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) to help new members of the community get involved with Kitura quickly and effectively. These issues include documentation changes, test cases, minor bug fixes, logging, renaming and refactoring.

To get started, you will need to open a Terminal and:

1. Fork this repo and clone it onto your machine.

   `$ git clone https://github.com/YOUR_GITHUB_ID/Kitura`


2. Make changes to code, usually by tackling an issue. A list of issues can be found at [here](https://github.com/IBM-Swift/Kitura/issues). If you are new to Swift or software development, look for issues labelled ["good starting issue"](https://github.com/IBM-Swift/Kitura/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).

   If there aren't any tagged issues, post in [Slack](http://swift-at-ibm-slack.mybluemix.net/) and the team would be happy to help you get started.

   **Tip:** If you are on macOS, Xcode can be a great way to work on Kitura. You can download the latest Xcode [here](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12). You'll need to open a Terminal window, and navigate to the root of the Kitura project you cloned. Then, type the following command into Terminal:

   `$ swift package generate-xcodeproj`
   ​
   This will generate an Xcode Project, open the .xcodeproj file with:

   `$ open *.xcodeproj`

   *Note: Xcode is macOS only, Linux users will need to use a different editor.*

3. All source code submitted requires an Apache License header at the top of the file. A Github Gist of this text can be found [here](https://gist.github.com/SwiftDevOps/141437c6861f88c959d0731bc3b16bee), just copy and paste it at the top of any new files your submitting.

4. Ensure all tests pass with your changes by running `swift test` in Terminal. If there is any new functionality introduced by your changes, new test case(s) may be required. If you need any help writing tests, contact us on [Slack](http://swift-at-ibm-slack.mybluemix.net/).

5. If they all pass, open a Pull Request following the guidelines below.


## Pull Requests

**Note about tests:** When opening a Pull Request, please run the tests for your OS with `swift test`.  Kitura is a cross platform web framework that uses Continuous Integration. You may see mentions of Travis CI in your PR and it's comments. Travis is an external service we use that is automatically called on every PR, and runs the test cases on macOS and Linux to ensure every code change is cross plaform compatible.

To open a new Pull Request, the GitHub website provides the simplest experience for new users. Go to your fork of the repo and click the New pull request button. You will be presented with a page featuring base fork: and base:, then an arrow, and then head fork: compare:. Make sure compare: has **your branch** with your changes selected and base: has **master** selected. When you are ready to open the PR, click the green button at the top called Create pull request.

If this is your first PR, a bot will comment with a link to the CLA which must be signed before we can merge in your changes.

When opening a PR, please:

1. Create minimal differences and do not reformat the code. If you feel the codes structure needs changing, open a separate PR.
2. Check for unnecessary white space using `git diff --check` before you commit your code.
3. Ensure you follow the coding standards for the Kitura project, [linked here](https://github.com/IBM-Swift/Kitura/blob/master/Documentation/CodeConventions.md).

## Coding Style

Contributions should follow the established coding style and conventions for this project,
which are loosely based on [GitHub's Swift Style Guide](https://github.com/github/swift-style-guide). When opening a PR, try to follow the coding style of the file you're working on, and comment code that is particularly complex.

This also ensures that [Swift Lint](https://github.com/realm/SwiftLint) works on the project.

## Contributor License Agreement

In order for us to merge any of your changes into Kitura, you need to sign the Contributor License Agreement. When you open up a Pull Request for the first time, a bot will comment with a link to the CLA.

## Asking Questions

If you have any questions, feel free to post in our [Slack](http://swift-at-ibm-slack.mybluemix.net/) Channel. Comment on existing issues, or raise new ones if you discover something new too.

We also check [dW Answers](https://developer.ibm.com/answers/smart-spaces/213/swift.htmlindex.html) and [Stack Overflow](https://www.stackoverflow.com), just tag your answer with the project name (i.e. Kitura or Kitura-net).

## Reporting Issues

See the [issue template](ISSUE_TEMPLATE.md). For any help, just post in our [Slack](http://swift-at-ibm-slack.mybluemix.net/) channel.

---

### Additional Resources

* [GitHub Help - Homepage](https://help.github.com)
* [Creating a Pull Request - GitHub Help](https://help.github.com/articles/creating-a-pull-request/)
