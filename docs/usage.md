# 사용법

```bash
seamosworld start [--vm-only] [--force]
seamosworld stop
seamosworld restart
seamosworld status            # 서비스 상태 (VM/dashboard/FIF/iot/mqtt)
seamosworld shell             # VM 에 SSH 접속
seamosworld dashboard         # 기본 브라우저로 dashboard 열기
seamosworld install <앱.fif>  # NEVONEX 앱 설치
seamosworld apps              # 설치된 앱 목록
seamosworld logs <service>    # 서비스 로그 follow
seamosworld update            # VM 이미지 최신본 재다운로드
seamosworld reset             # VM 데이터 초기화
seamosworld --help
```

## start 옵션

| 옵션 | 동작 |
|---|---|
| (기본) | VM(QEMU) + Electron 앱 창 함께 기동 |
| `--vm-only` | VM 만 기동 (Electron 앱 창 안 띄움) |
| `--force` | hostfwd 포트 충돌 시 충돌 프로세스 자동 SIGTERM→SIGKILL 후 기동 |

## 첫 실행 자동 다운로드

- VM 이미지 `qcow2` (압축 4.9GB) → `~/Library/Application Support/SimulationWorld/simworld.qcow2`
- Electron 앱 `SimWorld.app` (91MB) → 같은 디렉토리

이후 실행부터 캐시되어 바로 뜹니다. 이미지를 새로 받으려면 `seamosworld update`.
