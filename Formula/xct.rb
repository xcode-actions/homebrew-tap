class Xct < Formula
  desc "Manage, build, sign and deploy your Xcode projects"
  homepage "https://xcode-actions.com"
  url "https://github.com/xcode-actions/XcodeTools.git", using: :git, tag: "0.3.4", revision: "bf0ddafa9c0b9deff18faf108af9225203166f2b"
  head "https://github.com/xcode-actions/XcodeTools.git", using: :git, branch: "develop"

  depends_on xcode: "12.5"

  def install
    compiler = if build.head?
      # When building HEAD, we have to use build-sans-sandbox because to
      # workaround the CoreData model not being understood by swift. (In
      # production tags, the CoreData model is precompiled.)
      ["./Scripts/build-sans-sandbox.swift"]
    else
      ["swift", "build"]
    end
    # We compile directly in prefix because we _need_ compilation to be done
    # directly in destination directory because Swift hard-codes the bundle
    # location at compile time.
    system(*(compiler + ["--disable-sandbox", "--force-resolved-versions",
                         "--build-path", prefix, "--configuration", "release"]))

    # This contains some reference to Homebrew`'s shim and must be removed
    rm "#{prefix}/release.yaml"

    bin.install "#{prefix}/release/xct"
    bin.install "#{prefix}/release/hagvtool" # Obsolete
    # All xct-* bin (but not the dSYMs and co)
    bin.install Dir["#{prefix}/release/xct-*"] - Dir["#{prefix}/release/xct-*.*"]
  end

  test do
    system "xct", "--help"
  end
end
