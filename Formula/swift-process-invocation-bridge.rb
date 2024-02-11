class SwiftProcessInvocationBridge < Formula
  desc "Helper tool used by swift-process-invocation when it is asked to send file descriptors to the child process"
  homepage "https://xcode-actions.com/tools/swift-process-invocation"
  url "https://github.com/xcode-actions/swift-process-invocation.git", using: :git, tag: "1.0.0", revision: "5b74d422f99ad2bc6a16e075d1653712a59dfd6e"
  head "https://github.com/xcode-actions/swift-process-invocation.git", using: :git, branch: "develop"

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

    bins = Dir["#{prefix}/release/swift-process-invocation-bridge"]
    bins.each do |b|
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
      # TODO: Formula/r/rustfmt.rb:41 for a better way of doing this.
		system("install_name_tool", "-add_rpath", File.dirname(b), b)
      bin.install b
    end
  end

  test do
    system "swift-process-invocation-bridge","--help"
  end
end
