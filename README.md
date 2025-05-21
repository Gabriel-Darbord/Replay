# Replay

Replay user actions in a Pharo image.  
Build scenarios involving UI that can serve as tutorials or tests.

## Installing

```st
Metacello new
  githubUser: 'Gabriel-Darbord' project: 'Replay' commitish: 'main' path: 'src';
  baseline: 'Replay';
  load
```

## Usage

Open the editor and create your scenario using the GUI.
```st
ReplayEditor new
```

Saving your scenario gives you a STON string.
To run it:
```st
(STON fromString: '<your scenario STON string>') run
```

> [!TIP]
> Take a look at the examples on the class-side of `ReplayScenario`.
