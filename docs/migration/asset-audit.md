# Asset Audit

This audit was created during Phase 0 of the Flutter migration.

## Summary

- The legacy prototype now lives under `legacy/web-prototype/`.
- The legacy prototype still resolves image URLs through `legacy/web-prototype/images`, which is a symlink to `legacy/web-prototype/assets-from-prototype`.
- Only a small subset of referenced assets existed in the original repo.
- To keep the archived prototype runnable from its new location, lightweight placeholder assets were generated for the missing references.
- The Flutter app should not treat these generated placeholders as final production art.

## Referenced Assets

| Referenced by | Asset | Current status | Current source |
| --- | --- | --- | --- |
| `src/gameData.js` | `leapcreek_sigil.png` | generated placeholder | `legacy/web-prototype/assets-from-prototype/leapcreek_sigil.png` |
| `src/gameData.js` | `blackstone_sigil.png` | generated placeholder | `legacy/web-prototype/assets-from-prototype/blackstone_sigil.png` |
| `src/gameData.js` | `fangmarsh_sigil.png` | generated placeholder | `legacy/web-prototype/assets-from-prototype/fangmarsh_sigil.png` |
| `src/gameData.js` | `underclaw_sigil.png` | generated placeholder | `legacy/web-prototype/assets-from-prototype/underclaw_sigil.png` |
| `src/gameData.js` | `pouch_sigil.png` | generated placeholder | `legacy/web-prototype/assets-from-prototype/pouch_sigil.png` |
| `src/gameData.js` | `grinning-face-with-big-eyes-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/grinning-face-with-big-eyes-svgrepo-com.svg` |
| `src/gameData.js` | `face-with-head-bandage-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/face-with-head-bandage-svgrepo-com.svg` |
| `src/gameData.js` | `dizzy-face-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/dizzy-face-svgrepo-com.svg` |
| `src/gameApp.js` | `arrows-couple-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/arrows-couple-svgrepo-com.svg` |
| `src/gameApp.js` | `defend-icon.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/defend-icon.svg` |
| `src/gameApp.js` | `fire-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/fire-svgrepo-com.svg` |
| `src/gameApp.js` | `medicine-pharmacy-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/medicine-pharmacy-svgrepo-com.svg` |
| `src/gameApp.js` | `business-card-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/business-card-svgrepo-com.svg` |
| `src/gameApp.js` | `mountain-1-svgrepo-com.svg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/mountain-1-svgrepo-com.svg` |
| `src/gameApp.js` | `chinese-knot-svgrepo-com.svg` | original asset moved from repo root | `legacy/web-prototype/assets-from-prototype/chinese-knot-svgrepo-com.svg` |
| `src/gameApp.js` | `modal-background.jpeg` | generated placeholder | `legacy/web-prototype/assets-from-prototype/modal-background.jpeg` |

## Non-runtime source assets kept with the legacy prototype

| Asset | Status | Current source |
| --- | --- | --- |
| `map.png` | original source asset, not used by the current runtime board | `legacy/web-prototype/assets-from-prototype/map.png` |
| `map.psd` | original source asset, not used by the current runtime board | `legacy/web-prototype/assets-from-prototype/map.psd` |
| `soup-svgrepo-com.svg` | original source asset, not referenced by the current runtime code | `legacy/web-prototype/assets-from-prototype/soup-svgrepo-com.svg` |

## Flutter follow-up requirements

The Flutter port should replace the generated placeholders with bundled assets under:

- `apps/silver_wolf_flutter/assets/icons/`
- `apps/silver_wolf_flutter/assets/images/`
- `apps/silver_wolf_flutter/assets/sigils/`

Production-ready replacements are required for:

- city sigils
- status faces
- board action icons
- combat and modal background artwork

The existing `map.png` and `map.psd` files should remain reference material only unless a later design pass explicitly chooses to introduce a map-image-based board.
