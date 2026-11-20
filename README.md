# Heartstopper Todo List

A personal, Heartstopper-inspired Windows desktop customization for Microsoft To Do, built on Rainmeter and PowerShell.

一个给高中生活用的桌面待办组件：蓝黄叶子、半透明卡片，以及刚刚好的粉色逾期提醒。💙💛

## Current version

This repository documents the latest working customization. The complete current Windows source snapshot has not been imported yet; a ready-to-install package is not available here.

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

## Scope and limitations

- `Today` means a task's due date is today. It does not mean membership in Microsoft To Do's **My Day** list.
- The unload confirmation protects the widget's custom right-click action. Unloading through Rainmeter's own manager bypasses it.
- Source packaging and portable installation instructions will follow a review of the latest working Windows files.
- A current screenshot has not been published because it contains personal tasks and a third-party wallpaper.

## Credits and references

The code base comes from **[Suga-Rin's Microsoft To Do Rainmeter widget](https://github.com/Suga-Rin/what-I-wanna-To-Do---A-desktop-widget-based-on-Microsoft-To-Do)**, licensed under MIT. Iris's work customizes its appearance and interaction.

See **[CREDITS.md](CREDITS.md)** for the upstream revision, implementation references, visual-source notes, and development acknowledgements.

## License

Original code and documentation added here are provided under the [MIT License](LICENSE). The upstream license text is preserved verbatim in [LICENSES/Suga-Rin-MIT.txt](LICENSES/Suga-Rin-MIT.txt).

Third-party photos, television stills, and reference illustrations are not covered by this project's MIT license. Artwork with unverified source or redistribution permission is not bundled in the published repository.
