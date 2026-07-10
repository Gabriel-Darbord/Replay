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
ReplayEditorDemo class >> editScenario [

	<script>
	^ self scenario edit
]

{ #category : 'running' }
ReplayEditorDemo class >> run [

	<script>
	^ self scenario run
]

{ #category : 'instance creation' }
ReplayEditorDemo class >> scenario [

	^ self new scenario
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

	^ self stepNamed: 'Tour Replay editor widgets' with: {
		self clearAnnotationsAction.
		self annotate: 'Step list' text: 'Steps group actions control scenario navigation.'.
		self annotate: 'Action chooser' text: 'The action chooser lists Replay actions available to insert.'.
		self annotate: 'Action list' text: 'Actions run in order inside the selected step.'.
		self annotate: 'Action editor' text: 'Selecting an action shows its editable controls here.' }
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
		self closeReplayUIAction.
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
ReplayEditorDemo >> closeReplayUIAction [

	^ ReplayCloseUI new
]

{ #category : 'steps' }
ReplayEditorDemo >> editingStep [

	^ self stepNamed: 'Insert and edit actions' with: {
		self clearAnnotationsAction.
		self addScriptActionInEditor.
		self annotate: 'Action list' text: 'A Script action was inserted into the current step.'.
		self annotate: 'Action editor' text: 'The selected Script action exposes an editable source field.' }
]

{ #category : 'steps' }
ReplayEditorDemo >> keyboardStep [

	^ self stepNamed: 'Drive chooser keyboard actions' with: {
		self clearAnnotationsAction.
		self annotate: 'Action chooser' text: 'Keyboard actions can drive focused widgets, such as moving through this chooser.'.
		self pressDownInActionChooser }
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

{ #category : 'steps' }
ReplayEditorDemo >> replaceScriptStep [

	^ self stepNamed: 'Replace field value' with: self replaceScriptSourceActions , {
		self clearAnnotationsAction.
		self annotate: 'Action script' text: 'Select text and Type replaced the Script action source.'.
		self annotate: 'Action list' text: 'The edited action remains selected in the action list.' }
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
	scenario addStep: self scriptFieldStep.
	scenario addStep: self replaceScriptStep.
	scenario addStep: self cleanupStep.
	^ scenario
]

{ #category : 'actions' }
ReplayEditorDemo >> script: aString [

	^ ReplayScript new
		script: aString;
		yourself
]

{ #category : 'steps' }
ReplayEditorDemo >> scriptFieldStep [

	^ self stepNamed: 'Expose action editor fields' with: {
		self clearAnnotationsAction.
		self annotate: 'Action script' text: 'The selected Script action exposes the source field as a semantic target.'.
		self annotate: 'Action editor' text: 'Macros can target fields inside the current action editor without Morph paths.' }
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
		self attachEditorAction }
]

{ #category : 'building' }
ReplayEditorDemo >> stepNamed: aString with: actions [

	| step |
	step := ReplayStep new.
	actions do: [ :action | step addAction: action ].
	step navigation
		text: aString;
		skip: false.
	^ step
]

{ #category : 'actions' }
ReplayEditorDemo >> type: aString into: targetName [

	^ ReplayType new
		targetNamed: targetName;
		text: aString;
		yourself
]
