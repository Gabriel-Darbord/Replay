"
I execute a ReplayScenario step by step, managing action dispatch, UI manager state, and navigation.

My cursor is a step index and an action index; past the last action of a step, the cursor is on the step navigation. Actions run one after the other in a loop. An action that controls the runner continuation (it waits for the UI, a delay, or the user) sends `nextAction` or `nextStep` when it is done, possibly later from a deferred block. When it does so synchronously, the running loop goes on instead of nesting a new one, so the stack does not grow with the scenario.

Any error raised while running actions or deferred continuations stops me: the managed UI is closed (or detached when it is not owned), then the error goes on to the usual handlers.

My focus is free for scenario scripts to remember an object between actions.
"
Class {
	#name : 'ReplayRunner',
	#superclass : 'Object',
	#instVars : [
		'scenario',
		'manager',
		'stepIndex',
		'actionIndex',
		'focus',
		'proceeding',
		'advanced'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'instance creation' }
ReplayRunner class >> on: scenario [

	^ self new scenario: scenario
]

{ #category : 'accessing' }
ReplayRunner >> backend [
	"Answer the backend of the managed UI, or a default one when no UI is managed."

	^ manager
		  ifNil: [ ReplayUIBackend new ]
		  ifNotNil: [ manager backend ]
]

{ #category : 'accessing' }
ReplayRunner >> currentAction [
	"Answer the action under the cursor: an action of the current step, or its navigation once they are done."

	| step |
	step := self currentStep.
	^ actionIndex > step actions size
		  ifTrue: [ step navigation ]
		  ifFalse: [ step actions at: actionIndex ]
]

{ #category : 'accessing' }
ReplayRunner >> currentStep [

	^ scenario steps at: stepIndex
]

{ #category : 'running' }
ReplayRunner >> defer: aBlock [
	"Evaluate aBlock later in the UI process. Errors there stop me like errors of synchronous actions."

	self backend defer: [ self protect: aBlock ]
]

{ #category : 'accessing' }
ReplayRunner >> focus [
	"Answer the object scenario scripts chose to remember."

	^ focus
]

{ #category : 'accessing' }
ReplayRunner >> focus: anObject [

	focus := anObject
]

{ #category : 'initialization' }
ReplayRunner >> initialize [

	proceeding := false.
	advanced := false
]

{ #category : 'testing' }
ReplayRunner >> isStopped [

	^ actionIndex isNil
]

{ #category : 'accessing' }
ReplayRunner >> manager [

	^ manager
]

{ #category : 'accessing' }
ReplayRunner >> manager: aReplayUIManager [
	"Replace the managed UI. The previous manager is closed so its UI or overlay does not leak."

	(manager notNil and: [ manager ~~ aReplayUIManager ]) ifTrue: [
		manager close ].
	manager := aReplayUIManager
]

{ #category : 'running' }
ReplayRunner >> nextAction [
	"Continue after the current action.
	Actions that control the runner continuation send me once they are done."

	self isStopped ifTrue: [ ^ self ].
	actionIndex := actionIndex + 1.
	self proceed
]

{ #category : 'running' }
ReplayRunner >> nextStep [
	"Continue with the first action of the next step, or stop after the last step."

	(stepIndex isNil or: [ stepIndex >= scenario steps size ]) ifTrue: [
		^ self stop ].
	stepIndex := stepIndex + 1.
	actionIndex := 1.
	self proceed
]

{ #category : 'running' }
ReplayRunner >> proceed [
	"Run the actions from the cursor. When the loop is already running, an action continued
	synchronously: the loop goes on from the moved cursor instead of nesting another loop."

	proceeding ifTrue: [ ^ advanced := true ].
	proceeding := true.
	[ self protect: [ self runFromCursor ] ] ensure: [ proceeding := false ]
]

{ #category : 'running' }
ReplayRunner >> protect: aBlock [
	"Evaluate aBlock. If it fails, stop the scenario, closing or detaching the managed UI, then let the error through."

	^ aBlock
		  on: Error
		  do: [ :error |
			  self stop.
			  error pass ]
]

{ #category : 'running' }
ReplayRunner >> run [

	stepIndex := 0.
	actionIndex := 0.
	self nextStep
]

{ #category : 'running' }
ReplayRunner >> runAction: action [

	action runOn: self
]

{ #category : 'running' }
ReplayRunner >> runFromCursor [
	"Run actions until one takes control of the continuation or the scenario ends."

	[ self isStopped ] whileFalse: [
		| action |
		advanced := false.
		action := self currentAction.
		self runAction: action.
		(advanced or: [ self isStopped ]) ifFalse: [
			action controlsRunnerContinuation ifTrue: [ ^ self ].
			actionIndex := actionIndex + 1 ] ]
]

{ #category : 'running' }
ReplayRunner >> runStep: step [
	"Run the scenario from the given step."

	| index |
	index := scenario steps indexOf: step.
	index = 0 ifTrue: [
		ReplayError new
			messageText: 'Cannot run a step that is not in the scenario.';
			subject: step;
			signal ].
	stepIndex := index - 1.
	actionIndex := 0.
	self nextStep
]

{ #category : 'accessing' }
ReplayRunner >> scenario [

	^ scenario
]

{ #category : 'accessing' }
ReplayRunner >> scenario: aScenario [

	scenario := aScenario
]

{ #category : 'running' }
ReplayRunner >> settleUI [

	manager ifNil: [ ^ self backend settleUI ].
	manager settleUI
]

{ #category : 'running' }
ReplayRunner >> stop [
	"End the scenario, can happen before its last step."

	stepIndex := nil.
	actionIndex := nil.
	self manager: nil
]
