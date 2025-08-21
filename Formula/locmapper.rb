class Locmapper < Formula
  desc "Utility for working w/ LocMapper (*.lcm) files"
  homepage "https://github.com/xcode-actions/LocMapper"
  url "https://github.com/xcode-actions/LocMapper.git", using: :git, tag: "1.5.0", revision: "656606a370f6f61f4ac0269efcaeddd870b8a29b"
  head "https://github.com/xcode-actions/LocMapper.git", using: :git, branch: "develop"

  depends_on xcode: ["16.4", :build]

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release", "--disable-automatic-resolution"

    bins = ["./.build/release/locmapper"]
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
      bin.install b
    end
  end

  test do
    system bin/"locmapper", "--help"
  end
end
