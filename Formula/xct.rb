class Xct < Formula
  desc "Manage, build, sign and deploy your Xcode projects"
  homepage "https://xcode-actions.com"
  url "https://github.com/xcode-actions/XcodeTools.git", using: :git, tag: "0.3.0", revision: "bf0e013c51c1030e51ce1591614b8aff3d794894"
  head "https://github.com/xcode-actions/XcodeTools.git", using: :git, branch: "develop"

  depends_on xcode: "12.5"

  def install
    # We compile directly in prefix because we _need_ compilation to be done
    # directly in destination directory because Swift hard-codes the bundle
    # location at compile time.
    system "./Scripts/build-sans-sandbox.swift", "--disable-sandbox", "--force-resolved-versions",
           "--build-path", prefix, "--configuration", "release"

    # This contains some reference to Homebrew`'s shim and must be removed
    rm "#{prefix}/release.yaml"

    bin.install "#{prefix}/release/xct"
    bin.install "#{prefix}/release/hagvtool" # Obsolete
    # All xct-* bin (but not the dSYMs and co)
    bin.install Dir["#{prefix}/release/xct-*"] - Dir["#{prefix}/release/xct-*.*"]
  end
end