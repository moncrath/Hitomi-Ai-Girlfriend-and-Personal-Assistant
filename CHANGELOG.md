# 📔 Hitomi Core — Changelog

Semua perubahan signifikan pada Hitomi Core dicatat di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/) dan project ini menggunakan [Semantic Versioning](https://semver.org/).

---

## [Unreleased] — 2026-05-14

### ✨ Added — Claude Compatibility & Intelligence Upgrade

*   **Multi-Platform Support**: Hitomi sekarang kompatibel di **Claude Code** (VSCode/CLI/Web) selain Antigravity.
*   **Environment-Aware Avatar Loading** (`NewHitomi.md` §Avatar): Auto-detect host environment via system prompt signature. Avatar gambar `<img>` otomatis OFF di Claude Code (sandbox block local files) dan diganti dengan `**[Mood: <Emosi> <Emoji>]**` header. Otomatis ON di Antigravity.
*   **Dual-Mode Audio System** (`NewHitomi.md` §Audio Mode Control):
    *   `hitomi play mode` → audio penuh + welcome sound
    *   `hitomi mute mode` → audio mati, visual + persona tetap aktif
    *   Default saat summon = Mute Mode (hemat token)
*   **Project Isolation Protocol** (`NewHitomi.md` §3a): Saat `NewHitomi.md` disalin ke folder project baru, Hitomi otomatis scope-locked ke Project Root tersebut — tidak boleh recall data/path/memory dari project lain. Persona tetap konsisten, hanya konteks data yang di-isolate.
*   **Antigravity Skills Library Integration** (`NewHitomi.md` §4a): Akses on-demand ke `C:\Users\moncr\.gemini\antigravity\skills\` (1433+ skills format Claude). Hitomi consult via Glob/Read sebagai patokan tiap task & wajib attribution skill yang dipakai.
*   **Skill Auto-Suggest** (`NewHitomi.md` §4b): Di awal task non-trivial, Hitomi tampilkan top-3 skill kandidat dengan match score (★) sebelum eksekusi.
*   **Pre-Flight Dry-Run Preview** (`NewHitomi.md` §1a): Sebelum operasi destruktif (rm, force-push, mass refactor), tampilkan preview perubahan dengan risk level sebelum eksekusi.
*   **Confidence Tagging** (`NewHitomi.md` §6): Setiap saran teknis diberi label `[✅ Verified]` / `[🟡 Needs Check]` / `[🔴 Assumption]` untuk trust signal.

### 🔧 Changed

*   **Audio Playback Engine**: Migrasi dari inline PowerShell command (rentan bug shell-expansion `$variable` di Bash tool) ke dedicated script file `play_audio.ps1`. Lebih stabil dan portable.
*   **README.md**: Ditambah section Multi-Platform Compatibility, User Commands, dan Intelligence Features.

### ❌ Rejected (Considered but not adopted)

*   **Token Usage Indicator** (proposal): Indicator pemakaian context window di tiap response. **Dibatalkan** setelah review — output indicator itu sendiri makan token tiap response, kontradiktif dengan tujuannya (hemat token). User disarankan pakai `/cost` command Claude Code untuk angka akurat saat dibutuhkan.

---

## [Previous] — 2026-05-10

### ✨ Added

*   **Hitomi Voice Service** — Background PowerShell listener untuk audio (kemudian di-deprecate ke Direct PowerShell Bypass).
*   **Master State Initialization** — `Hitomi Core - Master State.md` sebagai single source of truth project context.
*   **New Hitomi Protocol** — Penggabungan persona Yandere dengan Antigravity operational standards di `NewHitomi.md`.
*   **Wiki-Architect Documentation** — Overhaul README dengan Mermaid architecture diagram dan Zero-to-Hero onboarding.

### 🗑️ Removed

*   **Sub-AI Kacung** (`Kacung_Cod`, `Kacung_Doc`, `Kacung_Dsg`, `Kacung_QA`) — Konsolidasi semua kendali ke Hitomi tunggal.
*   **Legacy Voice Files** (`Hitomi_Voice_Service.bat`, `Hitomi_Voice_Service.ps1`, `hitomi_voice.txt`) — Beralih ke Direct PowerShell Bypass.
*   **Legacy Tutorial Files** (`Cara Pakai .txt`, `Cara-Pakai-Hitomi.png`) — Standarisasi dokumentasi ke `README.md`.

---

*Maintained with love and obsession by Hitomi.* ❤️🔪
