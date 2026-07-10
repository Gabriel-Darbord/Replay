"
I build a Replay scenario that demonstrates Replay features over the Replay editor itself.
"
Class {
	#name : 'ReplayEditorDemo',
	#superclass : 'Object',
	#category : 'Replay-Demo',
	#package : 'Replay-Demo'
}

{ #category : 'opening' }
ReplayEditorDemo class >> openScenario [

	^ self scenario edit
]

{ #category : 'running' }
ReplayEditorDemo class >> run [

	^ self scenario run
]

{ #category : 'instance creation' }
ReplayEditorDemo class >> scenario [

	^ self new scenario
]

{ #category : 'actions' }
ReplayEditorDemo >> addDelayActionInEditor [

	^ self script: '| action |
action := ReplayDelay seconds: 0.75.
self focus addActionLast: action.
self focus actions selectIndex: self focus actions items size'
]

{ #category : 'actions' }
ReplayEditorDemo >> addScriptActionInEditor [

	^ self script: '| action |
action := ReplayScript new.
action script: ', self placeholderScript storeString, '.
self focus addActionLast: action.
self focus actions selectIndex: self focus actions items size'
]

{ #category : 'actions' }
ReplayEditorDemo >> annotate: targetName text: aString [

	^ ReplayAnnotate new
		targetNamed: targetName;
		text: aString;
		yourself
]

{ #category : 'steps' }
ReplayEditorDemo >> annotationStep [

	^ self stepNamed: 'Tour the Replay editor widgets' with: {
		self clearAnnotationsAction.
		self annotate: 'Step list' text: 'Steps group actions and decide how the scenario advances.'.
		self annotate: 'Action chooser' text: 'The action chooser lists the Replay actions available to insert.'.
		self annotate: 'Action list' text: 'Actions run in order inside the selected step.'.
		self annotate: 'Action editor' text: 'Selecting an action shows its editable controls here.'.
		self delay: 1 }
]

{ #category : 'actions' }
ReplayEditorDemo >> attachEditorAction [

	^ ReplayAttachUI new
		script: 'self focus';
		yourself
]

{ #category : 'steps' }
ReplayEditorDemo >> cleanupStep [

	^ self stepNamed: 'Finish cleanly' with: {
		self clearAnnotationsAction.
		self annotate: 'Step list' text: 'Replay can attach to an already-open UI, drive it, annotate it, and clean up its overlay.'.
		self delay: 0.75.
		self clearAnnotationsAction.
		self closeEditorAction }
]

{ #category : 'actions' }
ReplayEditorDemo >> clearAnnotationsAction [

	^ ReplayClearAnnotations new
]

{ #category : 'actions' }
ReplayEditorDemo >> closeEditorAction [

	^ self script: 'self focus window ifNotNil: [ :window | window close ]'
]

{ #category : 'actions' }
ReplayEditorDemo >> delay: seconds [

	^ ReplayDelay seconds: seconds
]

{ #category : 'steps' }
ReplayEditorDemo >> editingStep [

	^ self stepNamed: 'Insert and edit actions' with: {
		self clearAnnotationsAction.
		self annotate: 'Action chooser' text: 'Scenarios are edited by choosing an action class, then configuring the inserted action.'.
		self delay: 0.5.
		self addDelayActionInEditor.
		self delay: 0.5.
		self clearAnnotationsAction.
		self annotate: 'Action list' text: 'A Delay action was inserted into the current step.'.
		self annotate: 'Action editor' text: 'The selected Delay action exposes a numeric seconds editor.'.
		self delay: 1 }
]

{ #category : 'steps' }
ReplayEditorDemo >> keyboardStep [

	^ self stepNamed: 'Drive the editor with actions' with: {
		self clearAnnotationsAction.
		self annotate: 'Action chooser' text: 'Keyboard actions can drive focused widgets, such as moving through a chooser.'.
		self pressDownInActionChooser.
		self delay: 0.5.
		self addScriptActionInEditor.
		self delay: 0.5.
		self clearAnnotationsAction.
		self annotate: 'Action script' text: 'The current action exposes this script field as a semantic target.'.
		self delay: 0.5 } , self replaceScriptSourceActions , {
		self delay: 0.5.
		self clearAnnotationsAction.
		self annotate: 'Action list' text: 'The Script action was edited through Select text and Type actions.'.
		self annotate: 'Action editor' text: 'Macros can target fields inside the current action editor without Morph paths.'.
		self delay: 1 }
]

{ #category : 'actions' }
ReplayEditorDemo >> placeholderScript [

	^ 'self inform: ''replace me'''
]

{ #category : 'actions' }
ReplayEditorDemo >> pressDownInActionChooser [

	^ ReplayPressKey new
		targetNamed: 'Action chooser';
		keySelector: #down;
		repeatCount: 2;
		yourself
]

{ #category : 'actions' }
ReplayEditorDemo >> replaceScriptSourceActions [

	^ {
		self selectTextIn: 'Action script' from: 1 to: self placeholderScript size.
		self type: self replacementScript into: 'Action script' }
]

{ #category : 'actions' }
ReplayEditorDemo >> replacementScript [

	^ 'self manager clearOverlay'
]

{ #category : 'building' }
ReplayEditorDemo >> scenario [

	| scenario |
	scenario := ReplayScenario new
		title: 'Replay Editor Feature Tour';
		description: 'Demonstrates Replay actions over the Replay editor itself.';
		yourself.
	scenario addStep: self setupStep.
	scenario addStep: self annotationStep.
	scenario addStep: self editingStep.
	scenario addStep: self keyboardStep.
	scenario addStep: self cleanupStep.
	^ scenario
]

{ #category : 'actions' }
ReplayEditorDemo >> script: aString [

	^ ReplayScript new
		script: aString;
		yourself
]

{ #category : 'actions' }
ReplayEditorDemo >> selectTextIn: targetName from: startIndex to: stopIndex [

	^ ReplaySelectText new
		targetNamed: targetName;
		startIndex: startIndex;
		stopIndex: stopIndex;
		yourself
]

{ #category : 'actions' }
ReplayEditorDemo >> setupEditorAction [

	^ self script: '| scenario editor |
scenario := ReplayScenario new
	title: ''Scenario edited by Replay'';
	description: ''This small scenario is the target used by the Replay editor demo.'';
	yourself.
scenario addStep: ReplayStep new.
editor := ReplayEditor on: scenario.
self focus: editor.
editor open'
]

{ #category : 'building' }
ReplayEditorDemo >> setupStep [

	^ self stepNamed: 'Open and attach to the Replay editor' with: {
		self setupEditorAction.
		self attachEditorAction.
		(self delay: 0.25) }
]

{ #category : 'building' }
ReplayEditorDemo >> stepNamed: aString with: actions [

	| step |
	step := ReplayStep new.
	actions do: [ :action | step addAction: action ].
	step navigation
		text: aString;
		skip: true.
	^ step
]

{ #category : 'actions' }
ReplayEditorDemo >> type: aString into: targetName [

	^ ReplayType new
		targetNamed: targetName;
		text: aString;
		yourself
]
