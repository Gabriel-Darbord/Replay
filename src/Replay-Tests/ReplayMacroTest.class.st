"
I test ReplayMacro: identity, naming, STON, keymap installation and dispatch, and conflicts with existing keymaps.
"
Class {
	#name : 'ReplayMacroTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayMacroTest >> testCapturedShortcutInstallsAndRunsThroughMorphDispatcher [

	| catcher capturedShortcut macro spy |
	catcher := KMCatcherMorph new.
	[
		catcher keyStroke: (self keyboardEventForCharacter: $f buttons: 16).
		capturedShortcut := ReplayKeyBinding fromKMCombination: catcher shortcut ] ensure: [ catcher delete ].
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro scenario: spy keyBinding: capturedShortcut.
	macro contextNames: { #ReplayMacroCapturedShortcutDispatcherTest }.

	self assert: capturedShortcut equals: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers control).
	macro install.
	self dispatch: $f buttons: 16 inCategoryNamed: #ReplayMacroCapturedShortcutDispatcherTest.
	self assert: spy hasRun
]

{ #category : 'tests' }
ReplayMacroTest >> testIdentifierIsAssignedAtCreation [

	| macro copy |
	macro := self macroNamed: 'Never installed'.
	self assert: macro identifier notNil.
	copy := STON fromString: (STON toString: macro).
	self assert: copy identifier equals: macro identifier.
	self deny: (self macroNamed: 'Other') identifier equals: macro identifier
]

{ #category : 'tests' }
ReplayMacroTest >> testInstallRequiresKeyBindingAndContexts [

	| macro |
	macro := self macroNamed: 'Install requirements macro'.
	macro contextNames: { #RubTextEditor }.
	self deny: macro canInstall.
	self assert: macro install isEmpty.
	self deny: (macro installedInContextNamed: #RubTextEditor).

	macro keyBinding: (ReplayKeyBinding character: $r modifiers: 0).
	macro contextNames: #(  ).
	self deny: macro canInstall.
	self assert: macro install isEmpty.
	self deny: (macro installedInContextNamed: #RubTextEditor).

	macro contextNames: { #RubTextEditor }.
	self assert: macro canInstall.
	self deny: macro install isEmpty.
	self assert: (macro installedInContextNamed: #RubTextEditor).
	self assert: macro isInstalled
]

{ #category : 'tests' }
ReplayMacroTest >> testInstallReplacesOwnKeymapInCategory [

	| category macro firstKeymap secondKeymap ownKeymaps |
	category := KMCategory named: #ReplayMacroReplaceInstallTest.
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).

	firstKeymap := macro installInCategory: category.
	macro keyBinding: (ReplayKeyBinding fromKMCombination: $d command).
	secondKeymap := macro installInCategory: category.
	ownKeymaps := category allEntries keymaps select: [ :keymap | macro isOwnKeymap: keymap ].

	self deny: firstKeymap identicalTo: secondKeymap.
	self assert: ownKeymaps size equals: 1.
	self assert: ownKeymaps anyOne identicalTo: secondKeymap.
	self assert: secondKeymap shortcut asString equals: 'Cmd + D'
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledKeymapEntriesListMacroKeymaps [

	| macro |
	macro := self macroNamed: 'Installed entry macro' keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #RubTextEditor }.
	macro install.

	self assert: (ReplayMacro installedKeymapEntries anySatisfy: [ :association |
			 association key name = #RubTextEditor and: [ macro isOwnKeymap: association value ] ]).
	self assert: (ReplayMacro installedKeymaps anySatisfy: [ :keymap | macro isOwnKeymap: keymap ]).
	self assert: (macro installedKeymaps collect: [ :keymap | keymap name ]) asArray equals: { macro keymapName }
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledMacroRunsThroughMorphDispatcher [

	| macro spy |
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro scenario: spy keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #ReplayMacroDispatcherTest }.
	macro install.

	self dispatch: $f buttons: 16 inCategoryNamed: #ReplayMacroDispatcherTest.
	self assert: spy hasRun
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledMacroUsesReplacedScenarioWhenShortcutRuns [

	| macro spy |
	spy := ReplayMacroRunSpy new.
	macro := self macroNamed: 'Scenario macro' keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #ReplayMacroScenarioReplacementTest }.
	macro install.
	macro scenario: spy.

	self dispatch: $f buttons: 16 inCategoryNamed: #ReplayMacroScenarioReplacementTest.
	self assert: spy hasRun
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledTextEditorMacroIsVisibleToCategoryBinding [

	| macro binding keymap |
	macro := self macroNamed: 'Find macro' keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #RubTextEditor }.
	macro install.
	binding := (KMRepository default categoryForName: #RubTextEditor) bindToObject: nil andMorph: nil.
	keymap := binding keymapForShortcut: macro keyBinding asKMShortcut.

	self assert: (macro isOwnKeymap: keymap)
]

{ #category : 'tests' }
ReplayMacroTest >> testInstallsKeymapInCategory [

	| category macro keymap |
	category := KMCategory named: #ReplayMacroInstallTest.
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).

	keymap := macro installInCategory: category.

	self assert: keymap name equals: macro keymapName.
	self assert: keymap description equals: 'Replay macro: Save macro'.
	self assert: keymap shortcut asString equals: 'Cmd + S'.
	self assert: (category allEntries keymaps includes: keymap)
]

{ #category : 'tests' }
ReplayMacroTest >> testInstallDoesNotReportOwnKeymapAsConflict [

	| category macro keymap |
	category := KMCategory named: #ReplayMacroInstallTest.
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).

	keymap := macro installInCategory: category.

	self assert: keymap name equals: macro keymapName.
	self assert: (macro conflictsInCategory: category) isEmpty
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroDetectsBaseTextFindConflictInSmalltalkEditorContext [

	| macro |
	macro := self macroNamed: 'Smalltalk find replacement' keyBinding: self defaultFindShortcut.
	macro contextNames: { #RubSmalltalkEditor }.

	self assert: (macro conflicts anySatisfy: [ :conflict |
			 conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ])
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroDetectsConflictingKeymapInCategory [

	| category conflictingKeymap macro conflicts conflict |
	category := KMCategory named: #ReplayMacroTest.
	conflictingKeymap := KMKeymap named: #save shortcut: $s command action: [ ].
	category addKeymapEntry: conflictingKeymap.
	category addKeymapEntry: (KMKeymap named: #open shortcut: $o command action: [ ]).
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKeymap: conflictingKeymap).

	conflicts := macro conflictsInCategory: category.
	conflict := conflicts anyOne.

	self assert: conflicts size equals: 1.
	self assert: conflict keymap equals: conflictingKeymap.
	self assert: conflict category equals: category.
	self assert: conflict shortcutString equals: conflictingKeymap shortcut asString
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroDetectsFindConflictInTextEditorContext [

	| macro |
	macro := self macroNamed: 'Find replacement' keyBinding: self defaultFindShortcut.
	macro contextNames: { #RubTextEditor }.

	self assert: (macro conflicts anySatisfy: [ :conflict |
			 conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ])
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroIsNamedAfterItsScenario [

	| macro |
	macro := self macroNamed: 'Format method'.
	self assert: macro name equals: 'Format method'.
	macro scenario title: 'Renamed'.
	self assert: macro name equals: 'Renamed'.
	self assert: macro keymapDescription equals: 'Replay macro: Renamed'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroReportsExternalConflictAfterInstall [

	| category macro externalConflict conflicts |
	category := KMCategory named: #ReplayMacroExternalConflictTest.
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	externalConflict := KMKeymap named: #existingSave shortcut: $s command action: [ ].
	category addKeymapEntry: externalConflict.
	macro installInCategory: category.

	conflicts := macro conflictsInCategory: category.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne keymap equals: externalConflict
]

{ #category : 'tests' }
ReplayMacroTest >> testPrintStringToleratesUnknownKey [
	"A key name that no KeyboardKey has, as a hand-edited macro file may hold"

	| macro printString |
	macro := self
		         macroNamed: 'Malformed shortcut'
		         keyBinding: (ReplayKeyBinding chords: { ReplayKeyChord key: #NOT_A_KEY modifiers: ReplayKeyModifiers command }).
	printString := macro printString.
	self assert: (printString includesSubstring: 'Malformed shortcut').
	self assert: (printString includesSubstring: 'Command + NOT_A_KEY').
	self deny: macro hasKeyBinding.
	self deny: macro canInstall
]

{ #category : 'tests' }
ReplayMacroTest >> testReplayKeymapsAreRecognizedByName [

	| macro foreign |
	macro := self macroNamed: 'Recognized' keyBinding: (self controlShortcut: 'f').
	foreign := KMKeymap
		           named: #foreign
		           shortcut: $f ctrl
		           action: [ ]
		           description: ReplayMacro keymapDescriptionPrefix , 'not a macro'.

	self assert: (ReplayMacro isReplayKeymap: macro keymap).
	self deny: (ReplayMacro isReplayKeymap: foreign)
]

{ #category : 'tests' }
ReplayMacroTest >> testRoundTripsThroughSton [

	| scenario macro copy |
	scenario := ReplayScenario new
		            title: 'Macro scenario';
		            yourself.
	macro := ReplayMacro
		         scenario: scenario
		         keyBinding: (ReplayKeyBinding fromKeymap: (KMKeymap named: #save shortcut: $s command action: [ ])).
	macro addContextNamed: #RubSmalltalkEditor.

	copy := STON fromString: (STON toString: macro).

	self assert: copy name equals: 'Macro scenario'.
	self assert: copy identifier equals: macro identifier.
	self assert: copy keyBinding equals: (ReplayKeyBinding character: $s modifiers: ReplayKeyModifiers command).
	self assert: copy contextNames asArray equals: #( RubSmalltalkEditor )
]

{ #category : 'tests' }
ReplayMacroTest >> testStonHoldsTheKeyBindingAlone [
	"The key binding of a macro is a value, not a UI action with a target"

	| ston |
	ston := STON toString: (self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command)).

	self assert: (ston includesSubstring: '#keyBinding:ReplayKeyBinding[ReplayKeyChord[#S,64]]').
	#( 'ReplayShortcut' 'target' 'buttons' 'text' ) do: [ :field |
		self deny: (ston includesSubstring: field) ]
]

{ #category : 'tests' }
ReplayMacroTest >> testStoresContextNames [

	| macro |
	macro := ReplayMacro new.
	macro addContextNamed: #RubSmalltalkEditor.
	macro addContextNamed: #RubSmalltalkEditor.

	self assert: macro contextNames asArray equals: #( RubSmalltalkEditor ).
	self assert: macro contextCategories first name equals: #RubSmalltalkEditor
]

{ #category : 'tests' }
ReplayMacroTest >> testUninstallAllInstalledKeymapsRemovesEveryMacroKeymap [

	| first second |
	first := self macroNamed: 'First' keyBinding: (self controlShortcut: 'f').
	first contextNames: { #RubTextEditor }.
	second := self macroNamed: 'Second' keyBinding: (self controlShortcut: 'g').
	second contextNames: { #ReplayMacroUninstallAllTest }.
	first install.
	second install.

	ReplayMacro uninstallAllInstalledKeymaps.

	self deny: first isInstalled.
	self deny: second isInstalled.
	self assert: ReplayMacro installedKeymapEntries isEmpty
]

{ #category : 'tests' }
ReplayMacroTest >> testUninstallRemovesInstalledKeymaps [

	| macro |
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	macro contextNames: { #ReplayMacroUninstallTest. #RubTextEditor }.
	macro install.
	self assert: (macro installedInContextNamed: #ReplayMacroUninstallTest).

	macro uninstall.
	self deny: (macro installedInContextNamed: #ReplayMacroUninstallTest).
	self deny: macro isInstalled
]

{ #category : 'tests' }
ReplayMacroTest >> testUpdateInstalledKeymapsAfterShortcutChange [

	| category macro keymap |
	category := KMRepository default categoryForName: #ReplayMacroUpdateInstallTest.
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	macro contextNames: { category name }.
	macro install.
	macro keyBinding: (ReplayKeyBinding fromKMCombination: $d command).
	macro updateInstalledKeymaps.

	keymap := category allEntries keymaps detect: [ :each | macro isOwnKeymap: each ].
	self assert: keymap shortcut asString equals: 'Cmd + D'.
	self assert: (category allEntries keymaps count: [ :each | macro isOwnKeymap: each ]) equals: 1
]

{ #category : 'tests' }
ReplayMacroTest >> testUpdateInstalledKeymapsKeepsUninstalledMacroUninstalled [

	| macro |
	macro := self macroNamed: 'Not installed' keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #RubTextEditor }.
	macro updateInstalledKeymaps.

	self deny: macro isInstalled
]

{ #category : 'tests' }
ReplayMacroTest >> testUpdateInstalledKeymapsUninstallsWhenBindingRemoved [

	| macro |
	macro := self macroNamed: 'Invalidate installed macro' keyBinding: (self controlShortcut: 'i').
	macro contextNames: { #RubTextEditor }.
	macro install.
	self assert: (macro installedInContextNamed: #RubTextEditor).

	macro keyBinding: ReplayKeyBinding new.
	macro updateInstalledKeymaps.
	self deny: (macro installedInContextNamed: #RubTextEditor)
]

{ #category : 'tests' }
ReplayMacroTest >> testUpdateKeymapDescriptionsAfterRename [

	| category macro keymap |
	category := KMRepository default categoryForName: #ReplayMacroRenameInstallTest.
	macro := self macroNamed: 'Before rename' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	macro contextNames: { category name }.
	macro install.
	macro scenario title: 'After rename'.
	macro updateKeymapDescriptions.

	keymap := category allEntries keymaps detect: [ :each | macro isOwnKeymap: each ].
	self assert: keymap description equals: 'Replay macro: After rename'.
	self assert: (category allEntries keymaps count: [ :each | macro isOwnKeymap: each ]) equals: 1
]
