"
I edit the settings of a library macro: its key binding (with a ReplayKeyBindingPresenter, which also edits the modifiers of each key), the contexts it is installed in, and whether it is installed. I also list the shortcuts it conflicts with, in the image and in its library.

I am not a window: a ReplayEditor on a library macro shows me in its right pane when its Edit shortcut button is pressed. The macro name is the title of its scenario, edited with Edit scenario data.
I keep the installed keymaps of the macro up to date with my edits, then notify the block given to whenMacroChangedDo:.
"
Class {
	#name : 'ReplayMacroEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'macro',
		'macroLibrary',
		'changeBlock',
		'replayPresenters',
		'keyBindingLabelPresenter',
		'keyBindingPresenter',
		'contextDropList',
		'contextAddButton',
		'contextList',
		'contextRemoveButton',
		'contextClearButton',
		'installationStatusPresenter',
		'conflictWarningIconPresenter',
		'conflictList',
		'installButton',
		'installationRequirementsLabelPresenter',
		'keyBindingRequirementIconPresenter',
		'contextRequirementIconPresenter'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'layout' }
ReplayMacroEditor class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 8;
		  add: #keyBindingLabelPresenter expand: false;
		  add: #keyBindingPresenter expand: false;
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
				   add: #installButton withConstraints: [ :c |
					   c width: 132.
					   c height: self buttonHeight ];
				   add: #installationRequirementsLabelPresenter expand: false;
				   add: #keyBindingRequirementIconPresenter width: 18;
				   add: 'Contexts:' expand: false;
				   add: #contextRequirementIconPresenter width: 18;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'instance creation' }
ReplayMacroEditor class >> on: aReplayMacro inLibrary: aReplayMacroLibrary [

	^ self basicNew
		  setMacro: aReplayMacro library: aReplayMacroLibrary;
		  initialize;
		  refreshFromMacro;
		  yourself
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
	self macroChanged
]

