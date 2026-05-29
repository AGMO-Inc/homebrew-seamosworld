# homebrew-seamosworld

SeamOS SimulationWorld — NEVONEX FCAL 농기계 시뮬레이션 플랫폼(QEMU VM + Electron dashboard)의 Homebrew tap.

## 설치

```bash
brew install agmo-inc/seamosworld/seamosworld
```

`qemu` / `zstd` / `xorriso` 가 의존성으로 함께 설치됩니다 — 따로 설치할 것 없습니다.
설치 시 VM 이미지·앱이 자동으로 내려받아집니다(이후엔 버전이 바뀔 때만 갱신).

> 짧게 쓰려면 한 번 tap 후 short name 으로 설치할 수도 있습니다:
> ```bash
> brew tap agmo-inc/seamosworld
> brew install seamosworld
> ```

## 빠른 시작

```bash
seamosworld start --vm-only   # VM(QEMU)만 기동
seamosworld stop              # VM 종료 (Electron 앱도 함께 종료)
seamosworld start             # VM + Electron 앱 창
seamosworld install <앱.fif>  # NEVONEX 앱 설치
```

전체 명령: `status` · `shell` · `apps` · `logs <service>` · `restart` · `update` · `fetch` · `dashboard`

Dashboard: <http://localhost:3000>

## 제거

```bash
brew uninstall seamosworld
```

CLI 뿐 아니라 내려받은 **VM 이미지·Electron 앱·SSH 키·런타임 데이터**(`~/Library/Application Support/SimulationWorld`)까지 한 번에 삭제됩니다. 별도 정리 명령이 필요 없습니다.

## 요구사항

- macOS **Apple Silicon (arm64)** — QEMU `-accel hvf`
- 디스크 여유 **~12GB** (이미지 압축 4.9GB + 해제 후 11GB)
- 인터넷 (설치 시 S3 에서 이미지 4.9GB + 앱 91MB 자동 다운로드, 이후 캐시)

## 문서

- [사용법 상세](docs/usage.md) — 전체 명령
- [포트](docs/ports.md) — hostfwd 포트 목록 + 충돌 시 동작
- [트러블슈팅](docs/troubleshooting.md)
- [구조](docs/architecture.md) — VM / launcher / Electron 관계
- [시나리오 YAML 작성법](docs/scenario-yaml.md) — Script Test 용 `.yaml` 포맷
