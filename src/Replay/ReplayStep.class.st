"
I group an ordered list of actions and the navigation settings used after those actions finish.

My navigation is only serialized when it differs from the default one, which skips user navigation.
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

	super initialize.
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

{ #category : 'ston persistence' }
ReplayStep >> stonOn: stonWriter [
	"Omit the navigation when it is the default one."

	stonWriter writeObject: self streamMap: [ :map |
		actions isEmptyOrNil ifFalse: [ map at: #actions put: actions ].
		navigation isDefault ifFalse: [ map at: #navigation put: navigation ] ]
]
