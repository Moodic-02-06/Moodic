# :musical_note: Moodic (무딕)
> **"당신의 오늘을 음악으로 기록하세요."**

그날의 감정을 음악과 함께 기록하고 공유하는 **sns형 다이어리 앱** 입니다. 말로 다 할 수 없는 복잡한 감정을 음악에 투영하여 취향과 감정을 기반으로 타인과 깊게 연결되는 경험을 선사합니다.

---

## :hammer_and_wrench: Tech Stack & Libraries

### Environment
* **Framework:** Flutter
* **Language:** Dart

### Libraries & Backend
* **State Management:** `flutter_riverpod` - 전역 상태 관리 및 의존성 주입
* **Navigation:** `go_router` - 선언적 라우팅 관리
* **Backend & Auth:**
    * `firebase_core`, `cloud_firestore` - 실시간 데이터베이스
    * `firebase_auth`, `google_sign_in`, `kakao_flutter_sdk` - 다중 소셜 로그인
    * `firebase_storage` - 미디어 에셋 관리
* **Music & Media:**
    * `just_audio` - 오디오 재생 엔진 및 상태 제어
    * `image_picker` - 유저 커스텀 이미지 처리
* **Communication:**
    * `http` - 외부 음악 스트리밍 데이터 연동
    * `url_launcher` - 스트리밍 앱 외부 링크 연결

---

## :rocket: Key Features

### 1. 감정 태깅 기반 음악 공유 (Mood-Music Log)
* **감정 키워드 매칭:** 현재 느끼는 감정을 직관적으로 선택하고 기록합니다.
* **스트리밍 서비스 연동:** 외부 음악 데이터와 연동하여 선택한 감정에 어울리는 곡을 즉시 포스팅합니다.

### 2. 실시간 감정 피드 (Emotional Timeline)
* **정서적 교류:** 팔로워들의 실시간 감정 상태와 감상 곡을 확인하는 소셜 피드입니다.
* **소프트 인터랙션:** '좋아요'와 응원 메시지를 통해 따뜻한 유대감을 형성합니다.

### 3. [도전] 월간 감정 리포트 (Monthly Harmony)
* **데이터 시각화:** 한 달간의 감정 변화를 분석하여 리포트 형식으로 제공하며, 감정과 음악 장르 간의 상관관계를 분석합니다.

---

## :open_file_folder: Project Structure

```text
lib/
├── core/                  # 앱 설정 레이어 (Router, Theme)
│   ├── router/            # GoRouter 설정 및 라우팅 정의
│   └── theme/             # 다크 테마 및 전역 스타일 가이드
├── data/                  # Firebase 서비스 및 외부 API 통신 레이어
├── models/                # 데이터 엔티티 (User, MoodLog, MusicItem)
├── providers/             # Riverpod Providers 및 비즈니스 로직
├── views/                 # 기능별 UI 레이어
│   ├── home_page/         # 메인 감정 피드
│   ├── detail_page/       # 상세 페이지
│   ├── login_page/        # 소셜 로그인 및 인증
│   ├── like_page/         # 좋아요 페이지
│   ├── write_page/        # 감정 기록 및 음악 검색
│   ├── search_page/       # 음악 검색
│   └── mypage_page/       # 마이페이지 및 프로필 관리
├── firebase_options.dart  # Firebase 플랫폼별 설정 파일
└── main.dart              # 앱 진입점 (ProviderScope 초기화)
```