"
I am the Spec editor for a macro library, with macro list, detail editor, startup policy, and installation controls.
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
		'enableStartupButton',
		'disableStartupButton'
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
ReplayMacroLibraryEditor >> currentRegistry [

	^ registry ifNil: [ registry := ReplayMacroRegistry new library: self library; yourself ]
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: self toolbar expand: false;
		add: installationSummaryPresenter expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: startupPolicyPresenter;
			add: enableStartupButton expand: false;
			add: disableStartupButton expand: false;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: (SpBoxLayout newTopToBottom
				spacing: 8;
				add: 'Macros' expand: false;
				add: macroList;
				yourself)
			withConstraints: [ :c | c width: 300 ];
			add: (SpBoxLayout newLeftToRight
				add: macroEditorPane
				withConstraints: [ :c | c padding: 10 ];
				yourself);
			yourself);
		yourself
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> disableStartupButton [

	^ disableStartupButton
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

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> enableStartupButton [

	^ enableStartupButton
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> enableStartupInstallation [

	ReplayMacroRegistry enableStartupInstallation.
	self updateStartupPolicyStatus
]

{ #category : 'tools' }
ReplayMacroLibraryEditor >> importLibrary [

	(self uiManager
		request: 'Paste the STON string of a macro library to edit it.'
		initialAnswer: ''
		title: 'Import Macro Library') ifNotEmpty: [ :string |
		self library: (STON fromString: string) ]
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializePresenters [

	macroList := SpEditableListPresenter new.
	macroList items: self library macros.
	installationSummaryPresenter := self newLabel.
	startupPolicyPresenter := self newLabel.
	enableStartupButton := self newButton
		label: 'Enable startup';
		action: [ self enableStartupInstallation ];
		yourself.
	disableStartupButton := self newButton
		label: 'Disable startup';
		action: [ self disableStartupInstallation ];
		yourself.
	macroEditorPane := SpBoxLayout newLeftToRight.
	macroEditorPane add: self emptyMacroPresenter.
	self updateInstallationSummary.
	self updateStartupPolicyStatus
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializeWindow: aWindow [

	aWindow title: 'Macro Library Editor'.
	aWindow initialExtent: 1000 @ 600
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> installAllMacros [

	self library install.
	self refreshMacroEditorStatus.
	self updateInstallationSummary
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installationSummaryPresenter [

	^ installationSummaryPresenter
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> installationSummaryText [

	^ 'Installed macros: '
		, self library installedMacroCount asString
		, ' / '
		, self library macros size asString
		, '. Replay keymaps in image: '
		, ReplayMacro installedKeymapCount asString
		, '.'
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
	aPresenterName = 'Enable startup button' ifTrue: [ ^ enableStartupButton ].
	aPresenterName = 'Disable startup button' ifTrue: [ ^ disableStartupButton ].
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
ReplayMacroLibraryEditor >> startupPolicyPresenter [

	^ startupPolicyPresenter
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> startupPolicyText [

	^ 'Startup install: '
		, (ReplayMacroRegistry startupInstallationEnabled
			ifTrue: [ 'enabled' ]
			ifFalse: [ 'disabled' ])
		, '. Script: '
		, ReplayMacroRegistry startupInstallationScriptText
		, '.'
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> toolbar [

	^ self newToolbar
		addStyle: 'stToolbar';
		add: (self newToolbarButton
			label: 'Copy';
			icon: (self iconNamed: #smallCopy);
			help: 'Copy current macro library clipboard STON string.';
			action: [ self saveLibrary ]);
		add: (self newToolbarButton
			label: 'Paste';
			icon: (self iconNamed: #smallLoadProject);
			help: 'Import serialized macro library STON string.';
			action: [ self importLibrary ]);
		add: (self newToolbarButton
			label: 'Save';
			icon: (self iconNamed: #save);
			help: 'Save current macro library to the default Replay macro file.';
			action: [ self saveDefaultFile ]);
		add: (self newToolbarButton
			label: 'Load';
			icon: (self iconNamed: #open);
			help: 'Load the default Replay macro file.';
			action: [ self loadDefaultFile ]);
		add: (self newToolbarButton
			label: 'Install all';
			icon: (self iconNamed: #smallOk);
			help: 'Install all macros in selected contexts.';
			action: [ self installAllMacros ]);
		add: (self newToolbarButton
			label: 'Uninstall all';
			icon: (self iconNamed: #smallCancel);
			help: 'Uninstall all macros from every context where they are installed.';
			action: [ self uninstallAllMacros ]);
		add: (self newToolbarButton
			label: 'Clear installed';
			icon: (self iconNamed: #smallCancel);
			help: 'Remove every installed Replay macro keymap, including stale entries.';
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

	installationSummaryPresenter ifNotNil: [
		installationSummaryPresenter label: self installationSummaryText ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> updateStartupPolicyStatus [

	startupPolicyPresenter ifNotNil: [
		startupPolicyPresenter label: self startupPolicyText ]
]
