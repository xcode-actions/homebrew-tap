class Xct < Formula
  desc "Manage, build, sign and deploy your Xcode projects"
  homepage "https://xcode-actions.com"
  url "https://github.com/xcode-actions/XcodeTools.git", using: :git, tag: "0.7.2", revision: "13494449d338d40c30047f13a141fa619a75f9e1"
  head "https://github.com/xcode-actions/XcodeTools.git", using: :git, branch: "develop"

  depends_on xcode: "13.1"

  def install
    compiler = if build.head?
      # When building HEAD, we have to use build-sans-sandbox because to
      # workaround the CoreData model not being understood by swift. (In
      # production tags, the CoreData model is precompiled.)
      # Note: With Xcode 14 (and maybe before, idk), we can finally tell Xcode
      # not to use the sandbox! So we could use xcodebuild to build xct now.
      # Example of working invocation:
      # system(
      #   "xcodebuild",
      #   "-IDEPackageSupportDisableManifestSandbox=1",
      #   "-workspace", "XcodeTools.xcworkspace",
      #   "-scheme", "xct",
      #   "-disableAutomaticPackageResolution",
      #   "-showBuildTimingSummary",
      #   "-derivedDataPath", "#{prefix}/build",
      #   "-archivePath", "#{prefix}/archive",
      #   "archive"
      # )
      # On its own the invocation is not enough, but it`'s a good start.
      "./Scripts/xcswift.swift"
    else
      "swift"
    end
    # We compile directly in prefix because we _need_ compilation to be done
    # directly in destination directory because Swift hard-codes the bundle
    # location at compile time.
    system(compiler, "build", "--disable-sandbox", "--force-resolved-versions",
           "--build-path", prefix, "--configuration", "release")

    # This contains some reference to Homebrew`'s shim and must be removed.
    rm "#{prefix}/release.yaml"

    # This is not needed and generates an error on ARM computers when brew tries
    # to sign the frameworks in it.
    rm_rf "#{prefix}/artifacts"

    bins_meta_completion = ["#{prefix}/release/xct"]
    # All xct-* bin (but not the dSYMs and co)
    bins_normal_completion = Dir["#{prefix}/release/xct-*"] - Dir["#{prefix}/release/xct-*.*"] +
                             # Obsolete
                             ["#{prefix}/release/hagvtool"]

    bins_meta_completion.each do |b|
      # Generate and install bash completion.
      output = Utils.safe_popen_read(b, "generate-meta-completion-script", "bash")
      (bash_completion/File.basename(b)).write output
      # Generate and install zsh completion.
      output = Utils.safe_popen_read(b, "generate-meta-completion-script", "zsh")
      (zsh_completion/("_" + File.basename(b))).write output
      # Generate and install fish completion.
      # For now meta completion is not supported for fish, so we use normal one.
      output = Utils.safe_popen_read(b, "--generate-completion-script", "fish")
      (fish_completion/File.basename(b)).write output

      # Install the binary after completion is generated.
      bin.install b
    end

    bins_normal_completion.each do |b|
      # Generate and install bash completion.
      output = Utils.safe_popen_read(b, "--generate-completion-script", "bash")
      (bash_completion/File.basename(b)).write output
      # Generate and install zsh completion.
      output = Utils.safe_popen_read(b, "--generate-completion-script", "zsh")
      (zsh_completion/("_" + File.basename(b))).write output
      # Generate and install fish completion.
      output = Utils.safe_popen_read(b, "--generate-completion-script", "fish")
      (fish_completion/File.basename(b)).write output

      # Install the binary after completion is generated.
      bin.install b
    end

    # We use libSPM which is not static (but must install it _after_ we have generated the completion scripts).
    bin.install Dir["#{prefix}/release/*.dylib"]
  end

  test do
    system "xct", "--help"
  end
end
