Class {
	#name : 'ReplayMacroTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayMacroTest >> testInstalledMacroUsesReplacedScenarioWhenShortcutRuns [

	| macro morph spy event |
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro
		named: 'Scenario macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'scenario-replacement-test';
		contextNames: { #RubTextEditor }.
	morph := Morph new.

	[
		macro install.
		macro scenario: spy.
		morph kmDispatcher reset.
		morph attachKeymapCategory: #RubTextEditor.
		event := KeyboardEvent new.
		event
			setType: #keystroke
			buttons: 16
			position: 0 @ 0
			keyValue: $f asInteger
			charCode: $f asInteger
			hand: nil
			stamp: Time now.
		event key: (KeyboardKey fromCharacter: $f).
		morph kmDispatcher dispatchKeystroke: event.
		self assert: spy hasRun ]

		ensure: [
			macro uninstall.
			morph delete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledTextEditorMacroIsVisibleToCategoryBinding [

	| macro category binding keymap |
	category := KMRepository default categoryForName: #RubTextEditor.
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'binding-visible-test'.
	[
		macro contextNames: { #RubTextEditor }.
		macro install.
		binding := category bindToObject: nil andMorph: nil.
		keymap := binding keymapForShortcut: macro shortcut asKMShortcut.
		self assert: (macro isOwnKeymap: keymap) ]
		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testInstalledTextEditorMacroRunsThroughMorphDispatcher [

	| macro morph spy event |
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: spy.
	macro identifier: 'dispatcher-run-test'.
	morph := Morph new.

	[
		macro contextNames: { #RubTextEditor }.
		macro install.
		morph kmDispatcher reset.
		morph attachKeymapCategory: #RubTextEditor.
		event := KeyboardEvent new.
		event
			setType: #keystroke
			buttons: 16
			position: 0 @ 0
			keyValue: $f asInteger
			charCode: $f asInteger
			hand: nil
			stamp: Time now.
		event key: (KeyboardKey fromCharacter: $f).
		morph kmDispatcher dispatchKeystroke: event.
		self assert: spy hasRun ]

		ensure: [
			macro uninstall.
			morph delete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroContextDefaultContextsExposeUserFacingChoices [

	| contexts textContext codeContext morphicContext windowContext |
	contexts := ReplayMacroContext defaultContexts.
	textContext := contexts detect: [ :context | context identifier = #textEditors ].
	codeContext := contexts detect: [ :context | context identifier = #smalltalkEditors ].
	morphicContext := contexts detect: [ :context | context identifier = #morphicNavigation ].
	windowContext := contexts detect: [ :context | context identifier = #windows ].

	self assert: textContext displayName equals: 'Text editors'.
	self assert: textContext categoryNames asArray equals: { #RubTextEditor }.
	self assert: codeContext displayName equals: 'Smalltalk code editors'.
	self assert: codeContext categoryNames asArray equals: { #RubSmalltalkEditor }.
	self assert: morphicContext displayName equals: 'Morphic navigation'.
	self assert: morphicContext categoryNames asArray equals: { #MorphCtrlNavigation }.
	self assert: windowContext displayName equals: 'Windows'.
	self assert: windowContext categoryNames asArray equals: { #WindowShortcuts }
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroContextDetectsCategoriesAttachedToMorph [

	| morph categoryNames |
	morph := Morph new.
	morph kmDispatcher reset.
	morph attachKeymapCategory: #RubTextEditor.
	categoryNames := ReplayMacroContext categoryNamesForMorph: morph.

	self assert: (categoryNames includes: #RubTextEditor)
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroContextTextEditorsMapsToRubTextEditor [

	| context |
	context := ReplayMacroContext availableContexts
		detect: [ :each | each identifier = #textEditors ].

	self assert: context displayName equals: 'Text editors'.
	self assert: context categoryNames asArray equals: { #RubTextEditor }
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroDetectsConflictingKeymapInCategory [

	| category conflictingKeymap otherKeymap macro conflicts conflict |
	category := KMCategory named: #ReplayMacroTest.
	conflictingKeymap := KMKeymap
		named: #save
		shortcut: $s command
		action: [ ].
	otherKeymap := KMKeymap
		named: #open
		shortcut: $o command
		action: [ ].
	category addKeymapEntry: conflictingKeymap.
	category addKeymapEntry: otherKeymap.
	macro := ReplayMacro new
		shortcut: (ReplayShortcut fromKeymap: conflictingKeymap);
		yourself.

	conflicts := macro conflictsInCategory: category.
	conflict := conflicts anyOne.

	self assert: conflicts size equals: 1.
	self assert: conflict keymap equals: conflictingKeymap.
	self assert: conflict category equals: category.
	self assert: conflict shortcutString equals: conflictingKeymap shortcut asString
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorActiveContextStatusNamesFocusedConflict [

	| morph macro editor status |
	morph := Morph new.
	morph kmDispatcher reset.
	morph attachKeymapCategory: #RubTextEditor.
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 64;
			yourself)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.
	status := editor activeContextStatusTextForMorph: morph.

	self assert: (status includesSubstring: 'Text editor').
	self assert: (status includesSubstring: 'conflict')
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorBuildsAndRefreshesConflicts [

	| keymap macro editor category |
	category := KMRepository default categoryForName: #RubSmalltalkEditor.
	keymap := category allEntries keymaps anyOne.
	macro := ReplayMacro new
		shortcut: (ReplayShortcut fromKeymap: keymap);
		contextNames: { #RubSmalltalkEditor };
		yourself.
	editor := ReplayMacroEditor on: macro.

	self assert: editor conflictList notNil.
	self assert: editor contextDropList notNil.
	self assert: editor conflictStatusPresenter notNil.
	self assert: editor shortcutTextPresenter notNil.
	self assert: editor commandCheckBox notNil.
	self assert: editor controlCheckBox notNil.
	self assert: editor altCheckBox notNil.
	self assert: editor shiftCheckBox notNil.
	self assert: editor conflictList items notEmpty.
	self assert: (editor conflictStatusPresenter label includesSubstring: 'conflict')
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorCanUninstallMacro [

	| macro editor |
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'editor-uninstall-test'.
	macro contextNames: { #RubTextEditor }.
	editor := ReplayMacroEditor on: macro.
	[
		editor installMacro.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		self assert: (editor installationStatusPresenter label includesSubstring: 'Text editor').
		editor uninstallMacro.
		self deny: (macro installedInContextNamed: #RubTextEditor).
		self assert: editor installationStatusPresenter label equals: 'Not installed.' ]
		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorConflictStatusNamesConflictingContexts [

	| macro editor |
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 64;
			yourself)
		scenario: ReplayScenario new.
	macro contextNames: { #MorphCtrlNavigation }.
	editor := ReplayMacroEditor on: macro.

	self assert: (editor conflictStatusPresenter label includesSubstring: 'Text editor')
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorMovesInstalledMacroWhenContextChanges [

	| macro editor codeContext |
	macro := ReplayMacro
		named: 'Context macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'editor-context-move-test';
		contextNames: { #RubTextEditor }.
	editor := ReplayMacroEditor on: macro.

	[
		editor installMacro.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		codeContext := editor contextDropList items detect: [ :context | context identifier = #smalltalkEditors ].
		editor contextDropList selectItem: codeContext.
		self deny: (macro installedInContextNamed: #RubTextEditor).
		self assert: (macro installedInContextNamed: #RubSmalltalkEditor) ]

		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorShowsConflictsInAllKnownContexts [

	| macro editor conflict |
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 64;
			yourself)
		scenario: ReplayScenario new.
	macro contextNames: { #MorphCtrlNavigation }.
	editor := ReplayMacroEditor on: macro.
	conflict := editor conflictList items
		detect: [ :each | each categoryName = #RubTextEditor and: [ each name = #find ] ]
		ifNone: [ nil ].

	self assert: conflict notNil.
	self assert: (conflict contextDisplayName includesSubstring: 'Text editor').
	self assert: (editor conflictStatusPresenter label includesSubstring: 'context')
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorShowsLibraryInternalConflicts [

	| library first second editor conflict |
	library := ReplayMacroLibrary new.
	first := ReplayMacro
		named: 'First'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	first addContextNamed: #ReplayMacroContext.
	second := ReplayMacro
		named: 'Second'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	second addContextNamed: #ReplayMacroContext.
	library
		addMacro: first;
		addMacro: second.
	editor := ReplayMacroEditor on: first inLibrary: library.
	conflict := editor conflictList items
		detect: [ :each | each name = #Second ]
		ifNone: [ nil ].

	self assert: conflict notNil.
	self assert: conflict categoryName equals: #ReplayMacroContext
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorShowsNoContextStatusInitially [

	| editor |
	editor := ReplayMacroEditor new.

	self assert: editor conflictList items isEmpty.
	self assert: editor conflictStatusPresenter label equals: 'Enter shortcut keys to check known contexts.'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorShowsStoredShortcut [

	| macro editor |
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.

	self assert: editor shortcutTextPresenter text equals: macro shortcut text.
	self assert: editor commandCheckBox state.
	self deny: editor controlCheckBox state.
	self deny: editor altCheckBox state.
	self deny: editor shiftCheckBox state
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorUpdatesInstalledMacroWhenNameChanges [

	| macro editor keymap |
	macro := ReplayMacro
		named: 'Before rename'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'editor-name-update-test';
		contextNames: { #RubTextEditor }.
	editor := ReplayMacroEditor on: macro.

	[
		editor installMacro.
		editor namePresenter text: 'After rename'.
		keymap := (KMRepository default categoryForName: #RubTextEditor) allEntries keymaps
			detect: [ :each | macro isOwnKeymap: each ].
		self assert: keymap description equals: 'Replay macro: After rename' ]

		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorUpdatesInstalledMacroWhenShortcutChanges [

	| macro editor keymap |
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'editor-update-test'.
	macro contextNames: { #RubTextEditor }.
	editor := ReplayMacroEditor on: macro.
	[
		editor installMacro.
		editor shortcutTextPresenter text: 'g'.
		keymap := (KMRepository default categoryForName: #RubTextEditor) allEntries keymaps
			detect: [ :each | macro isOwnKeymap: each ].
		self assert: keymap shortcut asString equals: 'Ctrl + G' ]
		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorUpdatesShortcutModifier [

	| macro editor |
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut new text: 's'; yourself)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.

	editor commandCheckBox toggleState.

	self assert: (macro shortcut hasFlags: 64).
	self assert: macro shortcut asKMShortcut asString equals: 'Cmd + S'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorUpdatesShortcutText [

	| macro editor |
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.

	editor shortcutTextPresenter text: 'd'.

	self assert: macro shortcut text equals: 'd'.
	self assert: macro shortcut asKMShortcut asString equals: 'Cmd + D'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorUsesMacroContexts [

	| editor textContext |
	editor := ReplayMacroEditor new.
	textContext := editor contextDropList items detect: [ :context | context identifier = #textEditors ].

	self assert: textContext displayName equals: 'Text editors'.
	self assert: textContext categoryNames asArray equals: { #RubTextEditor }
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroInstallDoesNotReportOwnKeymapAsConflict [

	| category macro keymap conflicts |
	category := KMCategory named: #ReplayMacroInstallTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.

	keymap := macro installInCategory: category.
	conflicts := macro conflictsInCategory: category.

	self assert: keymap name equals: macro keymapName.
	self assert: keymap shortcut asString equals: 'Cmd + S'.
	self assert: conflicts isEmpty
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroInstallRemovesLegacyConflictingReplayKeymap [

	| category legacy macro conflicts |
	category := KMCategory named: #ReplayMacroLegacyCleanupTest.
	legacy := KMKeymap
		named: #'Old macro'
		shortcut: $f control
		action: [ ]
		description: 'Replay macro: Old macro'.
	category addKeymapEntry: legacy.
	macro := ReplayMacro
		named: 'New macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'legacy-cleanup-test'.
	macro installInCategory: category.
	conflicts := category allEntries keymaps select: [ :each |
		ReplayMacro isLegacyReplayKeymap: each ].

	self assert: conflicts isEmpty.
	self assert: (category allEntries keymaps anySatisfy: [ :each | macro isOwnKeymap: each ])
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroInstallReplacesOwnKeymapInCategory [

	| category macro firstKeymap secondKeymap ownKeymaps |
	category := KMCategory named: #ReplayMacroReplaceInstallTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.

	firstKeymap := macro installInCategory: category.
	macro shortcut: (ReplayShortcut fromShortcut: $d command).
	secondKeymap := macro installInCategory: category.
	ownKeymaps := category allEntries keymaps select: [ :keymap |
		macro isOwnKeymap: keymap ].

	self deny: firstKeymap identicalTo: secondKeymap.
	self assert: ownKeymaps size equals: 1.
	self assert: ownKeymaps anyOne identicalTo: secondKeymap.
	self assert: secondKeymap shortcut asString equals: 'Cmd + D'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroInstallsKeymapInCategory [

	| category macro keymap |
	category := KMCategory named: #ReplayMacroInstallTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.

	keymap := macro installInCategory: category.

	self assert: keymap name equals: macro keymapName.
	self assert: keymap description equals: 'Replay macro: Save macro'.
	self assert: keymap shortcut asString equals: 'Cmd + S'.
	self assert: (category allEntries keymaps includes: keymap)
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryAddsAndRemovesMacros [

	| library first second |
	library := ReplayMacroLibrary new.
	first := library addNewMacro.
	second := ReplayMacro new name: 'Second'; yourself.
	library addMacro: second.

	self assert: library macros asArray equals: { first. second }.
	library removeMacro: first.
	self assert: library macros asArray equals: { second }
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryAggregatesConflicts [

	| category keymap macro library |
	category := KMRepository default categoryForName: #RubSmalltalkEditor.
	keymap := category allEntries keymaps anyOne.
	macro := ReplayMacro new
		shortcut: (ReplayShortcut fromKeymap: keymap);
		contextNames: { #RubSmalltalkEditor };
		yourself.
	library := ReplayMacroLibrary new
		addMacro: macro;
		yourself.

	self assert: library conflicts notEmpty.
	self assert: (library conflicts anySatisfy: [ :conflict |
		conflict keymap = keymap ])
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryDetectsInternalConflicts [

	| library first second conflicts |
	library := ReplayMacroLibrary new.
	first := ReplayMacro
		named: 'First'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	first addContextNamed: #ReplayMacroContext.
	second := ReplayMacro
		named: 'Second'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	second addContextNamed: #ReplayMacroContext.
	library
		addMacro: first;
		addMacro: second.

	conflicts := library internalConflicts.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne categoryName equals: #ReplayMacroContext.
	self assert: conflicts anyOne name equals: #Second
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorAddsMacro [

	| library editor macro |
	library := ReplayMacroLibrary new.
	editor := ReplayMacroLibraryEditor on: library.
	macro := editor addMacro.

	self assert: library macros size equals: 1.
	self assert: library macros first identicalTo: macro.
	self assert: editor macroList items size equals: 1.
	self assert: editor selectedMacro identicalTo: macro
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorBuilds [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := ReplayMacro
		named: 'Format method'
		shortcut: ReplayShortcut new
		scenario: ReplayScenario new.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.

	self assert: editor macroList isNotNil.
	self assert: editor macroEditorPane isNotNil.
	self assert: editor toolbar isNotNil.
	self assert: editor macroList items size equals: 1
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorClearsInstalledReplayKeymaps [

	| snapshot library macro editor |
	snapshot := OrderedCollection new.
	KMRepository default categories valuesDo: [ :category |
		category allEntries keymaps do: [ :keymap |
			(ReplayMacro isReplayKeymap: keymap) ifTrue: [
				snapshot add: category -> keymap ] ] ].

	library := ReplayMacroLibrary new.
	macro := ReplayMacro
		named: 'Clear macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'library-clear-installed-test';
		contextNames: { #RubTextEditor }.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.
	editor selectMacro: macro.

	[
		editor installAllMacros.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		editor clearInstalledReplayMacros.
		self deny: (macro installedInContextNamed: #RubTextEditor).
		self assert: editor macroEditorPresenter installationStatusPresenter label equals: 'Not installed.' ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			snapshot do: [ :association | association key addKeymapEntry: association value ] ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorInstallationSummaryUpdatesWhenSelectedMacroInstalls [

	| snapshot library macro editor |
	snapshot := ReplayMacro installedKeymapEntries copy.
	ReplayMacro uninstallAllInstalledKeymaps.
	library := ReplayMacroLibrary new.
	macro := ReplayMacro
		named: 'Summary macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'library-summary-install-test';
		contextNames: { #RubTextEditor }.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList selectIndex: 1.

	[
		self assert: (editor installationSummaryPresenter label includesSubstring: '0 / 1').
		editor macroEditorPresenter installMacro.
		self assert: (editor installationSummaryPresenter label includesSubstring: '1 / 1') ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			snapshot do: [ :association | association key addKeymapEntry: association value ] ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorListAddCreatesOneMacro [

	| library editor |
	library := ReplayMacroLibrary new.
	editor := ReplayMacroLibraryEditor on: library.

	editor macroList addButton click.

	self assert: library macros size equals: 1.
	self assert: editor macroList items size equals: 1.
	self assert: editor selectedMacro identicalTo: library macros first
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorRemovesSelectedMacro [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (ReplayMacro new name: 'First'; yourself).
	second := library addMacro: (ReplayMacro new name: 'Second'; yourself).
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList selectIndex: 1.
	editor removeSelectedMacro.

	self deny: (library macros includes: first).
	self assert: library macros size equals: 1.
	self assert: library macros first identicalTo: second.
	self assert: editor selectedMacro identicalTo: second
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorRemovesUnselectedMacro [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (ReplayMacro new name: 'First'; yourself).
	second := library addMacro: (ReplayMacro new name: 'Second'; yourself).
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList selectIndex: 2.
	editor removeMacro: first.

	self deny: (library macros includes: first).
	self assert: library macros size equals: 1.
	self assert: library macros first identicalTo: second.
	self assert: editor selectedMacro identicalTo: second
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryIgnoresInternalConflictsInDifferentContexts [

	| library first second |
	library := ReplayMacroLibrary new.
	first := ReplayMacro
		named: 'First'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	first addContextNamed: #ReplayMacroContextA.
	second := ReplayMacro
		named: 'Second'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	second addContextNamed: #ReplayMacroContextB.
	library
		addMacro: first;
		addMacro: second.

	self assert: library internalConflicts isEmpty
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryInternalConflictsForMacro [

	| library first second conflicts |
	library := ReplayMacroLibrary new.
	first := ReplayMacro
		named: 'First'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	first addContextNamed: #ReplayMacroContext.
	second := ReplayMacro
		named: 'Second'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	second addContextNamed: #ReplayMacroContext.
	library
		addMacro: first;
		addMacro: second.

	conflicts := library internalConflictsForMacro: first.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne name equals: #Second
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryNamesNewMacros [

	| library first second |
	library := ReplayMacroLibrary new.
	first := library addNewMacro.
	second := library addNewMacro.

	self assert: first name equals: 'Macro 1'.
	self assert: second name equals: 'Macro 2'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryReportsInstalledMacros [

	| library installed uninstalled |
	library := ReplayMacroLibrary new.
	installed := ReplayMacro
		named: 'Installed'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	installed
		identifier: 'library-installed-test';
		contextNames: { #RubTextEditor }.
	uninstalled := ReplayMacro named: 'Uninstalled' shortcut: ReplayShortcut new scenario: ReplayScenario new.
	library
		addMacro: installed;
		addMacro: uninstalled.

	[
		installed install.
		self assert: library installedMacros asArray equals: { installed }.
		self assert: library installedMacroCount equals: 1 ]

		ensure: [ installed uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryReusesFirstAvailableMacroName [

	| library first second third |
	library := ReplayMacroLibrary new.
	first := library addNewMacro.
	second := library addNewMacro.
	library removeMacro: first.
	third := library addNewMacro.

	self assert: second name equals: 'Macro 2'.
	self assert: third name equals: 'Macro 1'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryRoundTripsThroughSton [

	| library copy |
	library := ReplayMacroLibrary new.
	library addMacro: (ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new).

	copy := STON fromString: (STON toString: library).

	self assert: copy macros size equals: 1.
	self assert: copy macros first name equals: 'Save macro'.
	self assert: copy macros first shortcut asKMShortcut asString equals: 'Cmd + S'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroRegistryLoadAndInstall [

	| file registry loaded macro |
	file := FileLocator temp / 'replay-macro-load-install-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	macro := registry library addNewMacro.
	macro
		identifier: 'load-install-test';
		name: 'Loaded macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'z';
			addFlags: 16;
			yourself).
	[
		registry saveToFile: file.
		loaded := ReplayMacroRegistry new.
		loaded loadFromFile: file.
		loaded install.
		self assert: (loaded library macros first installedInContextNamed: #RubTextEditor) ]
		ensure: [
			loaded ifNotNil: [ loaded uninstall ].
			file ensureDelete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroRegistryLoadAndInstallFromFileInstallsLoadedMacros [

	| file registry macro loaded loadedMacro |
	file := FileLocator temp / 'replay-macro-load-install-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	macro := registry library addNewMacro.
	macro
		identifier: 'registry-load-install-test';
		name: 'Load install macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself).

	[
		registry saveToFile: file.
		loaded := ReplayMacroRegistry new.
		loaded loadAndInstallFromFile: file.
		loadedMacro := loaded library macros first.
		self assert: (loadedMacro installedInContextNamed: #RubTextEditor) ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			file ensureDelete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroRegistryLoadFromFileDoesNotInstallLoadedMacros [

	| file registry macro loaded loadedMacro |
	file := FileLocator temp / 'replay-macro-load-only-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	macro := registry library addNewMacro.
	macro
		identifier: 'registry-load-only-test';
		name: 'Load only macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself).

	[
		registry saveToFile: file.
		loaded := ReplayMacroRegistry new.
		loaded loadFromFile: file.
		loadedMacro := loaded library macros first.
		self deny: (loadedMacro installedInContextNamed: #RubTextEditor) ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			file ensureDelete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroRegistrySavesAndLoadsLibrary [

	| file registry loaded macro |
	file := FileLocator temp / 'replay-macro-registry-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	macro := registry library addNewMacro.
	macro
		name: 'Saved macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself).
	[
		registry saveToFile: file.
		loaded := ReplayMacroRegistry new.
		loaded loadFromFile: file.
		self assert: loaded library macros size equals: 1.
		self assert: loaded library macros first name equals: 'Saved macro'.
		self assert: loaded library macros first contextNames asArray equals: { #RubTextEditor } ]
		ensure: [ file ensureDelete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroReportsExternalConflictAfterInstall [

	| category macro externalConflict conflicts |
	category := KMCategory named: #ReplayMacroExternalConflictTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	externalConflict := KMKeymap
		named: #existingSave
		shortcut: $s command
		action: [ ].
	category addKeymapEntry: externalConflict.
	macro installInCategory: category.

	conflicts := macro conflictsInCategory: category.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne keymap equals: externalConflict
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroRoundTripsThroughSton [

	| scenario macro copy |
	scenario := ReplayScenario new
		title: 'Macro scenario';
		yourself.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromKeymap: (KMKeymap
			named: #save
			shortcut: $s command
			action: [ ]))
		scenario: scenario.
	macro addContextNamed: #RubSmalltalkEditor.

	copy := STON fromString: (STON toString: macro).

	self assert: copy name equals: 'Save macro'.
	self assert: copy shortcut text equals: 'S'.
	self assert: copy shortcut flags equals: 64.
	self assert: copy scenario title equals: 'Macro scenario'.
	self assert: copy contextNames asArray equals: #( RubSmalltalkEditor )
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroStoresContextNames [

	| macro |
	macro := ReplayMacro new.
	macro addContextNamed: #RubSmalltalkEditor.
	macro addContextNamed: #RubSmalltalkEditor.

	self assert: macro contextNames asArray equals: #( RubSmalltalkEditor ).
	self assert: macro contextCategories first name equals: #RubSmalltalkEditor
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroUninstallRemovesInstalledKeymap [

	| category macro |
	category := KMCategory named: #ReplayMacroUninstallTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	macro identifier: 'uninstall-test'.
	macro installInCategory: category.

	self assert: (macro installedInCategory: category).
	macro uninstallFromCategory: category.
	self deny: (macro installedInCategory: category)
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroUpdateInstalledKeymapAfterRename [

	| category macro keymap |
	category := KMRepository default categoryForName: #ReplayMacroRenameInstallTest.
	macro := ReplayMacro
		named: 'Before rename'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	macro identifier: 'rename-install-test'.
	[
		macro installInCategory: category.
		macro name: 'After rename'.
		macro updateInstalledKeymaps.
		keymap := category allEntries keymaps detect: [ :each | macro isOwnKeymap: each ].
		self assert: keymap description equals: 'Replay macro: After rename'.
		self assert: (category allEntries keymaps count: [ :each | macro isOwnKeymap: each ]) equals: 1 ]
		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroUpdateInstalledKeymapAfterShortcutChange [

	| category macro keymap |
	category := KMRepository default categoryForName: #ReplayMacroUpdateInstallTest.
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	macro identifier: 'update-install-test'.
	[
		macro installInCategory: category.
		macro shortcut: (ReplayShortcut fromShortcut: $d command).
		macro updateInstalledKeymaps.
		keymap := category allEntries keymaps detect: [ :each | macro isOwnKeymap: each ].
		self assert: keymap shortcut asString equals: 'Cmd + D' ]
		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testReplayMacroReportsInstalledKeymapEntries [

	| macro entries |
	macro := ReplayMacro
		named: 'Installed entry macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'installed-entry-test';
		contextNames: { #RubTextEditor }.

	[
		macro install.
		entries := ReplayMacro installedKeymapEntries.
		self assert: (entries anySatisfy: [ :association |
			association key name = #RubTextEditor and: [ macro isOwnKeymap: association value ] ]).
		self assert: (ReplayMacro installedKeymaps anySatisfy: [ :keymap | macro isOwnKeymap: keymap ]) ]

		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testReplayShortcutCanBeBuiltFromKeymap [

	| keymap shortcut |
	keymap := KMKeymap
		named: #save
		shortcut: $s command
		action: [ ].
	shortcut := ReplayShortcut fromKeymap: keymap.

	self assert: shortcut text equals: 'S'.
	self assert: shortcut flags equals: 64.
	self assert: (shortcut matchesKeymap: keymap)
]

{ #category : 'tests' }
ReplayMacroTest >> testReplayShortcutConvertsBackToKMShortcut [

	| original replay copy |
	original := $s command.
	replay := ReplayShortcut fromShortcut: original.
	copy := replay asKMShortcut.

	self assert: copy asString equals: original asString.
	self assert: (ReplayShortcut fromShortcut: copy) text equals: replay text.
	self assert: (ReplayShortcut fromShortcut: copy) flags equals: replay flags
]

{ #category : 'tests' }
ReplayMacroTest >> testReplayShortcutMatchesKeymapCaseInsensitively [

	| category keymap shortcut |
	category := KMRepository default categoryForName: #RubTextEditor.
	keymap := category keymapNamed: #find.
	shortcut := ReplayShortcut new
		text: 'f';
		addFlags: 64;
		yourself.

	self assert: (shortcut matchesKeymap: keymap)
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutConflictShowsReadableContextDisplayName [

	| category keymap conflict |
	category := KMRepository default categoryForName: #RubTextEditor.
	keymap := category keymapNamed: #find.
	conflict := ReplayShortcutConflict category: category keymap: keymap.

	self assert: conflict contextDisplayName equals: 'Text editor (RubTextEditor)'
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutConflictUsesCommandDisplayForMetaShortcut [

	| category keymap conflict |
	category := KMRepository default categoryForName: #RubTextEditor.
	keymap := category keymapNamed: #find.
	conflict := ReplayShortcutConflict category: category keymap: keymap.

	self assert: conflict shortcutString equals: 'Command + F'
]
