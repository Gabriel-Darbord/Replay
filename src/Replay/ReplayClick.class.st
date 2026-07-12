"
Simulates a mouse click on a UI element.
"
Class {
	#name : 'ReplayClick',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithDebugging + TReplayActionWithFlags',
	#classTraits : 'TReplayActionWithDebugging classTrait + TReplayActionWithFlags classTrait',
	#instVars : [
		'position',
		'clickCount',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayClick class >> displayName [

	^ 'Click'
]

{ #category : 'adding' }
ReplayClick >> addModifiers: anInteger [

	self modifiers: (self modifiers bitOr: anInteger).
	^ anInteger
]

{ #category : 'editing' }
ReplayClick >> buttonsPresenterOn: editor [
	"Flags for the buttons to press, a combination of the left, right and middle clicks."

	^ SpBoxLayout new
		  add: 'Which buttons to press:';
		  add: (self flagsPresenterOn: editor namesAndValues: {
						   'Left click'.
						   MouseEvent redButton.
						   'Right click'.
						   MouseEvent yellowButton.
						   'Middle click'.
						   MouseEvent blueButton });
		  yourself
]

{ #category : 'accessing' }
ReplayClick >> clickCount [

	^ clickCount ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayClick >> clickCount: anInteger [

	clickCount := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplayClick >> clickCountPresenterOn: editor [

	| input |
	input := editor newNumberInput.
	input
		minimum: 1;
		numberType: Integer;
		number: self clickCount;
		whenNumberChangedDo: [ :number |
			self clickCount: number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Action click count'.
	editor registerReplayPresenter: input named: self class displayName , ' count'.
	^ SpBoxLayout newTopToBottom
		add: 'Click count:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'running' }
ReplayClick >> clickOn: ui [

	| worldPoint hand target |
	worldPoint := self worldPositionIn: ui.
	hand := self newHandAt: worldPoint.
	target := nil.
	1 to: self clickCount do: [ :index |
		| downEvent upEvent |
		hand position: worldPoint.
		downEvent := self mouseDownEventAt: worldPoint hand: hand.
		target := self targetStartingAt: ui handling: #handlesMouseDown: with: downEvent.
		hand mouseFocus: target.
		downEvent sentTo: target.
		target click: downEvent.
		index = 2 ifTrue: [ target doubleClick: downEvent asPseudoDoubleClickEvent ].
		upEvent := self mouseUpEventAt: worldPoint hand: hand.
		upEvent sentTo: target ]
]

{ #category : 'debugging' }
ReplayClick >> debugClickOn: editor [

	| builder |
	builder := ReplayUIBuilder on: editor model scenario.

	builder whenDone: [
		self findElementIn: builder manager managedUI thenDo: [ :ui |
			| debugSession |
			debugSession := self debug: [ self clickOn: ui ].
			3 timesRepeat: [ debugSession stepInto ] ] ].

	"We need to open the window for the UI to load correctly"
	(SpMorphPresenter new morph:
			 (builder uiForAction: self inStep: editor model currentStep))
		asWindow
		title: 'Debugging Click Event';
		open;
		maximize
]

{ #category : 'testing' }
ReplayClick >> hasModifiers: anInteger [

	^ (self modifiers bitAnd: anInteger) = anInteger
]

{ #category : 'initialization' }
ReplayClick >> initialize [

	flags := MouseEvent redButton.
	clickCount := 1.
	modifiers := 0
]

{ #category : 'testing' }
ReplayClick >> isClick [

	^ true
]

{ #category : 'testing' }
ReplayClick >> isSimpleLeftClick [

	^ self flags = MouseEvent redButton
		and: [ self modifiers = 0
			and: [ self position isNil
				and: [ self clickCount = 1 ] ] ]
]

{ #category : 'running' }
ReplayClick >> localPositionIn: aMorph [

	^ self position ifNil: [ aMorph center ] ifNotNil: [ :point | aMorph topLeft + point ]
]

{ #category : 'editing' }
ReplayClick >> modifierFlagsPresenterOn: editor namesAndValues: pairs [

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
			editor registerReplayPresenter: checkbox named: 'Action click ' , targetName.
			editor registerReplayPresenter: checkbox named: self class displayName , ' ' , targetName.
			layout add: checkbox ] ]
]

{ #category : 'accessing' }
ReplayClick >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayClick >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'editing' }
ReplayClick >> modifiersPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		add: 'Keyboard modifiers:' expand: false;
		add: (self modifierFlagsPresenterOn: editor namesAndValues: #(Shift 8 Control 16 'Alt/Option' 32 Command 64)) expand: false;
		yourself
]

{ #category : 'running' }
ReplayClick >> mouseDownEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: aPoint
		which: self flags
		buttons: (self flags bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayClick >> mouseUpEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseUp
		position: aPoint
		which: self flags
		buttons: self modifiers
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayClick >> newHandAt: aPoint [

	^ HandMorph new
		position: aPoint;
		privateOwner: self currentWorld;
		yourself
]

{ #category : 'accessing' }
ReplayClick >> position [

	^ position
]

{ #category : 'accessing' }
ReplayClick >> position: aPoint [

	position := aPoint
]

{ #category : 'accessing' }
ReplayClick >> positionOrZero [

	^ self position ifNil: [ 0 @ 0 ]
]

{ #category : 'editing' }
ReplayClick >> positionPresenterOn: editor [

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
	editor registerReplayPresenter: xInput named: 'Action click x'.
	editor registerReplayPresenter: yInput named: 'Action click y'.
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
ReplayClick >> printOn: stream [

	super printOn: stream.
	self position ifNotNil: [ :point |
		stream nextPutAll: ' @ '; print: point ].
	self clickCount = 1 ifFalse: [
		stream nextPutAll: ' x'; print: self clickCount ].
	self modifiers = 0 ifFalse: [
		stream nextPutAll: ' modifiers='; print: self modifiers ]
]

{ #category : 'removing' }
ReplayClick >> removeModifiers: anInteger [

	self modifiers: (self modifiers bitClear: anInteger).
	^ anInteger
]

{ #category : 'running' }
ReplayClick >> runOn: runner onUI: ui [

	self clickOn: ui
]

{ #category : 'running' }
ReplayClick >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runClick: self
]

{ #category : 'editing' }
ReplayClick >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self buttonsPresenterOn: editor) expand: false;
			add: (self modifiersPresenterOn: editor) expand: false;
			add: (self positionPresenterOn: editor) expand: false;
			add: (self clickCountPresenterOn: editor) expand: false;
			in: [ :layout |
				self hasSpecificTarget ifTrue: [
					layout add: (self debugButtonPresenterOn: editor labeled: ' Debug click event' action: [ self debugClickOn: editor ]) expand: false ] ];
			yourself);
		yourself
]

{ #category : 'accessing' }
ReplayClick >> settingsViewName [

	^ 'Click settings'
]

{ #category : 'running' }
ReplayClick >> targetStartingAt: aMorph handling: selector with: anEvent [

	| target |
	target := aMorph.
	[ target notNil and: [ (target perform: selector with: anEvent) not ] ]
		whileTrue: [ target := target owner ].
	^ target ifNil: [ aMorph ]
]

{ #category : 'running' }
ReplayClick >> worldPositionIn: aMorph [

	^ aMorph pointInWorld: (self localPositionIn: aMorph)
]
