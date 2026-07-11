Class {
	#name : 'ReplayMacroLibraryEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'registry',
		'library',
		'macroList',
		'macroEditorPane',
		'macroEditorPresenter'
	],
	#category : 'Replay',
	#package : 'Replay'
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
	macroEditorPane := SpBoxLayout newLeftToRight.
	macroEditorPane add: self emptyMacroPresenter
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializeWindow: aWindow [

	aWindow title: 'Macro Library Editor'.
	aWindow initialExtent: 1000 @ 600
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
	self selectFirstMacroIfNeeded
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
	macroEditorPresenter ifNotNil: [
		^ macroEditorPresenter
			replayPresenterAt: aPresenterName
			ifAbsent: absentBlock ].
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
		ifNotNil: [ ReplayMacroEditor on: aReplayMacro inLibrary: self library ].
	macroEditorPane replaceAtIndex: 1 with: macroEditorPresenter
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> selectedMacro [

	^ macroList selectedItem
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
			action: [ self library install ]);
		add: (self newToolbarButton
			label: 'Uninstall all';
			icon: (self iconNamed: #smallCancel);
			help: 'Uninstall all macros from every context where they are installed.';
			action: [ self library uninstall ]);
		yourself
]
