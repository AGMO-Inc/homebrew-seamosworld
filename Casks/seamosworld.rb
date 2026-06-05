# SeamOSWorld — Homebrew Cask
#
# Install (no extra setup — qemu/zstd/xorriso come as dependencies):
#   brew install agmo-inc/seamosworld/seamosworld
#
# Data cleanup: `brew uninstall --zap seamosworld` removes the downloaded VM
# image, Electron app, and data. A plain uninstall keeps them so that
# `brew upgrade` (= uninstall + install) never wipes the 4.3GB image.
#
# The launcher source is tiny; the VM image (qcow2) and Electron app are
# downloaded from public S3 on install (postflight -> `seamosworld fetch`)
# and refreshed only when their version changes (`--if-needed`).
cask "seamosworld" do
  version "1.0.7"
  sha256 "5a815db0a91ffe4938a419a27f806426ef78a4bc32e7b53b51432aaac1bb9762"

  url "https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/src/seamosworld-launcher-#{version}.tar.gz",
      verified: "seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/"
  name "SeamOSWorld"
  desc "QEMU VM + Electron dashboard for NEVONEX FCAL"
  homepage "https://github.com/AGMO-Inc/seamos-simulator"

  depends_on formula: "qemu"
  depends_on formula: "zstd"
  depends_on formula: "xorriso" # cloud-init NoCloud seed.iso (SSH key injection)
  depends_on formula: "python@3.12" # side-server(signal-controller) venv

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

  # `brew uninstall --zap` leaves nothing behind (VM image, app, data).
  zap trash: "~/Library/Application Support/SimulationWorld"

  caveats <<~EOS
    qemu/zstd/xorriso were installed as dependencies — nothing else to install.

      seamosworld start --vm-only   # Start VM(QEMU) only (image auto-downloads on first run)
      seamosworld stop              # Stop VM (and the Electron app)
      seamosworld start             # VM + Electron app window
      seamosworld install <app.fif> # Install a NEVONEX app
      seamosworld status / shell / apps / logs <svc>

    Dashboard: http://localhost:3000

    `brew uninstall --zap seamosworld` also removes the downloaded VM image and app data.
  EOS
end
