"
I simulate a mouse drag gesture on a resolved UI target: a mouse down at my start offset, interpolated mouse moves, and a mouse up at my end offset, with the mouse buttons and keyboard modifiers of my superclass. Offsets are from the top-left corner of the target, nil for its center.

My events go through a ReplayHandMorph, with the mouse focus on the morph that handles the mouse down, found up the owner chain of the target. The hand detects the drag as Morphic does, so the morph can start a drag and drop: it then carries the dragged morph and drops it at my end offset, on whatever widget is there.
"
Class {
	#name : 'ReplayDrag',
	#superclass : 'ReplayPointerAction',
	#instVars : [
		'startPosition',
		'endPosition',
		'steps'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayDrag class >> editorClass [

	^ ReplayDragEditor
]

{ #category : 'accessing' }
ReplayDrag class >> displayName [

	^ 'Drag'
]

{ #category : 'running' }
ReplayDrag >> dragOn: aMorph [
	"Send my events through the hand, which detects the drag and starts a drag and drop when the morph handling the mouse down asks for it.
	The mouse focus goes to that morph first, as the hand of the World would give it."

	| startPoint endPoint hand downEvent previousPoint |
	startPoint := self worldPointAt: self startPosition in: aMorph.
	endPoint := self worldPointAt: self endPosition in: aMorph.
	hand := self newHandAt: startPoint.
	downEvent := self mouseDownEventAt: startPoint hand: hand.
	hand mouseFocus: (self targetStartingAt: aMorph handling: #handlesMouseDown: with: downEvent).
	[
		hand handleEvent: downEvent.
		previousPoint := startPoint.
		1 to: self steps do: [ :index |
			| nextPoint |
			nextPoint := self interpolatedPointFrom: startPoint to: endPoint atStep: index.
			hand handleEvent: (self mouseMoveEventFrom: previousPoint to: nextPoint hand: hand).
			previousPoint := nextPoint ].
		hand handleEvent: (self mouseUpEventAt: endPoint hand: hand) ]
		ensure: [ hand endGesture ]
]

{ #category : 'accessing' }
ReplayDrag >> endPosition [

	^ endPosition
]

{ #category : 'accessing' }
ReplayDrag >> endPosition: aPoint [

	endPosition := aPoint
]

{ #category : 'accessing' }
ReplayDrag >> endPositionOrZero [

	^ self endPosition ifNil: [ 0 @ 0 ]
]

{ #category : 'running' }
ReplayDrag >> interpolatedPointFrom: startPoint to: endPoint atStep: stepIndex [

	^ startPoint + ((endPoint - startPoint) * (stepIndex / self steps))
]

{ #category : 'events' }
ReplayDrag >> mouseMoveEventFrom: startPoint to: endPoint hand: aHand [

	^ MouseMoveEvent new
		setType: #mouseMove
		startPoint: startPoint
		endPoint: endPoint
		trail: { startPoint. endPoint }
		buttons: (self buttons bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'printing' }
ReplayDrag >> printOn: stream [

	super printOn: stream.
	self startPosition ifNotNil: [ :point |
		stream nextPutAll: ' from '; print: point ].
	self endPosition ifNotNil: [ :point |
		stream nextPutAll: ' to '; print: point ].
	self steps = 1 ifFalse: [
		stream nextPutAll: ' steps='; print: self steps ].
	self printButtonsAndModifiersOn: stream
]

{ #category : 'running' }
ReplayDrag >> runOnMorph: aMorph [

	self dragOn: aMorph
]

{ #category : 'accessing' }
ReplayDrag >> startPosition [

	^ startPosition
]

{ #category : 'accessing' }
ReplayDrag >> startPosition: aPoint [

	startPosition := aPoint
]

{ #category : 'accessing' }
ReplayDrag >> startPositionOrZero [

	^ self startPosition ifNil: [ 0 @ 0 ]
]

{ #category : 'accessing' }
ReplayDrag >> steps [

	^ steps ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayDrag >> steps: anInteger [

	steps := 1 max: anInteger asInteger
]
