"
I group an ordered list of actions and the navigation settings used after those actions finish.
"
Class {
	#name : 'ReplayStep',
	#superclass : 'Object',
	#instVars : [
		'actions',
		'navigation'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'accessing' }
ReplayStep >> actions [

	^ actions ifNil: [ actions := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayStep >> actions: aCollectionOfActions [

	actions := aCollectionOfActions
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
