# Source import

## Working snapshot

The source was imported from `Heartstopper-Todo-List-current-20261121-021745.zip`, supplied by Iris after testing the current desktop version.

Snapshot SHA-256:

```text
21d37e02d209c4242ebdc9c1a0817417a5e5b870dedebe9680ce818dc9e63275
```

The rendering pipeline, current leaf positions and palette, font styling, date colors, six-row viewport, scrolling behavior, mouse dragging, and confirmed Unload menu were retained. The feature list in the README describes the effective final interface.

The authentication, task export, and Lua source match the uploaded files after newline and encoding normalization. The original upload is kept separately from the publication copy during preparation; personal machine paths and generated runtime files are not published.

## Publication changes

- Replaced machine-specific executable, INI, skin-directory, and launcher paths with `widget-paths.ps1` and an optional ignored `widget.config.json`.
- Preserved the rendering pipeline rather than replacing the current design. With the same synthetic tasks, random seed, and mocked Windows metrics, the generated INI matches the uploaded renderer after project-root paths are normalized.
- Added the retained C# drag-helper implementation as `src/ScrollbarDrag.cs` and a Windows PowerShell 5.1 build step. The supplied executable is not committed.
- Changed the setup script to require an existing Rainmeter installation, build the local helper from source, and use only current-user startup settings. It does not download or run a third-party installer.
- Made launchers relative to their own directory and use `RemoteSigned`; the hidden VBScript launchers are plain text without a UTF-8 BOM.
- Added explicit requirements and artwork instructions. The supplied leaf image, wallpaper, private tasks, login files, logs, backups, and generated skins are not committed.
- Preserved UTF-8 with BOM for PowerShell scripts, so Windows PowerShell 5.1 can read Unicode text correctly. Generated Rainmeter skins remain UTF-16 LE.

These changes affect the publication copy only. Preparing or publishing this repository does not modify Iris's working Windows installation.

## Scrollbar helper provenance

The uploaded helper was `widget-scroll-drag-v2.exe`, SHA-256:

```text
1c78b7d346889046a3d852ae9de74c6bd0ee75024448add4f62066edfaac859f
```

Its .NET metadata identifies `WidgetScrollbarDragV2` and the same entry point, mouse APIs, and command-sending methods as the retained source from the working implementation. This metadata check is not a claim of a bit-for-bit reproducible executable. `build-helper.ps1` creates a new executable locally from the published source.

## Validation

Publication checks used synthetic task data and mocked Windows graphics/screen APIs. No Microsoft account credentials, live task data, or uploaded executable were used for execution.

- All published PowerShell scripts passed syntax parsing.
- The C# helper source compiled without executing its Windows entry point.
- The uploaded and published renderers produced matching INI output for 0, 1, 6, 7, and 101 synthetic tasks.
- The final rendered interface retained pale-pink overdue task text and its current controls.
- Portable executable discovery, adjacent INI detection, relative `SkinPath`, and explicit skin-directory configuration were checked using filesystem fixtures.
- The imported Lua passed tests for smooth wheel movement, one bounce per edge arrival, sustained input at either edge, scrollbar drag bounds, and release.
- Mocked sync checks confirmed that unchanged data does not redraw the skin, overlapping polls skip immediately, and fetch failures retain the previous cache.
- The two-confirmation flow was checked with mocked dialogs: either No cancels; only Yes followed by Yes unloads.

The original interactive behavior was tested by Iris on Windows. The publication checks were run in a Linux execution environment; the revised setup, Windows message delivery, native drag boundaries, and freshly built Windows executable have not been exercised end to end on Windows here.
