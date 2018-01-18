This document contains information and guidlines about contributing to the Kitura project. Please ensure you give this document a read before making any Contributions. For any help, contact us on Slack.

## Getting Started

To get started on contributing to Kitura, you will need to:

1. Fork this repository to your account and then pull down to your machine.

   `$ git clone https://github.com/YOUR_GITHUB_ID/Kitura`

2. Make a change, usually by tackling an issue.

3. Open a Pull Request - TODO: Add to this section, not complete.

## Pull Requests

Issues that would be a good place to start for someone new to GitHub will have the label "Good First Issue". If there aren't any tagged issues, post in Slack and the team would be happy to help you get started.

 When opening a new PR, please follow the [PR template](PULL_REQUEST_TEMPLATE.md).

To start working on an issue, pick one from [here](https://github.com/IBM-Swift/Kitura/issues) and do the following:

1. Fork the repository to your own account, and create a branch for the issue you're working on. A good branch name could be as simple as issue.ISSUENUMBER or it can be more descriptive if you like.

2. Work on the issue. This part is harder to write a guide for but some general tips are:

   * Please respect the [original style guide](https://github.com/github/swift-style-guide).
   * Create minimal differences - try not to reformat the code. Open a separate PR if you feel the source codes structure needs changing.
   * Check for unneccessary white space using `git diff --check` before you commit.

3. Verify all the tests still pass with your changes by running `swift test`. If your code introduces a new test case, please add it and ensure it passes too.

4. Push your fork and then open a PR against the original repos **master** branch.

5. Keep an eye on your inbox - we may request clarification or ask for changes if there's a problem.

## Coding Style

Contributions should follow the established coding style and conventions for this project,
which are loosely based on [GitHub's Swift Style Guide](https://github.com/github/swift-style-guide). If opening a PR, try to follow the coding style of the file you're working in, and make sure to comment any code that is particularly complex.

## Asking Questions

If you have any questions from general Swift enquiries to questions about issues or anything in between, feel free to post in our Slack Channel. [Click here](http://swift-at-ibm-slack.mybluemix.net/) to be sign up to the Channel and join the discussion. Feel free to comment on existing issues as well, or raise new ones should you discover something new.

We also check [dW Answers](https://developer.ibm.com/answers/smart-spaces/213/swift.htmlindex.html) and [Stack Overflow](https://www.stackoverflow.com) frequently, just ensure you tag your answer with the project name (i.e. Kitura or KituraKit).

## Reporting Issues

See the [issue template](ISSUE_TEMPLATE.md). For any help reporting an issue, feel free to post in the Slack channel.

### Additional Resources

* [GitHub Help - Homepage](https://help.github.com)
* [Creating a Pull Request - GitHub Help](https://help.github.com/articles/creating-a-pull-request/)