{ #category : 'actions' }
ReplayMacroEditor >> clearContexts [

	self macro contextNames ifEmpty: [ ^ self ].
	self macro contextNames: #(  ).
	self macroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictList [

	^ conflictList
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflictStatusHelpTextFor: conflicts [

	| contextNames |
	self macro hasKeyBinding ifFalse: [
		^ 'Enter a key binding to check shortcut conflicts in this macro''s install contexts.' ].
	conflicts isEmpty ifTrue: [ ^ 'No shortcut conflicts in this macro''s install contexts.' ].
	contextNames := (conflicts collect: [ :conflict | conflict contextDisplayName ] as: Set) asArray sorted.
	conflicts size = 1 ifTrue: [ ^ '1 conflict in context: ' , contextNames first , '.' ].
	^ conflicts size asString , ' conflicts in contexts: ' , (', ' join: contextNames) , '.'
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflictStatusIconNameFor: conflicts [

	self macro hasKeyBinding ifFalse: [ ^ #smallQuestion ].
	conflicts isEmpty ifTrue: [ ^ #accept ].
	^ #warning
]

{ #category : 'accessing' }
ReplayMacroEditor >> conflictWarningIconPresenter [

	^ conflictWarningIconPresenter
]

{ #category : 'conflicts' }
ReplayMacroEditor >> conflicts [
	"Conflicts with the other macros of the library are internal ones, whether they are installed or not"

	| libraryKeymapNames |
	libraryKeymapNames := self macroLibrary macros collect: [ :each | each keymapName ] as: Set.
	^ (self macro conflicts reject: [ :conflict | libraryKeymapNames includes: conflict keymap name ])
	  , (self macroLibrary internalConflictsForMacro: self macro)
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

{ #category : 'initialization' }
ReplayMacroEditor >> initializePresenters [

	keyBindingLabelPresenter := self newLabel
		label: 'Key binding:';
		help: 'Choose the key sequence and modifier keys that trigger this macro.';
		yourself.
	keyBindingPresenter := ReplayKeyBindingPresenter
		on: self macro keyBinding
		whenChangedDo: [ :binding |
			self macro keyBinding: binding.
			self macroChanged ].

	contextDropList := self newDropList
		items: ReplayMacroContext availableContexts;
		display: [ :context | context displayName ];
		help: 'Choose a known shortcut context, then press add. Everywhere expands to all known installable UI contexts.';
		yourself.
	contextAddButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the selected context to this macro install context list.';
		action: [ self addSelectedContext ];
		yourself.
	contextList := self newTable
		addColumn: (SpStringTableColumn
			title: 'Contexts'
			evaluated: [ :categoryName | ReplayMacroContext displayNameForCategoryName: categoryName ]);
		beResizable;
		yourself.
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
	conflictWarningIconPresenter := self newImage.
	conflictList := self newTable
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
		beResizable;
		yourself.
	installButton := self newButton
		action: [ self toggleMacroInstallation ];
		yourself.
	installationRequirementsLabelPresenter := self newLabel
		label: 'Key binding:';
		help: 'A macro needs a key binding and at least one install context before it can be installed.';
		yourself.
	keyBindingRequirementIconPresenter := self newImage.
	contextRequirementIconPresenter := self newImage.
	self initializeReplayPresenters
]

{ #category : 'initialization' }
ReplayMacroEditor >> initializeReplayPresenters [
	"One semantic name per presenter, for Replay actions such as Annotate"

	| modifiers |
	modifiers := keyBindingPresenter modifiersPresenter.
	replayPresenters := Dictionary new
		at: 'Key binding label' put: keyBindingLabelPresenter;
		at: 'Key binding' put: keyBindingPresenter;
		at: 'Shift modifier' put: modifiers shiftCheckBox;
		at: 'Control modifier' put: modifiers controlCheckBox;
		at: 'Alt modifier' put: modifiers altCheckBox;
		at: 'Command modifier' put: modifiers commandCheckBox;
		at: 'Install context picker' put: contextDropList;
		at: 'Add install context button' put: contextAddButton;
		at: 'Install context list' put: contextList;
		at: 'Remove install context button' put: contextRemoveButton;
		at: 'Clear install contexts button' put: contextClearButton;
		at: 'Installation status' put: installationStatusPresenter;
		at: 'Conflict warning icon' put: conflictWarningIconPresenter;
		at: 'Conflict list' put: conflictList;
		at: 'Install button' put: installButton;
		yourself
]

{ #category : 'accessing' }
ReplayMacroEditor >> installButton [

	^ installButton
]

{ #category : 'actions' }
ReplayMacroEditor >> installMacro [

	self macro install.
	self updateInstallationStatus.
	self notifyMacroChanged
]

{ #category : 'updating' }
ReplayMacroEditor >> installationHelpText [

	self macro hasKeyBinding ifFalse: [ ^ 'Set a key binding before installing this macro.' ].
	self macro hasInstallContexts ifFalse: [ ^ 'Add at least one install context before installing this macro.' ].
	^ 'Install macro in contexts listed above.'
]

{ #category : 'accessing' }
ReplayMacroEditor >> installationRequirementsLabelPresenter [

	^ installationRequirementsLabelPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> installationStatusPresenter [

	^ installationStatusPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> keyBindingLabelPresenter [

	^ keyBindingLabelPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> keyBindingPresenter [

	^ keyBindingPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> keyBindingRequirementIconPresenter [

	^ keyBindingRequirementIconPresenter
]

{ #category : 'accessing' }
ReplayMacroEditor >> macro [

	^ macro
]

{ #category : 'updating' }
ReplayMacroEditor >> macroChanged [
	"After an edit of the key binding or contexts"

	self macro updateInstalledKeymaps.
	self refreshContextList.
	self updateConflicts.
	self updateInstallationStatus.
	self notifyMacroChanged
]

{ #category : 'accessing' }
ReplayMacroEditor >> macroLibrary [

	^ macroLibrary
]

{ #category : 'updating' }
ReplayMacroEditor >> notifyMacroChanged [

	changeBlock ifNotNil: [ changeBlock value ]
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshContextList [

	| selectedIndex items |
	selectedIndex := contextList selectedIndex ifNil: [ 0 ].
	items := self macro contextNames asArray.
	contextList items: items.
	items ifEmpty: [ ^ self ].
	contextList selectIndex: (selectedIndex = 0
			 ifTrue: [ 1 ]
			 ifFalse: [ selectedIndex min: items size ])
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshFromMacro [

	self refreshContextList.
	self refreshSelectedContext.
	self updateInstallationStatus.
	self updateConflicts
]

{ #category : 'updating' }
ReplayMacroEditor >> refreshSelectedContext [

	self macro contextNames ifEmpty: [ ^ self ].
	contextDropList items
		detect: [ :context | context matchesCategoryNames: self macro contextNames ]
		ifFound: [ :context | contextDropList selectItem: context ]
		ifNone: [ contextDropList selectItem: nil ]
]

{ #category : 'actions' }
ReplayMacroEditor >> removeSelectedContext [

	| selectedCategoryName |
	selectedCategoryName := contextList selectedItem.
	selectedCategoryName ifNil: [ ^ self ].
	self macro contextNames: (self macro contextNames reject: [ :each | each = selectedCategoryName ]).
	self macroChanged
]

{ #category : 'replay' }
ReplayMacroEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	^ replayPresenters
		  at: aPresenterName
		  ifAbsent: [ keyBindingPresenter replayPresenterAt: aPresenterName ifAbsent: absentBlock ]
]

{ #category : 'initialization' }
ReplayMacroEditor >> setMacro: aReplayMacro library: aReplayMacroLibrary [

	macro := aReplayMacro.
	macroLibrary := aReplayMacroLibrary
]

{ #category : 'private' }
ReplayMacroEditor >> summaryForDisplayNames: displayNames [

	| names |
	names := displayNames asArray.
	names size <= 2 ifTrue: [ ^ ', ' join: names ].
	^ (', ' join: (names first: 2)) , ' +' , (names size - 2) asString , ' more'
]

{ #category : 'actions' }
ReplayMacroEditor >> toggleMacroInstallation [

	self macro isInstalled
		ifTrue: [ self uninstallMacro ]
		ifFalse: [ self installMacro ]
]

{ #category : 'actions' }
ReplayMacroEditor >> uninstallMacro [

	self macro uninstall.
	self updateInstallationStatus.
	self notifyMacroChanged
]

{ #category : 'updating' }
ReplayMacroEditor >> updateConflicts [

	| conflicts |
	conflicts := self conflicts.
	conflictList items: conflicts.
	conflictWarningIconPresenter image: (self iconNamed: (self conflictStatusIconNameFor: conflicts)).
	self updateHelp: (self conflictStatusHelpTextFor: conflicts) on: conflictWarningIconPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> updateHelp: aString on: aPresenter [
	"Also update the balloon of a built widget, which does not follow the presenter help"

	aPresenter help: aString.
	aPresenter withAdapterDo: [ :anAdapter |
		anAdapter widget ifNotNil: [ :widget | widget setBalloonText: aString ] ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallButtonInstalled: isInstalled [

	isInstalled
		ifTrue: [
			installButton
				enabled: true;
				label: 'Uninstall macro';
				icon: (self iconNamed: #cancel).
			self updateHelp: 'Remove macro from the contexts where it is installed.' on: installButton ]
		ifFalse: [
			installButton
				enabled: self macro canInstall;
				label: 'Install macro';
				icon: (self iconNamed: #accept).
			self updateHelp: self installationHelpText on: installButton ]
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallRequirementPresenters [

	keyBindingRequirementIconPresenter image: (self iconNamed: (self macro hasKeyBinding
			  ifTrue: [ #accept ]
			  ifFalse: [ #cancel ])).
	self
		updateHelp: (self macro hasKeyBinding
				 ifTrue: [ 'Key binding is set.' ]
				 ifFalse: [ 'Set a key binding before installing this macro.' ])
		on: keyBindingRequirementIconPresenter.
	contextRequirementIconPresenter image: (self iconNamed: (self macro hasInstallContexts
			  ifTrue: [ #accept ]
			  ifFalse: [ #cancel ])).
	self
		updateHelp: (self macro hasInstallContexts
				 ifTrue: [ 'At least one install context is set.' ]
				 ifFalse: [ 'Add at least one install context before installing this macro.' ])
		on: contextRequirementIconPresenter
]

{ #category : 'updating' }
ReplayMacroEditor >> updateInstallationStatus [
	"Find the installed contexts once for the status, its help and the install button"

	| installedContexts |
	installedContexts := self macro installedCategories collect: [ :category |
		ReplayMacroContext displayNameForCategoryName: category name ].
	installationStatusPresenter label: (installedContexts
			 ifEmpty: [ 'Not installed.' ]
			 ifNotEmpty: [ 'Installed in: ' , (self summaryForDisplayNames: installedContexts) ]).
	self
		updateHelp: (installedContexts
				 ifEmpty: [ 'No installed contexts.' ]
				 ifNotEmpty: [ 'Installed in: ' , (', ' join: installedContexts) ])
		on: installationStatusPresenter.
	self updateInstallRequirementPresenters.
	self updateInstallButtonInstalled: installedContexts notEmpty
]

{ #category : 'updating' }
ReplayMacroEditor >> whenMacroChangedDo: aBlock [

	changeBlock := aBlock
]
