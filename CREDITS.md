# Credits and references

## Upstream code

**Project:** [Microsoft To Do desktop widget (Rainmeter)](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do)  
**Maintainer:** [Suga-Rin](https://github.com/Suga-Rin)  
**Reviewed revision:** [`d3f88e8e0451fe2ea2d017ce6e1a2bae8a28e02d`](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do/tree/d3f88e8e0451fe2ea2d017ce6e1a2bae8a28e02d)  
**License:** MIT; [original LICENSE](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do/blob/d3f88e8e0451fe2ea2d017ce6e1a2bae8a28e02d/LICENSE), with a verbatim copy in [LICENSES/Suga-Rin-MIT.txt](LICENSES/Suga-Rin-MIT.txt).

The working Windows customization was developed from this Rainmeter + PowerShell project. The upstream provides the Microsoft Graph integration, device-code sign-in, task fetching and caching, task actions, calendar generation, skin generation, and launcher/setup scripts.

The upstream LICENSE at the reviewed revision literally contains `Copyright (c) 2026 <Your Name>`. Its wording is preserved as received; the actual project maintainer is credited using the verified repository and profile above.

## Customization developed with Iris

The retained changes cover the current blue/yellow leaf layout, transparent card and dashed border, mention-style task labels, date and overdue colors, six-row viewport, smooth scrolling, single edge bounce, draggable scrollbar, invisible desktop margin, 15-second polling behavior, and the twice-confirmed custom Unload action.

Iris directed the visual design, chose and refined the interactions, and tested the working behavior on Windows. ChatGPT/Codex assisted with code drafting, debugging, and documentation.

The latest working source was imported from the snapshot supplied by Iris. [SOURCE_IMPORT.md](docs/SOURCE_IMPORT.md) records the source preservation and the limited portability changes. The original artwork and compiled drag-helper binary are not part of the public import.

## Implementation references

| Source | Relevance |
| --- | --- |
| [Rainmeter manual](https://docs.rainmeter.net/manual/) | Skin, measure, and meter configuration. |
| [Rainmeter Lua scripting](https://docs.rainmeter.net/manual/lua-scripting/) | In-process scrolling, animation state, and meter updates. |
| [Rainmeter image options](https://docs.rainmeter.net/manual/meters/general-options/image-options/) | `Greyscale` plus `ImageTint` for recoloring the leaf reference. |
| [Rainmeter mouse variables](https://docs.rainmeter.net/manual/variables/mouse-variables/) | Mouse coordinates used in interaction development. |
| [Rainmeter section variables](https://docs.rainmeter.net/manual/variables/section-variables/) | Reading actual meter positions and dimensions. |
| [Rainmeter built-in variables](https://docs.rainmeter.net/manual/variables/built-in-variables/) | Window position, size, and screen/work-area information. |
| [Rainmeter skin section](https://docs.rainmeter.net/manual/skins/rainmeter-section/) | Custom context-menu entries and close-action limitations. |
| [Rainmeter bangs](https://docs.rainmeter.net/manual/bangs/) | Meter updates, script calls, custom menus, and config activation/deactivation. |
| [Rainmeter source: Rainmeter.cpp](https://github.com/rainmeter/rainmeter/blob/master/Library/Rainmeter.cpp) | Reference for the control-window `WM_COPYDATA` command interface used by the drag helper. |
| [Rainmeter source: Rainmeter.h](https://github.com/rainmeter/rainmeter/blob/master/Library/Rainmeter.h) | Control-window class and title used by the drag helper. |
| [Rainmeter source: Skin.cpp](https://github.com/rainmeter/rainmeter/blob/master/Library/Skin.cpp) | Reference for native KeepOnScreen movement constraints. |
| [Microsoft Graph To Do API overview](https://learn.microsoft.com/en-us/graph/api/resources/todo-overview?view=graph-rest-1.0) | To Do lists and task operations used by the upstream. |
| [Microsoft identity platform device-code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code) | Authentication flow used by the upstream. |
| [Microsoft Win32 WM_COPYDATA](https://learn.microsoft.com/en-us/windows/win32/dataxchg/wm-copydata) | Local commands from the scrollbar helper to Rainmeter. |
| [Microsoft Win32 GetCursorPos](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos) | Mouse tracking while dragging the scrollbar. |
| [Microsoft Win32 GetAsyncKeyState](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate) | Detecting mouse-button release. |

Rainmeter is a separate dependency. This repository does not relicense Rainmeter or Microsoft products.

## Visual references and artwork

| Reference | Attribution and current status |
| --- | --- |
| Heartstopper | The visual theme was inspired by **Alice Oseman's Heartstopper** and the television adaptation. See [Alice Oseman's official Heartstopper page](https://aliceoseman.com/heartstopper/). |
| Four-leaf image reference | Adapted from **Alice Oseman's original Heartstopper comics**, with colors changed for this widget, as identified by Iris. The exact panel/page and original image URL have not been provided. Original illustration credit remains with Alice Oseman; the image is not bundled or covered by the code's MIT license. |
| Television still used as desktop wallpaper | Supplied by Iris as a personal visual reference. The exact still's publication source/photographer has not been verified. It is not bundled or licensed by this repository. |
| Mention-label appearance | Inspired by **[Discord](https://discord.com/)** `@mention` labels, using a screenshot supplied by Iris as the visual reference. The screenshot itself is not bundled. |
| Mathematical heading | Inspired by the double-struck **ℝℙ²** heading on the **[RP2 programme status page](https://rp2.rossprogram.org/status)** supplied by Iris. The widget uses the text `𝕋𝕠 𝔻𝕠` with Windows' Cambria Math font; no font file or programme code is redistributed. |

Only references relevant to the retained design and working implementation are listed here. The current public repository does not include these reference images or a screenshot of private tasks.

## Source snapshot and privacy

The import preserves the latest active scripts and includes the C# source corresponding to the working scrollbar helper. Local login files, cached task data, pending task input, machine-specific generated skins, personal settings, logs, binaries, and historical backup copies are excluded from version control.

