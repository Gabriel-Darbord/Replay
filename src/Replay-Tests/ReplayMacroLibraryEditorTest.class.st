"
I test the library window (ReplayMacroLibraryEditor) and the library side of ReplayEditor: the scenario editor embedded on the selected macro, and Add to library from a standalone editor.
"
Class {
	#name : 'ReplayMacroLibraryEditorTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroLibraryEditorTest >> displayedLabelsOf: anEditor [
	"The strings shown by the macro list of an open library window"

	| strings |
	strings := OrderedCollection new.
	anEditor macroList list withAdapterDo: [ :adapter |
		adapter widget allMorphsDo: [ :morph |
			(morph isKindOf: StringMorph) ifTrue: [ strings add: morph contents asString ] ] ].
	^ strings
]

{ #category : 'support' }
ReplayMacroLibraryEditorTest >> editorOnFile [
	"A library editor whose registry saves to a temporary file"

	^ ReplayMacroLibraryEditor onRegistry: (ReplayMacroRegistry new
			   file: self temporaryFile;
			   yourself)
]

{ #category : 'support' }
ReplayMacroLibraryEditorTest >> savedMacroNamesOf: anEditor [

	^ ((ReplayMacroRegistry libraryFromFile: anEditor registry file) macros collect: [ :macro | macro name ]) asArray
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testAddMacroSavesAndSelectsIt [

	| editor macro |
	editor := self editorOnFile.
	macro := editor addMacro.

	self assert: editor library macros asArray equals: { macro }.
	self assert: editor macroList items asArray equals: { macro }.
	self assert: editor selectedMacro identicalTo: macro.
	self assert: (self savedMacroNamesOf: editor) equals: #( 'Macro 1' )
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testAddToLibrarySavesTheDefaultLibrary [

	| registry scenario editor |
	registry := ReplayMacroRegistry new
		            file: self temporaryFile;
		            yourself.
	ReplayMacroRegistry default: registry.
	scenario := ReplayScenario new
		            title: 'Added scenario';
		            yourself.
	editor := ReplayEditor on: scenario.
	editor open.
	editor shortcutButton click.

	self assert: (registry library macroWithScenario: scenario) notNil.
	self
		assert: ((ReplayMacroRegistry libraryFromFile: registry file) macros collect: [ :macro | macro name ]) asArray
		equals: #( 'Added scenario' )
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testBuilds [

	| library editor |
	library := ReplayMacroLibrary new.
	library addMacro: (self macroNamed: 'Format method').
	editor := ReplayMacroLibraryEditor on: library.

	self assert: editor macroList items size equals: 1.
	self assert: editor selectedMacro identicalTo: library macros first.
	self assert: editor installationSummaryPresenter label equals: '0 / 1 macro installed'.
	self assert: editor installAllButton label equals: 'Install all'.
	self assert: editor installOnStartupCheckBox label equals: 'Install on startup'.
	self deny: editor installOnStartupCheckBox state.
	self shouldnt: [ editor build ] raise: Error
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testEditsSelectedMacroScenario [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addNewMacro.
	editor := ReplayMacroLibraryEditor on: library.
	editor showMacro: macro.

	self assert: editor scenarioEditor isInLibrary.
	self assert: editor scenarioEditor macro identicalTo: macro.
	self assert: editor scenarioEditor scenario identicalTo: macro scenario.
	self assert: editor scenarioEditor shortcutButton label equals: 'Edit shortcut'.
	self assert: editor macroEditor macro identicalTo: macro.
	self assert: editor macroEditor macroLibrary identicalTo: library
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testImportReportsBadStonWithoutChangingTheLibrary [

	| editor |
	editor := self editorOnFile.
	editor addMacro.

	self assert: (editor importString: 'ReplayMacro {') isEmpty.
	self assert: (editor importString: (STON toString: ReplayScenario new)) isEmpty.
	self assert: editor library macros size equals: 1.
	self assert: editor macroList items size equals: 1
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testImportSavesTheImportedMacros [

	| editor library imported |
	editor := self editorOnFile.
	library := ReplayMacroLibrary new.
	library addMacro: (self macroNamed: 'First').
	library addMacro: (self macroNamed: 'Second').
	imported := editor importString: (STON toString: library).

	self assert: editor library macros size equals: 2.
	self assert: editor macroList items size equals: 2.
	self assert: editor selectedMacro identicalTo: imported last.
	self assert: editor installationSummaryPresenter label equals: '0 / 2 macros installed'.
	self assert: (self savedMacroNamesOf: editor) equals: #( 'First' 'Second' )
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testInstallOnStartupCheckBoxSavesTheLibrary [

	| editor |
	editor := self editorOnFile.
	editor installOnStartupCheckBox state: true.

	self assert: editor library installsOnStartup.
	self assert: (ReplayMacroRegistry libraryFromFile: editor registry file) installsOnStartup.
	editor installOnStartupCheckBox state: false.
	self deny: (ReplayMacroRegistry libraryFromFile: editor registry file) installsOnStartup
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testInstallationSummaryUpdatesWhenSelectedMacroInstalls [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addMacro: (self macroNamed: 'Summary macro' shortcut: (self controlShortcut: 'f')).
	macro contextNames: { #RubTextEditor }.
	editor := ReplayMacroLibraryEditor on: library.

	self assert: editor installationSummaryPresenter label equals: '0 / 1 macro installed'.
	editor macroEditor installMacro.
	self assert: editor installationSummaryPresenter label equals: '1 / 1 macro installed'.
	self assert: editor installAllButton label equals: 'Uninstall all'
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testListAddButtonAddsThroughTheLibrary [

	| library editor |
	library := ReplayMacroLibrary new.
	editor := ReplayMacroLibraryEditor on: library.

	editor macroList addButton click.

	self assert: library macros size equals: 1.
	self assert: editor macroList items asArray equals: library macros asArray.
	self deny: editor macroList items identicalTo: library macros.
	self assert: editor selectedMacro identicalTo: library macros first.
	self assert: editor installationSummaryPresenter label equals: '0 / 1 macro installed'
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testListLabelFollowsShortcutChange [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addNewMacro.
	editor := ReplayMacroLibraryEditor on: library.
	editor open.
	self waitUntil: [ (self displayedLabelsOf: editor) includes: 'Macro 1' ].

	editor scenarioEditor editShortcut.
	editor macroEditor keyBindingPresenter text: 'k'.

	self waitUntil: [ (self displayedLabelsOf: editor) includes: macro printString ].
	self deny: ((self displayedLabelsOf: editor) includes: 'Macro 1')
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testListLabelAndKeymapsFollowTitleChange [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addMacro: (self macroNamed: 'Before' shortcut: (self controlShortcut: 'f')).
	macro contextNames: { #ReplayMacroLibraryEditorTest }.
	macro install.
	editor := ReplayMacroLibraryEditor on: library.
	editor open.
	self waitUntil: [ (self displayedLabelsOf: editor) anySatisfy: [ :each | each beginsWith: 'Before' ] ].

	editor scenarioEditor editScenarioData.
	(editor replayPresenterAt: 'Scenario title' ifAbsent: [ nil ]) text: 'After'.

	self assert: macro name equals: 'After'.
	self assert: macro installedKeymaps first description equals: 'Replay macro: After'.
	self waitUntil: [ (self displayedLabelsOf: editor) anySatisfy: [ :each | each beginsWith: 'After' ] ]
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testMacroSettingsChangeSavesTheLibrary [

	| editor macro |
	editor := self editorOnFile.
	macro := editor addMacro.
	editor scenarioEditor editShortcut.
	editor macroEditor keyBindingPresenter text: 'k'.

	self
		assert: (ReplayMacroRegistry libraryFromFile: editor registry file) macros first shortcut text
		equals: 'k'
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testMovingScenarioToLibraryKeepsOneEditor [

	| registry scenario editor macro libraryEditors |
	registry := ReplayMacroRegistry new.
	scenario := ReplayScenario new
		            title: 'Moved scenario';
		            yourself.
	editor := ReplayEditor on: scenario.
	editor open.
	macro := editor moveToLibraryOf: registry.
	libraryEditors := ReplayMacroLibraryEditor openInstances select: [ :each | each registry == registry ].

	self assert: macro scenario identicalTo: scenario.
	self assert: macro name equals: 'Moved scenario'.
	self assert: registry library macros asArray equals: { macro }.
	self deny: (ReplayEditor openInstances includes: editor).
	self assert: libraryEditors size equals: 1.
	self assert: libraryEditors first selectedMacro identicalTo: macro.
	self assert: (ReplayMacroLibraryEditor openOnRegistry: registry) identicalTo: libraryEditors first.
	self assert: (editor moveToLibraryOf: registry) identicalTo: macro.
	self assert: registry library macros size equals: 1
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testOpenShowsTheDefaultLibraryOnce [

	| editor |
	editor := ReplayMacroLibraryEditor open.

	self assert: editor registry identicalTo: ReplayMacroRegistry default.
	self assert: ReplayMacroLibraryEditor open identicalTo: editor.
	self assert: (self newWindowsLabeled: 'Replay Library') size equals: 1
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testOpenOnScenarioOfTheDefaultLibraryShowsTheLibraryWindow [

	| macro editor |
	macro := ReplayMacroRegistry default library addNewMacro.
	editor := ReplayEditor openOn: macro scenario.

	self assert: (editor isKindOf: ReplayMacroLibraryEditor).
	self assert: editor selectedMacro identicalTo: macro
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testOpensWithUnmappedShortcutCharacter [

	| macro library editor |
	macro := self macroNamed: 'Stored malformed shortcut' shortcut: (ReplayShortcut new
			          text: (String with: (Character value: 16rFFC3));
			          yourself).
	library := ReplayMacroLibrary new.
	library addMacro: macro.
	editor := ReplayMacroLibraryEditor on: library.

	self assert: editor macroList items first identicalTo: macro.
	self shouldnt: [ editor macroList items first printString ] raise: Error
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testRemoveMacroSavesAndSelectsTheNextOne [

	| editor first second |
	editor := self editorOnFile.
	first := editor addMacro.
	second := editor addMacro.
	editor showMacro: first.
	editor removeMacro: first.

	self assert: editor library macros asArray equals: { second }.
	self assert: editor selectedMacro identicalTo: second.
	self assert: (self savedMacroNamesOf: editor) equals: #( 'Macro 2' )
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testRemoveMacroUninstallsIt [

	| library macro editor |
	library := ReplayMacroLibrary new.
	macro := library addMacro: (self macroNamed: 'Removed' shortcut: (self controlShortcut: 'r')).
	macro contextNames: { #RubTextEditor }.
	macro install.
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList removeButton click.

	self deny: macro isInstalled.
	self assert: library macros isEmpty.
	self assert: editor scenarioEditor isNil.
	self assert: editor installationSummaryPresenter label equals: '0 / 0 macros installed'
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testRemovesUnselectedMacro [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First').
	second := library addMacro: (self macroNamed: 'Second').
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList selectIndex: 2.
	editor removeMacro: first.

	self assert: library macros asArray equals: { second }.
	self assert: editor selectedMacro identicalTo: second
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testScenarioEditorReplacesMacroScenario [

	| library macro editor imported |
	library := ReplayMacroLibrary new.
	macro := library addNewMacro.
	editor := ReplayMacroLibraryEditor on: library.
	imported := ReplayScenario new
		            title: 'Imported';
		            yourself.
	editor scenarioEditor scenario: imported.

	self assert: macro scenario identicalTo: imported.
	self assert: macro name equals: 'Imported'.
	self assert: editor scenarioEditor scenario identicalTo: imported
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testScenarioEditorOpensOncePerScenario [

	| scenario editor |
	scenario := ReplayScenario new.
	editor := ReplayEditor openOn: scenario.

	self assert: (ReplayEditor openOn: scenario) identicalTo: editor.
	self assert: (ReplayEditor openInstances select: [ :each | each scenario == scenario ]) size equals: 1
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testSemanticNames [

	| library editor |
	library := ReplayMacroLibrary new.
	library addNewMacro.
	editor := ReplayMacroLibraryEditor on: library.
	editor scenarioEditor editShortcut.

	self assert: (editor replayPresenterAt: 'Macro list' ifAbsent: [ nil ]) identicalTo: editor macroList.
	self assert: (editor replayPresenterAt: 'Scenario editor' ifAbsent: [ nil ]) identicalTo: editor scenarioEditor.
	self assert: (editor replayPresenterAt: 'Macro editor' ifAbsent: [ nil ]) identicalTo: editor macroEditor.
	self
		assert: (editor replayPresenterAt: 'Installation summary' ifAbsent: [ nil ])
		identicalTo: editor installationSummaryPresenter.
	self
		assert: (editor replayPresenterAt: 'Install on startup' ifAbsent: [ nil ])
		identicalTo: editor installOnStartupCheckBox.
	self assert: (editor replayPresenterAt: 'Install all button' ifAbsent: [ nil ]) identicalTo: editor installAllButton.
	#( 'Import button' 'Export library button' 'Export macro button' ) do: [ :name |
		self assert: (editor replayPresenterAt: name ifAbsent: [ nil ]) notNil ].
	self
		assert: (editor replayPresenterAt: 'Edit shortcut button' ifAbsent: [ nil ])
		identicalTo: editor scenarioEditor shortcutButton.
	self
		assert: (editor replayPresenterAt: 'Key binding' ifAbsent: [ nil ])
		identicalTo: editor macroEditor keyBindingPresenter.
	self assert: editor scenarioEditor actionEditor identicalTo: editor macroEditor
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testShowScenarioAddsItsMacroOnce [

	| editor scenario macro |
	editor := self editorOnFile.
	scenario := ReplayScenario new
		            title: 'Recorded flow';
		            yourself.
	macro := editor showScenario: scenario.

	self assert: macro scenario identicalTo: scenario.
	self assert: editor selectedMacro identicalTo: macro.
	self assert: (editor showScenario: scenario) identicalTo: macro.
	self assert: editor library macros size equals: 1.
	self assert: (self savedMacroNamesOf: editor) equals: #( 'Recorded flow' )
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testStandaloneScenarioEditorOffersToMoveToLibrary [

	| editor |
	editor := ReplayEditor on: ReplayScenario new.

	self deny: editor isInLibrary.
	self assert: editor macroEditor isNil.
	self assert: editor shortcutButton label equals: 'Add to library'.
	self
		assert: (editor replayPresenterAt: 'Add to library button' ifAbsent: [ nil ])
		identicalTo: editor shortcutButton
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testToggleInstallationInstallsAndUninstallsTheLibrary [

	| library first second editor |
	library := ReplayMacroLibrary new.
	first := library addMacro: (self macroNamed: 'First' shortcut: (self controlShortcut: 'f')).
	first contextNames: { #RubTextEditor }.
	second := library addMacro: (self macroNamed: 'Second' shortcut: (self controlShortcut: 'g')).
	second contextNames: { #RubTextEditor }.
	editor := ReplayMacroLibraryEditor on: library.
	editor scenarioEditor editShortcut.

	editor installAllButton click.
	self assert: first isInstalled.
	self assert: second isInstalled.
	self assert: editor installationSummaryPresenter label equals: '2 / 2 macros installed'.
	self assert: (editor macroEditor installationStatusPresenter label includesSubstring: 'Installed in').
	editor installAllButton click.
	self deny: first isInstalled.
	self deny: second isInstalled.
	self assert: editor installAllButton label equals: 'Install all'.
	self assert: editor macroEditor installationStatusPresenter label equals: 'Not installed.'
]

{ #category : 'tests' }
ReplayMacroLibraryEditorTest >> testWindowCloseSavesScenarioEdits [

	| editor macro |
	editor := self editorOnFile.
	macro := editor addMacro.
	editor open.
	macro scenario title: 'Edited title'.
	editor window close.

	self assert: (self savedMacroNamesOf: editor) equals: #( 'Edited title' )
]
