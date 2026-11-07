"
I am the abstract base for actions that send synthetic mouse events to the Morphic widget of their target: clicks, drags and scrolls.

I hold the mouse buttons pressed during the gesture, a mask of MouseEvent buttons (redButton for the left button by default), and the keyboard modifiers held, a ReplayKeyModifiers mask. Positions are offsets from the top-left corner of the target widget, nil for its center; I convert them to World points.

My events are sent directly to the morph handling them, found by walking up the owner chain of the target, with a private hand that is not the hand of the World, so a replay does not move the mouse focus of the user.
"
Class {
	#name : 'ReplayPointerAction',
	#superclass : 'ReplayUIHandler',
	#instVars : [
		'buttons',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayPointerAction class >> buttonChoices [
	"The mouse button masks, with their display names"

	^ {
		  (MouseEvent redButton -> 'Left').
		  (MouseEvent yellowButton -> 'Right').
		  (MouseEvent blueButton -> 'Middle') }
]

{ #category : 'testing' }
ReplayPointerAction class >> isAbstract [

	^ self == ReplayPointerAction
]

{ #category : 'accessing' }
ReplayPointerAction >> buttons [
	"The mask of the mouse buttons pressed during my gesture"

	^ buttons ifNil: [ self defaultButtons ]
]

{ #category : 'accessing' }
ReplayPointerAction >> buttons: anInteger [

	buttons := anInteger
]

{ #category : 'editing' }
ReplayPointerAction >> buttonsPresenterOn: editor [
	"One check box per mouse button, registered as 'Action left click', 'Click left click'..."

	| layout |
	layout := SpBoxLayout newLeftToRight spacing: 8.
	self class buttonChoices do: [ :association |
		| label checkBox |
		label := association value , ' ' , self class displayName asLowercase.
		(checkBox := editor newCheckBox)
			label: label;
			state: (self hasButton: association key);
			whenChangedDo: [ :state |
				self setButton: association key to: state.
				editor actionChanged: self ].
		editor registerReplayPresenter: checkBox named: 'Action ' , label asLowercase.
		editor registerReplayPresenter: checkBox named: self class displayName , ' ' , label asLowercase.
		layout add: checkBox expand: false ].
	^ SpBoxLayout newTopToBottom
		add: 'Mouse buttons:' expand: false;
		add: layout expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayPointerAction >> defaultButtons [

	^ MouseEvent redButton
]

{ #category : 'testing' }
ReplayPointerAction >> hasButton: aMask [

	^ (self buttons bitAnd: aMask) ~= 0
]

{ #category : 'accessing' }
ReplayPointerAction >> modifiers [
	"The ReplayKeyModifiers mask of the keys held during my gesture"

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayPointerAction >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'editing' }
ReplayPointerAction >> modifiersPresenterOn: editor [

	| presenter |
	presenter := editor instantiate: ReplayKeyModifiersPresenter.
	presenter
		modifiers: self modifiers;
		whenChangedDo: [ :newModifiers |
			self modifiers: newModifiers.
			editor actionChanged: self ].
	presenter registerReplayPresentersOn: editor named: 'Action ' , self class displayName asLowercase.
	presenter registerReplayPresentersOn: editor named: self class displayName.
	^ SpBoxLayout newTopToBottom
		add: 'Keyboard modifiers:' expand: false;
		add: presenter expand: false;
		yourself
]

{ #category : 'events' }
ReplayPointerAction >> mouseDownEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: aPoint
		which: self buttons
		buttons: (self buttons bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayPointerAction >> mouseUpEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseUp
		position: aPoint
		which: self buttons
		buttons: self modifiers
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayPointerAction >> newHandAt: aPoint [
	"A hand for my events, apart from the hand of the World"

	^ HandMorph new
		position: aPoint;
		privateOwner: self currentWorld;
		yourself
]

{ #category : 'editing' }
ReplayPointerAction >> offsetPresenterOn: editor labeled: label named: aString get: getBlock set: setBlock [
	"Inputs for an offset point, registered as 'Action <aString> x' and 'Action <aString> y'"

	| xInput yInput |
	xInput := editor newNumberInput.
	xInput
		numberType: Float;
		number: getBlock value x;
		whenNumberChangedDo: [ :number |
			setBlock value: number @ getBlock value y.
			editor actionChanged: self ].
	yInput := editor newNumberInput.
	yInput
		numberType: Float;
		number: getBlock value y;
		whenNumberChangedDo: [ :number |
			setBlock value: getBlock value x @ number.
			editor actionChanged: self ].
	editor registerReplayPresenter: xInput named: 'Action ' , aString , ' x'.
	editor registerReplayPresenter: yInput named: 'Action ' , aString , ' y'.
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
ReplayPointerAction >> printButtonsAndModifiersOn: stream [

	self buttons = self defaultButtons ifFalse: [
		stream nextPutAll: ' buttons='.
		(self class buttonChoices select: [ :association | self hasButton: association key ])
			do: [ :association | stream nextPutAll: association value ]
			separatedBy: [ stream nextPut: $+ ] ].
	self modifiers = 0 ifFalse: [
		stream nextPutAll: ' modifiers='.
		(ReplayKeyModifiers namesOf: self modifiers)
			do: [ :name | stream nextPutAll: name ]
			separatedBy: [ stream nextPut: $+ ] ]
]

{ #category : 'accessing' }
ReplayPointerAction >> setButton: aMask to: aBoolean [

	self buttons: (aBoolean
			 ifTrue: [ self buttons bitOr: aMask ]
			 ifFalse: [ self buttons bitClear: aMask ])
]

{ #category : 'events' }
ReplayPointerAction >> targetStartingAt: aMorph handling: selector with: anEvent [
	"The first morph of the owner chain of aMorph that handles anEvent, as Morphic dispatch would find it, or aMorph when none does"

	| target |
	target := aMorph.
	[ target notNil and: [ (target perform: selector with: anEvent) not ] ]
		whileTrue: [ target := target owner ].
	^ target ifNil: [ aMorph ]
]

{ #category : 'events' }
ReplayPointerAction >> worldPointAt: anOffset in: aMorph [
	"The World point at anOffset from the top-left corner of aMorph, or at its center when anOffset is nil"

	^ aMorph pointInWorld: (anOffset
			   ifNil: [ aMorph center ]
			   ifNotNil: [ aMorph topLeft + anOffset ])
]
