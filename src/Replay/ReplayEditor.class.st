"
I am the Spec editor for Replay scenarios. I edit scenario metadata, step navigation, action ordering, and per-action settings.
"
Class {
	#name : 'ReplayEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'model',
		'actionDropList',
		'actionEditor',
		'stepList',
		'actionList',
		'replayPresenters',
		'recorder',
		'recordTimingCheckBox',
		'recordButton',
		'stopRecordingButton',
		'recordingStatusPresenter',
		'recordingShortcutListener',
		'recordingTargetDescription'
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
ReplayEditor class >> onSton: aScenarioSTONString [

	^ self on: (STON fromString: aScenarioSTONString)
]

{ #category : 'instance creation' }
ReplayEditor class >> open [

	<script>
	^ self new open
]

{ #category : 'accessing' }
ReplayEditor >> actionEditor [

	^ actionEditor presenterAt: 1
]

{ #category : 'accessing' }
ReplayEditor >> actionEditor: aPresenter [
	"Sent by a replay model class that knows how to present itself"

	actionEditor replaceAtIndex: 1 with: aPresenter.
	aPresenter takeKeyboardFocus
]

{ #category : 'accessing' }
ReplayEditor >> actions [
	"The action list presenter"

	^ actionList
]

{ #category : 'event handling' }
ReplayEditor >> addAction [
	"When creating an action with the editable list"

	self addActionLast: actionDropList selectedItem new.
	^ nil "Do not let the editable list event add something"
]

{ #category : 'adding' }
ReplayEditor >> addAction: action after: another [

	self ensureStep.
	self model currentStep actions add: action after: another.
	actionList selectItem: action.
	actionList rebuildLayout
]

{ #category : 'adding' }
ReplayEditor >> addAction: action before: another [

	self ensureStep.
	self model currentStep actions add: action before: another.
	actionList selectItem: action.
	actionList rebuildLayout
]

{ #category : 'adding' }
ReplayEditor >> addActionLast: action [

	self ensureStep.
	self model addAction: action.
	actionList selectIndex: actionList items size
]

{ #category : 'recording' }
ReplayEditor >> addRecordedActions: aCollectionOfActions [
	self ensureStep.
	aCollectionOfActions do: [ :action | self model addAction: action ].
	actionList items: self model currentStep actions.
	actionList rebuildLayout.
	aCollectionOfActions ifNotEmpty: [ actionList selectItem: aCollectionOfActions last ]
]

{ #category : 'recording' }
ReplayEditor >> bindRecordingShortcut [
	"Recording shortcuts are handled by a hand listener while the editor window is open."
]

{ #category : 'replay' }
ReplayEditor >> clearReplayPresenterTargets [

	replayPresenters := Dictionary new
]

{ #category : 'recording' }
ReplayEditor >> closeRecordingSession [

	self isRecording ifTrue: [ self stopRecording ].
	self uninstallRecordingShortcutListener
]

{ #category : 'initialization' }
ReplayEditor >> connectPresenters [
	stepList
		addItemBlock: [ self model newStep ];
		removeItemBlock: [ :step | self removeStep: step ];
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :step | self selectStep: step ] ].

	actionList
		addItemBlock: [ self addAction ];
		removeItemBlock: [ :item | self removeAction: item ];
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :action |
				self selectAction: action ] ].

	"Create an action when it is selected in drop list"
	actionDropList whenSelectedItemChangedDo: [ :actionClass |
		self addActionLast: actionClass new ].

	self bindRecordingShortcut
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

{ #category : 'tools' }
ReplayEditor >> editScenarioData [

	self clearReplayPresenterTargets.
	self actionEditor: (self model scenario editionPresenterOn: self)
]

{ #category : 'layout' }
ReplayEditor >> editStepNavigation [

	self clearReplayPresenterTargets.
	self actionEditor:
		(model currentStep navigation editionPresenterOn: self)
]

{ #category : 'event handling' }
ReplayEditor >> ensureStep [
	"Create a step if necessary"

	self model currentStep ifNil: [
		actionList items: model addStep actions.
		stepList selectIndex: 1.
		stepList rebuildLayout ]
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

{ #category : 'recording' }
ReplayEditor >> ignoreRecordingControlsOn: aReplayRecorder [
	{ recordButton. stopRecordingButton. recordTimingCheckBox } do: [ :presenter |
		self ignoreRecordingPresenter: presenter on: aReplayRecorder ]
]

{ #category : 'recording' }
ReplayEditor >> ignoreRecordingPresenter: aPresenter on: aReplayRecorder [
	| presenterAdapter widget |
	aPresenter ifNil: [ ^ self ].
	presenterAdapter := aPresenter adapter.
	presenterAdapter ifNil: [ ^ self ].
	widget := presenterAdapter widget.
	widget ifNotNil: [ aReplayRecorder ignoreMorph: widget ]
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
	stepList := SpEditableListPresenter new.
	actionList := SpEditableListPresenter new.

	(actionDropList := self newDropList)
		items: ReplayAction actionsForDropList;
		display: [ :action | action displayName ];
		help: 'Choose an action to add current step.'.

	recordTimingCheckBox := self newCheckBox
		label: 'Preserve timing';
		state: false;
		help: 'Record delays between captured actions.';
		yourself.
	recordButton := self newButton
		label: 'Record World';
		help: 'Record at World scope. Use ' , self recordingShortcutDescription , ' from another window to record the active window.';
		action: [ self startRecording ];
		yourself.
	stopRecordingButton := self newButton
		label: 'Stop';
		help: 'Stop recording with ' , self recordingShortcutDescription , ' and add captured actions to current step.';
		action: [ self stopRecording ];
		yourself.
	recordingStatusPresenter := self newLabel
		label: self recordingStatusText;
		yourself.

	actionEditor := SpBoxLayout newLeftToRight.
	actionEditor add: self homePresenter
]

{ #category : 'initialization' }
ReplayEditor >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	aWindow title: 'Scenario Editor'.
	aWindow initialExtent: 1200 @ 675.
	self installRecordingShortcutListener.
	aWindow whenClosedDo: [ self closeRecordingSession ]
]

{ #category : 'recording' }
ReplayEditor >> installRecordingShortcutListener [

	recordingShortcutListener ifNotNil: [ ^ self ].
	recordingShortcutListener := ReplayRecordingToggleListener on: self.
	World activeHand addEventListener: recordingShortcutListener
]

{ #category : 'recording' }
ReplayEditor >> isRecording [
	^ recorder notNil
]

{ #category : 'tools' }
ReplayEditor >> macroForCurrentScenario [

	^ self macroForCurrentScenarioIn: ReplayMacroRegistry default
]

{ #category : 'tools' }
ReplayEditor >> macroForCurrentScenarioIn: aReplayMacroRegistry [

	^ aReplayMacroRegistry library macroForScenario: self model scenario
]

{ #category : 'accessing' }
ReplayEditor >> model [

	^ model ifNil: [ model := ReplayEditorModel new ]
]

{ #category : 'recording' }
ReplayEditor >> modifierFlagsFromEvent: anEvent [

	| modifiers |
	modifiers := 0.
	anEvent shiftPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent shiftKeyMask ].
	anEvent controlKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent ctrlKeyMask ].
	(anEvent optionKeyPressed or: [ anEvent altKeyPressed ]) ifTrue: [ modifiers := modifiers bitOr: UserInputEvent altKeyMask ].
	anEvent commandKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent cmdKeyMask ].
	^ modifiers
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
ReplayEditor >> recordingShortcut [
	^ ReplayShortcut new
		text: 'r';
		flags: self recordingShortcutFlags;
		asKMShortcut
]

{ #category : 'recording' }
ReplayEditor >> recordingShortcutDescription [

	^ self recordingShortcut asString
]

{ #category : 'recording' }
ReplayEditor >> recordingShortcutFlags [
	^ OSPlatform current defaultModifier eventCode
]

{ #category : 'recording' }
ReplayEditor >> recordingShortcutMatchesEvent: anEvent [

	| flags text |
	anEvent isKeyboard ifFalse: [ ^ false ].
	anEvent isKeyDown ifFalse: [ ^ false ].
	flags := self modifierFlagsFromEvent: anEvent.
	flags = self recordingShortcutFlags ifFalse: [ ^ false ].
	text := anEvent modifiedCharacter asString asLowercase.
	^ text = 'r'
]

{ #category : 'recording' }
ReplayEditor >> recordingStatusForTargetMorph: aMorph [

	aMorph == World ifTrue: [ ^ 'Recording World.' ].
	^ 'Recording active window.'
]

{ #category : 'recording' }
ReplayEditor >> recordingStatusText [

	| shortcut |
	shortcut := self recordingShortcutDescription.
	^ self isRecording
		ifTrue: [ (recordingTargetDescription ifNil: [ 'Recording.' ]) , ' Stop with ' , shortcut , '.' ]
		ifFalse: [ 'Not recording. Record or stop with ' , shortcut , '.' ]
]

{ #category : 'recording' }
ReplayEditor >> recordingTargetMorph [
	^ World
]

{ #category : 'recording' }
ReplayEditor >> recordingTargetMorphForShortcutEvent: anEvent [

	^ ReplayAttachActiveWindow activeWindowMorphFromHand: anEvent hand
]

{ #category : 'replay' }
ReplayEditor >> registerReplayPresenter: aPresenter named: aString [

	self replayPresenters at: aString put: aPresenter.
	^ aPresenter
]

{ #category : 'event handling' }
ReplayEditor >> removeAction: action [
	"When removing an action with the editable list"

	self removeItem: action from: actionList.
	actionList items ifEmpty: [
		self clearReplayPresenterTargets.
		self actionEditor: self homePresenter ]
]

{ #category : 'event handling' }
ReplayEditor >> removeItem: item from: specList [
	"Elegantly remove an item from a Spec list"

	| items nextIndex |
	(items := specList items) ifEmpty: [ ^ self ].

	items size = 1 ifTrue: [ "Delete the only step in the list"
		^ specList removeItem: item "Also unselects! `items remove:` when it matters" ].

	"Select the next element, or the previous if deleted is last"
	nextIndex := (items indexOf: item) min: items size - 1.
	specList items remove: item.
	specList selectIndex: nextIndex.
	specList rebuildLayout
]

{ #category : 'event handling' }
ReplayEditor >> removeStep: step [
	"When removing a step with the editable list"

	step ifNil: [ ^ self ].
	self removeItem: step from: stepList.
	stepList items
		ifEmpty: [ "There are no more steps"
			self model currentStep: nil.
			actionList items: #(  ) "Should never try to add to this array" ]
		ifNotEmpty: [ "The selected step was changed"
			| selectedStep |
			selectedStep := stepList selectedItem.
			self model currentStep: selectedStep.
			actionList items: selectedStep actions ]
]

{ #category : 'replay' }
ReplayEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [
	aPresenterName = 'Step list' ifTrue: [ ^ stepList ].
	aPresenterName = 'Action list' ifTrue: [ ^ actionList ].
	aPresenterName = 'Action chooser' ifTrue: [ ^ actionDropList ].
	aPresenterName = 'Action editor' ifTrue: [ ^ self actionEditor ].
	aPresenterName = 'Record button' ifTrue: [ ^ recordButton ].
	aPresenterName = 'Stop recording button' ifTrue: [ ^ stopRecordingButton ].
	aPresenterName = 'Preserve timing checkbox' ifTrue: [ ^ recordTimingCheckBox ].
	aPresenterName = 'Recording status' ifTrue: [ ^ recordingStatusPresenter ].
	^ self replayPresenters
		at: aPresenterName
		ifAbsent: [ super replayPresenterAt: aPresenterName ifAbsent: absentBlock ]
]

{ #category : 'replay' }
ReplayEditor >> replayPresenters [

	^ replayPresenters ifNil: [ replayPresenters := Dictionary new ]
]

{ #category : 'tools' }
ReplayEditor >> runScenario [

	model scenario run
]

{ #category : 'tools' }
ReplayEditor >> runStep [

	(ReplayRunner on: model scenario) runStep: model currentStep
]

{ #category : 'tools' }
ReplayEditor >> saveScenario [

	Clipboard
		clipboardText: (STON toString: model scenario)
		informing: 'Scenario copied to clipboard!'
]

{ #category : 'accessing' }
ReplayEditor >> scenario: scenario [

	| steps |
	self model scenario: scenario.
	steps := scenario steps.
	steps ifEmpty: [ self model addStep ].
	stepList items: steps.
	stepList selectItem: steps first
]

{ #category : 'event handling' }
ReplayEditor >> selectAction: action [
	"When an action has been selected in the action list"

	self model currentAction: action.
	self clearReplayPresenterTargets.
	self actionEditor: (action editionPresenterOn: self)
]

{ #category : 'event handling' }
ReplayEditor >> selectStep: step [
	"When a step has been selected in the step list"

	model currentStep: step.
	actionList items: step actions.
	step actions
		ifEmpty: [
			self clearReplayPresenterTargets.
			self actionEditor: self homePresenter ]
		ifNotEmpty: [ actionList selectIndex: 1 ]
]

{ #category : 'recording' }
ReplayEditor >> startRecording [

	self
		startRecordingOn: self recordingTargetMorph
		attachAction: ReplayAttachWorld new
		status: 'Recording World.'
]

{ #category : 'recording' }
ReplayEditor >> startRecordingFromShortcutEvent: anEvent [

	| target attachAction |
	target := self recordingTargetMorphForShortcutEvent: anEvent.
	attachAction := target == World
		ifTrue: [ ReplayAttachWorld new ]
		ifFalse: [ ReplayAttachActiveWindow new ].
	self
		startRecordingOn: target
		attachAction: attachAction
		status: (self recordingStatusForTargetMorph: target)
]

{ #category : 'recording' }
ReplayEditor >> startRecordingOn: targetMorph attachAction: attachAction status: statusString [

	| manager |
	self isRecording ifTrue: [ ^ self ].
	self ensureStep.
	manager := ReplayUIManager new observe: targetMorph.
	recorder := ReplayRecorder new
		manager: manager;
		preserveTiming: recordTimingCheckBox state;
		prologueActions: { attachAction };
		yourself.
	recordingTargetDescription := statusString.
	recorder stopShortcutText: 'r' flags: self recordingShortcutFlags do: [ self stopRecording ].
	self ignoreRecordingControlsOn: recorder.
	recorder start.
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

	| recordedActions activeRecorder |
	recorder ifNil: [ ^ #() ].
	activeRecorder := recorder.
	recordedActions := activeRecorder stop.
	activeRecorder manager close.
	recorder := nil.
	recordingTargetDescription := nil.
	self updateRecordingStatus.
	self addRecordedActions: recordedActions.
	^ recordedActions
]

{ #category : 'recording' }
ReplayEditor >> toggleRecording [
	self isRecording
		ifTrue: [ self stopRecording ]
		ifFalse: [ self startRecording ]
]

{ #category : 'recording' }
ReplayEditor >> toggleRecordingFromShortcutEvent: anEvent [

	self isRecording
		ifTrue: [ self stopRecording ]
		ifFalse: [ self startRecordingFromShortcutEvent: anEvent ]
]

{ #category : 'layout' }
ReplayEditor >> toolbar [
	"I wish SpToolbarPresenter made buttons equal size"

	^ self newToolbar
		addStyle: 'stToolbar';
		add: (self newToolbarButton
				label: 'Save';
				icon: (self iconNamed: #save);
				help:
					'Copy current scenario clipboard STON string.';
				action: [ self saveScenario ]);
		add: (self newToolbarButton
				label: 'Import';
				icon: (self iconNamed: #smallLoadProject);
				help: 'Import serialized scenario from STON string.';
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
		add: (self newToolbarButton
				label: 'Macro';
				icon: (self iconNamed: #keymapBrowser);
				help: 'Create or edit a macro backed by current scenario.';
				action: [ self useScenarioAsMacro ]);
		yourself
]

{ #category : 'recording' }
ReplayEditor >> uninstallRecordingShortcutListener [

	recordingShortcutListener ifNil: [ ^ self ].
	World activeHand removeEventListener: recordingShortcutListener.
	recordingShortcutListener := nil
]

{ #category : 'recording' }
ReplayEditor >> updateRecordingStatus [

	recordingStatusPresenter ifNil: [ ^ self ].
	recordingStatusPresenter label: self recordingStatusText
]

{ #category : 'tools' }
ReplayEditor >> useScenarioAsMacro [

	| registry editor macro |
	registry := ReplayMacroRegistry default.
	macro := self macroForCurrentScenarioIn: registry.
	editor := ReplayMacroLibraryEditor onRegistry: registry.
	editor addMacroForScenario: self model scenario.
	editor open.
	^ macro
]
