"
I simulate a mouse drag gesture on a resolved UI target: a mouse down at my start offset, interpolated mouse moves, and a mouse up at my end offset, with the mouse buttons and keyboard modifiers of my superclass. Offsets are from the top-left corner of the target, nil for its center.

All my events go to the morph that handles the mouse down, found up the owner chain of the target, as the mouse focus would.
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

{ #category : 'accessing' }
ReplayDrag class >> displayName [

	^ 'Drag'
]

{ #category : 'running' }
ReplayDrag >> dragOn: aMorph [

	| startPoint endPoint hand target downEvent previousPoint |
	startPoint := self worldPointAt: self startPosition in: aMorph.
	endPoint := self worldPointAt: self endPosition in: aMorph.
	hand := self newHandAt: startPoint.
	downEvent := self mouseDownEventAt: startPoint hand: hand.
	target := self targetStartingAt: aMorph handling: #handlesMouseDown: with: downEvent.
	hand mouseFocus: target.
	downEvent sentTo: target.
	previousPoint := startPoint.
	1 to: self steps do: [ :index |
		| nextPoint moveEvent |
		nextPoint := self interpolatedPointFrom: startPoint to: endPoint atStep: index.
		hand position: nextPoint.
		moveEvent := self mouseMoveEventFrom: previousPoint to: nextPoint hand: hand.
		moveEvent sentTo: target.
		previousPoint := nextPoint ].
	(self mouseUpEventAt: endPoint hand: hand) sentTo: target
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

{ #category : 'editing' }
ReplayDrag >> endPositionPresenterOn: editor [

	^ self
		  offsetPresenterOn: editor
		  labeled: 'End offset:'
		  named: 'end offset'
		  get: [ self endPositionOrZero ]
		  set: [ :point | self endPosition: point ]
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

{ #category : 'editing' }
ReplayDrag >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self buttonsPresenterOn: editor) expand: false;
			add: (self modifiersPresenterOn: editor) expand: false;
			add: (self startPositionPresenterOn: editor) expand: false;
			add: (self endPositionPresenterOn: editor) expand: false;
			add: (self stepsPresenterOn: editor) expand: false;
			yourself);
		yourself
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

{ #category : 'editing' }
ReplayDrag >> startPositionPresenterOn: editor [

	^ self
		  offsetPresenterOn: editor
		  labeled: 'Start offset:'
		  named: 'start offset'
		  get: [ self startPositionOrZero ]
		  set: [ :point | self startPosition: point ]
]

{ #category : 'accessing' }
ReplayDrag >> steps [

	^ steps ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayDrag >> steps: anInteger [

	steps := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplayDrag >> stepsPresenterOn: editor [

	| input |
	input := editor newNumberInput.
	input
		minimum: 1;
		numberType: Integer;
		number: self steps;
		whenNumberChangedDo: [ :number |
			self steps: number.
			editor actionChanged: self ].
	editor registerReplayPresenter: input named: 'Action drag steps'.
	editor registerReplayPresenter: input named: self class displayName , ' steps'.
	^ SpBoxLayout newTopToBottom
		add: 'Move steps:' expand: false;
		add: input expand: false;
		yourself
]
