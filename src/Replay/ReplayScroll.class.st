"
I simulate mouse wheel scrolling over a resolved UI target with direction, count, local offset, and modifiers.
"
Class {
	#name : 'ReplayScroll',
	#superclass : 'ReplayUIHandler',
	#instVars : [
		'direction',
		'count',
		'position',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayScroll class >> directionChoices [

	^ {
		#up -> 'Up'.
		#down -> 'Down'.
		#left -> 'Left'.
		#right -> 'Right' }
]

{ #category : 'accessing' }
ReplayScroll class >> displayName [

	^ 'Scroll'
]

{ #category : 'adding' }
ReplayScroll >> addModifiers: anInteger [

	self modifiers: (self modifiers bitOr: anInteger).
	^ anInteger
]

{ #category : 'accessing' }
ReplayScroll >> count [

	^ count ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayScroll >> count: anInteger [

	count := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplayScroll >> countPresenterOn: editor [

	| input |
	input := editor newNumberInput.
	input
		minimum: 1;
		numberType: Integer;
		number: self count;
		whenNumberChangedDo: [ :number |
			self count: number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Action scroll count'.
	editor registerReplayPresenter: input named: self class displayName , ' count'.
	^ SpBoxLayout newTopToBottom
		add: 'Scroll count:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayScroll >> direction [

	^ direction ifNil: [ #down ]
]

{ #category : 'accessing' }
ReplayScroll >> direction: aSymbol [

	(#(#up #down #left #right) includes: aSymbol)
		ifFalse: [ ReplayError new messageText: 'Unsupported scroll direction: ', aSymbol asString; tag: aSymbol; signal ].
	direction := aSymbol
]

{ #category : 'running' }
ReplayScroll >> directionCharacter [

	self direction = #up ifTrue: [ ^ Character arrowUp ].
	self direction = #left ifTrue: [ ^ Character arrowLeft ].
	self direction = #right ifTrue: [ ^ Character arrowRight ].
	^ Character arrowDown
]

{ #category : 'editing' }
ReplayScroll >> directionPresenterOn: editor [

	| dropList choices |
	choices := self class directionChoices.
	dropList := editor newDropList.
	dropList
		items: choices;
		display: [ :association | association value ];
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
				self direction: association key.
				editor actions rebuildLayout ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self direction ]
		ifNone: [ choices second ]).
	editor registerReplayPresenter: dropList named: 'Action scroll direction'.
	editor registerReplayPresenter: dropList named: self class displayName , ' direction'.
	^ SpBoxLayout newTopToBottom
		add: 'Scroll direction:' expand: false;
		add: dropList expand: false;
		yourself
]

{ #category : 'testing' }
ReplayScroll >> hasModifiers: anInteger [

	^ (self modifiers bitAnd: anInteger) = anInteger
]

{ #category : 'running' }
ReplayScroll >> localPositionIn: aMorph [

	^ self position ifNil: [ aMorph center ] ifNotNil: [ :point | aMorph topLeft + point ]
]

{ #category : 'editing' }
ReplayScroll >> modifierFlagTargetNameFor: aString [

	^ (aString asString copyReplaceAll: '/' with: ' ') asLowercase
]

{ #category : 'editing' }
ReplayScroll >> modifierFlagsPresenterOn: editor namesAndValues: pairs [

	^ SpGridLayout build: [ :layout |
		pairs pairsDo: [ :name :value |
			| checkbox targetName |
			targetName := self modifierFlagTargetNameFor: name.
			checkbox := editor newCheckBox
				label: name;
				state: (self hasModifiers: value);
				whenActivatedDo: [ self addModifiers: value ];
				whenDeactivatedDo: [ self removeModifiers: value ];
				yourself.
			editor registerReplayPresenter: checkbox named: 'Action scroll ' , targetName.
			editor registerReplayPresenter: checkbox named: self class displayName , ' ' , targetName.
			layout add: checkbox ] ]
]

{ #category : 'accessing' }
ReplayScroll >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayScroll >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'editing' }
ReplayScroll >> modifiersPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		add: 'Keyboard modifiers:' expand: false;
		add: (self modifierFlagsPresenterOn: editor namesAndValues: #(Shift 8 Control 16 'Alt/Option' 32 Command 64)) expand: false;
		yourself
]

{ #category : 'running' }
ReplayScroll >> newHandAt: aPoint [

	^ HandMorph new
		position: aPoint;
		privateOwner: self currentWorld;
		yourself
]

{ #category : 'accessing' }
ReplayScroll >> position [

	^ position
]

{ #category : 'accessing' }
ReplayScroll >> position: aPoint [

	position := aPoint
]

{ #category : 'accessing' }
ReplayScroll >> positionOrZero [

	^ self position ifNil: [ 0 @ 0 ]
]

{ #category : 'editing' }
ReplayScroll >> positionPresenterOn: editor [

	| xInput yInput |
	xInput := editor newNumberInput.
	xInput
		numberType: Float;
		number: self positionOrZero x;
		whenNumberChangedDo: [ :number |
			self position: number @ self positionOrZero y.
			editor actions rebuildLayout ].
	yInput := editor newNumberInput.
	yInput
		numberType: Float;
		number: self positionOrZero y;
		whenNumberChangedDo: [ :number |
			self position: self positionOrZero x @ number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: xInput named: 'Action scroll x'.
	editor registerReplayPresenter: yInput named: 'Action scroll y'.
	^ SpBoxLayout newTopToBottom
		add: 'Offset from target top-left:' expand: false;
		add: (SpBoxLayout newLeftToRight
			add: 'X' expand: false;
			add: xInput;
			add: 'Y' expand: false;
			add: yInput;
			yourself) expand: false;
		yourself
]

{ #category : 'printing' }
ReplayScroll >> printOn: stream [

	super printOn: stream.
	stream nextPutAll: ': '; nextPutAll: self direction asString.
	self count = 1 ifFalse: [
		stream nextPutAll: ' x'; print: self count ].
	self position ifNotNil: [ :point |
		stream nextPutAll: ' @ '; print: point ].
	self modifiers = 0 ifFalse: [
		stream nextPutAll: ' modifiers='; print: self modifiers ]
]

{ #category : 'removing' }
ReplayScroll >> removeModifiers: anInteger [

	self modifiers: (self modifiers bitClear: anInteger).
	^ anInteger
]

{ #category : 'running' }
ReplayScroll >> runOn: runner onUI: ui [

	self scrollOn: ui
]

{ #category : 'running' }
ReplayScroll >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runScroll: self
]

{ #category : 'running' }
ReplayScroll >> scrollOn: ui [

	| worldPoint hand target event |
	worldPoint := self worldPositionIn: ui.
	hand := self newHandAt: worldPoint.
	event := self wheelEventAt: worldPoint hand: hand.
	target := self targetStartingAt: ui handling: #handlesMouseWheel: with: event.
	self count timesRepeat: [
		hand position: worldPoint.
		event := self wheelEventAt: worldPoint hand: hand.
		event sentTo: target ]
]

{ #category : 'editing' }
ReplayScroll >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self directionPresenterOn: editor) expand: false;
			add: (self countPresenterOn: editor) expand: false;
			add: (self modifiersPresenterOn: editor) expand: false;
			add: (self positionPresenterOn: editor) expand: false;
			yourself);
		yourself
]

{ #category : 'running' }
ReplayScroll >> targetStartingAt: aMorph handling: selector with: anEvent [

	| target |
	target := aMorph.
	[ target notNil and: [ (target perform: selector with: anEvent) not ] ]
		whileTrue: [ target := target owner ].
	^ target ifNil: [ aMorph ]
]

{ #category : 'running' }
ReplayScroll >> wheelEventAt: aPoint hand: aHand [

	^ MouseWheelEvent new
		setType: #mouseWheel
		position: aPoint
		direction: self directionCharacter
		buttons: self modifiers
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayScroll >> worldPositionIn: aMorph [

	^ aMorph pointInWorld: (self localPositionIn: aMorph)
]
