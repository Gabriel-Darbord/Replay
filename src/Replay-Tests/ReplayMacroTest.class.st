Class {
	#name : 'ReplayMacroTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroTest >> defaultFindShortcut [

	^ ReplayShortcut new
		text: 'f';
		addFlags: OSPlatform current defaultModifier eventCode;
		yourself
]

{ #category : 'support' }
ReplayMacroTest >> findKeymapInCategoryNamed: aSymbol [

	^ (KMRepository default categoryForName: aSymbol) allEntries keymaps
		detect: [ :keymap | keymap name = #find ]
		ifNone: [ self fail: 'Expected find keymap in ' , aSymbol asString ]
]

{ #category : 'support' }
ReplayMacroTest >> keyboardEventForCharacter: aCharacter buttons: flags [

	| event |
	event := KeyboardEvent new.
	event
		setType: #keystroke
		buttons: flags
		position: 0 @ 0
		keyValue: aCharacter asInteger
		charCode: aCharacter asInteger
		hand: nil
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: aCharacter).
	^ event
]

{ #category : 'tests' }
ReplayMacroTest >> testCapturedShiftShortcutPreservesShiftedCharacter [

	| catcher capturedShortcut event |
	event := self keyboardEventForCharacter: $F buttons: 8.
	catcher := KMCatcherMorph new.
	[
		catcher keyStroke: event.
		capturedShortcut := ReplayShortcut fromShortcut: catcher shortcut.
		self assert: capturedShortcut text equals: 'F'.
		self assert: capturedShortcut flags equals: 8 ]
		ensure: [ catcher delete ]
]

{ #category : 'tests' }
ReplayMacroTest >> testCapturedShortcutInstallsAndRunsThroughMorphDispatcher [

	| catcher capturedShortcut macro morph spy event |
	event := self keyboardEventForCharacter: $f buttons: 16.
	catcher := KMCatcherMorph new.
	catcher keyStroke: event.
	capturedShortcut := ReplayShortcut fromShortcut: catcher shortcut.
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro
		named: 'Captured shortcut macro'
		shortcut: capturedShortcut
		scenario: spy.
	macro identifier: 'captured-shortcut-run-test'.
	morph := Morph new.
	[
		self assert: capturedShortcut text equals: 'f'.
		self assert: capturedShortcut flags equals: 16.
		macro contextNames: { #RubTextEditor }.
		macro install.
		morph kmDispatcher reset.
		morph attachKeymapCategory: #RubTextEditor.
		morph kmDispatcher dispatchKeystroke: event.
		self assert: spy hasRun ]
		ensure: [
			macro uninstall.
			morph delete.
			catcher delete ]
]

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
	self assert: textContext conflictCategoryNames asArray equals: { #RubTextEditor }.
	self assert: codeContext displayName equals: 'Smalltalk code editors'.
	self assert: codeContext categoryNames asArray equals: { #RubSmalltalkEditor }.
	self assert: codeContext conflictCategoryNames asArray equals: { #RubSmalltalkEditor. #RubTextEditor }.
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
ReplayMacroTest >> testMacroContextDetectsNestedRubricTextEditorCategory [

	| field categoryNames |
	field := RubTextFieldMorph new.
	[
		categoryNames := ReplayMacroContext categoryNamesForMorph: field.
		self assert: (categoryNames includes: #RubTextEditor) ]
		ensure: [ field delete ]
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
ReplayMacroTest >> testMacroDetectsBaseTextFindConflictInSmalltalkEditorContext [

	| macro conflicts |
	macro := ReplayMacro
		named: 'Smalltalk find replacement'
		shortcut: self defaultFindShortcut
		scenario: ReplayScenario new.
	macro contextNames: { #RubSmalltalkEditor }.

	conflicts := macro conflicts.
	self assert: (conflicts anySatisfy: [ :conflict |
		conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ])
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
ReplayMacroTest >> testMacroDetectsFindConflictInTextEditorContext [

	| macro conflicts |
	macro := ReplayMacro
		named: 'Find replacement'
		shortcut: self defaultFindShortcut
		scenario: ReplayScenario new.
	macro contextNames: { #RubTextEditor }.

	conflicts := macro conflicts.
	self assert: (conflicts anySatisfy: [ :conflict |
		conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ])
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
ReplayMacroTest >> testMacroEditorInstallsSelectedMacroInActiveMorphContext [

	| morph macro editor |
	morph := Morph new.
	morph kmDispatcher reset.
	morph attachKeymapCategory: #RubTextEditor.
	macro := ReplayMacro
		named: 'Active context macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'active-context-install-test'.
	editor := ReplayMacroEditor on: macro.

	[
		editor installInActiveContextForMorph: morph.
		self assert: macro contextNames asArray equals: { #RubTextEditor }.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		self assert: (editor installationStatusPresenter label includesSubstring: 'Text editor') ]

		ensure: [ macro uninstall ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroEditorInstallsTextFieldActiveContextForTextEditorDispatch [

	| field editingArea macro editor spy event |
	spy := ReplayMacroRunSpy new.
	macro := ReplayMacro
		named: 'Text field active context macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: spy.
	macro identifier: 'text-field-active-context-test'.
	field := RubTextFieldMorph new.
	[
		editor := ReplayMacroEditor on: macro.
		editor installInActiveContextForMorph: field.
		self assert: (macro contextNames includes: #RubTextEditor).
		self assert: (macro installedInContextNamed: #RubTextEditor).
		editingArea := self textEditingMorphIn: field.
		event := self keyboardEventForCharacter: $f buttons: 16.
		editingArea kmDispatcher dispatchKeystroke: event.
		self assert: spy hasRun ]
		ensure: [
			macro uninstall.
			field delete ]
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
ReplayMacroTest >> testMacroEditorReusesShortcutModifierTargets [

	| macro editor command |
	macro := ReplayMacro
		named: 'Save macro'
		shortcut: (ReplayShortcut fromShortcut: $s command)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.

	self assert: editor modifierPresenter notNil.
	command := editor replayPresenterAt: 'Shortcut command' ifAbsent: [ nil ].
	self assert: command == editor commandCheckBox.
	self assert: (editor replayPresenterAt: 'Action command' ifAbsent: [ nil ]) == editor commandCheckBox.
	self assert: (editor replayPresenterAt: 'Command modifier' ifAbsent: [ nil ]) == editor commandCheckBox.
	self assert: (editor replayPresenterAt: 'Shortcut alt option' ifAbsent: [ nil ]) == editor altCheckBox
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
ReplayMacroTest >> testMacroEditorShowsContextualInstallationButton [

	| macro editor |
	macro := ReplayMacro
		named: 'Find macro'
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro
		identifier: 'editor-contextual-install-button-test';
		contextNames: { #RubTextEditor }.
	editor := ReplayMacroEditor on: macro.

	[
		self assert: editor macroInstallationButton label equals: 'Install'.
		editor toggleMacroInstallation.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		self assert: editor macroInstallationButton label equals: 'Uninstall'.
		editor toggleMacroInstallation.
		self deny: (macro installedInContextNamed: #RubTextEditor).
		self assert: editor macroInstallationButton label equals: 'Install' ]
		ensure: [ macro uninstall ]
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
ReplayMacroTest >> testMacroEditorShowsSmalltalkFindConflictFromBaseTextContext [

	| macro editor conflicts |
	macro := ReplayMacro
		named: 'Smalltalk find replacement'
		shortcut: self defaultFindShortcut
		scenario: ReplayScenario new.
	macro contextNames: { #RubSmalltalkEditor }.
	editor := ReplayMacroEditor on: macro.

	conflicts := editor conflictList items.
	self assert: (conflicts anySatisfy: [ :conflict |
		conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ]).
	self assert: (editor conflictStatusPresenter label includesSubstring: 'Text editors').
	self deny: (editor conflictStatusPresenter label includesSubstring: 'RubTextEditor')
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
ReplayMacroTest >> testMacroEditorUsesShortcutKeysPresenter [

	| macro editor |
	macro := ReplayMacro
		named: 'Branch macro'
		shortcut: (ReplayShortcut new
			text: (String with: (Character arrowRight));
			addFlags: 64;
			yourself)
		scenario: ReplayScenario new.
	editor := ReplayMacroEditor on: macro.
	self assert: editor shortcutTextPresenter class equals: ReplayShortcutKeysPresenter.
	self assert: editor shortcutTextPresenter text equals: macro shortcut text.
	self assert: editor shortcutTextPresenter keyList items asArray equals: { (Character arrowRight) }.
	self assert: (editor replayPresenterAt: 'Shortcut key list' ifAbsent: [ nil ]) identicalTo: editor shortcutTextPresenter keyList
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroIdentitySurvivesSaveLoadEditInstallReloadWithoutDuplicateKeymaps [

	| file firstRegistry firstMacro secondRegistry loadedMacro thirdRegistry reloadedMacro category ownKeymaps |
	file := FileLocator temp / 'replay-macro-identity-reload-test.ston'.
	file ensureDelete.
	category := KMRepository default categoryForName: #RubTextEditor.
	firstRegistry := ReplayMacroRegistry new.
	firstMacro := firstRegistry library addNewMacro.
	firstMacro
		identifier: 'stable-identity-reload-test';
		name: 'Original macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself).

	[
		firstRegistry saveToFile: file.
		secondRegistry := ReplayMacroRegistry new.
		secondRegistry loadAndInstallFromFile: file.
		loadedMacro := secondRegistry library macros first.
		loadedMacro
			name: 'Edited macro';
			shortcut: (ReplayShortcut new
				text: 'g';
				addFlags: 16;
				yourself).
		loadedMacro updateInstalledKeymaps.
		secondRegistry saveToFile: file.

		thirdRegistry := ReplayMacroRegistry new.
		thirdRegistry loadAndInstallFromFile: file.
		reloadedMacro := thirdRegistry library macros first.
		ownKeymaps := category allEntries keymaps select: [ :keymap | reloadedMacro isOwnKeymap: keymap ].
		self assert: reloadedMacro identifier equals: 'stable-identity-reload-test'.
		self assert: reloadedMacro name equals: 'Edited macro'.
		self assert: reloadedMacro shortcut text equals: 'g'.
		self assert: ownKeymaps size equals: 1 ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			file ensureDelete ]
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
ReplayMacroTest >> testMacroLibraryCreatesMacroForScenario [

	| library scenario macro |
	library := ReplayMacroLibrary new.
	scenario := ReplayScenario new title: 'Format method'; yourself.
	macro := library macroForScenario: scenario.

	self assert: library macros size equals: 1.
	self assert: macro scenario identicalTo: scenario.
	self assert: macro name equals: 'Format method'
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryDetectsInternalConflictAcrossCompositeEditorContext [

	| smalltalkMacro textMacro library conflicts |
	smalltalkMacro := ReplayMacro
		named: 'Smalltalk macro'
		shortcut: self defaultFindShortcut
		scenario: ReplayScenario new.
	smalltalkMacro contextNames: { #RubSmalltalkEditor }.
	textMacro := ReplayMacro
		named: 'Text macro'
		shortcut: self defaultFindShortcut
		scenario: ReplayScenario new.
	textMacro contextNames: { #RubTextEditor }.
	library := ReplayMacroLibrary new
		addMacro: smalltalkMacro;
		addMacro: textMacro;
		yourself.

	conflicts := library internalConflicts.
	self assert: (conflicts anySatisfy: [ :conflict |
		conflict contextDisplayName = 'Smalltalk code editors'
			and: [ conflict name = 'Text macro' ] ])
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
ReplayMacroTest >> testMacroLibraryEditorAddsAndSelectsMacroForScenario [

	| library editor scenario macro |
	library := ReplayMacroLibrary new.
	editor := ReplayMacroLibraryEditor on: library.
	scenario := ReplayScenario new title: 'Recorded flow'; yourself.
	macro := editor addMacroForScenario: scenario.

	self assert: library macros size equals: 1.
	self assert: macro scenario identicalTo: scenario.
	self assert: editor selectedMacro identicalTo: macro.
	self assert: editor macroList items size equals: 1
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
ReplayMacroTest >> testMacroLibraryEditorBuildsSpecAdapter [

	| library macro editor result |
	library := ReplayMacroLibrary new.
	macro := ReplayMacro
		named: 'Format method'
		shortcut: ReplayShortcut new
		scenario: ReplayScenario new.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.

	result := [
		editor build.
		#built ]
		on: Error
		do: [ :error | error ].
	self assert: result equals: #built
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
ReplayMacroTest >> testMacroLibraryEditorOpensWithUnmappedShortcutCharacter [

	| character macro library editor |
	character := Character value: 16rFFC3.
	macro := ReplayMacro
		named: 'Stored malformed shortcut'
		shortcut: (ReplayShortcut new
			text: (String with: character);
			yourself)
		scenario: ReplayScenario new.
	library := ReplayMacroLibrary new.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.
	self assert: editor macroList items first identicalTo: macro.
	self shouldnt: [ editor macroList items first printString ] raise: Error
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorRemoveSelectedMacroUninstallsIt [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addNewMacro.
	macro
		identifier: 'editor-remove-installed-macro-test';
		shortcut: (ReplayShortcut new
			text: 'r';
			addFlags: 16;
			yourself);
		contextNames: { #RubTextEditor }.
	editor := ReplayMacroLibraryEditor on: library.
	[
		macro install.
		editor macroList selectItem: macro.
		editor removeSelectedMacro.
		self deny: (macro installedInContextNamed: #RubTextEditor).
		self assert: editor installationSummaryPresenter label equals: 'Installed macros: 0 / 0. Replay keymaps in image: 0.' ]
		ensure: [ macro uninstall ]
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
ReplayMacroTest >> testMacroLibraryEditorShowsContextualStartupButton [

	| editor |
	ReplayMacroRegistry disableStartupInstallation.
	editor := ReplayMacroLibraryEditor new.
	[
		self assert: editor startupPolicyPresenter label equals: 'Disabled'.
		self assert: editor startupPolicyButton label equals: 'Enable startup'.
		self assert: editor startupPolicyButton icon isNil.
		self assert: editor startupPolicyIconName equals: #smallCancel.
		self deny: editor startupPolicyIconPresenter image isNil.
		self assert: editor startupPolicyStatusPresenter notNil.
		self assert: editor startupPolicyPresenter help equals: editor startupPolicyHelpText.
		self assert: editor startupPolicyIconPresenter help equals: editor startupPolicyHelpText.
		self assert: editor startupPolicyButton help equals: editor startupPolicyHelpText.
		self assert: (editor startupPolicyHelpText includesSubstring: 'default macro file').
		self deny: (editor startupPolicyPresenter label includesSubstring: 'Script:').
		editor toggleStartupInstallation.
		self assert: ReplayMacroRegistry startupInstallationEnabled.
		self assert: editor startupPolicyPresenter label equals: 'Enabled'.
		self assert: editor startupPolicyButton label equals: 'Disable startup'.
		self assert: editor startupPolicyButton icon isNil.
		self assert: editor startupPolicyIconName equals: #smallOk.
		self deny: editor startupPolicyIconPresenter image isNil.
		editor toggleStartupInstallation.
		self deny: ReplayMacroRegistry startupInstallationEnabled.
		self assert: editor startupPolicyPresenter label equals: 'Disabled'.
		self assert: editor startupPolicyButton label equals: 'Enable startup'.
		self assert: editor startupPolicyButton icon isNil ]
		ensure: [ ReplayMacroRegistry disableStartupInstallation ]
]

{ #category : 'tests' }
ReplayMacroTest >> testMacroLibraryEditorTogglesStartupInstallPolicy [

	| editor |
	ReplayMacroRegistry disableStartupInstallation.
	editor := ReplayMacroLibraryEditor new.

	[
		self assert: editor startupPolicyPresenter label equals: 'Disabled'.
		editor enableStartupInstallation.
		self assert: ReplayMacroRegistry startupInstallationEnabled.
		self assert: editor startupPolicyPresenter label equals: 'Enabled'.
		self assert: editor startupPolicyButton label equals: 'Disable startup'.
		editor disableStartupInstallation.
		self deny: ReplayMacroRegistry startupInstallationEnabled.
		self assert: editor startupPolicyPresenter label equals: 'Disabled'.
		self assert: editor startupPolicyButton label equals: 'Enable startup' ]
		ensure: [ ReplayMacroRegistry disableStartupInstallation ]
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
ReplayMacroTest >> testMacroLibraryRemoveMacroUninstallsIt [

	| library macro |
	library := ReplayMacroLibrary new.
	macro := ReplayMacro
		named: 'Remove installed macro'
		shortcut: (ReplayShortcut new
			text: 'r';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	macro identifier: 'remove-installed-macro-test'.
	macro contextNames: { #RubTextEditor }.
	library addMacro: macro.
	[
		macro install.
		self assert: (macro installedInContextNamed: #RubTextEditor).
		library removeMacro: macro.
		self deny: (macro installedInContextNamed: #RubTextEditor) ]
		ensure: [ macro uninstall ]
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
ReplayMacroTest >> testMacroLibraryReusesMacroForSameScenario [

	| library scenario first second |
	library := ReplayMacroLibrary new.
	scenario := ReplayScenario new.
	first := library macroForScenario: scenario.
	second := library macroForScenario: scenario.

	self assert: first identicalTo: second.
	self assert: library macros size equals: 1
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
ReplayMacroTest >> testMacroPrintStringToleratesUnmappedShortcutCharacter [

	| character macro printString |
	character := Character value: 16rFFC3.
	macro := ReplayMacro
		named: 'Malformed shortcut'
		shortcut: (ReplayShortcut new
			text: (String with: character);
			yourself)
		scenario: ReplayScenario new.
	printString := macro printString.
	self assert: (printString includesSubstring: 'Malformed shortcut').
	self assert: (printString includesSubstring: 'Character value: 65475')
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
ReplayMacroTest >> testMacroRegistryLoadAndInstallClearsStaleInstalledMacros [

	| file registry oldMacro loadedMacro loadedLibrary |
	file := FileLocator temp / 'replay-macro-load-install-clears-stale-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	oldMacro := ReplayMacro
		named: 'Old macro'
		shortcut: (ReplayShortcut new
			text: 'o';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	oldMacro
		identifier: 'old-load-install-clear-test';
		contextNames: { #RubTextEditor }.
	loadedMacro := ReplayMacro
		named: 'Loaded macro'
		shortcut: (ReplayShortcut new
			text: 'l';
			addFlags: 16;
			yourself)
		scenario: ReplayScenario new.
	loadedMacro
		identifier: 'new-load-install-clear-test';
		contextNames: { #RubTextEditor }.
	loadedLibrary := ReplayMacroLibrary new
		addMacro: loadedMacro;
		yourself.

	[
		registry library addMacro: oldMacro.
		oldMacro install.
		file writeStreamDo: [ :stream | STON put: loadedLibrary onStreamPretty: stream ].
		registry loadAndInstallFromFile: file.
		self deny: (oldMacro installedInContextNamed: #RubTextEditor).
		self assert: (registry library macros first installedInContextNamed: #RubTextEditor).
		self assert: ReplayMacro installedKeymapCount equals: 1 ]
		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
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
ReplayMacroTest >> testMacroRegistryStartupPolicyInstallsOnlyWhenEnabled [

	| file registry macro loadedMacro |
	file := FileLocator temp / 'replay-macro-startup-policy-test.ston'.
	file ensureDelete.
	registry := ReplayMacroRegistry new.
	macro := registry library addNewMacro.
	macro
		identifier: 'startup-policy-test';
		name: 'Startup macro';
		contextNames: { #RubTextEditor };
		shortcut: (ReplayShortcut new
			text: 'f';
			addFlags: 16;
			yourself).

	[
		registry saveToFile: file.
		ReplayMacroRegistry disableStartupInstallation.
		registry := ReplayMacroRegistry new.
		registry installSavedMacrosOnStartupFromFile: file.
		loadedMacro := registry library macros first.
		self deny: (loadedMacro installedInContextNamed: #RubTextEditor).

		ReplayMacroRegistry enableStartupInstallation.
		registry := ReplayMacroRegistry new.
		registry installSavedMacrosOnStartupFromFile: file.
		loadedMacro := registry library macros first.
		self assert: (loadedMacro installedInContextNamed: #RubTextEditor) ]

		ensure: [
			ReplayMacroRegistry disableStartupInstallation.
			ReplayMacro uninstallAllInstalledKeymaps.
			file ensureDelete ]
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
	self assert: copy shortcut text equals: 's'.
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

	self assert: shortcut text equals: 's'.
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
ReplayMacroTest >> testReplayShortcutDisplayStringFallsBackForUnmappedCharacter [

	| character shortcut display |
	character := Character value: 16rFFC3.
	shortcut := ReplayShortcut new
		text: (String with: character);
		yourself.
	display := shortcut displayString.
	self assert: (display includesSubstring: 'Character value: 65475').
	self assert: (display includesSubstring: 'code 65475')
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
ReplayMacroTest >> testShortcutCaptureListenerUsesRecorderConversion [

	| event listener captured |
	event := ReplayShortcut new keyDown: $a buttons: 0.
	listener := ReplayShortcutCaptureListener
		onHand: nil
		do: [ :shortcut | captured := shortcut ].
	listener handleListenEvent: event.
	self assert: captured text equals: 'a'.
	self assert: captured flags equals: 0
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutConflictShowsReadableContextDisplayName [

	| category keymap conflict |
	category := KMRepository default categoryForName: #RubTextEditor.
	keymap := category keymapNamed: #find.
	conflict := ReplayShortcutConflict category: category keymap: keymap.

	self assert: conflict contextDisplayName equals: 'Text editors'
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutConflictUsesCommandDisplayForMetaShortcut [

	| category keymap conflict |
	category := KMRepository default categoryForName: #RubTextEditor.
	keymap := category keymapNamed: #find.
	conflict := ReplayShortcutConflict category: category keymap: keymap.

	self assert: conflict shortcutString equals: 'Command + F'
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutConflictUsesUserFacingKnownContextNames [

	| conflict |
	conflict := ReplayShortcutConflict
		category: (KMRepository default categoryForName: #RubTextEditor)
		keymap: (self findKeymapInCategoryNamed: #RubTextEditor).

	self assert: conflict contextDisplayName equals: 'Text editors'
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutKeysPresenterAddsAndRemovesKeys [

	| shortcut presenter changes leftChoice |
	changes := 0.
	shortcut := ReplayShortcut new.
	presenter := ReplayShortcutKeysPresenter
		on: shortcut
		whenChangedDo: [ changes := changes + 1 ].
	leftChoice := presenter keyDropList items detect: [ :association | association key = #left ].
	presenter keyDropList selectItem: leftChoice.
	presenter addSelectedKey.
	self assert: shortcut text equals: (String with: (Character arrowLeft)).
	self assert: changes equals: 1.
	presenter characterTextPresenter text: 'k'.
	presenter addCharacterText.
	self assert: shortcut text equals: (String with: (Character arrowLeft) with: $k).
	self assert: changes equals: 2.
	presenter keyList selectIndex: 1.
	presenter removeSelectedCharacter.
	self assert: shortcut text equals: 'k'.
	self assert: changes equals: 3
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutKeysPresenterCapturesNextShortcut [

	| shortcut presenter event listener |
	shortcut := ReplayShortcut new text: 'z'; yourself.
	presenter := ReplayShortcutKeysPresenter on: shortcut.
	event := ReplayShortcut new keyDown: $a buttons: 64.
	presenter startShortcutCapture.
	listener := presenter captureListener.
	self assert: listener isActive.
	listener handleListenEvent: event.
	self assert: shortcut text equals: 'a'.
	self assert: shortcut flags equals: 64.
	self assert: presenter captureListener isNil
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutKeysPresenterHasIconControls [

	| presenter |
	presenter := ReplayShortcutKeysPresenter on: ReplayShortcut new.
	self assert: presenter addKeyButton label equals: ''.
	self deny: presenter addKeyButton icon isNil.
	self assert: presenter addCharacterButton label equals: ''.
	self deny: presenter addCharacterButton icon isNil.
	self deny: presenter removeKeyButton icon isNil.
	self assert: (presenter removeKeyButton help includesSubstring: 'Delete').
	self assert: presenter captureShortcutButton label equals: 'Set from next shortcut'
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutKeysPresenterShowsSpecialCharacters [

	| shortcut presenter display |
	shortcut := ReplayShortcut new
		text: (String with: (Character arrowLeft) with: $k);
		yourself.
	presenter := ReplayShortcutKeysPresenter on: shortcut.
	display := presenter displayStringForCharacter: presenter keyList items first.
	self assert: presenter keyList items asArray equals: { (Character arrowLeft). $k }.
	self assert: (display includesSubstring: 'Left Arrow').
	self assert: (display includesSubstring: 'Character arrowLeft')
]

{ #category : 'tests' }
ReplayMacroTest >> testShortcutKeysPresenterUsesShortcut [

	| shortcut presenter captured |
	shortcut := ReplayShortcut new.
	presenter := ReplayShortcutKeysPresenter on: shortcut.
	captured := ReplayShortcut new
		text: 'f';
		flags: 64;
		yourself.
	presenter useShortcut: captured.
	self assert: shortcut text equals: 'f'.
	self assert: shortcut flags equals: 64
]

{ #category : 'support' }
ReplayMacroTest >> textEditingMorphIn: aMorph [

	^ aMorph allMorphs
		detect: [ :each | (ReplayMacroContext categoryNamesForMorph: each) includes: #RubTextEditor ]
		ifNone: [ self fail: 'Expected a nested Rubric text editor morph.' ]
]
