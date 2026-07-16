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
		'installationRequirementsLabelPresenter',
		'keyBindingRequirementIconPresenter',
		'contextRequirementIconPresenter',
		'changeBlock',
		'activeContextStatusPresenter',
		'refreshActiveContextButton',
		'installActiveContextButton',
		'keyBindingLabelPresenter',
		'contextList',
		'contextAddButton',
		'contextRemoveButton',
		'conflictWarningIconPresenter',
		'contextClearButton'
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
		  add: #keyBindingLabelPresenter expand: false;
		  add: #shortcutTextPresenter expand: false;
		  add: #modifierPresenter expand: false;
		  add: 'Install contexts:' expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignCenter;
				   add: #contextDropList width: 420;
				   add: #contextAddButton width: 40;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignStart;
				   add: (SpBoxLayout newTopToBottom
						    add: #contextList height: 81;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    spacing: 4;
						    vAlignStart;
						    add: #contextRemoveButton height: 37;
						    add: #contextClearButton height: 37;
						    yourself)
				   width: 40;
				   yourself)
		  expand: false;
		  add: #installationStatusPresenter expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 6;
				   vAlignCenter;
				   add: 'Conflicting shortcuts:' expand: false;
				   add: #conflictWarningIconPresenter width: 18;
				   yourself)
		  expand: false;
		  add: #conflictList;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignCenter;
				   add: #editScenarioButton expand: false;
				   add: #runMacroButton expand: false;
				   add: #macroInstallationButton width: 132;
				   add: #installationRequirementsLabelPresenter expand: false;
				   add: #keyBindingRequirementIconPresenter width: 18;
				   add: 'Contexts:' expand: false;
				   add: #contextRequirementIconPresenter width: 18;
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

