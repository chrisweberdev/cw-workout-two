# CW Hybrid Training App - Claude Code Instructions

## Project Overview
Flutter PWA hybrid training tracker (strength, running, HIIT) with GPT coaching, deployed to GitHub Pages.

## Branch Structure
- `main` - Development branch, all features merge here
- `gh-pages` - Deployment branch for GitHub Pages (https://chrisweberdev.github.io/cw-workout-two/)

## Development Workflow

### Starting a New Feature
```bash
cd cw_workout_app_two
git checkout main
git pull origin main
git checkout -b feature/feature-name
```

### Testing Locally
```bash
flutter run -d chrome
```

### When Feature is Ready
1. Merge to main:
```bash
git checkout main
git merge feature/feature-name
git push origin main
```

2. Delete feature branch:
```bash
git branch -d feature/feature-name
```

## Deployment to iPhone PWA

### IMPORTANT: Data Preservation
- PWA data is stored in IndexedDB (browser storage)
- Normal PWA updates preserve data automatically
- **DO NOT** delete and re-add the PWA from home screen (causes data loss)
- **RECOMMEND** user exports backup before major updates (Settings > Manual Backup)

### Deploy Steps
```bash
# 1. Ensure on main with latest changes
git checkout main

# 2. Clean build
flutter clean
flutter pub get

# 3. Build web release
flutter build web --release --base-href "/cw-workout-two/"

# 4. Copy build to temp location
cp -R build/web /tmp/cw-workout-two-build

# 5. Switch to gh-pages and deploy
git checkout gh-pages
cp -R /tmp/cw-workout-two-build/* .
git add -A
git commit -m "Deploy: description of changes"
git push origin gh-pages

# 6. Return to main
git checkout main
```

### After Deployment
- User refreshes PWA on iPhone (pull down or close/reopen)
- Service worker fetches new version
- Data in IndexedDB persists (no loss if done correctly)

## iOS PWA Data Considerations
- Safari may evict IndexedDB after 7 days of inactivity
- Low device storage can trigger data eviction
- User should open app regularly or use manual backup feature
- Reinstalling PWA (delete + re-add to home screen) = data loss

## Differences from CW Workout (App One)

| Feature | CW Workout | CW Hybrid |
|---------|------------|-----------|
| Focus | Strength training only | Hybrid (strength, running, HIIT) |
| Icon | Blue robot | Orange "H" dumbbell |
| Theme | Indigo (#6366F1) | Coral (#ff6b35) |
| GPT Integration | LLM progression tips | Full GPT coaching with custom URL |
| Cloud Backup | Google Drive | GitHub integration |
| Body Tracking | No | Body scan feature |

## Tech Stack
- Flutter 3.x with web support
- Hive for local storage (IndexedDB on web)
- fl_chart for analytics visualization
- GitHub Pages for hosting
- HTTP for GPT API integration
