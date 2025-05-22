"
A state-based iterator for running a tutorial.
"
Class {
	#name : 'ReplayRunner',
	#superclass : 'Object',
	#instVars : [
		'scenario',
		'uiManager',
		'stepIndex',
		'actionIndex'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'instance creation' }
ReplayRunner class >> on: scenario [

	^ self new scenario: scenario
]

{ #category : 'accessing' }
ReplayRunner >> manager [

	^ uiManager
]

{ #category : 'accessing' }
ReplayRunner >> manager: aReplayUIManager [

	uiManager := aReplayUIManager
]

{ #category : 'running' }
ReplayRunner >> nextAction [

	| step |
	actionIndex := actionIndex + 1.
	step := scenario steps at: stepIndex.

	actionIndex > step actions size ifTrue: [ "End of step"
		^ step navigation runOn: self ].

	self runAction
]

{ #category : 'running' }
ReplayRunner >> nextStep [

	(stepIndex isNil or: [ stepIndex >= scenario steps size ]) ifTrue: [
		^ self stop ].

	stepIndex := stepIndex + 1.
	actionIndex := 0.
	self nextAction
]

{ #category : 'running' }
ReplayRunner >> run [

	stepIndex := 0.
	self nextStep
]

{ #category : 'running' }
ReplayRunner >> runAction [

	| action |
	action := (scenario steps at: stepIndex) actions at: actionIndex.

	action runOn: self.

	action isUIHandler ifFalse: [ "UI handlers have continuation control"
		self nextAction ]
]

{ #category : 'running' }
ReplayRunner >> runStep: step [

	stepIndex := (scenario steps indexOf: step) - 1.
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
ReplayRunner >> stop [
	"End the scenario, can happen before its last step"

	uiManager ifNotNil: [ uiManager close ]
]
