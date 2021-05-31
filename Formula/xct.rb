class Xct < Formula
  desc "Manage, build, sign and deploy your Xcode projects"
  homepage "https://xcode-actions.com"
  url "https://github.com/xcode-actions/XcodeTools.git", using: :git, tag: "0.3.5", revision: "94b8c7ee88de106625357966b151d30220e7f2fb"
  revision 1
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

    bins = ["#{prefix}/release/xct"] +
           # Obsolete
           ["#{prefix}/release/hagvtool"] +
           # All xct-* bin (but not the dSYMs and co)
           Dir["#{prefix}/release/xct-*"] - Dir["#{prefix}/release/xct-*.*"]

    bins.each do |b|
      # Generate and install bash completion
      output = Utils.safe_popen_read(b, "--generate-completion-script", "bash")
      (bash_completion/File.basename(b)).write output
      # Generate and install zsh completion
      output = Utils.safe_popen_read(b, "--generate-completion-script", "zsh")
      (zsh_completion/("_" + File.basename(b))).write output
      # Generate and install fish completion
      output = Utils.safe_popen_read(b, "--generate-completion-script", "fish")
      (fish_completion/File.basename(b)).write output

      # Install the binary after completion is generated
      bin.install b
    end
  end

  test do
    system "xct", "--help"
  end
end
