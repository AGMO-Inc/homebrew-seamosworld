# 구조

```
seamosworld start
   │
   ├─ QEMU VM (launcher CLI 가 직접 기동, -accel hvf)
   │    └─ VM 내부 systemd
   │         ├─ nginx        → Dashboard SPA (:3000)
   │         ├─ api-server   (:5100)
   │         ├─ iot-server   (:5050)
   │         ├─ MQTT broker  (:8121 WS / :8122 mTLS)
   │         └─ NEVONEX SDK runtime (FCAL / FIL / 앱)
   │
   └─ Electron 앱 (SimWorld.app)
        └─ Dashboard(:3000)를 띄우는 창. QEMU 는 안 건드림.
```

## 핵심
- **VM 은 Electron 이 아니라 launcher CLI(`seamosworld start`)가 QEMU 로 직접 기동**합니다.
- VM 안 systemd 가 dashboard·api-server·iot·MQTT·NEVONEX runtime 을 올립니다.
- Electron 앱은 dashboard(`:3000`)를 표시하는 데스크톱 창일 뿐입니다(`--vm-only` 면 안 띄움).
- 소스/이미지/앱은 **public S3 에서 배포**합니다(repo 가 private 라 git/tap 인증을 피하기 위함).

## 데이터 흐름 (시뮬레이션)
```
Simulator/시나리오 → signal-controller → CAN(:29536) / GPS NMEA(:29539) / MQTT(:8122)
   → VM 내부 FIL → NEVONEX 앱 → 앱 WebSocket(:1456) → dashboard
```

## 배포 자산 (S3, public-read)
- `images/simworld-v1.0.0.qcow2.zst` (+ `latest.json`, `.sha256`)
- `app/SimWorld-arm64.zip` (+ `latest.json`, `.sha256`)
- `src/seamosworld-launcher-1.0.0.tar.gz` (Homebrew formula source)
