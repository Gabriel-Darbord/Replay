"
I represent a step in a `ReplayScenario`.
I am composed of `ReplayAction`s that are executed sequentially.
After all the actions have been run with a `ReplayRunner`, a final `ReplayNavigate` action is executed.
This final action can be configured to return control to the user.
"
Class {
	#name : 'ReplayStep',
	#superclass : 'Object',
	#instVars : [
		'actions',
		'navigation'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayStep >> actions [

	^ actions ifNil: [ actions := OrderedCollection new ]
]

{ #category : 'adding' }
ReplayStep >> addAction: action [

	^ self actions add: action
]

{ #category : 'initialization' }
ReplayStep >> initialize [

	navigation := ReplayNavigate new
]

{ #category : 'accessing' }
ReplayStep >> navigation [
	"Action responsible for letting users navigate the scenario, executed after the step actions."

	^ navigation
]

{ #category : 'printing' }
ReplayStep >> printOn: stream [

	stream nextPutAll: 'Step'.
	navigation text ifNotEmpty: [ :text |
		stream nextPutAll: ': '.
		stream nextPutAll: text ]
]
