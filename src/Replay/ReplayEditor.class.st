"
I am the Spec editor for Replay scenarios. I edit scenario metadata, step navigation, action ordering, and per-action settings.

The current step and the current action are the selections of my step and action lists. The action chooser picks the kind of action that the + button of the action list adds to the current step. The right pane (the action editor) shows the settings of the current action, or the scenario data, the navigation of the current step, or the macro settings, and then no action is selected.

Recording: Record and Stop recording, or the recording key binding (Cmd + R, see recordingKeyBinding) pressed anywhere, record the user's input into actions appended to the current step (a ReplayRecorder). I record the active window, the World when there is none, and never the window that shows me: the window of a Replay tool is skipped (see ReplayAttachActiveWindow), so the Record button records the window used last. While I am shown (between openSession and closeSession), a ReplayRecordingToggleListener shared by all editors toggles recording on the key binding.

Library: a standalone editor offers to add its scenario to the macro library (Add to library), which hands it over to the library window. The library window embeds one of me on the scenario of its selected macro (see onMacro:inLibrary:) and opens and closes my session. Then my Edit shortcut button shows a ReplayMacroEditor on the macro settings, and I notify the library window when those settings or the scenario title, which names the macro, change.

Semantic names: replayPresenterAt:ifAbsent: answers my widgets by stable names for Replay actions ('Step list', 'Action list', 'Action chooser', 'Record button', ...). The presenters of the action editor register their own names (registerReplayPresenter:named:) while buildActionEditor: builds them, and are forgotten when the pane is replaced. The settings of the macro are found while they are shown.
"
Class {
	#name : 'ReplayEditor',
	#superclass : 'ReplayToolPresenter',
	#instVars : [
		'scenario',
		'stepList',
		'actionList',
		'actionDropList',
		'actionEditor',
		'recordTimingCheckBox',
		'recordButton',
		'stopRecordingButton',
		'recordingStatusPresenter',
		'shortcutButton',
		'namedPresenters',
		'replayPresenters',
		'recorder',
		'macro',
		'macroLibrary',
		'macroEditor',
		'macroChangeBlock',
		'titleChangeBlock'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'instance creation' }
ReplayEditor class >> new [

	^ self on: ReplayScenario new
]

