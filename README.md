![Passage Swift](https://storage.googleapis.com/passage-docs/passage-github-banner.png)

# Passage Swift

![SPM Version](https://img.shields.io/github/v/release/passageidentity/passage-swift?style=flat&label=Swift%20Package)
![Cocoapods Version](https://img.shields.io/github/v/release/passageidentity/passage-swift?style=flat&label=CocoaPods)

![Language](https://img.shields.io/badge/Swift-informational?style=flat&logo=swift&logoColor=white&color=FA7343)
![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpassage-swift%2Fpassage-swift%2Fbadge%3Ftype%3Dplatforms)
![Company](https://img.shields.io/badge/1Password-informational?style=flat&logo=1password&logoColor=white&color=3B66BC)
![License](https://img.shields.io/github/license/passageidentity/passage-swift.svg?style=flat)

 <br />

## ⚙️ Installation
### Swift Package Manager
To install via Swift Package Manager, enter this url Xcode's Swift Package Manager's search bar:
```
https://github.com/passageidentity/passage-swift
```

### CocoaPods
To install via Cocoapods, add this dependency to your Podfile:
``` ruby
pod 'PassageSwift'
```

 <br />

## 👩🏽‍💻 Example Usage
Below is an example of how easy it is to use Passage Swift to register a new user with a passkey and get their auth token:

``` swift
import Passage

let passage = Passage(appId: "YOUR_PASSAGE_APP_ID")

try await passage.passkey.register(identifier: "new_user@email.com")

let authToken = passage.tokenStore.authToken
```

 <br />

## 🚀 Get Started
### Visit our 📚 [Passage Swift Docs](https://docs.passage.id) to get started adding Passage to your Swift app.
 <br />

---
<br />
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://storage.googleapis.com/passage-docs/logo-small-light.pngg" width="150">
    <source media="(prefers-color-scheme: dark)" srcset="https://storage.googleapis.com/passage-docs/logo-small-dark.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>

<p align="center">Give customers the passwordless future they deserve. To learn more check out <a href="https://passage.1password.com">passage.1password.com</a></p>

<p align="center">This project is licensed under the MIT license. See the <a href="./LICENSE"> LICENSE</a> file for more info.</p>