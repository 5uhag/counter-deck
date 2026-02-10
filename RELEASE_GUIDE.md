# 🚀 How to Create a GitHub Release with APK

## Method 1: Automatic Build via GitHub Actions (Recommended)

Your repo has GitHub Actions set up to automatically build and release the APK!

### Steps:

1. **Tag your version**
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

2. **GitHub Actions will automatically:**
   - Build the APK
   - Create a Release
   - Upload the APK to the release
   - Generate release notes

3. **Check progress:**
   - Go to: `https://github.com/5uhag/counter-deck/actions`
   - Watch the build complete (~2-3 minutes)

4. **Release is ready!**
   - Go to: `https://github.com/5uhag/counter-deck/releases`
   - Your APK will be available for download

### Version Tagging

```bash
# List existing tags
git tag

# Create new version tag
git tag v1.1.0

# Push tag to GitHub (triggers build)
git push origin v1.1.0

# Or push all tags
git push --tags
```

---

## Method 2: Manual Release Upload

If you prefer to upload your locally-built APK:

1. **Build APK locally**
   ```bash
   cd counter_deck_flutter
   flutter build apk --release
   ```

2. **Create Release on GitHub**
   - Go to: `https://github.com/5uhag/counter-deck/releases/new`
   - Tag version: `v1.1.0`
   - Release title: `SounDeck v1.1.0`
   - Description: Copy from the workflow file or customize

3. **Upload APK**
   - Drag and drop: `counter_deck_flutter/build/app/outputs/flutter-apk/app-release.apk`

4. **Publish Release**

---

## Method 3: Manual Workflow Trigger

You can manually trigger the build from GitHub:

1. Go to: `https://github.com/5uhag/counter-deck/actions`
2. Click "Build and Release APK" workflow
3. Click "Run workflow" button
4. Select branch: `main`
5. Click "Run workflow"

**Note:** For manual trigger, you still need to create the release tag first.

---

## 🎯 Recommended Workflow for v1.1 Release

Since you have new features, here's the complete flow:

```bash
# 1. Make sure all changes are committed
git add .
git commit -m "v1.1: Add backend enforcement, API auth, and process killer"

# 2. Push to GitHub
git push origin main

# 3. Create and push version tag
git tag v1.1.0
git push origin v1.1.0

# 4. Wait for GitHub Actions to build (2-3 min)
# Check: https://github.com/5uhag/counter-deck/actions

# 5. Release is ready!
# View: https://github.com/5uhag/counter-deck/releases
```

---

## ⚠️ Important Notes

### APK Not in Repo
The APK file itself is **NOT** stored in the GitHub repository:
- ✅ **Good:** Keeps repo size small
- ✅ **GitHub Actions builds it fresh** from source code
- ✅ **Automatically uploaded to Releases page**

### When APK Gets Built
The APK builds automatically when you:
1. Push a version tag (e.g., `v1.1.0`)
2. Manually trigger the workflow

### Where to Download APK
Users download the APK from:
```
https://github.com/5uhag/counter-deck/releases/latest
```

---

## 🐛 Troubleshooting

### Build Fails on GitHub Actions
Check the logs:
1. Go to Actions tab
2. Click on the failed workflow
3. Check error messages

Common issues:
- Dependency conflicts (update `pubspec.yaml`)
- Gradle version issues (update `build.gradle`)
- Missing permissions (set in workflow file)

### APK Not Appearing
Make sure:
- Tag was pushed: `git push origin v1.1.0`
- Workflow completed successfully (green checkmark)
- You're looking at the Releases page, not the repo files

---

## 📋 Quick Command Summary

```bash
# Complete release process (one-shot)
git add .
git commit -m "v1.1: Release features"
git push origin main
git tag v1.1.0
git push origin v1.1.0

# Then wait for GitHub Actions to complete!
# APK will be at: https://github.com/5uhag/counter-deck/releases
```

Users will download the APK from the Releases page, not from the repository files! 🎉