{ #category : 'instance creation' }
ReplayEditor class >> on: scenario [

	^ self basicNew initialize scenario: scenario
]

{ #category : 'instance creation' }
ReplayEditor class >> onMacro: aReplayMacro inLibrary: aReplayMacroLibrary [
	"An editor for the scenario of a library macro, as shown in the library window.
	It also edits the shortcut of the macro."

	^ self basicNew
		  setMacro: aReplayMacro library: aReplayMacroLibrary;
		  initialize;
		  scenario: aReplayMacro scenario;
		  yourself
]

{ #category : 'instance creation' }
ReplayEditor class >> onSton: aScenarioSTONString [

	^ self on: (STON fromString: aScenarioSTONString)
]

{ #category : 'instance creation' }
ReplayEditor class >> open [

	<script>
	^ self new open
]

{ #category : 'instance creation' }
ReplayEditor class >> openOn: aScenario [
	"Show the editor of aScenario, never a second one.
	A scenario of the default macro library is edited in the library window."

	ReplayMacroRegistry hasDefault ifTrue: [
		| registry |
		registry := ReplayMacroRegistry default.
		(registry library macroWithScenario: aScenario) ifNotNil: [ :macro |
			^ (ReplayMacroLibraryEditor openOnRegistry: registry)
				  showMacro: macro;
				  yourself ] ].
	^ self
		  openInstanceSuchThat: [ :editor | editor scenario == aScenario ]
		  ifNone: [ self on: aScenario ]
]

{ #category : 'recording' }
ReplayEditor class >> recordingKeyBinding [
	"The binding that starts and stops recording: Cmd + R, or Ctrl + R where Control is the default modifier"

	^ ReplayKeyBinding character: $r modifiers: OSPlatform current defaultModifier replayModifiers
]

{ #category : 'editing' }
ReplayEditor >> actionChanged: anAction [
	"Sent by the settings of anAction after they edit it: show its new label"

	actionList list refresh
]

{ #category : 'accessing' }
ReplayEditor >> actionEditor [
	"The presenter shown in the right pane"

	^ actionEditor presenterAt: 1
]

{ #category : 'accessing' }
ReplayEditor >> actions [
	"The action list presenter"

	^ actionList
]

{ #category : 'editing' }
ReplayEditor >> addAction [
	"The + button of the action list adds an action of the kind shown by the action chooser"

	actionDropList selectedItem ifNotNil: [ :actionClass | self addActionLast: actionClass new ].
	^ nil "The action is already in the list"
]

{ #category : 'editing' }
ReplayEditor >> addAction: action after: another [
	"Add action after another in the current step, or last when another is not in it"

	self ensureStep.
	(self currentStep actions includes: another) ifFalse: [ ^ self addActionLast: action ].
	self currentStep actions add: action after: another.
	self showActionsSelecting: action
]

{ #category : 'editing' }
ReplayEditor >> addAction: action before: another [
	"Add action before another in the current step, or last when another is not in it"

	self ensureStep.
	(self currentStep actions includes: another) ifFalse: [ ^ self addActionLast: action ].
	self currentStep actions add: action before: another.
	self showActionsSelecting: action
]

{ #category : 'editing' }
ReplayEditor >> addActionLast: action [

	self ensureStep.
	self currentStep addAction: action.
	self showActionsSelecting: action
]

{ #category : 'recording' }
ReplayEditor >> addRecordedActions: aCollectionOfActions [

	aCollectionOfActions ifEmpty: [ ^ self ].
	self ensureStep.
	aCollectionOfActions do: [ :action | self currentStep addAction: action ].
	self showActionsSelecting: aCollectionOfActions last
]

{ #category : 'action editor' }
ReplayEditor >> buildActionEditor: aBlock [
	"Show in the right pane the presenter that aBlock builds. The semantic names of the previous pane are forgotten before aBlock registers the ones of the new pane."

	| pane |
	self stopShortcutCaptures.
	self clearReplayPresenterTargets.
	pane := aBlock value.
	self registerReplayPresenter: pane named: 'Action editor'.
	actionEditor presenters
		ifEmpty: [ actionEditor add: pane ]
		ifNotEmpty: [ actionEditor replaceAtIndex: 1 with: pane ].
	pane takeKeyboardFocus.
	^ pane
]

{ #category : 'replay' }
ReplayEditor >> clearReplayPresenterTargets [

	replayPresenters := Dictionary new
]

{ #category : 'session' }
ReplayEditor >> closeSession [
	"I am no longer shown: stop recording, stop listening to the recording key binding and to captured shortcuts"

	self stopRecording.
	ReplayRecordingToggleListener unregister: self.
	self stopShortcutCaptures
]

{ #category : 'initialization' }
ReplayEditor >> connectPresenters [

	stepList
		addItemBlock: [ ReplayStep new ];
		removeItemBlock: [ :step | self removeStep: step ];
		whenSelectionChangedDo: [ :selection | self selectStep: selection selectedItem ].
	actionList
		addItemBlock: [ self addAction ];
		removeItemBlock: [ :action | self removeAction: action ];
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :action | self selectAction: action ] ]
]

{ #category : 'accessing' }
ReplayEditor >> currentAction [
	"The action selected in the action list, or nil"

	^ actionList selectedItem
]

{ #category : 'accessing' }
ReplayEditor >> currentStep [
	"The step selected in the step list, or nil"

	^ stepList selectedItem
]

{ #category : 'layout' }
ReplayEditor >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		add: self toolbar expand: false;
		add: self recordingControls expand: false;
		add: (SpPanedLayout newLeftToRight
			positionOfSlider: 0.3;
			add: (SpBoxLayout newLeftToRight
				add: (SpBoxLayout newTopToBottom
					add: self editScenarioButton expand: false;
					add: shortcutButton expand: false;
					add: stepList;
					yourself);
				add: (SpBoxLayout newTopToBottom
					add: self stepNavigationEditor expand: false;
					add: actionDropList expand: false;
					add: actionList;
					yourself);
				yourself);
			add: (SpBoxLayout newLeftToRight
				add: actionEditor withConstraints: [ :c | c padding: 10 ]);
			yourself);
		yourself
]

{ #category : 'layout' }
ReplayEditor >> editScenarioButton [

	^ SpButtonPresenter new
		  icon: (self iconNamed: #edit);
		  label: 'Edit scenario data';
		  help: 'Edit the data of the scenario, such as its title';
		  action: [ self editScenarioData ]
]

{ #category : 'action editor' }
ReplayEditor >> editScenarioData [

	self unselectAction.
	self buildActionEditor: [ self scenario editionPresenterOn: self ].
	self isInLibrary ifTrue: [
		self replayPresenters
			at: 'Scenario title'
			ifPresent: [ :titlePresenter |
			titlePresenter whenTextChangedDo: [ self scenarioTitleChanged ] ] ]
]

{ #category : 'macro' }
ReplayEditor >> editShortcut [

	self unselectAction.
	self buildActionEditor: [ self macroEditor ]
]

{ #category : 'action editor' }
ReplayEditor >> editStepNavigation [

	self currentStep ifNil: [ ^ self ].
	self unselectAction.
	self buildActionEditor: [ self currentStep navigation editionPresenterOn: self ]
]

{ #category : 'editing' }
ReplayEditor >> ensureStep [
	"Select a step, the first one, created when the scenario has none"

	self currentStep ifNotNil: [ ^ self ].
	self scenario steps ifEmpty: [
		self scenario addStep: ReplayStep new.
		stepList items: self scenario steps ].
	stepList selectIndex: 1
]

{ #category : 'layout' }
ReplayEditor >> homePresenter [

	^ self newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #example) expand: false;
						    add: 'Create or select an action to edit it.';
						    yourself)
				   withConstraints: [ :c |
					   c expand: false.
					   c padding: 10 ];
				   yourself);
		  yourself
]

{ #category : 'tools' }
ReplayEditor >> importScenario [

	(self uiManager
		 request: 'Paste the STON string of a scenario to edit it.'
		 initialAnswer: ''
		 title: 'Import Scenario') ifNotEmpty: [ :string |
		self scenario: (STON fromString: string) ]
]

{ #category : 'initialization' }
ReplayEditor >> initializePresenters [

	| shortcut |
	shortcut := self recordingShortcutDescription.
	stepList := SpEditableListPresenter new.
	actionList := SpEditableListPresenter new.
	(actionDropList := self newDropList)
		items: ReplayAction actionsForDropList;
		display: [ :action | action displayName ];
		help: 'Choose the kind of action that the + button of the action list adds to the current step.'.
	recordTimingCheckBox := self newCheckBox
		label: 'Preserve timing';
		state: false;
		help: 'Record delays between captured actions.';
		yourself.
	recordButton := self newButton
		label: 'Record';
		help: 'Record the window used last, or the World when no other window is open. Press ' , shortcut , ' in a window to record it.';
		action: [ self startRecording ];
		yourself.
	stopRecordingButton := self newButton
		label: 'Stop recording';
		help: 'Stop recording, also with ' , shortcut , ', and add the recorded actions to the current step.';
		action: [ self stopRecording ];
		yourself.
	recordingStatusPresenter := self newLabel
		label: self recordingStatusText;
		yourself.
	shortcutButton := self newShortcutButton.
	namedPresenters := Dictionary new
		at: 'Step list' put: stepList;
		at: 'Action list' put: actionList;
		at: 'Action chooser' put: actionDropList;
		at: 'Record button' put: recordButton;
		at: 'Stop recording button' put: stopRecordingButton;
		at: 'Preserve timing checkbox' put: recordTimingCheckBox;
		at: 'Recording status' put: recordingStatusPresenter;
		at: (self isInLibrary
				 ifTrue: [ 'Edit shortcut button' ]
				 ifFalse: [ 'Add to library button' ])
		put: shortcutButton;
		yourself.
	actionEditor := SpBoxLayout newLeftToRight.
	self showHome
]

{ #category : 'initialization' }
ReplayEditor >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	aWindow
		title: 'Replay Scenario Editor';
		initialExtent: 1200 @ 675;
		whenOpenedDo: [ self openSession ];
		whenClosedDo: [ self closeSession ]
]

{ #category : 'macro' }
ReplayEditor >> isInLibrary [

	^ macro isNotNil
]

{ #category : 'recording' }
ReplayEditor >> isRecording [
	^ recorder notNil
]

{ #category : 'macro' }
ReplayEditor >> macro [
	"The library macro whose scenario I edit, or nil when my scenario is not in a library"

	^ macro
]

{ #category : 'macro' }
ReplayEditor >> macroEditor [
	"The settings of my macro, shown by the Edit shortcut button, or nil when my scenario is not in a library"

	macro ifNil: [ ^ nil ].
	^ macroEditor ifNil: [
		  macroEditor := (ReplayMacroEditor on: macro inLibrary: macroLibrary)
			                 whenMacroChangedDo: [ macroChangeBlock ifNotNil: [ macroChangeBlock value ] ];
			                 yourself ]
]

{ #category : 'macro' }
ReplayEditor >> moveToLibrary [

	^ [ self moveToLibraryOf: ReplayMacroRegistry default ]
		  on: ReplayError
		  do: [ :error |
			  self inform: error messageText.
			  nil ]
]

{ #category : 'macro' }
ReplayEditor >> moveToLibraryOf: aReplayMacroRegistry [
	"Hand my scenario over to the library window, which saves it, and close: a scenario has a single editor.
	A recording ends first, so that its actions are in the scenario that the library window shows."

	| libraryMacro |
	self closeSession.
	libraryMacro := (ReplayMacroLibraryEditor openOnRegistry: aReplayMacroRegistry) showScenario: self scenario.
	self withWindowDo: [ :window | window close ].
	^ libraryMacro
]

{ #category : 'initialization' }
ReplayEditor >> newShortcutButton [
	"In a library, my scenario can be bound to a shortcut. Otherwise, it must move to a library first."

	^ self isInLibrary
		  ifTrue: [
				  self newButton
					  icon: (self iconNamed: #scriptManager);
					  label: 'Edit shortcut';
					  help: 'Edit the key binding and contexts that run this scenario as a macro.';
					  action: [ self editShortcut ];
					  yourself ]
		  ifFalse: [
				  self newButton
					  icon: (self iconNamed: #add);
					  label: 'Add to library';
					  help: 'Move this scenario to the macro library window, which saves it and can bind it to a shortcut.';
					  action: [ self moveToLibrary ];
					  yourself ]
]

{ #category : 'session' }
ReplayEditor >> openSession [
	"I am shown: toggle recording with the recording key binding"

	ReplayRecordingToggleListener register: self
]

{ #category : 'layout' }
ReplayEditor >> recordingControls [
	^ SpBoxLayout newLeftToRight
		spacing: 8;
		add: recordButton expand: false;
		add: stopRecordingButton expand: false;
		add: recordTimingCheckBox expand: false;
		add: recordingStatusPresenter expand: false;
		yourself
]

{ #category : 'recording' }
ReplayEditor >> recorder [
	"The recorder of the current recording, or nil"

	^ recorder
]

{ #category : 'recording' }
ReplayEditor >> recordingKeyBinding [

	^ self class recordingKeyBinding
]

{ #category : 'recording' }
ReplayEditor >> recordingShortcutDescription [

	^ self recordingKeyBinding displayString
]

{ #category : 'recording' }
ReplayEditor >> recordingStatusText [

	| shortcut target |
	shortcut := self recordingShortcutDescription.
	recorder ifNil: [ ^ 'Press ' , shortcut , ' to record the active window.' ].
	target := recorder manager managedUI.
	^ 'Recording ' , ((target isKindOf: SystemWindow)
		   ifTrue: [ '"' , target label , '"' ]
		   ifFalse: [ 'the World' ]) , '. Stop with ' , shortcut , '.'
]

{ #category : 'recording' }
ReplayEditor >> recordingTargetMorph [
	"The active window, never mine, or the World when there is none"

	^ ReplayAttachActiveWindow activeWindowMorphFromHand: self hand
]

{ #category : 'replay' }
ReplayEditor >> registerReplayPresenter: aPresenter named: aString [

	self replayPresenters at: aString put: aPresenter.
	^ aPresenter
]

{ #category : 'editing' }
ReplayEditor >> removeAction: action [
	"When removing an action with the editable list"

	action ifNil: [ ^ self ].
	self removeItem: action from: actionList.
	actionList selectedItem ifNil: [ self showHome ]
]

{ #category : 'editing' }
ReplayEditor >> removeItem: item from: specList [
	"Remove item from a list, and select the next item, or the previous one when item is the last"

	| items index |
	items := specList items.
	index := items indexOf: item.
	index = 0 ifTrue: [ ^ self ].
	items removeIndex: index.
	specList items: items.
	items ifNotEmpty: [ specList selectIndex: (index min: items size) ]
]

{ #category : 'editing' }
ReplayEditor >> removeStep: step [
	"When removing a step with the editable list"

	step ifNil: [ ^ self ].
	self removeItem: step from: stepList.
	stepList selectedItem ifNil: [ self selectStep: nil ]
]

{ #category : 'replay' }
ReplayEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	^ namedPresenters at: aPresenterName ifAbsent: [
		  self replayPresenters at: aPresenterName ifAbsent: [
			  self shownMacroEditor
				  ifNil: absentBlock
				  ifNotNil: [ :editor | editor replayPresenterAt: aPresenterName ifAbsent: absentBlock ] ] ]
]

{ #category : 'replay' }
ReplayEditor >> replayPresenters [
	"The semantic names registered by the presenters of the action editor"

	^ replayPresenters ifNil: [ replayPresenters := Dictionary new ]
]

{ #category : 'tools' }
ReplayEditor >> runScenario [

	scenario run
]

{ #category : 'tools' }
ReplayEditor >> runStep [

	self currentStep ifNotNil: [ :step | (ReplayRunner on: scenario) runStep: step ]
]

{ #category : 'tools' }
ReplayEditor >> saveScenario [

	Clipboard
		clipboardText: (STON toString: scenario)
		informing: 'Scenario copied to clipboard!'
]

{ #category : 'accessing' }
ReplayEditor >> scenario [

	^ scenario
]

{ #category : 'accessing' }
ReplayEditor >> scenario: aScenario [
	"In a library, my scenario is the one of my macro: replacing one replaces the other, and renames the macro"

	scenario := aScenario.
	aScenario steps ifEmpty: [ aScenario addStep: ReplayStep new ].
	stepList items: aScenario steps.
	stepList selectIndex: 1.
	(macro isNotNil and: [ macro scenario ~~ aScenario ]) ifTrue: [
		macro scenario: aScenario.
		self scenarioTitleChanged ]
]

{ #category : 'macro' }
ReplayEditor >> scenarioTitleChanged [
	"My macro is named after my scenario"

	macro updateKeymapDescriptions.
	titleChangeBlock ifNotNil: [ titleChangeBlock value ]
]

{ #category : 'editing' }
ReplayEditor >> selectAction: action [
	"When an action has been selected in the action list"

	self buildActionEditor: [ action editionPresenterOn: self ]
]

{ #category : 'editing' }
ReplayEditor >> selectStep: aStepOrNil [
	"When the selection of the step list changed: show the actions of the selected step and select the first one"

	actionList items: (aStepOrNil ifNil: [ #(  ) ] ifNotNil: [ aStepOrNil actions ]).
	(aStepOrNil isNil or: [ aStepOrNil actions isEmpty ]) ifTrue: [ ^ self showHome ].
	actionList selectIndex: 1
]

{ #category : 'macro' }
ReplayEditor >> setMacro: aReplayMacro library: aReplayMacroLibrary [

	macro := aReplayMacro.
	macroLibrary := aReplayMacroLibrary
]

{ #category : 'accessing' }
ReplayEditor >> shortcutButton [

	^ shortcutButton
]

{ #category : 'editing' }
ReplayEditor >> showActionsSelecting: anAction [
	"Show the actions of the current step after they changed, and select anAction"

	actionList items: self currentStep actions.
	actionList selectItem: anAction
]

{ #category : 'action editor' }
ReplayEditor >> showHome [

	^ self buildActionEditor: [ self homePresenter ]
]

{ #category : 'macro' }
ReplayEditor >> shownMacroEditor [
	"The settings of my macro when they are shown, or nil"

	^ (macroEditor notNil and: [ self actionEditor == macroEditor ])
		  ifTrue: [ macroEditor ]
		  ifFalse: [ nil ]
]

{ #category : 'recording' }
ReplayEditor >> startRecording [
	"Record the active window, never mine, or the World when there is none"

	self startRecordingOn: self recordingTargetMorph
]

{ #category : 'recording' }
ReplayEditor >> startRecordingOn: aMorph [
	"Record the user input in aMorph, a window or the World. The recorded actions attach to the same kind of target when replayed."

	self isRecording ifTrue: [ ^ self ].
	self ensureStep.
	recorder := ReplayRecorder new
		manager: (ReplayUIManager new observe: aMorph);
		preserveTiming: recordTimingCheckBox state;
		prologueActions: { aMorph isWorldMorph
				ifTrue: [ ReplayAttachWorld new ]
				ifFalse: [ ReplayAttachActiveWindow new ] };
		ignoreKeyBinding: self recordingKeyBinding;
		ignoreMorph: self windowMorph;
		yourself.
	recorder startOnHand: self hand.
	self updateRecordingStatus
]

{ #category : 'layout' }
ReplayEditor >> stepNavigationEditor [

	^ self newButton
		  icon: (self iconNamed: #edit);
		  label: 'Edit step navigation';
		  help:
			  'All steps end with a navigation action that can allow the user to continue or end the scenario';
		  action: [ self editStepNavigation ]
]

{ #category : 'accessing' }
ReplayEditor >> steps [
	"The step list presenter"

	^ stepList
]

{ #category : 'recording' }
ReplayEditor >> stopRecording [
	"Answer the recorded actions, which I add to the current step"

	| recordedActions |
	recorder ifNil: [ ^ #(  ) ].
	recordedActions := recorder stop.
	recorder manager close.
	recorder := nil.
	self updateRecordingStatus.
	self addRecordedActions: recordedActions.
	^ recordedActions
]

{ #category : 'action editor' }
ReplayEditor >> stopShortcutCaptures [
	"A shortcut capture must not outlive the pane that shows it"

	actionEditor presenters do: [ :pane |
		(pane isKindOf: SpPresenter) ifTrue: [
			(pane allPresenters copyWith: pane) do: [ :each |
				(each isKindOf: ReplayKeyBindingPresenter) ifTrue: [ each stopShortcutCapture ] ] ] ]
]

{ #category : 'layout' }
ReplayEditor >> toolbar [
	"I wish SpToolbarPresenter made buttons equal size"

	^ self newToolbar
		addStyle: 'stToolbar';
		add: (self newToolbarButton
			label: 'Copy';
			icon: (self iconNamed: #smallCopy);
			help: 'Copy the current scenario to the clipboard as a STON string.';
			action: [ self saveScenario ]);
		add: (self newToolbarButton
			label: 'Import';
			icon: (self iconNamed: #smallLoadProject);
			help: 'Replace the current scenario by one pasted as a STON string.';
			action: [ self importScenario ]);
		add: (self newToolbarButton
			label: 'Run';
			icon: (self iconNamed: #go);
			help: 'Execute current scenario.';
			action: [ self runScenario ]);
		add: (self newToolbarButton
			label: 'Run step';
			icon: (self iconNamed: #smallForward);
			help: 'Execute currently selected step.';
			action: [ self runStep ]);
		yourself
]

{ #category : 'editing' }
ReplayEditor >> unselectAction [
	"The action editor shows something else than the current action: selecting the action again shows it"

	actionList selectIndex: 0
]

{ #category : 'recording' }
ReplayEditor >> updateRecordingStatus [

	recordingStatusPresenter ifNil: [ ^ self ].
	recordingStatusPresenter label: self recordingStatusText
]

{ #category : 'macro' }
ReplayEditor >> whenMacroChangedDo: aBlock [
	"Evaluate aBlock after an edit of the settings of my macro"

	macroChangeBlock := aBlock
]

{ #category : 'macro' }
ReplayEditor >> whenTitleChangedDo: aBlock [
	"Evaluate aBlock after my scenario title, which names my macro, changes"

	titleChangeBlock := aBlock
]
