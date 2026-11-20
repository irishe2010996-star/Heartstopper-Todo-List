# Heartstopper Todo List

A personal, Heartstopper-inspired Windows desktop customization for Microsoft To Do, built on Rainmeter and PowerShell.

A small desktop companion for school days: blue and yellow leaves, a translucent card, and soft pink overdue reminders. 💙💛

## Current version

This repository contains the source imported from Iris's latest working Windows snapshot, including the Lua scrolling code and the C# source for the draggable scrollbar. Personal data, compiled binaries, and third-party artwork are not included.

The current design and behavior are:

- An English interface, with a translucent white card, white dashed frame, and blue/yellow leaves scattered above the tasks.
- `𝕋𝕠 𝔻𝕠` heading and translucent `@task` labels.
- Six visible task rows, smooth wheel scrolling, and a scrollbar that can be held and dragged.
- A small bounce at the top and bottom, triggered once per edge arrival.
- A movable card with an invisible outer margin, using Rainmeter's screen constraint.
- Blue date labels for regular tasks. Overdue tasks have uniformly pale-pink task text and softer rose-pink date labels.
- An iceberg-blue importance star, white calendar icon, and translucent task input.
- A custom right-click Unload action with two confirmations, both defaulting to No.

The customization checks for Microsoft To Do changes every 15 seconds. Unchanged task data does not reload the skin; overlapping sync polls are skipped.

Task sign-in, fetching, adding, completion, and calendar support build on the upstream project credited below.

## Requirements

- Windows 10 or 11 and Windows PowerShell 5.1 (`powershell.exe`).
- [Rainmeter](https://www.rainmeter.net/), installed separately. Setup does not download installers or request administrator privileges.
- A Microsoft account using Microsoft To Do.
- A local copy of `soft-rainbow-leaves.png`; see [the artwork notes](assets/README.md). The exact theme requires this separate image.
- A permanent, writable project folder. Keep it in place after setup because the skin refers to the scripts in that folder.

## Setup

1. Download this repository with **Code → Download ZIP**, then extract it to a permanent folder. An existing working installation should be kept separately until the new copy is verified.
2. Supply the leaf image as described in [assets/README.md](assets/README.md).
3. Start Rainmeter. The scripts detect the running installation or standard install locations. For a custom installation, copy `widget.config.example.json` to `widget.config.json` and edit its paths. `rainmeterIni` and `skinsDirectory` can be left `null` for automatic detection.
4. Review the scripts, then open a regular Windows PowerShell window in the project folder and run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\setup.ps1
   ```

   If Windows blocks a downloaded unsigned script, review it before unblocking that specific file with `Unblock-File -LiteralPath .\filename.ps1`. Review and unblock any required helper scripts individually as well. Do not change the machine-wide policy or use an administrator window.

5. Setup builds the scrollbar helper from `src/ScrollbarDrag.cs`, signs in if needed, generates the skin, activates it, and enables current-user startup.

For a portable Rainmeter installation, the configuration can point to its executable and adjacent `Rainmeter.ini`. Existing skin folders and Rainmeter's configured `SkinPath` are respected.

## Using the widget

| Action | How |
| --- | --- |
| Add a task | Type in the input field and press Enter. |
| Set importance or a due date | Use the star or calendar before adding the task. Right-click the calendar to clear the pending date. |
| Complete a task | Click its circle; it disappears locally while completion is sent to Microsoft To Do. |
| Scroll | Use the wheel over the task area, or hold and drag the right scrollbar. |
| Move the card | Drag a blank area of the card. |
| Switch accounts | Double-click the `𝕋𝕠 𝔻𝕠` heading. |
| Hide the widget | Right-click a blank area → **Unload (confirm twice)** → confirm twice. Either No cancels. |
| Reopen it | Use the desktop shortcut or `open-widget.vbs`. |

## Source layout

| File | Purpose |
| --- | --- |
| `todo-render.ps1` | Generates the current themed Rainmeter skin from local task data. |
| `todo-export.ps1` | Fetches Microsoft To Do tasks, skips overlapping polls, and renders changed data. |
| `todo-action.ps1` | Task creation, completion, and pending task options. |
| `todo-auth.ps1`, `switch-account.ps1` | Device-code sign-in and account switching. |
| `todo-cal.ps1` | Clickable due-date calendar. |
| `widget-scroll.lua` | Smooth scrolling, single edge bounce, and scrollbar dragging. |
| `src/ScrollbarDrag.cs`, `build-helper.ps1` | Source and local build step for mouse tracking while the scrollbar is held. |
| `widget-paths.ps1` | Resolves standard or portable Rainmeter paths. |
| `confirm-unload.ps1` | Two-step confirmation for the custom Unload action. |
| `setup.ps1`, `open-widget.ps1`, `*.vbs` | Current-user setup and launchers. |

See [the source-import notes](docs/SOURCE_IMPORT.md) for the limited portability changes made during publication.

## Scope and limitations

- `Today` means a task's due date is today. It does not mean membership in Microsoft To Do's **My Day** list.
- The unload confirmation protects the widget's custom right-click action. Unloading through Rainmeter's own manager bypasses it.
- The current upstream-derived fetcher reads up to the first 100 tasks per list; pagination is not implemented.
- The interactive customization was tested by Iris on Windows. Publication checks use mocked Windows APIs and synthetic tasks; a fresh Windows installation of this portable-path package has not been tested here.
- A current screenshot has not been published because it contains personal tasks and a third-party wallpaper.

## Credits and references

The code base comes from **[Suga-Rin's Microsoft To Do Rainmeter widget](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do)**, licensed under MIT. Iris's work customizes its appearance and interaction.

See **[CREDITS.md](CREDITS.md)** for the upstream revision, implementation references, visual-source notes, and development acknowledgements.

| Reference | Used for |
| --- | --- |
| [Suga-Rin's Rainmeter widget](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do) | Original task integration and widget foundation; MIT license preserved. |
| [Alice Oseman — Heartstopper](https://aliceoseman.com/heartstopper/) | Original comic leaf artwork, subsequently recolored for the local theme. Artwork is separate from the code license and is not bundled. |
| [Discord](https://discord.com/) | Visual reference for `@task` mention-style labels. |
| [ℝℙ² programme status page](https://rp2.rossprogram.org/status) | Visual reference for the mathematical double-struck (`mathbb`-like) heading. |

## License

Original code and documentation added here are provided under the [MIT License](LICENSE). The upstream license text is preserved verbatim in [LICENSES/Suga-Rin-MIT.txt](LICENSES/Suga-Rin-MIT.txt).

Third-party photos, television stills, and reference illustrations are not covered by this project's MIT license. Artwork with unverified source or redistribution permission is not bundled in the published repository.

