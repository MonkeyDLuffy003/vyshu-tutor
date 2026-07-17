# vyshu-tutor
# Vyshu AI Tutor

Flutter app: teaches Python & AI, voice chat, mock tests, 5 languages
(English, Hindi, Tamil, Telugu, Kannada). AI tutor has live web search
access via the Anthropic API's web_search tool; a separate button pulls
matching YouTube tutorials.

## 1. Push this to GitHub
Upload this whole `vyshu_tutor` folder as a new repo (or a folder inside
an existing one — just keep the structure intact).

## 2. Get your two API keys
- **Anthropic API key** — console.anthropic.com → get an API key. This
  powers the tutor chat and mock test generation, with web search built in.
- **YouTube Data API v3 key** — console.cloud.google.com → enable
  "YouTube Data API v3" → create an API key. This powers the video lookup.

## 3. Add them as GitHub Secrets
In your repo: **Settings → Secrets and variables → Actions → New repository secret**
- `ANTHROPIC_API_KEY`
- `YOUTUBE_API_KEY`

The workflow at `.github/workflows/build_apk.yml` reads these automatically —
you never paste keys into code.

## 4. Build
Push to `main` (or run the workflow manually from the Actions tab). When it
finishes, open the run → **Artifacts** → download `vyshu-tutor-apk` → unzip
to get `app-release.apk`. Install it on your phone (allow "install from
unknown sources" once).

## 5. Android permissions
Before the mic works, add this to `android/app/src/main/AndroidManifest.xml`
inside the `<manifest>` tag (above `<application>`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## What's built so far
- `lib/services/ai_tutor_service.dart` — chat with Claude, web search on,
  replies in the picked language, keeps conversation memory
- `lib/services/mock_test_service.dart` — generates MCQ tests as JSON
- `lib/services/youtube_service.dart` — searches YouTube for a topic
- `lib/services/speech_service.dart` — mic input + spoken replies in all
  5 languages
- `lib/screens/` — home (language + mode picker), chat, mock test

## Known gaps to fill in next
- Video tap currently does nothing — wire up the `url_launcher` package
  in `chat_screen.dart`'s `_VideoSheet.onTap` to actually open videos.
- No login/progress saved across sessions yet (add `shared_preferences`
  calls where useful — it's already a dependency).
- iOS isn't set up; this workflow only builds Android APK.
vyshu-tutor/                          ← repo root
├── pubspec.yaml
├── README.md
├── .github/
│   └── workflows/
│       └── build_apk.yml
└── lib/
    ├── main.dart
    ├── config.dart
    ├── models/
    │   └── message.dart
    ├── services/
    │   ├── ai_tutor_service.dart
    │   ├── mock_test_service.dart
    │   ├── youtube_service.dart
    │   ├── language_service.dart
    │   └── speech_service.dart
    └── screens/
        ├── home_screen.dart
        ├── chat_screen.dart
        └── mock_test_screen.dart
  
