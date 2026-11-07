"
I simulate mouse wheel scrolling over a resolved UI target: count wheel events in a direction, at an offset from the top-left corner of the target (nil for its center), with the keyboard modifiers of my superclass. No mouse button is pressed by default.

My events go to the morph that handles mouse wheel events, found up the owner chain of the target.
"
Class {
	#name : 'ReplayScroll',
	#superclass : 'ReplayPointerAction',
	#instVars : [
		'direction',
		'count',
		'position'
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
			editor actionChanged: self ].
	editor registerReplayPresenter: input named: 'Action scroll count'.
	editor registerReplayPresenter: input named: self class displayName , ' count'.
	^ SpBoxLayout newTopToBottom
		add: 'Scroll count:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayScroll >> defaultButtons [
	"Scrolling holds no mouse button"

	^ 0
]

{ #category : 'accessing' }
ReplayScroll >> direction [

	^ direction ifNil: [ #down ]
]

{ #category : 'accessing' }
ReplayScroll >> direction: aSymbol [

	(#(#up #down #left #right) includes: aSymbol)
		ifFalse: [ ReplayError new messageText: 'Unsupported scroll direction: ', aSymbol asString; subject: aSymbol; signal ].
	direction := aSymbol
]

{ #category : 'events' }
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
				editor actionChanged: self ] ].
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

{ #category : 'accessing' }
ReplayScroll >> position [
	"My offset from the top-left corner of the target, nil to scroll over its center"

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

	^ self
		  offsetPresenterOn: editor
		  labeled: 'Offset from target top-left:'
		  named: 'scroll'
		  get: [ self positionOrZero ]
		  set: [ :point | self position: point ]
]

{ #category : 'printing' }
ReplayScroll >> printOn: stream [

	super printOn: stream.
	stream nextPutAll: ': '; nextPutAll: self direction asString.
	self count = 1 ifFalse: [
		stream nextPutAll: ' x'; print: self count ].
	self position ifNotNil: [ :point |
		stream nextPutAll: ' @ '; print: point ].
	self printButtonsAndModifiersOn: stream
]

{ #category : 'running' }
ReplayScroll >> runOnMorph: aMorph [

	self scrollOn: aMorph
]

{ #category : 'running' }
ReplayScroll >> scrollOn: aMorph [

	| worldPoint hand target |
	worldPoint := self worldPointAt: self position in: aMorph.
	hand := self newHandAt: worldPoint.
	target := self
		          targetStartingAt: aMorph
		          handling: #handlesMouseWheel:
		          with: (self wheelEventAt: worldPoint hand: hand).
	self count timesRepeat: [
		hand position: worldPoint.
		(self wheelEventAt: worldPoint hand: hand) sentTo: target ]
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

{ #category : 'events' }
ReplayScroll >> wheelEventAt: aPoint hand: aHand [

	^ MouseWheelEvent new
		setType: #mouseWheel
		position: aPoint
		direction: self directionCharacter
		buttons: (self buttons bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]
