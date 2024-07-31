# Contributing to Passage Swift

Thank you for considering contributing to Passage Swift! Here are some guidelines and instructions to help you get started.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Code Style](#code-style)
4. [Code Generation](#code-generation)
5. [Testing](#testing)
6. [Submitting Changes](#submitting-changes)
7. [Community](#community)

## Code of Conduct

Please read our [Code of Conduct](CODE-OF-CONDUCT.md) to understand the behavior we expect from all contributors.

## Getting Started

1. Fork the repository and clone your fork.
2. Create a new branch for your changes: `git checkout -b my-feature-branch`.
3. Install the necessary dependencies.

## Code Style

Please follow these guidelines to ensure a consistent code style:

- Use [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions.
- Write clear, concise commit messages.
- Comment your code, especially complex or non-obvious sections.

## Code Generation

To update the OpenAPI generated code, follow these steps:

1. Run the below command to update the OpenAPI generated code:
    ```sh
    openapi-generator generate -i https://api.swaggerhub.com/apis/passage/passage-auth-api/1 -g swift5 --additional-properties=responseAs=AsyncAwait -o Sources/Passage/generated
    ```

2. Run the script to fix known generated code issues:
    ```sh
    python3 Sources/Passage/fix_generated_code.py
    ```

## Testing

1. Write unit and/or integration tests for your code changes.
2. Run all tests to ensure they pass:
    ```sh
    swift test
    ```

## Submitting Changes

1. Ensure all tests pass and there are no linting errors.
2. Commit your changes to your branch with a clear commit message.
3. Push your branch to your forked repository: `git push origin my-feature-branch`.
4. Create a pull request against the `main` repository.
5. Ensure your pull request includes:
   - A reference to the related Jira ticket (internal use only).
   - A detailed description of the changes.
   - Any additional context or screenshots.

## Community

- Join our discussions on [Discord](https://discord.com/invite/445QpyEDXh) to ask questions and interact with our developers other contributors.
- Check out the [issue tracker](https://github.com/passageidentity/passage-swift/issues) for ways to contribute.

Thank you for contributing to [Your Project Name]! Your efforts help make this project better for everyone.
