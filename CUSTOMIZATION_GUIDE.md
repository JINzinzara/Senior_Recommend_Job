# 시니어 일자리 추천 앱 - 색상 및 글씨체 커스터마이징 가이드

## 1. 글씨체 변경 방법

### 현재 적용된 글씨체
- **Noto Sans KR** (동글동글한 한글 폰트)
- Google Fonts에서 제공하는 무료 폰트

### 글씨체 수정 파일
**파일 경로:** `/app/global.css`

```css
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700&display=swap');

* {
  font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
```

### 글씨체 변경 방법
1. Google Fonts (https://fonts.google.com)에서 원하는 한글 폰트 검색
2. 폰트 선택 후 `@import` URL 복사
3. `global.css`의 `@import url()` 부분을 새로운 URL로 교체
4. `font-family` 값을 새 폰트명으로 변경

**예시 (다른 폰트로 변경):**
```css
/* Pretendard 폰트로 변경 */
@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css');

* {
  font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
```

---

## 2. 색상 변경 방법

### 현재 적용된 색상 팔레트

| 용도 | 색상 코드 | 사용 위치 |
|------|---------|---------|
| **글자 색상** | `#5C3D2E` (진한 브라운) | 모든 텍스트 |
| **배경 색상** | `#FFFFFF` (흰색) | 모든 화면 배경 |
| **버튼/강조** | `#D4A574` (골드) | 버튼, 진행 바, 선택 표시 |
| **보조 글자** | `#8B6F47` (옅은 브라운) | 부제목, 설명 텍스트 |
| **테두리** | `#E8D4B8` (베이지) | 카드 테두리, 구분선 |
| **경고/필수** | `#EF4444` (빨강) | 선택 개수 안내 |

### 색상 수정 파일 (3가지 방법)

#### **방법 1: theme.config.js (권장 - 전체 앱에 적용)**

**파일 경로:** `/theme.config.js`

```javascript
const themeColors = {
  primary: { light: '#D4A574', dark: '#D4A574' },      // 버튼, 강조색
  background: { light: '#FFFFFF', dark: '#FFFFFF' },   // 배경
  surface: { light: '#FFFFFF', dark: '#FFFFFF' },      // 카드 배경
  foreground: { light: '#5C3D2E', dark: '#5C3D2E' },   // 주 텍스트
  muted: { light: '#8B6F47', dark: '#8B6F47' },        // 보조 텍스트
  border: { light: '#E8D4B8', dark: '#E8D4B8' },       // 테두리
  error: { light: '#EF4444', dark: '#EF4444' },        // 경고/필수
};
```

**색상 변경 예시:**
```javascript
const themeColors = {
  primary: { light: '#FF6B6B', dark: '#FF6B6B' },      // 빨강으로 변경
  background: { light: '#F5F5F5', dark: '#F5F5F5' },   // 밝은 회색으로 변경
  foreground: { light: '#1A1A1A', dark: '#1A1A1A' },   // 검정으로 변경
  // ... 나머지 색상
};
```

#### **방법 2: 개별 화면 파일에서 직접 수정**

각 화면 파일에서 색상을 직접 지정할 수 있습니다.

**웰컴 화면:** `/app/index.tsx`
```typescript
const styles = StyleSheet.create({
  mainText: {
    color: "#5C3D2E",  // 글자 색상 변경
  },
  startButton: {
    backgroundColor: "#D4A574",  // 버튼 색상 변경
  },
});
```

**설문 화면:** `/app/survey.tsx`
```typescript
<Text style={styles.hintText}>
  {currentQuestion.maxSelect}개까지 선택 가능
</Text>

// styles에서:
hintText: {
  color: "#EF4444",  // 빨간색 변경
}
```

**로딩 화면:** `/app/loading.tsx`
```typescript
{ backgroundColor: "#D4A574", opacity: 0.08 }  // 배경 원 색상
```

**결과 화면:** `/app/result.tsx`
```typescript
{ backgroundColor: "#FFFFFF", borderColor: "#E8D4B8" }  // 카드 색상
```

#### **방법 3: global.css에서 CSS 변수로 관리 (고급)**

```css
:root {
  --color-primary: #D4A574;
  --color-background: #FFFFFF;
  --color-foreground: #5C3D2E;
  --color-text-secondary: #8B6F47;
  --color-border: #E8D4B8;
  --color-error: #EF4444;
}

* {
  font-family: 'Noto Sans KR', sans-serif;
}
```

---

## 3. 색상 변경 체크리스트

색상을 변경할 때 다음 파일들을 확인하세요:

- [ ] `theme.config.js` - 전체 테마 색상 정의
- [ ] `app/index.tsx` - 웰컴 화면 (글자, 버튼)
- [ ] `app/survey.tsx` - 설문 화면 (진행 바, 선택지, 버튼)
- [ ] `app/loading.tsx` - 로딩 화면 (배경, 텍스트)
- [ ] `app/result.tsx` - 결과 화면 (카드, 텍스트)

---

## 4. 앱 UI 저장 및 배포

### 4.1 현재 코드 저장 (GitHub)

현재 앱의 모든 코드는 GitHub에 저장할 수 있습니다:

```bash
# 프로젝트 디렉토리에서
cd /home/ubuntu/senior_job_recommender_app

# Git 초기화 (처음 한 번만)
git init
git add .
git commit -m "시니어 일자리 추천 앱 초기 버전"

# GitHub에 푸시 (GitHub 계정 필요)
git remote add origin https://github.com/YOUR_USERNAME/senior-job-recommender.git
git branch -M main
git push -u origin main
```

### 4.2 앱 빌드 및 배포

#### **iOS 빌드 (Apple App Store)**
```bash
cd /home/ubuntu/senior_job_recommender_app
eas build --platform ios
```

#### **Android 빌드 (Google Play Store)**
```bash
cd /home/ubuntu/senior_job_recommender_app
eas build --platform android
```

#### **웹 배포**
```bash
cd /home/ubuntu/senior_job_recommender_app
npm run build
# 생성된 dist 폴더를 웹 호스팅 서비스에 업로드
```

### 4.3 Expo Go로 테스트 (무료)

개발 중에는 Expo Go 앱을 사용하여 실시간으로 테스트할 수 있습니다:

1. 휴대폰에 Expo Go 앱 설치 (iOS App Store / Google Play Store)
2. 다음 명령어 실행:
   ```bash
   cd /home/ubuntu/senior_job_recommender_app
   pnpm dev
   ```
3. 터미널에 표시된 QR 코드를 Expo Go에서 스캔
4. 앱이 휴대폰에서 실시간으로 로드됨

---

## 5. 주요 파일 구조

```
senior_job_recommender_app/
├── app/
│   ├── index.tsx           # 웰컴 화면
│   ├── survey.tsx          # 설문 화면 (Q1~Q6)
│   ├── loading.tsx         # 로딩 화면
│   ├── result.tsx          # 결과 화면 (슬라이드)
│   └── _layout.tsx         # 네비게이션 설정
├── theme.config.js         # 색상 팔레트 (전체 테마)
├── global.css              # 글씨체 및 전역 스타일
├── lib/
│   └── recommendation.ts   # 추천 로직 (NCS 매핑, LLM)
├── server/
│   └── routers.ts          # API 엔드포인트
└── app.config.ts           # 앱 설정 (이름, 아이콘 등)
```

---

## 6. 색상 조합 추천

### 따뜻한 톤 (현재)
- 주색: `#D4A574` (골드)
- 텍스트: `#5C3D2E` (진한 브라운)
- 배경: `#FFFFFF` (흰색)

### 차가운 톤
- 주색: `#4A90E2` (파랑)
- 텍스트: `#1A3A52` (진한 파랑)
- 배경: `#F0F4F8` (밝은 파랑)

### 활기찬 톤
- 주색: `#FF6B6B` (빨강)
- 텍스트: `#2C3E50` (진한 회색)
- 배경: `#FFFFFF` (흰색)

---

## 7. 도움말

### 색상 코드 찾기
- [Color Picker](https://htmlcolorcodes.com/)
- [Coolors.co](https://coolors.co/)
- [Adobe Color](https://color.adobe.com/)

### 글씨체 찾기
- [Google Fonts](https://fonts.google.com/?subset=korean)
- [Noto Sans KR](https://fonts.google.com/noto/specimen/Noto+Sans+KR)
- [Pretendard](https://github.com/orioncactus/pretendard)

---

## 8. 변경 후 테스트

색상이나 글씨체를 변경한 후 다음 명령어로 테스트하세요:

```bash
cd /home/ubuntu/senior_job_recommender_app

# 테스트 실행
pnpm test

# 개발 서버 시작
pnpm dev

# TypeScript 타입 체크
pnpm check
```