{ #category : 'active context' }
ReplayMacroEditor >> activeContextDisplayNamesForCategoryNames: categoryNames [

	^ categoryNames collect: [ :categoryName |
		ReplayShortcutConflict displayNameForCategoryName: categoryName ]
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextFullStatusTextForMorph: aMorph [

	| context categoryNames conflicts contextSummary |
	context := ReplayMacroContext forMorph: aMorph.
	categoryNames := context categoryNames.
	categoryNames isEmpty ifTrue: [ ^ 'Current keyboard focus contexts: none.' ].
	conflicts := self macro conflictsInCategories: context categories.
	contextSummary := self activeContextFullSummaryForCategoryNames: categoryNames.
	conflicts isEmpty ifTrue: [
		^ 'Current keyboard focus contexts: ' , contextSummary , '. No conflicts.' ].
	^ 'Current keyboard focus contexts: ' , contextSummary , '. ' , (self conflictStatusTextFor: conflicts)
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextFullSummaryForCategoryNames: categoryNames [

	^ ', ' join: (self activeContextDisplayNamesForCategoryNames: categoryNames)
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextHelpText [

	^ self currentFocusContextHelpText
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextHelpTextForMorph: aMorph [

	^ self activeContextHelpText , ' ' , (self activeContextFullStatusTextForMorph: aMorph)
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

	| context categoryNames conflicts contextSummary |
	context := ReplayMacroContext forMorph: aMorph.
	categoryNames := context categoryNames.
	categoryNames isEmpty ifTrue: [ ^ 'Current keyboard focus contexts: none.' ].
	conflicts := self macro conflictsInCategories: context categories.
	contextSummary := self activeContextSummaryForCategoryNames: categoryNames.
	conflicts isEmpty ifTrue: [
		^ 'Current keyboard focus contexts: ' , contextSummary , '. No conflicts.' ].
	^ 'Current keyboard focus contexts: ' , contextSummary , '. ' , (self conflictStatusTextFor: conflicts)
]

{ #category : 'active context' }
ReplayMacroEditor >> activeContextSummaryForCategoryNames: categoryNames [

	^ self summaryForDisplayNames: (self activeContextDisplayNamesForCategoryNames: categoryNames)
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

{ #category : 'actions' }
ReplayMacroEditor >> addSelectedContext [

	| selectedContext contextNames newContextNames |
	selectedContext := contextDropList selectedItem.
	selectedContext ifNil: [ ^ self ].
	contextNames := self macro contextNames asOrderedCollection.
	newContextNames := selectedContext categoryNames reject: [ :each | contextNames includes: each ].
	newContextNames ifEmpty: [ ^ self ].
	contextNames addAll: newContextNames.
	self macro contextNames: contextNames.
	self refreshContextList.
	self macroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> altCheckBox [

	^ altCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> availableMacroContexts [

	^ ReplayMacroContext availableContexts
]

{ #category : 'actions' }
ReplayMacroEditor >> clearContexts [

	self macro contextNames ifEmpty: [ ^ self ].
	self macro contextNames: #().
	self refreshContextList.
	self macroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> commandCheckBox [

	^ commandCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictList [

	^ conflictList
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflictStatusHelpTextFor: conflicts [

	self macro shortcut text isEmpty ifTrue: [
		^ 'Enter a key binding to check shortcut conflicts in this macro''s install contexts.' ].
	conflicts isEmpty ifTrue: [ ^ 'No shortcut conflicts in this macro''s install contexts.' ].
	^ 'This macro has shortcut conflicts in at least one install context.'
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflictStatusIconNameFor: conflicts [

	self macro shortcut text isEmpty ifTrue: [ ^ #smallQuestion ].
	conflicts isEmpty ifTrue: [ ^ #accept ].
	^ #warning
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictStatusPresenter [

	^ conflictStatusPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> conflictStatusTextFor: conflicts [

	| contextNames |
	self macro shortcut text isEmpty ifTrue: [ ^ '' ].
	conflicts isEmpty ifTrue: [ ^ 'No conflicts.' ].
	contextNames := (conflicts collect: [ :conflict | conflict contextDisplayName ]) asSet asArray sorted: [ :first :second |
		                first <= second ].
	conflicts size = 1 ifTrue: [ ^ '1 conflict in context: ' , contextNames first , '.' ].
	^ conflicts size asString , ' conflicts in contexts: ' , (', ' join: contextNames) , '.'
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictWarningIconPresenter [

	^ conflictWarningIconPresenter
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflicts [

	| conflicts |
	conflicts := self macro conflicts asOrderedCollection.
	self macroLibrary ifNotNil: [ :library | conflicts addAll: (library internalConflictsForMacro: self macro) ].
	^ conflicts
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextAddButton [

	^ contextAddButton
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextClearButton [

	^ contextClearButton
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextDropList [

	^ contextDropList
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextList [

	^ contextList
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextRemoveButton [

	^ contextRemoveButton
]

{ #category : 'accessing' }
ReplayMacroEditor >> contextRequirementIconPresenter [

	^ contextRequirementIconPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> controlCheckBox [

	^ controlCheckBox
]

{ #category : 'active context' }
ReplayMacroEditor >> currentFocusContextHelpText [

	^ 'These contexts are detected from the current Pharo keyboard focus, not from the scenario and not from the dropdown. Focus a target window or widget, then refresh before installing focused contexts.'
]

{ #category : 'accessing' }
ReplayMacroEditor >> displayNameForContextCategory: aReplayMacroContext [

	^ aReplayMacroContext displayName
]

{ #category : 'accessing' }
ReplayMacroEditor >> displayNameForContextName: aCategoryName [

	^ ReplayShortcutConflict displayNameForCategoryName: aCategoryName
]

{ #category : 'accessing' }
ReplayMacroEditor >> displayNameForInstalledCategory: aKMCategory [

	^ ReplayShortcutConflict displayNameForCategoryName: aKMCategory name
]

{ #category : 'actions' }
ReplayMacroEditor >> editScenario [

	self macro scenario edit
]

{ #category : 'accessing' }
ReplayMacroEditor >> editScenarioButton [

	^ editScenarioButton
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

	keyBindingLabelPresenter := self newLabel.
	keyBindingLabelPresenter
		label: 'Key binding:';
		help: 'Choose the key sequence and modifier keys that trigger this macro.'.

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
		help: 'Choose a known shortcut context, then press add. Everywhere expands to all known installable UI contexts.'.

	contextAddButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the selected context to this macro install context list.';
		action: [ self addSelectedContext ];
		yourself.

	contextList := self newTable.
	contextList
		addColumn: (SpStringTableColumn title: 'Contexts' evaluated: [ :categoryName | self displayNameForContextName: categoryName ]);
		beResizable.

	contextRemoveButton := self newButton
		icon: (self iconNamed: #remove);
		help: 'Remove the selected install context from this macro.';
		action: [ self removeSelectedContext ];
		yourself.
	contextClearButton := self newButton
		icon: (self iconNamed: #delete);
		help: 'Remove every install context from this macro.';
		action: [ self clearContexts ];
		yourself.

	installationStatusPresenter := self newLabel.
	conflictStatusPresenter := self newLabel.
	conflictStatusPresenter help: 'Conflicts are checked against the macro install contexts. Add Everywhere to check every installable context.'.
	conflictWarningIconPresenter := self newImage.
	conflictWarningIconPresenter
		image: (self iconNamed: #smallQuestion);
		help: (self conflictStatusHelpTextFor: #());
		visible: true.
	activeContextStatusPresenter := self newLabel.
	activeContextStatusPresenter
		label: 'Current keyboard focus contexts: not checked.';
		help: self currentFocusContextHelpText.
	refreshActiveContextButton := self newButton
		label: 'Refresh focus';
		help: self refreshActiveContextHelpText;
		action: [ self refreshActiveContextStatus ];
		yourself.
	installActiveContextButton := self newButton
		label: 'Install focused contexts';
		help: 'Install this macro in every shortcut context detected from current Pharo keyboard focus.';
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
		icon: (self iconNamed: #edit);
		action: [ self editScenario ];
		yourself.
	runMacroButton := self newButton
		label: 'Run macro';
		icon: (self iconNamed: #go);
		action: [ self macro run ];
		yourself.
	macroInstallationButton := self newButton
		action: [ self toggleMacroInstallation ];
		yourself.
	installationRequirementsLabelPresenter := self newLabel
		label: 'Key binding:';
		help: 'A macro needs a key binding and at least one install context before it can be installed.';
		yourself.
	keyBindingRequirementIconPresenter := self newImage
		help: 'Set a key binding before installing this macro.';
		yourself.
	contextRequirementIconPresenter := self newImage
		help: 'Add at least one install context before installing this macro.';
		yourself.
	self refreshContextList.
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

{ #category : 'updating' }
ReplayMacroEditor >> installContextListItems [

	^ self macro contextNames asArray
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
	self refreshContextList.
	self refreshSelectedContext.
	self installMacro.
	self refreshActiveContextStatus
]

{ #category : 'actions' }
ReplayMacroEditor >> installMacro [

	self macro canInstall ifFalse: [
			self updateInstallationStatus.
			^ self ].
	self macro install.
	self updateInstallationStatus.
	self updateConflicts.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> installationRequirementsLabelPresenter [

	^ installationRequirementsLabelPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> installationStatusHelpText [

	| installedContexts |
	installedContexts := self installedContextDisplayNames.
	installedContexts isEmpty ifTrue: [ ^ 'No installed contexts.' ].
	^ 'Installed in: ' , (', ' join: installedContexts)
]

{ #category : 'accessing' }
ReplayMacroEditor >> installationStatusPresenter [

	^ installationStatusPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> installationStatusText [

	| installedContexts |
	installedContexts := self installedContextDisplayNames.
	installedContexts isEmpty ifTrue: [ ^ 'Not installed.' ].
	^ 'Installed in: ' , (self summaryForDisplayNames: installedContexts)
]

{ #category : 'updating' }
ReplayMacroEditor >> installedContextDisplayNames [

	^ self macro installedCategories collect: [ :category |
		self displayNameForInstalledCategory: category ]
]

{ #category : 'testing' }
ReplayMacroEditor >> isMacroInstalled [

	^ self macro installedCategories isNotEmpty
]

{ #category : 'accessing' }
ReplayMacroEditor >> keyBindingLabelPresenter [

	^ keyBindingLabelPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> keyBindingRequirementIconPresenter [

	^ keyBindingRequirementIconPresenter
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
	self refreshContextList.
	self updateConflicts.
	self updateInstallationStatus.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroInstallationButton [

	^ macroInstallationButton
]

{ #category : 'updating' }
ReplayMacroEditor >> macroInstallationHelpText [

	self macro hasKeyBinding ifFalse: [ ^ 'Set a key binding before installing this macro.' ].
	self macro hasInstallContexts ifFalse: [ ^ 'Add at least one install context before installing this macro.' ].
	^ 'Install macro in contexts listed above.'
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
ReplayMacroEditor >> refreshActiveContextHelpText [

	^ 'Re-read the current Pharo keyboard focus and recompute conflicts for those contexts. Macro edits refresh automatically; use this after focusing another window or if keymaps changed elsewhere.'
]

{ #category : 'active context' }
ReplayMacroEditor >> refreshActiveContextStatus [

	| activeMorph |
	activeContextStatusPresenter ifNotNil: [
		activeMorph := self activeKeyboardFocusMorph.
		activeContextStatusPresenter
			label: (self activeContextStatusTextForMorph: activeMorph);
			help: (self activeContextHelpTextForMorph: activeMorph) ]
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshContextList [

	| selectedIndex items newSelection |
	contextList ifNil: [ ^ self ].
	selectedIndex := contextList selectedIndex ifNil: [ 0 ].
	items := self installContextListItems.
	contextList items: items.
	items isEmpty ifTrue: [ ^ self ].
	newSelection := selectedIndex = 0
		                ifTrue: [ 1 ]
		                ifFalse: [ selectedIndex min: items size ].
	contextList selectIndex: newSelection
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshFromMacro [

	namePresenter ifNotNil: [ namePresenter text: self macro name ].
	self refreshShortcut.
	self refreshContextList.
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
		ifNone: [ contextDropList selectItem: nil ]
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

{ #category : 'actions' }
ReplayMacroEditor >> removeSelectedContext [

	| selectedCategoryName contextNames |
	selectedCategoryName := contextList selectedItem.
	selectedCategoryName ifNil: [ ^ self ].
	contextNames := self macro contextNames reject: [ :each | each = selectedCategoryName ].
	self macro contextNames: contextNames.
	self refreshContextList.
	self macroChanged
]

{ #category : 'replay' }
ReplayMacroEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Macro name' ifTrue: [ ^ namePresenter ].
	aPresenterName = 'Key binding label' ifTrue: [ ^ keyBindingLabelPresenter ].
	(#('Key binding' 'Shortcut keys') includes: aPresenterName) ifTrue: [ ^ shortcutTextPresenter ].
	(#('Command modifier' 'Action command' 'Shortcut command') includes: aPresenterName) ifTrue: [ ^ commandCheckBox ].
	(#('Control modifier' 'Action control' 'Shortcut control') includes: aPresenterName) ifTrue: [ ^ controlCheckBox ].
	(#('Alt modifier' 'Action alt option' 'Shortcut alt option') includes: aPresenterName) ifTrue: [ ^ altCheckBox ].
	(#('Shift modifier' 'Action shift' 'Shortcut shift') includes: aPresenterName) ifTrue: [ ^ shiftCheckBox ].
	shortcutTextPresenter ifNotNil: [
		(aPresenterName beginsWith: 'Shortcut ') ifTrue: [
			^ shortcutTextPresenter replayPresenterAt: aPresenterName ifAbsent: absentBlock ] ].
	(#('Selected install context' 'Macro context' 'Install context picker') includes: aPresenterName) ifTrue: [ ^ contextDropList ].
	(#('Add install context button' 'Install context add button') includes: aPresenterName) ifTrue: [ ^ contextAddButton ].
	(#('Install context list' 'Macro context list') includes: aPresenterName) ifTrue: [ ^ contextList ].
	(#('Remove install context button' 'Install context remove button') includes: aPresenterName) ifTrue: [ ^ contextRemoveButton ].
	(#('Clear install contexts button' 'Delete install contexts button') includes: aPresenterName) ifTrue: [ ^ contextClearButton ].
	aPresenterName = 'Installation status' ifTrue: [ ^ installationStatusPresenter ].
	aPresenterName = 'Conflict status' ifTrue: [ ^ conflictStatusPresenter ].
	(#('Conflict warning icon' 'Shortcut conflict warning') includes: aPresenterName) ifTrue: [ ^ conflictWarningIconPresenter ].
	(#('Current keyboard focus context status' 'Active UI context status') includes: aPresenterName) ifTrue: [ ^ activeContextStatusPresenter ].
	(#('Refresh focus button' 'Refresh active UI button') includes: aPresenterName) ifTrue: [ ^ refreshActiveContextButton ].
	(#('Install focused contexts button' 'Install active contexts button' 'Install active UI button') includes: aPresenterName) ifTrue: [ ^ installActiveContextButton ].
	aPresenterName = 'Conflict list' ifTrue: [ ^ conflictList ].
	aPresenterName = 'Edit scenario button' ifTrue: [ ^ editScenarioButton ].
	aPresenterName = 'Run macro button' ifTrue: [ ^ runMacroButton ].
	(#('Macro installation button' 'Install macro button' 'Uninstall macro button' 'Install selected context button') includes: aPresenterName) ifTrue: [ ^ macroInstallationButton ].
	^ absentBlock value
]

{ #category : 'accessing' }
ReplayMacroEditor >> runMacroButton [

	^ runMacroButton
]

{ #category : 'accessing' }
ReplayMacroEditor >> shiftCheckBox [

	^ shiftCheckBox
]

{ #category : 'accessing' }
ReplayMacroEditor >> shortcutTextPresenter [

	^ shortcutTextPresenter
]

{ #category : 'private' }
ReplayMacroEditor >> summaryForDisplayNames: displayNames [

	| names visibleNames remainingCount |
	names := displayNames asArray.
	names size <= 2 ifTrue: [ ^ ', ' join: names ].
	visibleNames := names first: 2.
	remainingCount := names size - visibleNames size.
	^ (', ' join: visibleNames) , ' +' , remainingCount asString , ' more'
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
			conflictStatusPresenter label: (self conflictStatusTextFor: conflicts).
			self
				updateHelp: 'Conflicts are checked against the macro install contexts. Add Everywhere to check every installable context.'
				on: conflictStatusPresenter ].
	conflictWarningIconPresenter ifNotNil: [
			conflictWarningIconPresenter image: (self iconNamed: (self conflictStatusIconNameFor: conflicts)).
			self updateHelp: (self conflictStatusHelpTextFor: conflicts) on: conflictWarningIconPresenter.
			conflictWarningIconPresenter visible: true ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateHelp: aString on: aPresenter [

	aPresenter ifNotNil: [
		aPresenter help: aString.
		aPresenter withAdapterDo: [ :anAdapter |
			anAdapter widget ifNotNil: [ :widget |
				widget setBalloonText: aString ] ] ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallRequirementPresenters [

	keyBindingRequirementIconPresenter ifNotNil: [
			keyBindingRequirementIconPresenter image: (self iconNamed: (self macro hasKeyBinding
						  ifTrue: [ #accept ]
						  ifFalse: [ #cancel ])).
			self
				updateHelp: (self macro hasKeyBinding
						 ifTrue: [ 'Key binding is set.' ]
						 ifFalse: [ 'Set a key binding before installing this macro.' ])
				on: keyBindingRequirementIconPresenter ].
	contextRequirementIconPresenter ifNotNil: [
			contextRequirementIconPresenter image: (self iconNamed: (self macro hasInstallContexts
						  ifTrue: [ #accept ]
						  ifFalse: [ #cancel ])).
			self
				updateHelp: (self macro hasInstallContexts
						 ifTrue: [ 'At least one install context is set.' ]
						 ifFalse: [ 'Add at least one install context before installing this macro.' ])
				on: contextRequirementIconPresenter ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallationStatus [

	installationStatusPresenter ifNotNil: [
		installationStatusPresenter label: self installationStatusText.
		self updateHelp: self installationStatusHelpText on: installationStatusPresenter ].
	self updateMacroInstallationButton
]

{ #category : 'updating' }
ReplayMacroEditor >> updateMacroInstallationButton [

	macroInstallationButton ifNil: [ ^ self ].
	self updateInstallRequirementPresenters.
	self isMacroInstalled
		ifTrue: [
				macroInstallationButton
					enabled: true;
					label: 'Uninstall macro';
					icon: (self iconNamed: #cancel).
				self updateHelp: 'Remove macro context where currently installed.' on: macroInstallationButton ]
		ifFalse: [
				macroInstallationButton
					enabled: self macro canInstall;
					label: 'Install macro';
					icon: (self iconNamed: #accept).
				self updateHelp: self macroInstallationHelpText on: macroInstallationButton ]
]

{ #category : 'updating' }
ReplayMacroEditor >> whenMacroChangedDo: aBlock [

	changeBlock := aBlock
]
