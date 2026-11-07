"
I record the gestures that the hand detects for me: on mouse down I ask it to wait for a click, a double click or a drag, as many Morphic widgets do.
"
Class {
	#name : 'ReplayClickOrDragMorph',
	#superclass : 'Morph',
	#instVars : [
		'gestures'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'event handling' }
ReplayClickOrDragMorph >> click: anEvent [

	gestures add: #click
]

{ #category : 'event handling' }
ReplayClickOrDragMorph >> doubleClick: anEvent [

	gestures add: #doubleClick
]

{ #category : 'accessing' }
ReplayClickOrDragMorph >> gestures [

	^ gestures
]

{ #category : 'event handling' }
ReplayClickOrDragMorph >> handlesMouseDown: anEvent [

	^ true
]

{ #category : 'initialization' }
ReplayClickOrDragMorph >> initialize [

	super initialize.
	gestures := OrderedCollection new.
	self extent: 100 @ 60
]

{ #category : 'event handling' }
ReplayClickOrDragMorph >> mouseDown: anEvent [

	gestures add: #mouseDown.
	anEvent hand waitForClicksOrDrag: self event: anEvent
]

{ #category : 'event handling' }
ReplayClickOrDragMorph >> mouseUp: anEvent [

	gestures add: #mouseUp
]

{ #category : 'event handling' }
ReplayClickOrDragMorph >> startDrag: anEvent [

	gestures add: #startDrag
]
