Class {
	#name : 'ReplayMacroEditorDemo',
	#superclass : 'Object',
	#category : 'Replay-Demo',
	#package : 'Replay-Demo'
}

{ #category : 'opening' }
ReplayMacroEditorDemo class >> editScenario [

	<script>
	^ self scenario edit
]

{ #category : 'running' }
ReplayMacroEditorDemo class >> run [
	<script>

	^ self scenario run
]

{ #category : 'instance creation' }
ReplayMacroEditorDemo class >> scenario [

	^ self new scenario
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> addMacroAction [

	^ self script: 'self focus macroList addButton click.
self focus scenarioEditor editShortcut'
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> annotate: targetName text: aString [

	^ ReplayAnnotate new
		targetNamed: targetName;
		text: aString;
		yourself
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> attachMacroEditorAction [

	^ ReplayAttachUI new
		script: 'self focus';
		yourself
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> clearAnnotationsAction [

	^ ReplayClearAnnotations new
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> clearTriggeredFlagAction [

	^ self script: 'Smalltalk globals removeKey: #ReplayMacroEditorDemoTriggered ifAbsent: [ ]'
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> configureFindMacroAction [

	^ self script: '| editor context payload step |
editor := self focus macroEditor.
editor keyBindingPresenter keyBinding: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers control).
context := editor contextDropList items detect: [ :each | each identifier = #textEditors ].
editor contextDropList selectItem: context.
editor addSelectedContext.
payload := ReplayScenario new title: ''Find helper''; yourself.
step := ReplayStep new.
step navigation skip: true.
step addAction: (ReplayScript new script: ''Smalltalk globals at: #ReplayMacroEditorDemoTriggered put: true'').
payload addStep: step.
self focus scenarioEditor scenario: payload; editShortcut'
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> configureShortcutStep [

	^ self stepNamed: 'Choose shortcut and context' with: {
		self clearAnnotationsAction.
		self configureFindMacroAction.
		self annotate: 'Key binding' text: 'Shortcut keys are ordinary characters such as f or g.'.
		self annotate: 'Control modifier' text: 'Modifiers compose with keys to form shortcuts such as Control+F.'.
		self annotate: 'Install context picker' text: 'The context is user-facing. Text editors maps to the keymap category used by Rubric text editors.'.
		self annotate: 'Install context list' text: 'The macro is installed in every context of this list.' }
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> conflictsStep [

	^ self stepNamed: 'Review conflicts' with: {
		self clearAnnotationsAction.
		self annotate: 'Conflict warning icon' text: 'Replay checks the install contexts and summarizes the conflicts in the help of this icon.'.
		self annotate: 'Conflict list' text: 'Conflicts show readable contexts, shortcuts, action names, and descriptions.' }
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> createMacroStep [

	^ self stepNamed: 'Create a macro' with: {
		self clearAnnotationsAction.
		self addMacroAction.
		self annotate: 'Macro list' text: 'A new macro appears in the library and is selected for editing. Its name is the title of its scenario.'.
		self annotate: 'Edit shortcut button' text: 'Edit shortcut shows the key binding and the contexts of the macro.' }
]

{ #category : 'constants' }
ReplayMacroEditorDemo >> editorPosition [

	^ 20 @ 20
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> installMacroAction [

	^ self script: 'self focus macroEditor installMacro'
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> installStep [

	^ self stepNamed: 'Install the macro' with: {
		self clearAnnotationsAction.
		self installMacroAction.
		self annotate: 'Install button' text: 'Install/update writes the macro keymap into its selected context.'.
		self annotate: 'Installation status' text: 'The status line shows where this macro is currently installed.' }
]

{ #category : 'constants' }
ReplayMacroEditorDemo >> navigationPosition [

	^ 520 @ 420
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> openEditorStep [

	^ self stepNamed: 'Open macro library editor' with: {
		self setupMacroEditorAction.
		self attachMacroEditorAction.
		self clearAnnotationsAction.
		self annotate: 'Macro list' text: 'The library holds user macros. Use built-in plus and trash buttons to add or remove macros.'.
		self annotate: 'Scenario editor' text: 'Selecting a macro opens its scenario here. Edit shortcut shows its key binding and contexts.' }
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> runtimePolicyStep [

	^ self stepNamed: 'Review runtime policy' with: {
		self clearAnnotationsAction.
		self annotate: 'Installation summary' text: 'The summary counts the macros of this library that are installed.'.
		self annotate: 'Install on startup' text: 'When checked, the image installs these macros when it starts. The library is saved after each change.' }
]

{ #category : 'instance creation' }
ReplayMacroEditorDemo >> scenario [

	| scenario |
	scenario := ReplayScenario new
		title: 'Replay Macro Editor Feature Tour';
		description: 'Create, check, install, trigger, update, and uninstall Replay macros.';
		yourself.
	scenario
		addStep: self openEditorStep;
		addStep: self runtimePolicyStep;
		addStep: self createMacroStep;
		addStep: self configureShortcutStep;
		addStep: self conflictsStep;
		addStep: self installStep;
		addStep: self triggerShortcutStep;
		addStep: self updateInstalledStep;
		addStep: self uninstallStep.
	^ scenario
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> script: aString [

	^ ReplayScript new
		script: aString;
		yourself
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> setupMacroEditorAction [

	^ self script: '| registry editor window |
registry := ReplayMacroRegistry new.
editor := ReplayMacroLibraryEditor onRegistry: registry.
self focus: editor.
window := editor asWindow.
window initialPosition: ', self editorPosition storeString, '.
window open'
]

{ #category : 'building' }
ReplayMacroEditorDemo >> stepNamed: aString with: actions [

	| step |
	step := ReplayStep new.
	actions do: [ :action | step addAction: action ].
	step navigation
		text: aString;
		placement: (ReplayPlacement position: self navigationPosition);
		skip: false.
	^ step
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> triggerInstalledShortcutAction [

	^ self script: '| editor macro keymaps |
Smalltalk globals removeKey: #ReplayMacroEditorDemoTriggered ifAbsent: [ ].
editor := self focus macroEditor.
macro := editor macro.
keymaps := macro installedKeymaps.
keymaps isEmpty ifTrue: [ self error: ''Macro keymap was not installed'' ].
keymaps first action value.
(Smalltalk globals at: #ReplayMacroEditorDemoTriggered ifAbsent: [ false ]) ifFalse: [
	self error: ''Macro shortcut did not run'' ]'
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> triggerShortcutStep [

	^ self stepNamed: 'Trigger installed shortcut' with: {
		self clearAnnotationsAction.
		self triggerInstalledShortcutAction.
		self annotate: 'Installation status' text: 'A Control+F event was dispatched through the text editor context, and the macro payload ran.'.
		self annotate: 'Edit shortcut button' text: 'The shortcut runs the scenario of this macro, as Run in the toolbar does.' }
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> uninstallMacroAction [

	^ self script: 'self focus macroEditor uninstallMacro'
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> uninstallStep [

	^ self stepNamed: 'Uninstall the macro' with: {
		self clearAnnotationsAction.
		self uninstallMacroAction.
		self clearTriggeredFlagAction.
		self annotate: 'Install button' text: 'Uninstall removes this macro from every context where it is installed.'.
		self annotate: 'Installation status' text: 'After uninstalling, the status returns to Not installed.' }
]

{ #category : 'actions' }
ReplayMacroEditorDemo >> updateInstalledShortcutAction [

	^ self script: 'self focus macroEditor keyBindingPresenter keyBinding: (ReplayKeyBinding character: $g modifiers: ReplayKeyModifiers control)'
]

{ #category : 'steps' }
ReplayMacroEditorDemo >> updateInstalledStep [

	^ self stepNamed: 'Update an installed macro' with: {
		self clearAnnotationsAction.
		self updateInstalledShortcutAction.
		self annotate: 'Key binding' text: 'Editing an installed macro refreshes its installed keymap immediately.'.
		self annotate: 'Installation status' text: 'The macro remains installed while its shortcut changes.' }
]
