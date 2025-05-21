"
Model for the `ReplayEditor`.
"
Class {
	#name : 'ReplayEditorModel',
	#superclass : 'Object',
	#instVars : [
		'scenario',
		'currentStep',
		'currentAction'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'adding' }
ReplayEditorModel >> addAction: action [

	^ currentStep addAction: (currentAction := action)
]

{ #category : 'adding' }
ReplayEditorModel >> addStep [

	^ scenario addStep: self newStep
]

{ #category : 'adding' }
ReplayEditorModel >> addStep: step [

	^ scenario addStep: (currentStep := step)
]

{ #category : 'accessing' }
ReplayEditorModel >> currentAction [

	^ currentAction
]

{ #category : 'instance creation' }
ReplayEditorModel >> currentAction: action [

	^ currentAction := action
]

{ #category : 'accessing' }
ReplayEditorModel >> currentStep [

	^ currentStep
]

{ #category : 'accessing' }
ReplayEditorModel >> currentStep: step [

	currentStep := step
]

{ #category : 'instance creation' }
ReplayEditorModel >> newStep [

	^ currentStep := ReplayStep new
]

{ #category : 'accessing' }
ReplayEditorModel >> scenario [

	^ scenario ifNil: [ scenario := ReplayScenario new ]
]

{ #category : 'accessing' }
ReplayEditorModel >> scenario: aScenario [

	scenario := aScenario.
	currentStep := currentAction := nil
]
