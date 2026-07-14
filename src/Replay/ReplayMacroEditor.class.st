"
I am Spec editor for one ReplayMacro, including name, shortcut, contexts, conflict status, and install controls.
"
Class {
	#name : 'ReplayMacroEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'macro',
		'macroLibrary',
		'namePresenter',
		'shortcutTextPresenter',
		'modifierPresenter',
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
		'macroInstallationButton',
		'changeBlock',
		'activeContextStatusPresenter',
		'refreshActiveContextButton',
		'installActiveContextButton'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'layout' }
ReplayMacroEditor class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 8;
		add: 'Macro name:' expand: false;
		add: #namePresenter expand: false;
		add: 'Shortcut keys:' expand: false;
		add: #shortcutTextPresenter expand: false;
		add: #modifierPresenter expand: false;
		add: 'Install in context:' expand: false;
		add: #contextDropList expand: false;
		add: #installationStatusPresenter expand: false;
		add: #conflictStatusPresenter expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: #activeContextStatusPresenter;
			add: #refreshActiveContextButton expand: false;
			add: #installActiveContextButton expand: false;
			yourself)
		expand: false;
		add: 'Conflicting shortcuts in known contexts:' expand: false;
		add: #conflictList;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			add: #editScenarioButton expand: false;
			add: #runMacroButton expand: false;
			add: #macroInstallationButton expand: false;
			yourself)
		expand: false;
		yourself
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> new [

	^ self on: ReplayMacro new
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> on: aReplayMacro [

	| editor |
	editor := self basicNew.
	editor initializeModel: aReplayMacro library: nil.
	editor initialize.
	editor refreshFromMacro.
	^ editor
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> on: aReplayMacro inLibrary: aReplayMacroLibrary [

	| editor |
	editor := self basicNew.
	editor initializeModel: aReplayMacro library: aReplayMacroLibrary.
	editor initialize.
	editor refreshFromMacro.
	^ editor
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
ReplayMacroEditor >> initializeModel: aReplayMacro library: aReplayMacroLibrary [

	macro := aReplayMacro.
	macroLibrary := aReplayMacroLibrary
]

{ #category : 'initialization' }
ReplayMacroEditor >> initializePresenters [

	namePresenter := self newText.
	namePresenter
		text: self macro name;
		whenTextChangedDo: [ :aString |
			self macro name: aString.
			self macroChanged ].

	shortcutTextPresenter := ReplayShortcutKeysPresenter
		on: self macro shortcut
		whenChangedDo: [
			self refreshShortcut.
			self macroChanged ].

	modifierPresenter := self newPresenter
		layout: (self macro shortcut
			modifierPresenterOn: self
			whenChangedDo: [ self macroChanged ]);
		yourself.

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
		addColumn: ((SpStringTableColumn title: 'Context' evaluated: #contextDisplayName)
			width: 220;
			yourself);
		addColumn: ((SpStringTableColumn title: 'Shortcut' evaluated: #shortcutString)
			width: 120;
			yourself);
		addColumn: ((SpStringTableColumn title: 'Action' evaluated: #name)
			width: 120;
			yourself);
		addColumn: ((SpStringTableColumn title: 'Description' evaluated: #description)
			width: 220;
			yourself);
		beResizable.
	editScenarioButton := self newButton
		label: 'Edit scenario';
		action: [ self editScenario ];
		yourself.
	runMacroButton := self newButton
		label: 'Run macro';
		action: [ self macro run ];
		yourself.
	macroInstallationButton := self newButton
		action: [ self toggleMacroInstallation ];
		yourself.
	self updateMacroInstallationButton
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

{ #category : 'testing' }
ReplayMacroEditor >> isMacroInstalled [

	^ self macro installedCategories isNotEmpty
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
ReplayMacroEditor >> macroInstallationButton [

	^ macroInstallationButton
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroLibrary [

	^ macroLibrary
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroLibrary: aReplayMacroLibrary [

	macroLibrary := aReplayMacroLibrary
]

{ #category : 'accessing' }
ReplayMacroEditor >> modifierPresenter [

	^ modifierPresenter
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

	shortcutTextPresenter ifNotNil: [ shortcutTextPresenter setTextSilently: self macro shortcut text ].
	commandCheckBox ifNotNil: [ commandCheckBox state: (self macro shortcut hasFlags: 64) ].
	controlCheckBox ifNotNil: [ controlCheckBox state: (self macro shortcut hasFlags: 16) ].
	altCheckBox ifNotNil: [ altCheckBox state: (self macro shortcut hasFlags: 32) ].
	shiftCheckBox ifNotNil: [ shiftCheckBox state: (self macro shortcut hasFlags: 8) ]
]

{ #category : 'replay' }
ReplayMacroEditor >> registerReplayPresenter: aPresenter named: aString [

	(#('Action command' 'Shortcut command') includes: aString) ifTrue: [
		commandCheckBox := aPresenter ].
	(#('Action control' 'Shortcut control') includes: aString) ifTrue: [
		controlCheckBox := aPresenter ].
	(#('Action alt option' 'Shortcut alt option') includes: aString) ifTrue: [
		altCheckBox := aPresenter ].
	(#('Action shift' 'Shortcut shift') includes: aString) ifTrue: [
		shiftCheckBox := aPresenter ].
	^ aPresenter
]

{ #category : 'replay' }
ReplayMacroEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Macro name' ifTrue: [ ^ namePresenter ].
	aPresenterName = 'Shortcut keys' ifTrue: [ ^ shortcutTextPresenter ].
	(#('Command modifier' 'Action command' 'Shortcut command') includes: aPresenterName) ifTrue: [ ^ commandCheckBox ].
	(#('Control modifier' 'Action control' 'Shortcut control') includes: aPresenterName) ifTrue: [ ^ controlCheckBox ].
	(#('Alt modifier' 'Action alt option' 'Shortcut alt option') includes: aPresenterName) ifTrue: [ ^ altCheckBox ].
	(#('Shift modifier' 'Action shift' 'Shortcut shift') includes: aPresenterName) ifTrue: [ ^ shiftCheckBox ].
	shortcutTextPresenter ifNotNil: [
		(aPresenterName beginsWith: 'Shortcut ') ifTrue: [
			^ shortcutTextPresenter replayPresenterAt: aPresenterName ifAbsent: absentBlock ] ].
	aPresenterName = 'Macro context' ifTrue: [ ^ contextDropList ].
	aPresenterName = 'Installation status' ifTrue: [ ^ installationStatusPresenter ].
	aPresenterName = 'Conflict status' ifTrue: [ ^ conflictStatusPresenter ].
	aPresenterName = 'Active UI context status' ifTrue: [ ^ activeContextStatusPresenter ].
	aPresenterName = 'Refresh active UI button' ifTrue: [ ^ refreshActiveContextButton ].
	aPresenterName = 'Install active UI button' ifTrue: [ ^ installActiveContextButton ].
	aPresenterName = 'Conflict list' ifTrue: [ ^ conflictList ].
	aPresenterName = 'Edit scenario button' ifTrue: [ ^ editScenarioButton ].
	aPresenterName = 'Run macro button' ifTrue: [ ^ runMacroButton ].
	(#('Macro installation button' 'Install macro button' 'Uninstall macro button') includes: aPresenterName) ifTrue: [ ^ macroInstallationButton ].
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
ReplayMacroEditor >> toggleMacroInstallation [

	self isMacroInstalled
		ifTrue: [ self uninstallMacro ]
		ifFalse: [ self installMacro ]
]

{ #category : 'actions' }
ReplayMacroEditor >> uninstallMacro [

	self macro uninstall.
	self updateInstallationStatus.
	self updateConflicts.
	self notifyMacroChanged
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
		installationStatusPresenter label: self installationStatusText ].
	self updateMacroInstallationButton
]

{ #category : 'updating' }
ReplayMacroEditor >> updateMacroInstallationButton [

	macroInstallationButton ifNil: [ ^ self ].
	macroInstallationButton label: (self isMacroInstalled
		ifTrue: [ 'Uninstall' ]
		ifFalse: [ 'Install' ])
]

{ #category : 'updating' }
ReplayMacroEditor >> whenMacroChangedDo: aBlock [

	changeBlock := aBlock
]
