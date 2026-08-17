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
  version "1.6.20"
  sha256 "aee290db0fae7ed36485a4400c5f955089f1603330f82f30191bd16319b8ebd2"

  url "https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/src/seamosworld-launcher-#{version}.tar.gz",
      verified: "seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/"
  name "SeamOSWorld"
  desc "QEMU VM + Electron dashboard for NEVONEX FCAL"
  homepage "https://github.com/AGMO-Inc/seamos-simulator"

  depends_on formula: "qemu"
  depends_on formula: "zstd"
  depends_on formula: "xorriso" # cloud-init NoCloud seed.iso (SSH key injection)
  depends_on formula: "socket_vmnet" # real-IP (vmnet) networking; without it the launcher falls back to slirp
  # (socket_vmnet needs `sudo brew services start socket_vmnet` once — install.sh guides it.)

  # Expose the launcher CLI as `seamosworld` on PATH (symlink into bin).
  binary "seamosworld-#{version}/seamosworld", target: "seamosworld"

  # On install/upgrade, download the VM image + Electron app (only what's
  # missing or out of date). Asset failures are non-fatal — `seamosworld start`
  # retries them as a safety net.
  postflight do
    # vmnet daemon (socket_vmnet) must run as root; `brew install` never starts
    # services on its own. Without it the VM cannot get an IP and `start` stalls
    # at "Resolving the VM address". Start it here with sudo so that installing
    # is genuinely just `brew install` + `seamosworld start` — no extra commands.
    #
    # Skip it when the daemon is already running. `brew upgrade --cask` is
    # uninstall + install, so this postflight runs on every upgrade — and the
    # sudo prompt appeared each time even though nothing needed starting. The
    # launcher pipes brew's output away, so users saw a bare "Password:" with no
    # explanation and cancelled it (2026-08-17).
    unless system("/usr/bin/pgrep", "-qf", "socket_vmnet")
      system_command "/opt/homebrew/bin/brew",
                     args:         ["services", "start", "socket_vmnet"],
                     sudo:         true,
                     print_stdout: true,
                     print_stderr: true
    end
    # Asset download must never fail the install: the VM may be running (qcow2
    # locked), the disk may be full, or the network may be down. `seamosworld
    # start` retries this anyway, so warn instead of aborting the whole install
    # (2026-08-14: a running VM made `brew install` exit 1 after it had already
    # linked the binary, leaving a confusing half-failed install).
    begin
      system_command "#{staged_path}/seamosworld-#{version}/seamosworld",
                     args:         ["fetch", "--if-needed"],
                     print_stdout: true,
                     print_stderr: true
    rescue StandardError
      opoo "Asset download incomplete — 'seamosworld start' will retry " \
           "(stop the VM first if it is running: seamosworld stop)."
    end
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
