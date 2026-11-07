# Replay

Replay user actions in a Pharo image.  
Build scenarios involving UI that can serve as tutorials or tests, and bind them to keyboard shortcuts as macros.

## Installing

```st
Metacello new
  githubUser: 'Gabriel-Darbord' project: 'Replay' commitish: 'main' path: 'src';
  baseline: 'Replay';
  load
```

This loads the core. Add the guided tours with `load: #( 'core' 'demo' )`, or everything including tests with `load: #( 'core' 'demo' 'tests' )`.

Replay runs on Pharo 13, 14 and 15, each covered by CI. Pharo 14 is the development version.

## Scenarios

A scenario is a list of steps, and each step is a list of actions: open or attach to some UI, click, drag and drop, scroll, type, press keys, select list and tree items by label, choose menu items, check conditions, annotate widgets, wait, run scripts.
A step ends with an optional navigation dialog that lets the viewer continue or stop, which turns a scenario into a tutorial.

Open the editor to create one:
```st
ReplayEditor open
```

- Add actions with the chooser and the **+** button, then edit them on the right. UI actions have a second view, **Edit UI interaction**, that previews the UI and lets you pick a target by clicking it.
- Record instead of writing actions by hand: press **Cmd + R** (Ctrl + R outside macOS) in the window you want to record, do what the scenario should do, and press it again to stop. The **Record** button records the window you used last.
- **Run** plays the scenario, **Run step** plays the selected step.

Actions find the widgets of Spec presenters by name: by default, the name of the instance variable holding the subpresenter, such as `runButton`, or a dotted path such as `toolbar.runButton` when the name alone is ambiguous. Recording and picking a target use these names when they can, so scenarios survive layout changes; other widgets are found by their position in the window. A presenter can expose other names by overriding `replayPresenterAt:ifAbsent:`.

**Check** turns a scenario into a test: its condition is evaluated with the target as `self`, and the run waits for it to hold, then fails if it does not. **Select item** and **Choose menu item** also wait for what they look for, such as a menu opened by a right click.

Scenarios are plain objects serialized with STON. **Copy** puts the scenario on the clipboard and **Import** reads one back. To run a scenario from code:
```st
(STON fromString: '<your scenario STON string>') run
```

> [!TIP]
> `ReplayScenario example` builds a small scenario, and the `Replay-Demo` package holds guided tours of Replay itself:
> `ReplayEditorDemo run`, `ReplayMacroEditorDemo run` and `ReplayMacroExistingWindowDemo run` (or `editScenario` to look at how they are made).

## Macros

A macro binds a scenario to a keyboard shortcut. Macros live in the macro library:
```st
ReplayMacroLibraryEditor open
```

- The library window lists the macros and edits the scenario of the selected one in place. **Edit shortcut** sets its key binding (one or more chords, each with its own modifiers) and the contexts it is installed in, such as text editors or every window, and shows conflicts with existing shortcuts.
- A scenario edited in a standalone editor can be moved there with **Add to library**.
- **Install all** activates every macro's shortcut, and each macro can also be installed on its own.
- **Import** and **Export** exchange single macros or whole libraries as STON.

The library is saved automatically to `replay-macros.ston` in Pharo's shared preferences folder (`FileLocator preferences`), so every image sees the same macros. Check **Install on startup** to have them installed whenever an image with Replay starts.
