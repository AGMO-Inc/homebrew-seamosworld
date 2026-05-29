# 포트

VM 이 아래 호스트 포트를 hostfwd 로 점유합니다. **하나라도 다른 프로세스가 쓰고 있으면 기동이 중단**되고, 어느 포트를 누가 점유 중인지(PID/명령) 표시됩니다.

| 포트 | 용도 |
|---|---|
| 3000 | Dashboard (VM nginx) |
| 2222 | VM SSH |
| 8116 | FIF API (앱 설치) |
| 8121 | MQTT WebSocket |
| 8122 | MQTT mTLS broker |
| 8118 / 8119 / 8120 / 8123 / 8126 | 보조 서비스 |
| 8201 / 8202 | 보조 서비스 |
| 5050 | iot-server |
| 5100 | api-server |
| 1456 | 앱 WebSocket (CustomUI) |
| 29536 | CAN TCP proxy |
| 29539 | GPS serial (ttyAMA2/FIL) |

## 충돌 시

QEMU 는 hostfwd 규칙 중 **하나라도 겹치면 전체 기동이 실패**합니다(부분 기동 없음). launcher 는 start 전에 위 포트를 모두 검사해, 충돌이 있으면 명확한 에러와 함께 기동을 중단합니다.

```bash
seamosworld start --force   # 충돌 프로세스를 SIGTERM→SIGKILL 후 기동
```

> 주의: `--force` 는 lsof 로 찾은 점유 프로세스를 종료합니다. Docker 컨테이너나 다른 작업 프로세스가 그 포트를 쓰고 있으면 함께 종료될 수 있으니, 가능하면 해당 프로세스를 직접 정리한 뒤 `--force` 없이 기동하세요.
