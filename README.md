# homebrew-seamosworld

SeamOS World 에뮬레이터의 Homebrew tap 입니다. SeamOS World 는 가상 기기와 3D 트랙터 시뮬레이터로, 실제 기계 없이 SeamOS 앱을 실행하고 검증할 수 있습니다.

## 요구 사항

| | 최소 | 권장 |
| --- | --- | --- |
| 운영체제 | macOS, Apple Silicon | - |
| 메모리 | 8GB | 16GB |
| 디스크 여유 | 15GB | 30GB |

- 첫 실행 때 가상 기기 이미지(약 5GB)를 내려받습니다. 내려받은 파일과 압축을 푼 이미지가 잠깐 함께 있어서 15GB 가 필요합니다.
- Ubuntu / Debian 은 아래 [Ubuntu / Debian](#ubuntu--debian) 을 보세요.

## 설치

```bash
brew install agmo-inc/seamosworld/seamosworld
```

- 설치되는 것은 런처뿐입니다. QEMU 를 비롯해 필요한 도구는 의존성으로 함께 설치됩니다.
- 설치 중에 비밀번호를 한 번 묻습니다. 가상 기기에 주소를 주는 네트워크 서비스(`socket_vmnet`)를 시작하기 위해서입니다.

## 시작

```bash
seamosworld start
```

첫 실행은 가상 기기 이미지와 화면 앱을 내려받느라 몇 분 걸립니다. 그 뒤로는 가상 기기를 켜고 SeamOS World 창을 엽니다.

실행할 때 모드를 묻습니다. 미리 정하려면 옵션으로 넘깁니다.

| 옵션 | 동작 |
| --- | --- |
| `--nevonex` | 기기 플랫폼까지 켭니다. SeamOS 앱을 설치하고 검증할 때 씁니다. |
| `--simulator-only` | 기기 플랫폼 없이 시뮬레이터만 켭니다. 작업기 ECU, 맵, 시험을 다룰 때 씁니다. |
| `--vm-only` | 가상 기기만 켜고 창은 열지 않습니다. |
| `--force` | 필요한 포트를 다른 프로그램이 쓰고 있으면 그 프로그램을 끝내고 시작합니다. |

## 명령

| 명령 | 동작 |
| --- | --- |
| `seamosworld start` | 에뮬레이터를 시작합니다. |
| `seamosworld stop` | 에뮬레이터를 끕니다. |
| `seamosworld restart` | 다시 시작합니다. |
| `seamosworld status` | 서비스 상태와 버전을 보여 줍니다. |
| `seamosworld doctor` | 이 컴퓨터의 가상화, QEMU, 디스크, 포트, 버전을 점검합니다. |
| `seamosworld dashboard` | 화면을 기본 브라우저로 엽니다. |
| `seamosworld install <app.fif>` | 앱을 설치합니다. |
| `seamosworld send-file <file>` | 실행 중인 앱에 파일을 보냅니다. |
| `seamosworld apps` | 설치된 앱을 나열합니다. |
| `seamosworld logs <service>` | 서비스 로그를 따라 봅니다. |
| `seamosworld shell` | 가상 기기에 SSH 로 들어갑니다. |
| `seamosworld host` | 다른 도구가 접속할 가상 기기 주소를 출력합니다. |
| `seamosworld update` | 최신 릴리스로 업데이트합니다. |
| `seamosworld reset` | 가상 기기 데이터를 초기화합니다. |
| `seamosworld version` | 버전을 출력합니다. |

## 업데이트

```bash
brew upgrade seamosworld
seamosworld stop && seamosworld update && seamosworld start
```

첫 줄이 런처를, 둘째 줄이 가상 기기 이미지를 업데이트합니다. 둘 다 하세요.

## 제거

```bash
brew uninstall seamosworld          # 런처만 제거, 내려받은 이미지와 데이터는 남김
brew uninstall --zap seamosworld    # 이미지, 화면 앱, 데이터까지 모두 제거
```

데이터는 `~/Library/Application Support/SimulationWorld` 에 있습니다.

## 자주 나는 문제

| 증상 | 해결 |
| --- | --- |
| 무엇이 문제인지 모르겠음 | `seamosworld doctor` 로 점검합니다. |
| 포트가 사용 중이라 시작이 멈춤 | 그 포트를 쓰는 프로그램을 끄거나 `seamosworld start --force` 로 시작합니다. |
| 이미지 내려받기 실패 | 인터넷과 디스크 여유(15GB)를 확인한 뒤 `seamosworld start` 를 다시 실행합니다. |
| 창이 열리지 않음 | `seamosworld dashboard` 로 브라우저에서 엽니다. |
| 앱 설치 실패 | `seamosworld status` 로 가상 기기가 켜져 있는지 확인합니다. `--nevonex` 모드여야 합니다. |
| 업데이트했는데 바뀐 것이 없음 | [업데이트](#업데이트)의 두 줄을 모두 실행합니다. |

## Ubuntu / Debian

Homebrew 대신 apt 저장소로 설치합니다. 첫 명령은 저장소 등록이고 한 번만 실행하면 됩니다.

```bash
echo 'deb [trusted=yes] https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/apt stable main' \
  | sudo tee /etc/apt/sources.list.d/seamosworld.list

sudo apt update && sudo apt install seamosworld
seamosworld start
```

업데이트:

```bash
sudo apt update && sudo apt install --only-upgrade seamosworld seamosworld-app
seamosworld stop && seamosworld update && seamosworld start
```

## 문서

SeamOS 개발 문서: <https://docs.seamos.io>
