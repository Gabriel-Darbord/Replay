"
I simulate a mouse drag gesture across a resolved UI target using local start and end offsets, button flags, modifiers, and interpolated move events.
"
Class {
	#name : 'ReplayDrag',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithFlags',
	#classTraits : 'TReplayActionWithFlags classTrait',
	#instVars : [
		'startPosition',
		'endPosition',
		'steps',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayDrag class >> displayName [

	^ 'Drag'
]

{ #category : 'adding' }
ReplayDrag >> addModifiers: anInteger [

	self modifiers: (self modifiers bitOr: anInteger).
	^ anInteger
]

{ #category : 'editing' }
ReplayDrag >> buttonsPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		add: 'Mouse buttons:' expand: false;
		add: (self flagsPresenterOn: editor namesAndValues: {
			'Left drag'. MouseEvent redButton.
			'Right drag'. MouseEvent yellowButton.
			'Middle drag'. MouseEvent blueButton }) expand: false;
		yourself
]

{ #category : 'running' }
ReplayDrag >> dragOn: ui [

	| startPoint endPoint hand target downEvent previousPoint |
	startPoint := self worldStartPositionIn: ui.
	endPoint := self worldEndPositionIn: ui.
	hand := self newHandAt: startPoint.
	downEvent := self mouseDownEventAt: startPoint hand: hand.
	target := self targetStartingAt: ui handling: #handlesMouseDown: with: downEvent.
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
		pointPresenterOn: editor
		label: 'End offset:'
		value: self endPositionOrZero
		update: [ :point | self endPosition: point ]
]

{ #category : 'testing' }
ReplayDrag >> hasModifiers: anInteger [

	^ (self modifiers bitAnd: anInteger) = anInteger
]

{ #category : 'initialization' }
ReplayDrag >> initialize [

	super initialize.
	flags := MouseEvent redButton.
	steps := 1.
	modifiers := 0
]

{ #category : 'running' }
ReplayDrag >> interpolatedPointFrom: startPoint to: endPoint atStep: stepIndex [

	^ startPoint + ((endPoint - startPoint) * (stepIndex / self steps))
]

{ #category : 'running' }
ReplayDrag >> localEndPositionIn: aMorph [

	^ self endPosition ifNil: [ aMorph center ] ifNotNil: [ :point | aMorph topLeft + point ]
]

{ #category : 'running' }
ReplayDrag >> localStartPositionIn: aMorph [

	^ self startPosition ifNil: [ aMorph center ] ifNotNil: [ :point | aMorph topLeft + point ]
]

{ #category : 'editing' }
ReplayDrag >> modifierFlagsPresenterOn: editor namesAndValues: pairs [

	^ SpGridLayout build: [ :layout |
		pairs pairsDo: [ :name :value |
			| checkbox targetName |
			targetName := self flagTargetNameFor: name.
			checkbox := editor newCheckBox
				label: name;
				state: (self hasModifiers: value);
				whenActivatedDo: [ self addModifiers: value ];
				whenDeactivatedDo: [ self removeModifiers: value ];
				yourself.
			editor registerReplayPresenter: checkbox named: 'Action drag ' , targetName.
			editor registerReplayPresenter: checkbox named: self class displayName , ' ' , targetName.
			layout add: checkbox ] ]
]

{ #category : 'accessing' }
ReplayDrag >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayDrag >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'editing' }
ReplayDrag >> modifiersPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		add: 'Keyboard modifiers:' expand: false;
		add: (self modifierFlagsPresenterOn: editor namesAndValues: #(Shift 8 Control 16 'Alt/Option' 32 Command 64)) expand: false;
		yourself
]

{ #category : 'running' }
ReplayDrag >> mouseDownEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: aPoint
		which: self flags
		buttons: (self flags bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayDrag >> mouseMoveEventFrom: startPoint to: endPoint hand: aHand [

	^ MouseMoveEvent new
		setType: #mouseMove
		startPoint: startPoint
		endPoint: endPoint
		trail: { startPoint. endPoint }
		buttons: (self flags bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayDrag >> mouseUpEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseUp
		position: aPoint
		which: self flags
		buttons: self modifiers
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayDrag >> newHandAt: aPoint [

	^ HandMorph new
		position: aPoint;
		privateOwner: self currentWorld;
		yourself
]

{ #category : 'editing' }
ReplayDrag >> pointPresenterOn: editor label: label value: point update: updateBlock [

	| xInput yInput targetName |
	targetName := (label allButLast copyReplaceAll: ' ' with: ' ') asLowercase.
	xInput := editor newNumberInput.
	xInput
		numberType: Float;
		number: point x;
		whenNumberChangedDo: [ :number |
			updateBlock value: number @ point y.
			editor actions rebuildLayout ].
	yInput := editor newNumberInput.
	yInput
		numberType: Float;
		number: point y;
		whenNumberChangedDo: [ :number |
			updateBlock value: point x @ number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: xInput named: 'Action ' , targetName , ' x'.
	editor registerReplayPresenter: yInput named: 'Action ' , targetName , ' y'.
	^ SpBoxLayout newTopToBottom
		add: label expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'X' expand: false;
			add: xInput;
			add: 'Y' expand: false;
			add: yInput;
			yourself) expand: false;
		yourself
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
	self flags = MouseEvent redButton ifFalse: [
		stream nextPutAll: ' button='; print: self flags ].
	self modifiers = 0 ifFalse: [
		stream nextPutAll: ' modifiers='; print: self modifiers ]
]

{ #category : 'removing' }
ReplayDrag >> removeModifiers: anInteger [

	self modifiers: (self modifiers bitClear: anInteger).
	^ anInteger
]

{ #category : 'running' }
ReplayDrag >> runOn: runner onUI: ui [

	self dragOn: ui
]

{ #category : 'running' }
ReplayDrag >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runDrag: self
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
		pointPresenterOn: editor
		label: 'Start offset:'
		value: self startPositionOrZero
		update: [ :point | self startPosition: point ]
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
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Action drag steps'.
	editor registerReplayPresenter: input named: self class displayName , ' steps'.
	^ SpBoxLayout newTopToBottom
		add: 'Move steps:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'running' }
ReplayDrag >> targetStartingAt: aMorph handling: selector with: anEvent [

	| target |
	target := aMorph.
	[ target notNil and: [ (target perform: selector with: anEvent) not ] ]
		whileTrue: [ target := target owner ].
	^ target ifNil: [ aMorph ]
]

{ #category : 'running' }
ReplayDrag >> worldEndPositionIn: aMorph [

	^ aMorph pointInWorld: (self localEndPositionIn: aMorph)
]

{ #category : 'running' }
ReplayDrag >> worldStartPositionIn: aMorph [

	^ aMorph pointInWorld: (self localStartPositionIn: aMorph)
]
