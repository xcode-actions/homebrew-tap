class SwiftShAT31 < Formula
  desc "Run Swift script with SPM dependencies directly"
  homepage "https://xcode-actions.com/tools/swift-sh"
  url "https://github.com/xcode-actions/swift-sh.git", using: :git, tag: "3.1.0", revision: "3917784be29684095fd57c315fc8b2709c2b2269"
  head "https://github.com/xcode-actions/swift-sh.git", using: :git, branch: "develop"

  depends_on xcode: "15.0"

  def install
    # We compile directly in prefix because we _need_ compilation to be done
    # directly in destination directory because Swift hard-codes the bundle
    # location at compile time.
    system("swift", "build", "--disable-sandbox", "--force-resolved-versions",
           "--build-path", prefix, "--configuration", "release")

    # This contains some reference to Homebrew`'s shim and must be removed.
    rm "#{prefix}/release.yaml"

    # This is not needed and generates an error on ARM computers when brew tries
    # to sign the frameworks in it.
    rm_rf "#{prefix}/artifacts"

    bins_meta_completion = []
    bins_normal_completion = Dir["#{prefix}/release/swift-sh"]

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

      # Install the binary after completion is generated and change its rpath.
      # TODO: Formula/r/rustfmt.rb:41 for a better way of doing this.
		system("install_name_tool", "-add_rpath", File.dirname(b), b)
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
		system("install_name_tool", "-add_rpath", File.dirname(b), b)
      bin.install b
    end
  end

  test do
    system "swift-sh", "--help"
  end
end
