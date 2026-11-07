"
I am the library window (""Replay Macro Library""): I show the macros of a ReplayMacroRegistry and edit the selected one.

The left list holds the macros, named after their scenario. The right pane embeds a ReplayEditor on the scenario of the selected macro; its Edit shortcut button shows the macro settings (a ReplayMacroEditor). The toolbar imports macros pasted as STON, exports the library or the selected macro to the clipboard, and installs or uninstalls the whole library. The status row counts installed macros and sets whether the library installs on startup.

The embedded editor records like a standalone one while my window is open: I open its session when my window opens or another macro is selected, and close it when my window closes or the macro is no longer selected, which ends its recording. My hand (hand:) is the one of the embedded editor.

I am always on a registry, and I save it after each library-level change (add, remove, import, macro settings, startup setting) and when my window closes, which also captures scenario edits. Use open for the default library, which is saved in the user's preferences.
"
Class {
	#name : 'ReplayMacroLibraryEditor',
	#superclass : 'ReplayToolPresenter',
	#instVars : [
		'registry',
		'toolbar',
		'installAllButton',
		'installationSummaryPresenter',
		'installOnStartupCheckBox',
		'macroList',
		'scenarioPane',
		'scenarioEditor',
		'replayPresenters'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> on: aReplayMacroLibrary [
	"An editor on aReplayMacroLibrary in a registry without file"

	^ self onRegistry: (ReplayMacroRegistry new
			   replaceLibrary: aReplayMacroLibrary;
			   yourself)
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> onRegistry: aReplayMacroRegistry [

	^ self basicNew
		  setRegistry: aReplayMacroRegistry;
		  initialize;
		  yourself
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> open [
	"Show the library window of the default registry"

	<script>
	^ [ self openOnRegistry: ReplayMacroRegistry default ]
		  on: ReplayError
		  do: [ :error |
			  UIManager default inform: error messageText.
			  nil ]
]

{ #category : 'instance creation' }
ReplayMacroLibraryEditor class >> openOnRegistry: aReplayMacroRegistry [
	"Show the library window of aReplayMacroRegistry, never a second one"

	^ self
		  openInstanceSuchThat: [ :editor | editor registry == aReplayMacroRegistry ]
		  ifNone: [ self onRegistry: aReplayMacroRegistry ]
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> addMacro [

	| macro |
	macro := self library addNewMacro.
	self macrosChanged.
	self showMacro: macro.
	^ macro
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> connectPresenters [

	macroList
		addItemBlock: [
			self addMacro.
			nil "The macro is already in the list" ];
		removeItemBlock: [ :macro | macro ifNotNil: [ self removeMacro: macro ] ];
		whenSelectionChangedDo: [ :selection |
			self selectMacro: selection selectedItem ].
	installOnStartupCheckBox whenChangedDo: [ :state |
		self setInstallsOnStartup: state ].
	self refreshMacroList.
	self updateInstallationSummary
]

{ #category : 'layout' }
ReplayMacroLibraryEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 8;
		  add: toolbar expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 20;
				   vAlignCenter;
				   add: installationSummaryPresenter width: 160;
				   add: installOnStartupCheckBox expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: macroList withConstraints: [ :c | c width: 240 ];
				   add: scenarioPane;
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

{ #category : 'actions' }
ReplayMacroLibraryEditor >> exportLibrary [

	Clipboard
		clipboardText: (STON toString: self library)
		informing: 'Macro library copied to clipboard!'
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> exportSelectedMacro [

	self selectedMacro
		ifNil: [ self inform: 'Select a macro to export.' ]
		ifNotNil: [ :macro |
			Clipboard
				clipboardText: (STON toString: macro)
				informing: 'Macro copied to clipboard!' ]
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> import [

	(self
		 requestSton: 'Paste the STON string of a macro or of a macro library to add its macros to this library.'
		 title: 'Import Macros') ifNotNil: [ :string | self importString: string ]
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> importString: aString [
	"Add the macros of the STON aString and select the last one. A string without macros is reported, and changes nothing."

	| macros |
	macros := [ self registry importString: aString ]
		          on: ReplayError
		          do: [ :error |
			          self inform: error messageText.
			          ^ #(  ) ].
	self refreshMacroList.
	self updateInstallationSummary.
	macros ifNotEmpty: [ self showMacro: macros last ].
	^ macros
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> hand: aHandMorph [

	super hand: aHandMorph.
	scenarioEditor ifNotNil: [ scenarioEditor hand: aHandMorph ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installAllButton [

	^ installAllButton
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installOnStartupCheckBox [

	^ installOnStartupCheckBox
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> installationSummaryPresenter [

	^ installationSummaryPresenter
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializePresenters [

	| importButton exportLibraryButton exportMacroButton |
	importButton := self newToolbarButton
		label: 'Import';
		icon: (self iconNamed: #smallLoadProject);
		help: 'Add the macros of a STON string, one macro or a whole library.';
		action: [ self import ];
		yourself.
	exportLibraryButton := self newToolbarButton
		label: 'Export library';
		icon: (self iconNamed: #smallCopy);
		help: 'Copy this macro library to the clipboard as a STON string.';
		action: [ self exportLibrary ];
		yourself.
	exportMacroButton := self newToolbarButton
		label: 'Export macro';
		icon: (self iconNamed: #scriptManager);
		help: 'Copy the selected macro to the clipboard as a STON string.';
		action: [ self exportSelectedMacro ];
		yourself.
	installAllButton := self newToolbarButton
		action: [ self toggleInstallation ];
		yourself.
	toolbar := self newToolbar
		addStyle: 'stToolbar';
		add: importButton;
		add: exportLibraryButton;
		add: exportMacroButton;
		add: installAllButton;
		yourself.
	installationSummaryPresenter := self newLabel
		help: 'Macros of this library currently registered as keyboard shortcuts.';
		yourself.
	installOnStartupCheckBox := self newCheckBox
		label: 'Install on startup';
		help: 'Install the macros of this library when the image starts.';
		state: self library installsOnStartup;
		yourself.
	macroList := SpEditableListPresenter new.
	macroList layout: SpEditableListPresenter withoutOrderingBar.
	scenarioPane := SpBoxLayout newLeftToRight
		add: self emptyMacroPresenter;
		yourself.
	replayPresenters := Dictionary new
		at: 'Import button' put: importButton;
		at: 'Export library button' put: exportLibraryButton;
		at: 'Export macro button' put: exportMacroButton;
		at: 'Install all button' put: installAllButton;
		at: 'Installation summary' put: installationSummaryPresenter;
		at: 'Install on startup' put: installOnStartupCheckBox;
		at: 'Macro list' put: macroList;
		yourself
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	aWindow
		title: 'Replay Macro Library';
		initialExtent: 1500 @ 820;
		whenOpenedDo: [ scenarioEditor ifNotNil: [ scenarioEditor openSession ] ];
		whenClosedDo: [
			scenarioEditor ifNotNil: [ scenarioEditor closeSession ].
			self registry save ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> library [

	^ self registry library
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> macroEditor [
	"The settings of the selected macro"

	^ scenarioEditor ifNotNil: [ scenarioEditor macroEditor ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> macroList [

	^ macroList
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> macroSettingsChanged [

	self refreshMacroLabels.
	self updateInstallationSummary.
	self registry save
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> macrosChanged [
	"After a macro was added or removed"

	self refreshMacroList.
	self updateInstallationSummary.
	self registry save
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> refreshMacroEditorStatus [

	self macroEditor ifNotNil: [ :editor | editor updateInstallationStatus ]
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> refreshMacroLabels [
	"Macros are named after their scenario, and show their shortcut"

	macroList list refresh
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> refreshMacroList [
	"The list has its own copy: macros are added and removed through the library"

	macroList items: self library macros copy.
	(macroList selectedItem isNil and: [ self library macros notEmpty ]) ifTrue: [
		macroList selectIndex: 1 ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> registry [

	^ registry
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> removeMacro: aReplayMacro [

	| nextIndex |
	nextIndex := (self library macros indexOf: aReplayMacro) min: self library macros size - 1.
	self library removeMacro: aReplayMacro.
	self macrosChanged.
	self library macros ifNotEmpty: [ macroList selectIndex: (nextIndex max: 1) ]
]

{ #category : 'replay' }
ReplayMacroLibraryEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Scenario editor' ifTrue: [ ^ scenarioPane presenterAt: 1 ].
	aPresenterName = 'Macro editor' ifTrue: [ ^ self macroEditor ifNil: absentBlock ].
	^ replayPresenters at: aPresenterName ifAbsent: [
		  scenarioEditor
			  ifNil: absentBlock
			  ifNotNil: [ scenarioEditor replayPresenterAt: aPresenterName ifAbsent: absentBlock ] ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> scenarioEditor [
	"The editor of the selected macro scenario, or nil without selection"

	^ scenarioEditor
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> selectMacro: aReplayMacro [
	"Show the scenario of aReplayMacro in an embedded scenario editor, which also edits its settings"

	scenarioEditor ifNotNil: [ scenarioEditor closeSession ].
	scenarioEditor := aReplayMacro ifNotNil: [
		(ReplayEditor onMacro: aReplayMacro inLibrary: self library)
			hand: hand;
			whenMacroChangedDo: [ self macroSettingsChanged ];
			whenTitleChangedDo: [ self refreshMacroLabels ];
			yourself ].
	scenarioPane replaceAtIndex: 1 with: (scenarioEditor ifNil: [ self emptyMacroPresenter ]).
	(scenarioEditor isNotNil and: [ self isDisplayed ]) ifTrue: [ scenarioEditor openSession ]
]

{ #category : 'accessing' }
ReplayMacroLibraryEditor >> selectedMacro [

	^ macroList selectedItem
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> setInstallsOnStartup: aBoolean [

	self library installsOnStartup = aBoolean ifTrue: [ ^ self ].
	self library installsOnStartup: aBoolean.
	self registry save
]

{ #category : 'initialization' }
ReplayMacroLibraryEditor >> setRegistry: aReplayMacroRegistry [

	registry := aReplayMacroRegistry
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> showMacro: aReplayMacro [

	macroList selectItem: aReplayMacro
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> showScenario: aReplayScenario [
	"Select the macro of aReplayScenario, added to the library if it has none. Answer the macro."

	| macro |
	macro := self library macroWithScenario: aReplayScenario.
	macro ifNil: [
		macro := self library addMacroForScenario: aReplayScenario.
		self macrosChanged ].
	self showMacro: macro.
	^ macro
]

{ #category : 'actions' }
ReplayMacroLibraryEditor >> toggleInstallation [
	"Uninstall the library if any of its macros is installed, otherwise install it"

	self library installedMacros
		ifEmpty: [ self library install ]
		ifNotEmpty: [ self library uninstall ].
	self refreshMacroEditorStatus.
	self updateInstallationSummary
]

{ #category : 'updating' }
ReplayMacroLibraryEditor >> updateInstallationSummary [

	| installedCount macroCount |
	installedCount := self library installedMacroCount.
	macroCount := self library macros size.
	installationSummaryPresenter label: installedCount asString , ' / ' , macroCount asString , ' macro'
		, (macroCount = 1
				 ifTrue: [ '' ]
				 ifFalse: [ 's' ]) , ' installed'.
	installAllButton
		label: (installedCount > 0
				 ifTrue: [ 'Uninstall all' ]
				 ifFalse: [ 'Install all' ]);
		icon: (self iconNamed: (installedCount > 0
					  ifTrue: [ #smallCancel ]
					  ifFalse: [ #smallOk ]));
		help: (installedCount > 0
				 ifTrue: [ 'Uninstall every macro of this library.' ]
				 ifFalse: [ 'Install every macro of this library in its contexts.' ])
]
