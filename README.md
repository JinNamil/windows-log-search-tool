# windows-log-search-tool
# Multi Log Keyword Scanner

Windows 환경에서 여러 키워드를 로그 파일에서 빠르게 검색하는 PowerShell 기반 도구입니다.

- ini 파일 기반 설정
- 여러 키워드 동시 검색
- 파일 또는 디렉토리 검색 지원
- 키워드별 검색 횟수 출력
- 검색 결과 파일 저장
- 대용량 로그 대응

---

# Features

- `keywords.ini` 설정만 수정하면 바로 사용 가능
- 디렉토리 지정 시 하위 파일 전체 검색
- 파일 지정 시 단일 파일 검색
- 검색 결과와 카운트 저장
- 특수문자 포함 문자열 검색 지원
- 빠른 검색 성능

---

# Project Structure

```text
project/
├─ keywords.ini
├─ search_logs.ps1
├─ run_search.bat
└─ search_result.txt
```

---

# Configuration

## keywords.ini

```ini
[config]
target=C:\project\debug_log

[keywords]
1=Hello RTOS World
2=POWER OFF (REBOOT)
3=_ISF_VdoEnc_UnLockCB
4=_ISF_VdoEnc_LockCB
5=off_reason:REBOOT_SYS_ERROR
6=job queue full
```

## target

### 디렉토리 검색

```ini
target=C:\project\debug_log
```

하위 파일 전체 검색

### 단일 파일 검색

```ini
target=C:\project\debug_log\system.log
```

파일 하나만 검색

---

# Supported File Extensions

다음 파일들을 검색합니다.

- `.txt`
- `.log`
- `.ini`
- `.csv`
- `.xml`
- `.json`
- `.c`
- `.cpp`
- `.h`
- `.hpp`
- `.py`
- `.bat`
- `.ps1`

필요 시 `search_logs.ps1`에서 추가 가능합니다.

---

# Usage

## Run

```bat
run_search.bat
```

또는

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File search_logs.ps1
```

---

# Output Example

```text
=========================================
Search Start
Target: C:\project\debug_log
File Count: 124
=========================================

Hello RTOS World : 12
POWER OFF (REBOOT) : 4
_ISF_VdoEnc_UnLockCB : 89
_ISF_VdoEnc_LockCB : 89
off_reason:REBOOT_SYS_ERROR : 2
job queue full : 15

=========================================
Search Complete
Result saved to search_result.txt
=========================================
```

---

# Output File

검색 상세 결과는 아래 파일에 저장됩니다.

```text
search_result.txt
```

형식:

```text
C:\project\debug_log\system.log:123:POWER OFF (REBOOT)
```

---

# Requirements

- Windows
- PowerShell 5.1 이상

---

# License

MIT License
