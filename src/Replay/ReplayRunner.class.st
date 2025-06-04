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
		'actionIndex',
		'focus'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'instance creation' }
ReplayRunner class >> on: scenario [

	^ self new scenario: scenario
]

{ #category : 'accessing' }
ReplayRunner >> currentAction [

	^ self currentStep actions at: actionIndex
]

{ #category : 'accessing' }
ReplayRunner >> currentStep [

	^ scenario steps at: stepIndex
]

{ #category : 'accessing' }
ReplayRunner >> focus [

	^ focus
]

{ #category : 'accessing' }
ReplayRunner >> focus: anObject [

	focus := anObject
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
	step := self currentStep.

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

{ #category : 'enumerating' }
ReplayRunner >> previousAction [

	actionIndex = 1 ifFalse: [
		^ self currentStep actions at: actionIndex - 1 ].

	self shouldBeImplemented
]

{ #category : 'running' }
ReplayRunner >> run [

	stepIndex := 0.
	self nextStep
]

{ #category : 'running' }
ReplayRunner >> runAction [

	| action |
	action := self currentAction.

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
