"
I test ReplayMacroEditor, the settings pane of a library macro: key binding, install contexts, installation and conflicts.
"
Class {
	#name : 'ReplayMacroEditorTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroEditorTest >> conflictingMacro [
	"A macro bound to the shortcut of an existing Smalltalk editor keymap"

	| keymap macro |
	keymap := (KMRepository default categoryForName: #RubSmalltalkEditor) allEntries keymaps anyOne.
	macro := self macroNamed: 'Conflicting macro' keyBinding: (ReplayKeyBinding fromKeymap: keymap).
	macro contextNames: { #RubSmalltalkEditor }.
	^ macro
]

{ #category : 'support' }
ReplayMacroEditorTest >> installableMacro [
	"A macro bound to Control+F in text editors"

	| macro |
	macro := self macroNamed: 'Find macro' keyBinding: (self controlShortcut: 'f').
	macro contextNames: { #RubTextEditor }.
	^ macro
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testAddsAndRemovesInstallContexts [

	| macro editor textContext morphicContext |
	macro := self macroNamed: 'Context macro'.
	editor := self editorOn: macro.
	textContext := editor contextDropList items detect: [ :context | context identifier = #textEditors ].
	morphicContext := editor contextDropList items detect: [ :context | context identifier = #morphicNavigation ].
	editor contextDropList selectItem: textContext.
	editor addSelectedContext.
	self assert: macro contextNames asArray equals: { #RubTextEditor }.
	self assert: editor contextList items asArray equals: { #RubTextEditor }.
	editor contextDropList selectItem: morphicContext.
	editor addSelectedContext.
	self assert: (macro contextNames includes: #MorphCtrlNavigation).
	editor contextList selectItem: #RubTextEditor.
	editor removeSelectedContext.
	self deny: (macro contextNames includes: #RubTextEditor).
	self assert: editor contextList items asArray equals: { #MorphCtrlNavigation }.
	editor clearContexts.
	self assert: macro contextNames isEmpty.
	self assert: editor contextList items isEmpty
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testAddsAnywhereInstallContext [

	| macro editor anyContext |
	macro := self macroNamed: 'Everywhere macro'.
	editor := self editorOn: macro.
	anyContext := editor contextDropList items detect: [ :context | context identifier = #anywhere ].
	editor contextDropList selectItem: anyContext.
	editor addSelectedContext.
	self assert: (macro contextNames includes: #RubTextEditor).
	self assert: (macro contextNames includes: #MorphCtrlNavigation).
	self assert: (macro contextNames includes: #WindowShortcuts).
	self assert: (editor contextList items includes: #RubTextEditor).
	self deny: (macro contextNames anySatisfy: [ :categoryName |
			 categoryName asString beginsWith: 'Replay' ])
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testBuildsAndRefreshesConflicts [

	| editor |
	editor := self editorOn: self conflictingMacro.
	self assert: editor contextList items asArray equals: { #RubSmalltalkEditor }.
	self assert: editor conflictList items isNotEmpty.
	self assert: editor conflictWarningIconPresenter image equals: (editor iconNamed: #warning).
	self assert: (editor conflictWarningIconPresenter help includesSubstring: 'conflict')
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testCanUninstallMacro [

	| macro editor |
	macro := self installableMacro.
	editor := self editorOn: macro.
	editor installMacro.
	self assert: (macro installedInContextNamed: #RubTextEditor).
	self assert: (editor installationStatusPresenter label includesSubstring: 'Text editor').
	editor uninstallMacro.
	self deny: (macro installedInContextNamed: #RubTextEditor).
	self assert: editor installationStatusPresenter label equals: 'Not installed.'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testConflictHelpNamesConflictingContexts [

	| shortcut macro editor |
	shortcut := ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers command.
	self
		withKeymapNamed: #replayTestFind
		shortcut: shortcut asKMShortcut
		inCategoryNamed: #RubTextEditor
		during: [
			macro := self macroNamed: 'Find macro' keyBinding: shortcut.
			macro contextNames: { #RubSmalltalkEditor }.
			editor := self editorOn: macro.

			self assert: (editor conflictList items anySatisfy: [ :each |
					 each categoryName = #RubTextEditor and: [ each name = #replayTestFind ] ]).
			self assert: (editor conflictWarningIconPresenter help includesSubstring: 'Text editors').
			self deny: (editor conflictWarningIconPresenter help includesSubstring: 'RubTextEditor') ]
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testConflictsIgnoreInstalledKeymapsOfTheLibrary [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First' keyBinding: (self controlShortcut: 'f')).
	first contextNames: { #ReplayMacroEditorTest }.
	second := library addMacro: (self macroNamed: 'Second' keyBinding: (self controlShortcut: 'f')).
	second contextNames: { #ReplayMacroEditorTest }.
	library install.
	editor := ReplayMacroEditor on: first inLibrary: library.

	self assert: editor conflictList items size equals: 1.
	self assert: editor conflictList items first name equals: 'Second'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testDisablesInstallUntilBindingAndContext [

	| macro editor |
	macro := self macroNamed: 'Editor install requirements macro'.
	editor := self editorOn: macro.

	self deny: editor installButton isEnabled.
	self assert: (editor installButton help includesSubstring: 'key binding').
	self assert: editor keyBindingRequirementIconPresenter image equals: (editor iconNamed: #cancel).
	self assert: editor contextRequirementIconPresenter image equals: (editor iconNamed: #cancel).

	macro keyBinding: (ReplayKeyBinding character: $r modifiers: 0).
	editor macroChanged.
	self deny: editor installButton isEnabled.
	self assert: (editor installButton help includesSubstring: 'install context').
	self assert: editor keyBindingRequirementIconPresenter image equals: (editor iconNamed: #accept).
	self assert: editor contextRequirementIconPresenter image equals: (editor iconNamed: #cancel).

	macro contextNames: { #RubTextEditor }.
	editor macroChanged.
	self assert: editor installButton isEnabled.
	self assert: (editor installButton help includesSubstring: 'Install macro').
	self assert: editor keyBindingRequirementIconPresenter image equals: (editor iconNamed: #accept).
	self assert: editor contextRequirementIconPresenter image equals: (editor iconNamed: #accept)
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testInstallButtonFitsUninstallLabel [

	| editor buttonMorph |
	editor := self editorOn: self installableMacro.
	editor build.
	editor installMacro.
	editor installButton withAdapterDo: [ :adapter | buttonMorph := adapter widget ].

	self assert: editor installButton label equals: 'Uninstall macro'.
	self assert: buttonMorph extent x >= 125.
	self assert: buttonMorph extent x <= 140
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testInstallButtonTogglesInstallation [

	| macro editor |
	macro := self installableMacro.
	editor := self editorOn: macro.

	self assert: editor installButton label equals: 'Install macro'.
	self assert: editor installButton icon equals: (editor iconNamed: #accept).
	editor toggleMacroInstallation.
	self assert: (macro installedInContextNamed: #RubTextEditor).
	self assert: editor installButton label equals: 'Uninstall macro'.
	self assert: editor installButton icon equals: (editor iconNamed: #cancel).
	editor toggleMacroInstallation.
	self deny: (macro installedInContextNamed: #RubTextEditor).
	self assert: editor installButton label equals: 'Install macro'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testInstallDoesNotInstallWithoutBinding [

	| macro editor |
	macro := self macroNamed: 'Editor no binding macro'.
	macro contextNames: { #RubTextEditor }.
	editor := self editorOn: macro.
	editor installMacro.

	self deny: macro isInstalled.
	self deny: editor installButton isEnabled
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testMovesInstalledMacroWhenContextChanges [

	| macro editor codeContext |
	macro := self installableMacro.
	editor := self editorOn: macro.
	editor installMacro.
	codeContext := editor contextDropList items detect: [ :context | context identifier = #smalltalkEditors ].
	editor contextDropList selectItem: codeContext.
	editor addSelectedContext.
	self assert: (macro installedInContextNamed: #RubSmalltalkEditor).
	editor contextList selectItem: #RubTextEditor.
	editor removeSelectedContext.

	self deny: (macro installedInContextNamed: #RubTextEditor).
	self assert: (macro installedInContextNamed: #RubSmalltalkEditor)
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testNotifiesSettingChanges [

	| editor changes |
	editor := self editorOn: self installableMacro.
	changes := 0.
	editor whenMacroChangedDo: [ changes := changes + 1 ].
	editor keyBindingPresenter keyBinding: (ReplayKeyBinding character: $g modifiers: 0).
	editor keyBindingPresenter modifiersPresenter shiftCheckBox toggleState.
	editor clearContexts.
	editor installMacro.

	self assert: changes equals: 4
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testSelectsNextContextAfterRemoval [

	| macro editor |
	macro := self macroNamed: 'Context selection macro'.
	macro contextNames: { #RubTextEditor. #WindowShortcuts. #MorphCtrlNavigation }.
	editor := self editorOn: macro.
	editor contextList selectIndex: 2.
	editor removeSelectedContext.

	self assert: editor contextList items asArray equals: { #RubTextEditor. #MorphCtrlNavigation }.
	self assert: editor contextList selectedItem equals: #MorphCtrlNavigation
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testSemanticNames [

	| editor |
	editor := self editorOn: (self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command)).
	{
		'Key binding' -> editor keyBindingPresenter.
		'Key binding label' -> editor keyBindingLabelPresenter.
		'Shift modifier' -> editor keyBindingPresenter modifiersPresenter shiftCheckBox.
		'Control modifier' -> editor keyBindingPresenter modifiersPresenter controlCheckBox.
		'Alt modifier' -> editor keyBindingPresenter modifiersPresenter altCheckBox.
		'Command modifier' -> editor keyBindingPresenter modifiersPresenter commandCheckBox.
		'Install context picker' -> editor contextDropList.
		'Add install context button' -> editor contextAddButton.
		'Install context list' -> editor contextList.
		'Remove install context button' -> editor contextRemoveButton.
		'Clear install contexts button' -> editor contextClearButton.
		'Installation status' -> editor installationStatusPresenter.
		'Conflict warning icon' -> editor conflictWarningIconPresenter.
		'Conflict list' -> editor conflictList.
		'Install button' -> editor installButton.
		'Shortcut key list' -> editor keyBindingPresenter keyList } do: [ :association |
		self
			assert: (editor replayPresenterAt: association key ifAbsent: [ nil ])
			identicalTo: association value ].
	#( 'Macro name' 'Action command' 'Shortcut command' 'Conflict status' 'Install macro button' ) do: [ :name |
		self assert: (editor replayPresenterAt: name ifAbsent: [ #missing ]) equals: #missing ]
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testShowsNoConflictsWithoutInstallContexts [

	| macro editor |
	macro := self conflictingMacro.
	macro contextNames: #(  ).
	editor := self editorOn: macro.

	self assert: editor contextList items isEmpty.
	self assert: editor conflictList items isEmpty.
	self assert: editor conflictWarningIconPresenter image equals: (editor iconNamed: #accept)
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testShowsSmalltalkFindConflictFromBaseTextContext [

	| macro editor |
	macro := self macroNamed: 'Smalltalk find replacement' keyBinding: self defaultFindShortcut.
	macro contextNames: { #RubSmalltalkEditor }.
	editor := self editorOn: macro.

	self assert: (editor conflictList items anySatisfy: [ :conflict |
			 conflict categoryName = #RubTextEditor and: [ conflict name = #find ] ])
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testShowsStoredShortcut [

	| macro editor modifiers |
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	editor := self editorOn: macro.

	self assert: editor keyBindingPresenter keyBinding equals: macro keyBinding.
	modifiers := editor keyBindingPresenter modifiersPresenter.
	self assert: modifiers commandCheckBox state.
	self deny: modifiers controlCheckBox state.
	self deny: modifiers altCheckBox state.
	self deny: modifiers shiftCheckBox state
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testShowsLibraryInternalConflicts [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First' keyBinding: (ReplayKeyBinding fromKMCombination: $s command)).
	first addContextNamed: #ReplayMacroContext.
	second := library addMacro: (self macroNamed: 'Second' keyBinding: (ReplayKeyBinding fromKMCombination: $s command)).
	second addContextNamed: #ReplayMacroContext.
	editor := ReplayMacroEditor on: first inLibrary: library.

	self assert: (editor conflictList items anySatisfy: [ :each |
			 each name = 'Second' and: [ each categoryName = #ReplayMacroContext ] ])
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testSummarizesInstalledContextsWithFullHelp [

	| macro editor |
	macro := self macroNamed: 'Many context macro' keyBinding: (self controlShortcut: 'm').
	macro contextNames: { #RubTextEditor. #MorphCtrlNavigation. #WindowShortcuts }.
	editor := self editorOn: macro.
	editor installMacro.

	self assert: (editor installationStatusPresenter label includesSubstring: '+1 more').
	self assert: (editor installationStatusPresenter help includesSubstring: 'Text editor').
	self assert: (editor installationStatusPresenter help includesSubstring: 'Morphic navigation').
	self assert: (editor installationStatusPresenter help includesSubstring: 'Windows').
	self deny: (editor installationStatusPresenter help includesSubstring: '+1 more')
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUpdatesInstallationStatusHelpAfterInstall [

	| editor |
	editor := self editorOn: self installableMacro.

	self assert: editor installationStatusPresenter help equals: 'No installed contexts.'.
	editor installMacro.
	self assert: (editor installationStatusPresenter label includesSubstring: 'Installed in:').
	self assert: (editor installationStatusPresenter help includesSubstring: 'Text editor').
	editor uninstallMacro.
	self assert: editor installationStatusPresenter label equals: 'Not installed.'.
	self assert: editor installationStatusPresenter help equals: 'No installed contexts.'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUpdatesInstalledMacroWhenShortcutChanges [

	| macro editor keymap |
	macro := self installableMacro.
	editor := self editorOn: macro.
	editor installMacro.
	editor keyBindingPresenter keyBinding: (self controlShortcut: 'g').

	keymap := (KMRepository default categoryForName: #RubTextEditor) allEntries keymaps detect: [ :each |
		          macro isOwnKeymap: each ].
	self assert: keymap shortcut asString equals: 'Ctrl + G'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUpdatesShortcutModifier [

	| macro editor |
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding character: $s modifiers: 0).
	editor := self editorOn: macro.

	editor keyBindingPresenter modifiersPresenter commandCheckBox toggleState.
	self assert: macro keyBinding equals: (ReplayKeyBinding character: $s modifiers: ReplayKeyModifiers command).
	self assert: macro keyBinding asKMShortcut asString equals: 'Cmd + S'.
	editor keyBindingPresenter modifiersPresenter commandCheckBox toggleState.
	self assert: macro keyBinding equals: (ReplayKeyBinding character: $s modifiers: 0)
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUpdatesShortcutText [

	| macro editor |
	macro := self macroNamed: 'Save macro' keyBinding: (ReplayKeyBinding fromKMCombination: $s command).
	editor := self editorOn: macro.

	editor keyBindingPresenter keyBinding: (ReplayKeyBinding character: $d modifiers: ReplayKeyModifiers command).

	self assert: macro keyBinding equals: (ReplayKeyBinding fromKMCombination: $d command).
	self assert: macro keyBinding asKMShortcut asString equals: 'Cmd + D'
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUsesAcceptIconWithoutConflicts [

	| macro editor |
	macro := self macroNamed: 'No conflict macro' keyBinding: (self controlShortcut: 'z').
	macro contextNames: { #ReplayMacroTestNoConflict }.
	editor := self editorOn: macro.

	self assert: editor conflictList items isEmpty.
	self assert: editor conflictWarningIconPresenter image equals: (editor iconNamed: #accept).
	self assert: (editor conflictWarningIconPresenter help includesSubstring: 'No shortcut conflicts')
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUsesMacroContexts [

	| editor textContext |
	editor := self editorOn: (self macroNamed: 'Contexts').
	textContext := editor contextDropList items detect: [ :context | context identifier = #textEditors ].

	self assert: textContext displayName equals: 'Text editors'.
	self assert: textContext categoryNames asArray equals: { #RubTextEditor }
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUsesQuestionIconWithoutBinding [

	| macro editor |
	macro := self macroNamed: 'No binding macro'.
	macro contextNames: { #RubTextEditor }.
	editor := self editorOn: macro.

	self assert: editor conflictWarningIconPresenter image equals: (editor iconNamed: #smallQuestion).
	self assert: (editor conflictWarningIconPresenter help includesSubstring: 'Enter a key binding')
]

{ #category : 'tests' }
ReplayMacroEditorTest >> testUsesKeyBindingPresenter [

	| macro editor |
	macro := self
		         macroNamed: 'Branch macro'
		         keyBinding: (ReplayKeyBinding character: Character arrowRight modifiers: ReplayKeyModifiers command).
	editor := self editorOn: macro.

	self assert: editor keyBindingLabelPresenter label equals: 'Key binding:'.
	self assert: (editor keyBindingLabelPresenter help includesSubstring: 'trigger').
	self assert: editor keyBindingPresenter class equals: ReplayKeyBindingPresenter.
	self assert: editor keyBindingPresenter keyBinding equals: macro keyBinding.
	self assert: editor keyBindingPresenter keyList items asArray equals: macro keyBinding chords.
	self assert: editor keyBindingPresenter modifiersPresenter commandCheckBox state
]
