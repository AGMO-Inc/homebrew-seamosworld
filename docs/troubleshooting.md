# 트러블슈팅

## `포트 XXXX 사용 중` — 기동 중단
충돌 프로세스를 끄거나 `seamosworld start --force`. QEMU 는 hostfwd 포트 중 하나라도 겹치면 전체 기동이 실패합니다. → [포트](ports.md)

## 이미지 다운로드 실패
인터넷/디스크(~12GB) 확인 후 `seamosworld start` 재시도. 이어받기가 아니라 재다운로드입니다. 수동: `seamosworld update`.

## Electron 앱이 안 뜸
Dashboard 는 브라우저에서 <http://localhost:3000> 으로 접속 가능합니다. 앱(.app) 다운로드가 실패해도 VM/dashboard 는 정상 동작합니다.

## 앱 설치(`install`) 실패
- `seamosworld status` 로 VM/FIF 기동 확인
- VM 이 떠 있어야 함(`seamosworld start` 먼저)
- `.fif` 경로 확인

## VM 은 떴는데 dashboard 무응답
`seamosworld status` → dashboard FAIL 이면 VM 부팅 직후일 수 있음. 수십 초 대기 후 재확인, 또는 `seamosworld logs dashboard`.

## SSH 접속
```bash
seamosworld shell
# 또는
ssh -p 2222 -i "~/Library/Application Support/SimulationWorld/simworld_key" simworld@localhost
```

## 완전 초기화
```bash
seamosworld stop
seamosworld reset    # VM 데이터 초기화
```
