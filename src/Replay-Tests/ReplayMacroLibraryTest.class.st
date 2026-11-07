"
I test ReplayMacroLibrary: adding, naming and removing macros, importing them, installing them together, and conflicts between them.
"
Class {
	#name : 'ReplayMacroLibraryTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroLibraryTest >> libraryWithTwoSaveMacrosIn: firstContext and: secondContext [

	| library |
	library := ReplayMacroLibrary new.
	(library addMacro: (self macroNamed: 'First' shortcut: (ReplayShortcut fromShortcut: $s command)))
		addContextNamed: firstContext.
	(library addMacro: (self macroNamed: 'Second' shortcut: (ReplayShortcut fromShortcut: $s command)))
		addContextNamed: secondContext.
	^ library
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testAddMacroForScenarioIsNamedAfterIt [

	| library scenario macro |
	library := ReplayMacroLibrary new.
	scenario := ReplayScenario new
		            title: 'Format method';
		            yourself.
	macro := library addMacroForScenario: scenario.

	self assert: library macros asArray equals: { macro }.
	self assert: macro scenario identicalTo: scenario.
	self assert: macro name equals: 'Format method'.
	self assert: (library macroWithScenario: scenario) identicalTo: macro.
	self assert: (library macroWithScenario: ReplayScenario new) isNil
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testAddsAndRemovesMacros [

	| library first second |
	library := ReplayMacroLibrary new.
	first := library addNewMacro.
	second := library addMacro: (self macroNamed: 'Second').

	self assert: library macros asArray equals: { first. second }.
	library removeMacro: first.
	self assert: library macros asArray equals: { second }
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testAggregatesConflicts [

	| keymap macro library |
	keymap := (KMRepository default categoryForName: #RubSmalltalkEditor) allEntries keymaps anyOne.
	macro := self macroNamed: 'Conflicting' shortcut: (ReplayShortcut fromKeymap: keymap).
	macro contextNames: { #RubSmalltalkEditor }.
	library := ReplayMacroLibrary new.
	library addMacro: macro.

	self assert: (library conflicts anySatisfy: [ :conflict | conflict keymap = keymap ])
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testDetectsInternalConflictAcrossCompositeEditorContext [

	| smalltalkMacro textMacro library |
	smalltalkMacro := self macroNamed: 'Smalltalk macro' shortcut: self defaultFindShortcut.
	smalltalkMacro contextNames: { #RubSmalltalkEditor }.
	textMacro := self macroNamed: 'Text macro' shortcut: self defaultFindShortcut.
	textMacro contextNames: { #RubTextEditor }.
	library := ReplayMacroLibrary new.
	library
		addMacro: smalltalkMacro;
		addMacro: textMacro.

	self assert: (library internalConflicts anySatisfy: [ :conflict |
			 conflict contextDisplayName = 'Smalltalk code editors' and: [ conflict name = 'Text macro' ] ])
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testDetectsInternalConflicts [

	| conflicts |
	conflicts := (self libraryWithTwoSaveMacrosIn: #ReplayMacroContext and: #ReplayMacroContext) internalConflicts.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne categoryName equals: #ReplayMacroContext.
	self assert: conflicts anyOne name equals: 'Second'
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testIgnoresInternalConflictsInDifferentContexts [

	self assert: (self libraryWithTwoSaveMacrosIn: #ReplayMacroContextA and: #ReplayMacroContextB) internalConflicts isEmpty
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testImportMacroKeepsIdentifiersUnique [

	| library first imported other otherIdentifier |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First').
	imported := STON fromString: (STON toString: first).
	other := self macroNamed: 'Other'.
	otherIdentifier := other identifier.
	library importMacro: imported.
	library importMacro: other.

	self assert: library macros size equals: 3.
	self deny: imported identifier equals: first identifier.
	self assert: imported name equals: 'First'.
	self assert: other identifier equals: otherIdentifier
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testInstallAndUninstallAllMacros [

	| library first second |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First' shortcut: (self controlShortcut: 'f')).
	first contextNames: { #RubTextEditor }.
	second := library addMacro: (self macroNamed: 'Second' shortcut: (self controlShortcut: 'g')).
	second contextNames: { #RubTextEditor }.

	library install.
	self assert: library installedMacroCount equals: 2.
	library uninstall.
	self assert: library installedMacroCount equals: 0.
	self deny: first isInstalled
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testInstallsOnStartupIsSavedOnlyWhenSet [

	| library |
	library := ReplayMacroLibrary new.
	self deny: library installsOnStartup.
	self deny: ((STON toString: library) includesSubstring: 'installsOnStartup').
	library installsOnStartup: true.
	self assert: (STON fromString: (STON toString: library)) installsOnStartup.
	library installsOnStartup: false.
	self deny: ((STON toString: library) includesSubstring: 'installsOnStartup')
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testInternalConflictsForMacro [

	| library conflicts |
	library := self libraryWithTwoSaveMacrosIn: #ReplayMacroContext and: #ReplayMacroContext.
	conflicts := library internalConflictsForMacro: library macros first.

	self assert: conflicts size equals: 1.
	self assert: conflicts anyOne name equals: 'Second'
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testNamesNewMacros [

	| library first second |
	library := ReplayMacroLibrary new.
	first := library addNewMacro.
	second := library addNewMacro.

	self assert: first name equals: 'Macro 1'.
	self assert: first scenario title equals: 'Macro 1'.
	self assert: second name equals: 'Macro 2'
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testRemoveMacroUninstallsIt [

	| library macro |
	library := ReplayMacroLibrary new.
	macro := library addMacro: (self macroNamed: 'Remove installed macro' shortcut: (self controlShortcut: 'r')).
	macro contextNames: { #RubTextEditor }.
	macro install.
	self assert: (macro installedInContextNamed: #RubTextEditor).

	library removeMacro: macro.
	self deny: (macro installedInContextNamed: #RubTextEditor)
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testReportsInstalledMacros [

	| library installed |
	library := ReplayMacroLibrary new.
	installed := library addMacro: (self macroNamed: 'Installed' shortcut: (self controlShortcut: 'f')).
	installed contextNames: { #RubTextEditor }.
	library addMacro: (self macroNamed: 'Uninstalled').
	installed install.

	self assert: library installedMacros asArray equals: { installed }.
	self assert: library installedMacroCount equals: 1
]

{ #category : 'tests' }
ReplayMacroLibraryTest >> testReusesFirstAvailableMacroName [

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
ReplayMacroLibraryTest >> testRoundTripsThroughSton [

	| library copy |
	library := ReplayMacroLibrary new.
	library addMacro: (self macroNamed: 'Save macro' shortcut: (ReplayShortcut fromShortcut: $s command)).

	copy := STON fromString: (STON toString: library).

	self assert: copy macros size equals: 1.
	self assert: copy macros first name equals: 'Save macro'.
	self assert: copy macros first shortcut asKMShortcut asString equals: 'Cmd + S'
]
