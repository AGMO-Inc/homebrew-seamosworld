# SeamOSWorld — Homebrew Cask
#
# Install (no extra setup — qemu/zstd/xorriso come as dependencies):
#   brew install agmo-inc/seamosworld/seamosworld
#
# Why a Cask (not a Formula): only a Cask can run cleanup on uninstall.
# `brew uninstall seamosworld` removes the CLI AND the downloaded VM image,
# Electron app, and data under ~/Library/Application Support/SimulationWorld
# (see uninstall_postflight) — no separate purge command needed.
#
# The launcher source is tiny; the VM image (qcow2) and Electron app are
# downloaded from public S3 on install (postflight -> `seamosworld fetch`)
# and refreshed only when their version changes (`--if-needed`).
cask "seamosworld" do
  version "1.0.6"
  sha256 "43606ef75c15b6f6253a8a4ad1872a5e06254387d041fd76300f4887ffde9cd6"

  url "https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/src/seamosworld-launcher-#{version}.tar.gz",
      verified: "seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/"
  name "SeamOSWorld"
  desc "QEMU VM + Electron dashboard for NEVONEX FCAL"
  homepage "https://github.com/AGMO-Inc/seamos-simulator"

  depends_on formula: "qemu"
  depends_on formula: "zstd"
  depends_on formula: "xorriso" # cloud-init NoCloud seed.iso (SSH key injection)

  # Expose the launcher CLI as `seamosworld` on PATH (symlink into bin).
  binary "seamosworld-#{version}/seamosworld", target: "seamosworld"

  # On install/upgrade, download the VM image + Electron app (only what's
  # missing or out of date). Asset failures are non-fatal — `seamosworld start`
  # retries them as a safety net.
  postflight do
    system_command "#{staged_path}/seamosworld-#{version}/seamosworld",
                   args:         ["fetch", "--if-needed"],
                   print_stdout: true,
                   print_stderr: true
  end

  # `brew uninstall` removes the symlink automatically; here we also wipe the
  # downloaded VM image, Electron app, SSH key, and all runtime data.
  uninstall_postflight do
    require "fileutils"
    data = File.expand_path("~/Library/Application Support/SimulationWorld")
    FileUtils.rm_r(data) if File.exist?(data)
  end

  # `brew uninstall --zap` (or `brew uninstall` via uninstall_postflight above)
  # leaves nothing behind.
  zap trash: "~/Library/Application Support/SimulationWorld"

  caveats <<~EOS
    qemu/zstd/xorriso were installed as dependencies — nothing else to install.

      seamosworld start --vm-only   # Start VM(QEMU) only (image auto-downloads on first run)
      seamosworld stop              # Stop VM (and the Electron app)
      seamosworld start             # VM + Electron app window
      seamosworld install <app.fif> # Install a NEVONEX app
      seamosworld status / shell / apps / logs <svc>

    Dashboard: http://localhost:3000

    `brew uninstall seamosworld` also removes the downloaded VM image and app data.
  EOS
end
