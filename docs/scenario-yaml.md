# Scenario YAML Format

signal-controller 가 재생하는 시나리오 파일 포맷. **메타데이터(metadata)** 와
**신호부(signals)** 를 명확히 분리한다.

시나리오는 시뮬레이터 없이도 신호를 재생하는 용도다. dashboard 의 Signal 패널
→ Script Test 에서 `.yaml` 을 업로드하거나, WS 8765 로 `load_scenario` →
`start` 액션을 보내면 engine 이 `signals` 를 `metadata.hz` 주기로 재생한다.
재생 중에는 simulator 의 manual_inject(WS 8765) 가 무시된다(frames-authoritative).

---

## 구조

```yaml
metadata:
  name: "Leveler — rough ground leveling (60s)"   # 표시 이름
  version: "1.0"                                    # 시나리오 버전 (포맷/내용 개정 추적)
  description: "..."                                # 설명 (선택)
  hz: 10                                            # 재생 주기 (Hz)
  loop: true                                        # 끝나면 처음부터 반복
  target_apps:                                      # 이 시나리오가 전제하는 앱 (선택)
    - leveler_app                                   #   로드 시 active 확인 근거 + dashboard 표시
  implement:                                        # 작업기 메타 (선택)
    attached: true                                  # 부착 여부 — hitch/HYD publish 의 단일 진실
    type: leveler                                   # 작업기 종류 (leveler 등)
    front_attach: false                             # 전방 히치 사용 여부
  initial:                                          # 초기 상태 (signals 첫 프레임 전)
    latitude: 37.5665
    longitude: 126.978
    speed_kmh: 5.0
    heading_deg: 90.0
  provides:                                         # 이 시나리오가 직접 주는 신호 키 목록
    - latitude
    - longitude
    - heading_deg
    - ...

signals:                                            # 신호부 — 매 tick(1/hz초) 1 프레임
  - latitude: 37.5665
    longitude: 126.9780016
    heading_deg: 90.0
    speed_kmh: 5.0
    roll: 1.2
    pitch: -0.5
    hitch_pos_rear_pct: 70.0
    ...
  - { ... }
```

---

## metadata 필드

| 키 | 타입 | 의미 |
|---|---|---|
| `name` | string | 시나리오 표시 이름 |
| `version` | string | 시나리오 버전(포맷/내용 개정 추적). 기본 `"1.0"` |
| `description` | string | 설명 (선택) |
| `hz` | number | signals 재생 주기. 기본 10 |
| `loop` | bool | 끝나면 처음부터 반복. 기본 false |
| `target_apps` | string \| list[string] | 이 시나리오가 전제하는 앱(`leveler_app` 등). 로드 시 대상 앱 active 확인 근거 + dashboard 표시. str 하나도 허용 |
| `duration_s` | number | 길이(초). **명시 불필요 — `len(signals)/hz` 로 자동 계산해 broadcast** |
| `implement.attached` | bool | **작업기 부착 여부.** true 면 hitch(fek/248·251·254·257) + HYD(fek/9457) 를 신호값대로 publish, false 면 안전값 0 으로 publish. **signal 의 hitch 값으로 추론하지 않는다 — 반드시 여기서 명시.** |
| `implement.type` | string | 작업기 종류 (`leveler` 등). 표시·로깅용 |
| `implement.front_attach` | bool | 전방 히치(fek/254·257) 사용 여부. 기본 false |
| `initial.latitude/longitude/speed_kmh/heading_deg` | number | signals 첫 프레임 전 초기 상태 |
| `provides` | list[string] | 이 시나리오가 직접 주는 신호 키. `latitude`+`longitude` 둘 다 있으면 GPS 절대위치 모드(적분 OFF), 없으면 speed/heading 으로 위치 적분(적분 ON) |

---

## signals 프레임 키 (FRAME_FIELD_MAP)

각 프레임은 아래 키들의 부분집합. 없는 키는 이전 값 유지.

| 키 | 단위 | 대상 신호 |
|---|---|---|
| `latitude`, `longitude` | deg | GPS (fek/9465) |
| `heading_deg` (= `heading`, `yaw`) | deg | heading |
| `speed_kmh` | km/h | 차속 |
| `rpm` | rpm | 엔진 RPM |
| `roll`, `pitch` | deg | IMU 자세 (Allynav fek/9437) |
| `accel_x`, `accel_y`, `accel_z` | m/s² | IMU 가속도 (fek/9438) |
| `gyro_x`, `gyro_y`, `gyro_z` | rad/s | IMU 각속도 (fek/9439) |
| `steerAngle` (= `steer_angle`) | deg | 앞바퀴 조향각 |
| `measuredSteerAngleDeg` | deg | 조향휠 실측각 |
| `hitch_pos_rear_pct` | % | 후방 히치 위치 (fek/251) |
| `hitch_pos_front_pct` | % | 전방 히치 위치 (fek/257) |
| `hitch_load_per` | % | 히치 부하율 |
| `hyd_voltage_v1`, `hyd_voltage_v2` | V | 유압 센서 전압 (fek/9457) |
| `hyd_pressure_bar` | bar | 유압 압력 |

> 주의: `implement_attached` 는 **signals 프레임에 넣지 않는다** — `metadata.implement.attached`
> 로만 결정한다.

---

## 하위호환 (v1 legacy)

`metadata` 블록 없이 `name`/`hz`/`loop`/`provides`/`frames` 가 top-level 에 평탄하게
있는 옛 포맷도 읽힌다. `metadata` 가 있으면 그게 우선, 없으면 top-level 에서 읽는다.
신호부는 `signals`(v2) 또는 `frames`(v1) 둘 다 허용.

---

## 예시

- `leveler_rough_ground.yaml` — 울퉁불퉁한 땅 위 leveler 작업 (v2 포맷 레퍼런스)
- `AGMO_SOLUTION_1.yaml`, `straight_line.yaml` — v1 legacy 포맷
