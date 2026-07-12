Class {
	#name : 'ReplayMacroEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'macro',
		'macroLibrary',
		'namePresenter',
		'shortcutTextPresenter',
		'commandCheckBox',
		'controlCheckBox',
		'altCheckBox',
		'shiftCheckBox',
		'contextDropList',
		'installationStatusPresenter',
		'conflictStatusPresenter',
		'conflictList',
		'editScenarioButton',
		'runMacroButton',
		'installMacroButton',
		'uninstallMacroButton',
		'changeBlock',
		'activeContextStatusPresenter',
		'refreshActiveContextButton',
		'installActiveContextButton'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'layout' }
ReplayMacroEditor class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: 'Macro name:' expand: false;
		add: #namePresenter expand: false;
		add: 'Shortcut keys:' expand: false;
		add: #shortcutTextPresenter expand: false;
		add: 'Modifiers:' expand: false;
		add: (SpBoxLayout newTopToBottom
			spacing: 4;
			add: (SpBoxLayout newLeftToRight
				spacing: 12;
				add: #commandCheckBox expand: false;
				add: #controlCheckBox expand: false;
				yourself) expand: false;
			add: (SpBoxLayout newLeftToRight
				spacing: 12;
				add: #altCheckBox expand: false;
				add: #shiftCheckBox expand: false;
				yourself) expand: false;
			yourself) expand: false;
		add: 'Install in context:' expand: false;
		add: #contextDropList expand: false;
		add: #installationStatusPresenter expand: false;
		add: #conflictStatusPresenter expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: #activeContextStatusPresenter;
			add: #refreshActiveContextButton expand: false;
			add: #installActiveContextButton expand: false;
			yourself) expand: false;
		add: 'Conflicting shortcuts in known contexts:' expand: false;
		add: #conflictList;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: #editScenarioButton expand: false;
			add: #runMacroButton expand: false;
			add: #installMacroButton expand: false;
			add: #uninstallMacroButton expand: false;
			yourself) expand: false;
		yourself
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> new [

	^ self on: ReplayMacro new
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> on: aReplayMacro [

	^ self basicNew
		initialize;
		macro: aReplayMacro;
		yourself
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> on: aReplayMacro inLibrary: aReplayMacroLibrary [

	^ self basicNew
		initialize;
		macroLibrary: aReplayMacroLibrary;
		macro: aReplayMacro;
		yourself
]

{ #category : 'opening' }
ReplayMacroEditor class >> open [

	<script>
	^ self new open
]

{ #category : 'accessing' }
ReplayMacroEditor >> activeContextStatusPresenter [

	^ activeContextStatusPresenter
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextStatusText [

	^ self activeContextStatusTextForMorph: self activeKeyboardFocusMorph
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextStatusTextForMorph: aMorph [

	| context categoryNames conflicts contextNames |
	context := ReplayMacroContext forMorph: aMorph.
	categoryNames := context categoryNames.
	categoryNames isEmpty ifTrue: [ ^ 'Active UI context: none.' ].
	conflicts := self macro conflictsInCategories: context categories.
	contextNames := ', ' join: (categoryNames collect: [ :categoryName |
		ReplayShortcutConflict displayNameForCategoryName: categoryName ]).
	conflicts isEmpty ifTrue: [
		^ 'Active UI contexts: ' , contextNames , '. No conflicts.' ].
	^ 'Active UI contexts: ' , contextNames , '. ' , (self conflictStatusTextFor: conflicts)
]

{ #category : 'active context' }
ReplayMacroEditor >> activeKeyboardFocusMorph [

	| hand focus |
	World ifNil: [ ^ nil ].
	hand := World activeHand.
	hand ifNil: [ ^ nil ].
	focus := hand keyboardFocus.
	(focus isKindOf: Morph) ifFalse: [ ^ nil ].
	^ focus
]

{ #category : 'accessing' }
ReplayMacroEditor >> altCheckBox [

	^ altCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> availableMacroContexts [

	^ ReplayMacroContext availableContexts
]

{ #category : 'accessing' }
ReplayMacroEditor >> commandCheckBox [

	^ commandCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictList [

	^ conflictList
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictStatusPresenter [

	^ conflictStatusPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> conflictStatusTextFor: conflicts [

	| contextNames |
	self macro shortcut text isEmpty ifTrue: [
		^ 'Enter shortcut keys to check known contexts.' ].
	conflicts isEmpty ifTrue: [ ^ 'No conflicts in known contexts.' ].
	contextNames := ((conflicts collect: [ :conflict | conflict contextDisplayName ]) asSet asArray sorted: [ :first :second | first <= second ]).
	conflicts size = 1 ifTrue: [
		^ '1 conflict in context: ' , contextNames first , '.' ].
	^ conflicts size asString , ' conflicts in contexts: ' , (', ' join: contextNames) , '.'
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflicts [

	| categories conflicts |
	categories := (self availableMacroContexts
		flatCollect: [ :context | context conflictCategories ]) asSet asArray.
	conflicts := (self macro conflictsInCategories: categories) asOrderedCollection.
	self macroLibrary ifNotNil: [ :library |
		conflicts addAll: (library internalConflictsForMacro: self macro) ].
	^ conflicts
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextDropList [

	^ contextDropList
]

{ #category : 'accessing' }
ReplayMacroEditor >> controlCheckBox [

	^ controlCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> displayNameForContextCategory: aReplayMacroContext [

	^ aReplayMacroContext displayName
]

{ #category : 'accessing' }
ReplayMacroEditor >> displayNameForInstalledCategory: aKMCategory [

	^ ReplayShortcutConflict displayNameForCategoryName: aKMCategory name
]

{ #category : 'actions' }
ReplayMacroEditor >> editScenario [

	self macro scenario edit
]

{ #category : 'initialization' }
ReplayMacroEditor >> initializePresenters [

	namePresenter := self newText.
	namePresenter
		text: self macro name;
		whenTextChangedDo: [ :aString |
			self macro name: aString.
			self macroChanged ].

	shortcutTextPresenter := self newText.
	shortcutTextPresenter
		text: self macro shortcut text;
		help: 'Type shortcut key characters; use modifier checkboxes below.';
		whenTextChangedDo: [ :aString |
			self macro shortcut text: aString.
			self macroChanged ].

	commandCheckBox := self modifierCheckBoxNamed: 'Command' flag: 64.
	controlCheckBox := self modifierCheckBoxNamed: 'Control' flag: 16.
	altCheckBox := self modifierCheckBoxNamed: 'Alt/Option' flag: 32.
	shiftCheckBox := self modifierCheckBoxNamed: 'Shift' flag: 8.

	contextDropList := self newDropList.
	contextDropList
		items: self availableMacroContexts;
		display: [ :context | context displayName ];
		whenSelectedItemChangedDo: [ :context |
			context ifNotNil: [
				self macro contextNames: context categoryNames.
				self macroChanged ] ].

	installationStatusPresenter := self newLabel.
	conflictStatusPresenter := self newLabel.
	activeContextStatusPresenter := self newLabel.
	activeContextStatusPresenter label: 'Active UI context: not checked.'.
	refreshActiveContextButton := self newButton
		label: 'Refresh active UI';
		action: [ self refreshActiveContextStatus ];
		yourself.
	installActiveContextButton := self newButton
		label: 'Install active UI';
		action: [ self installInActiveContext ];
		yourself.

	conflictList := self newTable.
	conflictList
		addColumn: ((SpStringTableColumn title: 'Context' evaluated: #contextDisplayName) width: 220; yourself);
		addColumn: ((SpStringTableColumn title: 'Shortcut' evaluated: #shortcutString) width: 120; yourself);
		addColumn: ((SpStringTableColumn title: 'Action' evaluated: #name) width: 120; yourself);
		addColumn: ((SpStringTableColumn title: 'Description' evaluated: #description) width: 220; yourself);
		beResizable.

	editScenarioButton := self newButton
		label: 'Edit scenario';
		action: [ self editScenario ];
		yourself.
	runMacroButton := self newButton
		label: 'Run macro';
		action: [ self macro run ];
		yourself.
	installMacroButton := self newButton
		label: 'Install/update';
		action: [ self installMacro ];
		yourself.
	uninstallMacroButton := self newButton
		label: 'Uninstall';
		action: [ self uninstallMacro ];
		yourself
]

{ #category : 'initialization' }
ReplayMacroEditor >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Macro Editor';
		initialExtent: 760 @ 520
]

{ #category : 'accessing' }
ReplayMacroEditor >> installActiveContextButton [

	^ installActiveContextButton
]

{ #category : 'active context' }
ReplayMacroEditor >> installInActiveContext [

	^ self installInActiveContextForMorph: self activeKeyboardFocusMorph
]

{ #category : 'active context' }
ReplayMacroEditor >> installInActiveContextForMorph: aMorph [

	| context |
	context := ReplayMacroContext forMorph: aMorph.
	context categoryNames isEmpty ifTrue: [
		self refreshActiveContextStatus.
		^ self ].
	self macro contextNames: context categoryNames.
	self refreshSelectedContext.
	self installMacro.
	self refreshActiveContextStatus
]

{ #category : 'actions' }
ReplayMacroEditor >> installMacro [

	self macro install.
	self updateInstallationStatus.
	self updateConflicts.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> installationStatusPresenter [

	^ installationStatusPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> installationStatusText [

	| installedContexts |
	installedContexts := self macro installedCategories collect: [ :category |
		self displayNameForInstalledCategory: category ].
	installedContexts isEmpty ifTrue: [ ^ 'Not installed.' ].
	^ 'Installed in: ' , (', ' join: installedContexts)
]

{ #category : 'accessing' }
ReplayMacroEditor >> macro [

	^ macro ifNil: [ macro := ReplayMacro new ]
]

{ #category : 'accessing' }
ReplayMacroEditor >> macro: aReplayMacro [

	macro := aReplayMacro.
	self refreshFromMacro
]

{ #category : 'updating' }
ReplayMacroEditor >> macroChanged [

	self macro updateInstalledKeymaps.
	self updateConflicts.
	self updateInstallationStatus.
	self refreshActiveContextStatus.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroLibrary [

	^ macroLibrary
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroLibrary: aReplayMacroLibrary [

	macroLibrary := aReplayMacroLibrary
]

{ #category : 'initialization' }
ReplayMacroEditor >> modifierCheckBoxNamed: aString flag: anInteger [

	^ self newCheckBox
		label: aString;
		state: (self macro shortcut hasFlags: anInteger);
		whenActivatedDo: [
			self macro shortcut addFlags: anInteger.
			self macroChanged ];
		whenDeactivatedDo: [
			self macro shortcut removeFlags: anInteger.
			self macroChanged ];
		yourself
]

{ #category : 'accessing' }
ReplayMacroEditor >> namePresenter [

	^ namePresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> notifyMacroChanged [

	changeBlock ifNotNil: [ changeBlock value ]
]

{ #category : 'accessing' }
ReplayMacroEditor >> refreshActiveContextButton [

	^ refreshActiveContextButton
]

{ #category : 'active context' }
ReplayMacroEditor >> refreshActiveContextStatus [

	activeContextStatusPresenter ifNotNil: [
		activeContextStatusPresenter label: self activeContextStatusText ]
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshFromMacro [

	namePresenter ifNotNil: [ namePresenter text: self macro name ].
	self refreshShortcut.
	self refreshSelectedContext.
	self updateInstallationStatus.
	self updateConflicts
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshSelectedContext [

	(contextDropList isNil or: [ self macro contextNames isEmpty ]) ifTrue: [ ^ self ].
	contextDropList items
		detect: [ :context | context matchesCategoryNames: self macro contextNames ]
		ifFound: [ :context | contextDropList selectItem: context ]
		ifNone: [ ]
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshShortcut [

	shortcutTextPresenter ifNotNil: [
		shortcutTextPresenter text: self macro shortcut text ].
	commandCheckBox ifNotNil: [
		commandCheckBox state: (self macro shortcut hasFlags: 64) ].
	controlCheckBox ifNotNil: [
		controlCheckBox state: (self macro shortcut hasFlags: 16) ].
	altCheckBox ifNotNil: [
		altCheckBox state: (self macro shortcut hasFlags: 32) ].
	shiftCheckBox ifNotNil: [
		shiftCheckBox state: (self macro shortcut hasFlags: 8) ]
]

{ #category : 'replay' }
ReplayMacroEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Macro name' ifTrue: [ ^ namePresenter ].
	aPresenterName = 'Shortcut keys' ifTrue: [ ^ shortcutTextPresenter ].
	aPresenterName = 'Command modifier' ifTrue: [ ^ commandCheckBox ].
	aPresenterName = 'Control modifier' ifTrue: [ ^ controlCheckBox ].
	aPresenterName = 'Alt modifier' ifTrue: [ ^ altCheckBox ].
	aPresenterName = 'Shift modifier' ifTrue: [ ^ shiftCheckBox ].
	aPresenterName = 'Macro context' ifTrue: [ ^ contextDropList ].
	aPresenterName = 'Installation status' ifTrue: [ ^ installationStatusPresenter ].
	aPresenterName = 'Conflict status' ifTrue: [ ^ conflictStatusPresenter ].
	aPresenterName = 'Active UI context status' ifTrue: [ ^ activeContextStatusPresenter ].
	aPresenterName = 'Refresh active UI button' ifTrue: [ ^ refreshActiveContextButton ].
	aPresenterName = 'Install active UI button' ifTrue: [ ^ installActiveContextButton ].
	aPresenterName = 'Conflict list' ifTrue: [ ^ conflictList ].
	aPresenterName = 'Edit scenario button' ifTrue: [ ^ editScenarioButton ].
	aPresenterName = 'Run macro button' ifTrue: [ ^ runMacroButton ].
	aPresenterName = 'Install macro button' ifTrue: [ ^ installMacroButton ].
	aPresenterName = 'Uninstall macro button' ifTrue: [ ^ uninstallMacroButton ].
	^ absentBlock value
]

{ #category : 'accessing' }
ReplayMacroEditor >> shiftCheckBox [

	^ shiftCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> shortcutTextPresenter [

	^ shortcutTextPresenter
]

{ #category : 'actions' }
ReplayMacroEditor >> uninstallMacro [

	self macro uninstall.
	self updateInstallationStatus.
	self updateConflicts.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> uninstallMacroButton [

	^ uninstallMacroButton
]

{ #category : 'updating' }
ReplayMacroEditor >> updateConflicts [

	| conflicts |
	conflicts := self conflicts.
	conflictList ifNotNil: [ conflictList items: conflicts ].
	conflictStatusPresenter ifNotNil: [
		conflictStatusPresenter label: (self conflictStatusTextFor: conflicts) ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallationStatus [

	installationStatusPresenter ifNotNil: [
		installationStatusPresenter label: self installationStatusText ]
]

{ #category : 'updating' }
ReplayMacroEditor >> whenMacroChangedDo: aBlock [

	changeBlock := aBlock
]
