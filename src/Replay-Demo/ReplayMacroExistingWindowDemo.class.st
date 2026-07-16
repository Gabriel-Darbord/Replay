"
I demonstrate using a Replay macro against an already-open Replay editor window.
"
Class {
	#name : 'ReplayMacroExistingWindowDemo',
	#superclass : 'Object',
	#category : 'Replay-Demo',
	#package : 'Replay-Demo'
}

{ #category : 'opening' }
ReplayMacroExistingWindowDemo class >> editScenario [

	<script>
	^ self scenario edit
]

{ #category : 'running' }
ReplayMacroExistingWindowDemo class >> run [

	<script>
	^ self scenario run
]

{ #category : 'instance creation' }
ReplayMacroExistingWindowDemo class >> scenario [

	^ self new scenario
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> addMacroAction [

	^ self script: 'self focus macroList addButton click'
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> annotate: targetName text: aString [

	^ ReplayAnnotate new
		targetNamed: targetName;
		text: aString;
		yourself
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> attachMacroEditorAction [

	^ ReplayAttachUI new
		script: 'self focus';
		yourself
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> cleanupStep [

	^ self stepNamed: 'Finish cleanly' with: {
		self clearAnnotationsAction.
		self closeReplayUIAction.
		self closeMacroEditorAction.
		self closeTargetEditorAction }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> clearAnnotationsAction [

	^ ReplayClearAnnotations new
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> closeMacroEditorAction [

	^ self script: 'self focus ifNotNil: [ :editor | editor window ifNotNil: [ :window | window close ] ]'
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> closeReplayUIAction [

	^ ReplayCloseUI new
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> closeTargetEditorAction [

	^ self script: '(Smalltalk globals at: ', self targetEditorKey storeString, ' ifAbsent: [ nil ]) ifNotNil: [ :editor |
	editor window ifNotNil: [ :window | window close ] ].
Smalltalk globals removeKey: ', self targetEditorKey storeString, ' ifAbsent: [ ]'
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> configureMacroAction [

	^ self script: '| editor context macro payload step |
editor := self focus macroEditorPresenter.
editor namePresenter text: ''Insert script helper''.
editor shortcutTextPresenter text: ''m''.
editor controlCheckBox state ifFalse: [ editor controlCheckBox toggleState ].
context := editor contextDropList items detect: [ :each | each identifier = #textEditors ].
editor contextDropList selectItem: context.
editor addSelectedContext.
macro := editor macro.
payload := ReplayScenario new title: ''Existing window macro payload''; yourself.
step := ReplayStep new.
step navigation skip: true.
step addAction: (ReplayAttachUI new script: ''Smalltalk globals at: #ReplayMacroExistingWindowDemoTarget'').
step addAction: (ReplayScript new script: ' , self targetPayloadScript storeString , ').
payload addStep: step.
macro scenario: payload'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> configureStep [

	^ self stepNamed: 'Define macro for the existing window' with: {
		self clearAnnotationsAction.
		self addMacroAction.
		self configureMacroAction.
		self annotate: 'Shortcut keys' text: 'The macro uses Control+M in text editor contexts.'.
		self annotate: 'Macro context' text: 'Text editors means the shortcut is active in Rubric text editing widgets.' }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> installMacroAction [

	^ self script: 'self focus macroEditorPresenter installMacro'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> installStep [

	^ self stepNamed: 'Install the macro' with: {
		self clearAnnotationsAction.
		self installMacroAction.
		self annotate: 'Installation status' text: 'The macro is installed into the selected context.'.
		self annotate: 'Active UI context status' text: 'Refresh active UI checks the current keyboard focus categories.' }
]

{ #category : 'constants' }
ReplayMacroExistingWindowDemo >> macroEditorPosition [

	^ 520 @ 40
]

{ #category : 'constants' }
ReplayMacroExistingWindowDemo >> navigationPosition [

	^ 520 @ 520
]

{ #category : 'building' }
ReplayMacroExistingWindowDemo >> scenario [

	| scenario |
	scenario := ReplayScenario new
		title: 'Replay Macro Existing Window Tour';
		description: 'Define and run a macro against an already-open Replay editor.';
		yourself.
	scenario
		addStep: self setupStep;
		addStep: self configureStep;
		addStep: self installStep;
		addStep: self triggerStep;
		addStep: self updateStep;
		addStep: self triggerUpdatedStep;
		addStep: self uninstallStep;
		addStep: self cleanupStep.
	^ scenario
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> script: aString [

	^ ReplayScript new
		script: aString;
		yourself
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> setupMacroEditorAction [

	^ self script: '| registry editor window |
registry := ReplayMacroRegistry new.
editor := ReplayMacroLibraryEditor onRegistry: registry.
self focus: editor.
window := editor asWindow.
window initialPosition: ', self macroEditorPosition storeString, '.
window open'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> setupStep [

	^ self stepNamed: 'Open existing target and macro editor' with: {
		self setupTargetEditorAction.
		self setupMacroEditorAction.
		self attachMacroEditorAction.
		self annotate: 'Macro list' text: 'Macros are edited in this window while the target Replay editor is already open.' }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> setupTargetEditorAction [

	^ self script: '| scenario editor window |
scenario := ReplayScenario new title: ''Existing window macro target''; yourself.
scenario addStep: ReplayStep new.
editor := ReplayEditor on: scenario.
Smalltalk globals at: ', self targetEditorKey storeString, ' put: editor.
window := editor asWindow.
window initialPosition: ', self targetEditorPosition storeString, '.
window open'
]

{ #category : 'building' }
ReplayMacroExistingWindowDemo >> stepNamed: aString with: actions [

	| step |
	step := ReplayStep new.
	actions do: [ :action | step addAction: action ].
	step navigation
		text: aString;
		position: self navigationPosition;
		skip: false.
	^ step
]

{ #category : 'constants' }
ReplayMacroExistingWindowDemo >> targetEditorKey [

	^ #ReplayMacroExistingWindowDemoTarget
]

{ #category : 'constants' }
ReplayMacroExistingWindowDemo >> targetEditorPosition [

	^ 20 @ 40
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> targetPayloadScript [

	^ '| target |
target := Smalltalk globals at: #ReplayMacroExistingWindowDemoTarget.
target addActionLast: (ReplayScript new script: ''self inform: ''''macro ran'''' '').
target actions selectIndex: target actions items size'
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> triggerInstalledShortcutAction [

	^ self script: '| editor macro keymaps target |
target := Smalltalk globals at: ' , self targetEditorKey storeString , '.
editor := self focus macroEditorPresenter.
macro := editor macro.
keymaps := macro installedKeymaps.
keymaps isEmpty ifTrue: [ self error: ''Macro keymap was not installed'' ].
keymaps first action value.
target actions items isEmpty ifTrue: [ self error: ''Macro did not update existing editor'' ]'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> triggerStep [

	^ self stepNamed: 'Trigger the macro' with: {
		self clearAnnotationsAction.
		self triggerInstalledShortcutAction.
		self annotate: 'Run macro button' text: 'The shortcut fired the same macro payload that Run macro would execute directly.'.
		self annotate: 'Installation status' text: 'The existing target editor now has a Script action inserted by the macro.' }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> triggerUpdatedShortcutAction [

	^ self script: '| editor macro keymaps target originalSize |
target := Smalltalk globals at: ' , self targetEditorKey storeString , '.
originalSize := target actions items size.
editor := self focus macroEditorPresenter.
macro := editor macro.
keymaps := macro installedKeymaps.
keymaps isEmpty ifTrue: [ self error: ''Macro keymap was not installed'' ].
keymaps first action value.
(target actions items size > originalSize) ifFalse: [ self error: ''Updated shortcut did not run macro'' ]'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> triggerUpdatedStep [

	^ self stepNamed: 'Trigger the updated shortcut' with: {
		self clearAnnotationsAction.
		self triggerUpdatedShortcutAction.
		self annotate: 'Shortcut keys' text: 'Control+N now triggers the installed macro.'.
		self annotate: 'Installation status' text: 'The old shortcut was replaced by the new installed keymap.' }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> uninstallMacroAction [

	^ self script: 'self focus macroEditorPresenter uninstallMacro'
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> uninstallStep [

	^ self stepNamed: 'Uninstall and clean up' with: {
		self clearAnnotationsAction.
		self uninstallMacroAction.
		self annotate: 'Uninstall macro button' text: 'Uninstall removes the macro keymap from its installed context.'.
		self annotate: 'Installation status' text: 'After uninstalling, status returns to Not installed.' }
]

{ #category : 'actions' }
ReplayMacroExistingWindowDemo >> updateInstalledShortcutAction [

	^ self script: 'self focus macroEditorPresenter shortcutTextPresenter text: ''n'''
]

{ #category : 'steps' }
ReplayMacroExistingWindowDemo >> updateStep [

	^ self stepNamed: 'Update the installed shortcut' with: {
		self clearAnnotationsAction.
		self updateInstalledShortcutAction.
		self annotate: 'Shortcut keys' text: 'Editing the shortcut updates the installed keymap immediately.'.
		self annotate: 'Installation status' text: 'The macro remains installed after the shortcut changes.' }
]
