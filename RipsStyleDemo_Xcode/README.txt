Rips Style Demo — Xcode project + cloud build

This is an independent SwiftUI demo with fake credits and local demo data. It does
not connect to Rips/Triumph servers or process payments, and is not affiliated
with Triumph.

BUILD WITHOUT OWNING A MAC (GitHub Actions)
1. Sign in to GitHub and create a new repository.
2. Upload the contents of this folder to the repository (keep the .github folder).
3. Open the repository's Actions tab and enable Actions if prompted.
4. Run the workflow named "Build unsigned iOS IPA" (or push to the main branch).
5. When it finishes, open that workflow run and download the artifact named
   "RipsStyleDemo-unsigned-IPA". It contains RipsStyleDemo-unsigned.ipa.
6. Open Sideloadly on Windows, select the downloaded IPA, connect your iPhone,
   and use your own Apple ID to sign/install it.

The GitHub-hosted macOS runner compiles the project using Xcode. The workflow
creates an unsigned IPA; Sideloadly performs signing on your Windows PC.
A free GitHub account may have usage limits; GitHub controls runner availability.

BUILD LOCALLY ON A MAC (optional)
The build_ipa_on_mac.sh script is retained for users who have Xcode and an Apple
Developer team. The bundle identifier is com.example.RipsStyleDemo; change it to
a unique identifier if needed.
