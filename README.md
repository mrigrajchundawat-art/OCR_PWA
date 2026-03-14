# OCR PWA

A **Flutter PWA** that extracts text from images using on-device OCR. Supports **English** and **Hindi**.

## Features

- **Web Share Target** – Share images from other apps (gallery, camera) and extract text
- **On-device OCR** – Runs entirely in the browser via Tesseract.js (no backend)
- **Pick image** – Choose an image from your device when opened directly
- **Copy to clipboard** – One-tap copy of extracted text
- **Dark UI** – Clean, minimal interface

## Run locally

```bash
# Development
flutter run -d chrome

# Production build
flutter build web
```

Then serve `build/web` with any static server (e.g. `cd build/web && python -m http.server 8080`).

## Install as PWA

1. Open the app in **Chrome** on Android (or desktop).
2. Use **Add to Home Screen** / **Install app** from the browser menu.
3. The app will appear in your share sheet when sharing images.

## Share Target (Android)

After installing the PWA:

1. Open any app with an image (Photos, Camera, etc.).
2. Tap **Share** → choose **OCR Scanner**.
3. The shared image is processed and text is extracted.

## Browser support

- **Android Chrome** – Full share target support
- **Desktop Chrome** – Pick image works; share target limited
- **iOS Safari** – Share target support is limited; use **Pick image** instead

## Deploy to GitHub Pages

1. **Push your code** to a GitHub repository.

2. **Enable GitHub Pages** (one-time setup):
   - Go to **Settings → Pages**
   - Under **Build and deployment**, set **Source** to **GitHub Actions**

3. **Push to `main`** – the workflow runs automatically and deploys to:
   ```
   https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
   ```

4. **Manual deploy** – Go to **Actions → Deploy to GitHub Pages → Run workflow**

The workflow (`.github/workflows/deploy.yml`) builds with the correct `base-href` for your repo path, so Share Target and service worker work correctly.

## Tech stack

- Flutter Web
- Tesseract.js (eng + hin)
- Web Share Target API
- Service Worker for share handling
