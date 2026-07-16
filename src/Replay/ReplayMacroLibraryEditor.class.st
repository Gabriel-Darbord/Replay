"
I am a Spec editor for macro libraries. I let users edit macros, choose shortcuts and contexts, manage installed keymaps, and control startup installation.
"
Class {
	#name : 'ReplayMacroLibraryEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'registry',
		'library',
		'macroList',
		'macroEditorPane',
		'macroEditorPresenter',
		'installationSummaryPresenter',
		'startupPolicyPresenter',
		'startupPolicyIconPresenter',
		'startupPolicyStatusPresenter',
		'startupPolicyButton',
		'installedMacroIconPresenter',
		'installedKeymapIconPresenter',
		'installedKeymapSummaryPresenter'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> new [

	^ self on: ReplayMacroLibrary new
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> on: aReplayMacroLibrary [

	^ self basicNew
		initialize;
		library: aReplayMacroLibrary;
		yourself
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> onRegistry: aReplayMacroRegistry [

	^ self basicNew
		initialize;
		registry: aReplayMacroRegistry;
		library: aReplayMacroRegistry library;
		yourself
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> open [
	<script>

	^ self new open
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> openDefault [
	<script>

	^ (self onRegistry: ReplayMacroRegistry default) open
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> addImportedMacro: aReplayMacro [

	self ensureImportedMacroHasUniqueIdentifier: aReplayMacro.
	self library addMacro: aReplayMacro.
	self refreshFromLibrary.
	macroList ifNotNil: [
		macroList selectIndex: (self library macros indexOf: aReplayMacro) ].
	^ aReplayMacro
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> addMacro [

	| macro |
	macro := self library addNewMacro.
	self refreshFromLibrary.
	macroList selectIndex: self library macros size.
	^ macro
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> addMacroForScenario: aReplayScenario [

	| macro index |
	macro := self library macroForScenario: aReplayScenario.
	self refreshFromLibrary.
	macroList ifNotNil: [
		index := self library macros indexOf: macro.
		index > 0 ifTrue: [ macroList selectIndex: index ] ].
	^ macro
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> clearInstalledReplayMacros [

	ReplayMacro uninstallAllInstalledKeymaps.
	self refreshMacroEditorStatus.
	self updateInstallationSummary
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> connectPresenters [

	macroList
		addItemBlock: [ self library newMacro ];
		removeItemBlock: [ :macro | self removeMacro: macro ];
		whenSelectionChangedDo: [ :selection |
			self selectMacro: selection selectedItem ]
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> copySelectedMacro [

	self selectedMacro
		ifNil: [ self uiManager inform: 'Select a macro to copy.' ]
		ifNotNil: [ :macro |
			Clipboard
				clipboardText: (STON toString: macro)
				informing: 'Macro copied to clipboard!' ]
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> currentRegistry [

	^ registry ifNil: [ registry := ReplayMacroRegistry new library: self library; yourself ]
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: self toolbar expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 20;
			vAlignCenter;
			add: (SpBoxLayout newLeftToRight
				spacing: 6;
				vAlignCenter;
				add: installedMacroIconPresenter expand: false;
				add: installationSummaryPresenter width: 130;
				yourself) expand: false;
			add: (SpBoxLayout newLeftToRight
				spacing: 6;
				vAlignCenter;
				add: installedKeymapIconPresenter expand: false;
				add: installedKeymapSummaryPresenter width: 120;
				yourself) expand: false;
			add: (SpBoxLayout newLeftToRight
				spacing: 8;
				vAlignCenter;
				add: startupPolicyButton width: 145;
				add: startupPolicyStatusPresenter width: 120;
				yourself) expand: false;
			yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: macroList withConstraints: [ :c | c width: 300 ];
			add: (SpScrollableLayout new
				vAlignStart;
				hAlignStart;
				child: (SpBoxLayout newLeftToRight
					add: macroEditorPane withConstraints: [ :c | c padding: 10 ];
					yourself);
				yourself);
			yourself);
		yourself
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> disableStartupInstallation [

	ReplayMacroRegistry disableStartupInstallation.
	self updateStartupPolicyStatus
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> emptyMacroPresenter [

	^ self newPresenter
		layout: (SpBoxLayout newTopToBottom
			add: (SpBoxLayout newLeftToRight
				spacing: 10;
				add: (self iconNamed: #smallInfo) expand: false;
				add: 'Create or select a macro to edit it.';
				yourself)
			withConstraints: [ :c |
				c expand: false.
				c padding: 10 ];
			yourself);
		yourself
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> enableStartupInstallation [

	ReplayMacroRegistry enableStartupInstallation.
	self updateStartupPolicyStatus
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> ensureImportedMacroHasUniqueIdentifier: aReplayMacro [

	| importedIdentifier identifierExists |
	importedIdentifier := aReplayMacro identifier.
	identifierExists := self library macros anySatisfy: [ :macro |
		macro identifier = importedIdentifier ].
	identifierExists ifTrue: [ aReplayMacro identifier: UUID new asString ]
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> importLibrary [

	(self uiManager
		request: 'Paste the STON string of a macro library to edit it.'
		initialAnswer: ''
		title: 'Import Macro Library') ifNotEmpty: [ :string |
		self library: (STON fromString: string) ]
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> importMacro [

	(self uiManager
		request: 'Paste the STON string of one macro to add it to this library.'
		initialAnswer: ''
		title: 'Import Macro') ifNotEmpty: [ :string |
			self importMacroFromString: string ]
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> importMacroFromString: aString [

	| importedMacro |
	importedMacro := STON fromString: aString.
	(importedMacro isKindOf: ReplayMacro) ifFalse: [
		self error: 'Expected a ReplayMacro STON string.' ].
	^ self addImportedMacro: importedMacro
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializePresenters [

	macroList := SpEditableListPresenter new.
	macroList items: self library macros.
	installedMacroIconPresenter := self newImage.
	installationSummaryPresenter := self newLabel.
	installedKeymapIconPresenter := self newImage.
	installedKeymapSummaryPresenter := self newLabel.
	startupPolicyIconPresenter := self newImage.
	startupPolicyPresenter := self newLabel.
	startupPolicyStatusPresenter := self newPresenter
		layout: (SpBoxLayout newLeftToRight
			spacing: 4;
			vAlignCenter;
			add: startupPolicyIconPresenter expand: false;
			add: startupPolicyPresenter expand: false;
			yourself);
		yourself.
	startupPolicyButton := self newButton
		action: [ self toggleStartupInstallation ];
		yourself.
	macroEditorPane := SpBoxLayout newLeftToRight.
	macroEditorPane add: self emptyMacroPresenter.
	self updateInstallationSummary.
	self updateStartupPolicyStatus
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializeWindow: aWindow [

	aWindow title: 'Macro Library Editor'.
	aWindow initialExtent: 1200 @ 720
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> installAllMacros [

	self library install.
	self refreshMacroEditorStatus.
	self updateInstallationSummary
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installationSummaryHelpText [

	^ 'Installed macros are the macros currently registered as keyboard shortcuts. Replay keymaps are keymap entries currently installed in the image.'
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installationSummaryPresenter [

	^ installationSummaryPresenter
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installationSummaryText [

	^ self installedMacroSummaryText , '. ' , self installedKeymapSummaryText
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installedKeymapSummaryHelpText [

	^ 'Replay keymaps are keyboard shortcut entries currently installed in the image.'
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installedKeymapSummaryPresenter [

	^ installedKeymapSummaryPresenter
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installedKeymapSummaryText [

	| keymapCount |
	keymapCount := ReplayMacro installedKeymapCount.
	^ keymapCount asString
		, ' keymap'
		, (self pluralSuffixFor: keymapCount)
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installedMacroSummaryHelpText [

	^ 'Installed macros are macros from this library that are currently registered as keyboard shortcuts.'
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installedMacroSummaryText [

	^ self library installedMacroCount asString
		, ' / '
		, self library macros size asString
		, ' macros'
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> library [

	^ library ifNil: [ library := ReplayMacroLibrary new ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> library: aReplayMacroLibrary [

	library := aReplayMacroLibrary.
	self refreshFromLibrary
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> loadDefaultFile [

	self currentRegistry load.
	self library: self currentRegistry library
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> macroEditorPane [

	^ macroEditorPane
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> macroEditorPresenter [

	^ macroEditorPresenter
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> macroList [

	^ macroList
]

{ #category : 'formatting' }
ReplayMacroLibraryEditor >> pluralSuffixFor: aNumber [

	^ aNumber = 1
		ifTrue: [ '' ]
		ifFalse: [ 's' ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> refreshFromLibrary [

	macroList ifNotNil: [ macroList items: self library macros ].
	self updateInstallationSummary.
	self selectFirstMacroIfNeeded
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> refreshMacroEditorStatus [

	self selectedMacro ifNil: [ ^ self ].
	macroEditorPresenter ifNil: [ ^ self ].
	macroEditorPresenter updateInstallationStatus.
	macroEditorPresenter updateConflicts
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> registry [

	^ registry
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> registry: aReplayMacroRegistry [

	registry := aReplayMacroRegistry
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> removeMacro: aReplayMacro [

	| nextIndex |
	nextIndex := (self library macros
		indexOf: aReplayMacro
		ifAbsent: [ macroList selectedIndex ifNil: [ 1 ] ])
		min: self library macros size - 1.
	self library removeMacro: aReplayMacro.
	self refreshFromLibrary.
	self library macros
		ifEmpty: [ self selectMacro: nil ]
		ifNotEmpty: [ macroList selectIndex: (nextIndex max: 1) ]
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> removeSelectedMacro [

	self selectedMacro ifNotNil: [ :macro | self removeMacro: macro ]
]

{ #category : 'replay' }
ReplayMacroLibraryEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Macro list' ifTrue: [ ^ macroList ].
	aPresenterName = 'Macro editor' ifTrue: [ ^ macroEditorPresenter ifNil: [ macroEditorPane ] ].
	aPresenterName = 'Installation summary' ifTrue: [ ^ installationSummaryPresenter ].
	aPresenterName = 'Startup policy' ifTrue: [ ^ startupPolicyPresenter ].
	aPresenterName = 'Startup policy icon' ifTrue: [ ^ startupPolicyIconPresenter ].
	aPresenterName = 'Startup policy status' ifTrue: [ ^ startupPolicyStatusPresenter ].
	(#('Startup policy button' 'Enable startup button' 'Disable startup button') includes: aPresenterName) ifTrue: [ ^ startupPolicyButton ].
	macroEditorPresenter ifNotNil: [
		^ macroEditorPresenter replayPresenterAt: aPresenterName ifAbsent: absentBlock ].
	^ absentBlock value
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> saveDefaultFile [

	self currentRegistry save
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> saveLibrary [

	Clipboard
		clipboardText: (STON toString: self library)
		informing: 'Macro library copied to clipboard!'
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> selectFirstMacroIfNeeded [

	(macroList isNil or: [ macroList selectedItem notNil ]) ifTrue: [ ^ self ].
	self library macros ifNotEmpty: [ macroList selectIndex: 1 ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> selectMacro: aReplayMacro [

	macroEditorPresenter := aReplayMacro
		ifNil: [ self emptyMacroPresenter ]
		ifNotNil: [
			(ReplayMacroEditor on: aReplayMacro inLibrary: self library)
				whenMacroChangedDo: [
					self refreshMacroEditorStatus.
					self updateInstallationSummary ];
				yourself ].
	macroEditorPane replaceAtIndex: 1 with: macroEditorPresenter.
	self updateInstallationSummary
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> selectedMacro [

	^ macroList selectedItem
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> startupPolicyButton [

	^ startupPolicyButton
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> startupPolicyButtonLabel [

	^ ReplayMacroRegistry startupInstallationEnabled
		ifTrue: [ 'Disable startup' ]
		ifFalse: [ 'Enable startup' ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> startupPolicyHelpText [

	^ 'When enabled, Replay installs macros saved in the default macro file when the image starts. Disable it to keep saved macros inactive until you install them manually.'
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> startupPolicyIconName [

	^ ReplayMacroRegistry startupInstallationEnabled
		ifTrue: [ #smallOk ]
		ifFalse: [ #smallCancel ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> startupPolicyIconPresenter [

	^ startupPolicyIconPresenter
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> startupPolicyPresenter [

	^ startupPolicyPresenter
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> startupPolicyStatusPresenter [

	^ startupPolicyStatusPresenter
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> startupPolicyText [

	^ ReplayMacroRegistry startupInstallationEnabled
		ifTrue: [ 'Enabled' ]
		ifFalse: [ 'Disabled' ]
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> toggleStartupInstallation [

	ReplayMacroRegistry startupInstallationEnabled
		ifTrue: [ self disableStartupInstallation ]
		ifFalse: [ self enableStartupInstallation ]
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> toolbar [

	^ self newToolbar
		addStyle: 'stToolbar';
		add: (self newToolbarButton
			label: 'Copy library';
			icon: (self iconNamed: #smallCopy);
			help: 'Copy current macro library to the clipboard as a STON string.';
			action: [ self saveLibrary ]);
		add: (self newToolbarButton
			label: 'Import library';
			icon: (self iconNamed: #smallLoadProject);
			help: 'Replace current macro library from a clipboard STON string.';
			action: [ self importLibrary ]);
		add: (self newToolbarButton
			label: 'Copy macro';
			icon: (self iconNamed: #scriptManager);
			help: 'Copy the selected macro to the clipboard as a STON string.';
			action: [ self copySelectedMacro ]);
		add: (self newToolbarButton
			label: 'Import macro';
			icon: (self iconNamed: #smallLoadProject);
			help: 'Add one macro from a clipboard STON string.';
			action: [ self importMacro ]);
		add: (self newToolbarButton
			label: 'Save file';
			icon: (self iconNamed: #save);
			help: 'Save current macro library to the default Replay macro file.';
			action: [ self saveDefaultFile ]);
		add: (self newToolbarButton
			label: 'Load file';
			icon: (self iconNamed: #open);
			help: 'Load the default Replay macro file.';
			action: [ self loadDefaultFile ]);
		add: (self newToolbarButton
			label: 'Install all';
			icon: (self iconNamed: #smallOk);
			help: 'Install all macros in their configured contexts.';
			action: [ self installAllMacros ]);
		add: (self newToolbarButton
			label: 'Uninstall library';
			icon: (self iconNamed: #smallCancel);
			help: 'Uninstall only macros from the current library.';
			action: [ self uninstallAllMacros ]);
		add: (self newToolbarButton
			label: 'Clear all installs';
			icon: (self iconNamed: #smallCancel);
			help: 'Remove every installed Replay macro keymap, including stale entries not present in the library.';
			action: [ self clearInstalledReplayMacros ]);
		yourself
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> uninstallAllMacros [

	self library uninstall.
	self refreshMacroEditorStatus.
	self updateInstallationSummary
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> updateInstallationSummary [

	| macroHelpText keymapHelpText |
	macroHelpText := self installedMacroSummaryHelpText.
	keymapHelpText := self installedKeymapSummaryHelpText.
	installedMacroIconPresenter ifNotNil: [
		installedMacroIconPresenter
			image: (self iconNamed: #scriptManager);
			help: macroHelpText ].
	installationSummaryPresenter ifNotNil: [
		installationSummaryPresenter
			label: self installedMacroSummaryText;
			help: macroHelpText ].
	installedKeymapIconPresenter ifNotNil: [
		installedKeymapIconPresenter
			image: (self iconNamed: #objects);
			help: keymapHelpText ].
	installedKeymapSummaryPresenter ifNotNil: [
		installedKeymapSummaryPresenter
			label: self installedKeymapSummaryText;
			help: keymapHelpText ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> updateStartupPolicyStatus [

	startupPolicyPresenter ifNotNil: [
		startupPolicyPresenter
			label: self startupPolicyText;
			help: self startupPolicyHelpText ].
	startupPolicyIconPresenter ifNotNil: [
		startupPolicyIconPresenter
			image: (self iconNamed: self startupPolicyIconName);
			help: self startupPolicyHelpText ].
	startupPolicyButton ifNotNil: [
		startupPolicyButton
			label: self startupPolicyButtonLabel;
			help: self startupPolicyHelpText ]
]
