# Pre-Push Checklist for GitHub

Run this checklist before pushing to GitHub to ensure no sensitive data is leaked.

## ✅ Security Checks

- [x] **config.json** is gitignored (contains API key)
- [x] **config.json.template** exists (for users to copy)
- [x] Sound files are gitignored (user-specific)
- [x] No hardcoded passwords/keys in code
- [x] .gitkeep files are kept for empty directories

## ✅ Documentation

- [x] README.md is up to date
- [x] Setup instructions include config template copying
- [x] All features are documented
- [x] Troubleshooting section is complete

## ✅ Code Quality

- [x] No debug print statements left in production code
- [x] All functions have docstrings
- [x] Code is properly formatted
- [x] No unused imports

## ✅ Build Artifacts

- [x] APK is in release folder (for users to download)
- [x] Flutter build artifacts are gitignored  
- [x] Python __pycache__ is gitignored

## 🚀 Ready to Push

Everything is ready! Run:

```bash
git status
git add .
git commit -m "feat: add backend enforcement, API key field, and kill processes feature"
git push origin main
```

## 📋 What Gets Pushed

**Included:**
- ✅ Source code (Python, Dart)
- ✅ config.json.template (without API key)
- ✅ Documentation (README, guides)
- ✅ Helper scripts (.bat files)
- ✅ Release APK
- ✅ .gitkeep placeholders

**Excluded (Private):**
- ❌ config.json (has your API key)
- ❌ Sound files (user-specific)
- ❌ Build artifacts
- ❌ IDE settings
- ❌ Python cache files

## ⚠️ Important Notes

1. **First Time Setup for Others:**
   Users will need to:
   - Copy `config.json.template` to `config.json`
   - Run backend once to generate API key
   - Add their own sound files

2. **Your Local Config:**
   Your `config.json` with API key stays local and won't be pushed.

3. **Future Updates:**
   When you make changes, the API key in your local `config.json` is safe because it's gitignored.
