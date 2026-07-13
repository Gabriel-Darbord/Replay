"
I simulate mouse button interactions on a resolved UI target. My mousePhase controls whether I send a full synthetic click, only mouse-down, only mouse-up, or a down/up pair. I can click at a local offset, repeat double-clicks, and include mouse button and keyboard modifier flags.
"
Class {
	#name : 'ReplayClick',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithDebugging + TReplayActionWithFlags',
	#classTraits : 'TReplayActionWithDebugging classTrait + TReplayActionWithFlags classTrait',
	#instVars : [
		'position',
		'clickCount',
		'modifiers',
		'mousePhase'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayClick class >> displayName [

	^ 'Click'
]

{ #category : 'accessing' }
ReplayClick class >> mousePhaseChoices [

	^ {
		#click -> 'Click'.
		#down -> 'Mouse down'.
		#up -> 'Mouse up'.
		#downUp -> 'Mouse down/up' }
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

	| worldPoint hand |
	worldPoint := self worldPositionIn: ui.
	hand := self newHandAt: worldPoint.
	1 to: self clickCount do: [ :index |
		| downEvent upEvent target |
		hand position: worldPoint.
		self sendsMouseDown ifTrue: [
			downEvent := self mouseDownEventAt: worldPoint hand: hand.
			target := self targetStartingAt: ui handling: #handlesMouseDown: with: downEvent.
			hand mouseFocus: target.
			downEvent sentTo: target ].
		self sendsSyntheticClick ifTrue: [
			target click: downEvent.
			index = 2 ifTrue: [ target doubleClick: downEvent asPseudoDoubleClickEvent ] ].
		self sendsMouseUp ifTrue: [
			upEvent := self mouseUpEventAt: worldPoint hand: hand.
			target ifNil: [ target := ui ].
			upEvent sentTo: target ] ]
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
	modifiers := 0.
	mousePhase := #click
]

{ #category : 'testing' }
ReplayClick >> isClick [

	^ true
]

{ #category : 'testing' }
ReplayClick >> isSimpleLeftClick [

	^ self mousePhase = #click
		and: [ self flags = MouseEvent redButton
			and: [ self modifiers = 0
				and: [ self position isNil
					and: [ self clickCount = 1 ] ] ] ]
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

{ #category : 'accessing' }
ReplayClick >> mousePhase [

	^ mousePhase ifNil: [ #click ]
]

{ #category : 'accessing' }
ReplayClick >> mousePhase: aSymbol [

	| normalized |
	normalized := aSymbol ifNil: [ #click ] ifNotNil: [ aSymbol asSymbol ].
	(self class mousePhaseChoices anySatisfy: [ :association | association key = normalized ])
		ifFalse: [ normalized := #click ].
	mousePhase := normalized
]

{ #category : 'accessing' }
ReplayClick >> mousePhaseLabel [

	^ (self class mousePhaseChoices
		detect: [ :association | association key = self mousePhase ]
		ifNone: [ self class mousePhaseChoices first ]) value
]

{ #category : 'editing' }
ReplayClick >> mousePhasePresenterOn: editor [

	| dropList choices |
	choices := self class mousePhaseChoices.
	dropList := editor newDropList.
	dropList
		items: choices;
		display: [ :association | association value ];
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
				self mousePhase: association key.
				editor actions rebuildLayout ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self mousePhase ]
		ifNone: [ choices first ]).
	editor registerReplayPresenter: dropList named: 'Action click phase'.
	editor registerReplayPresenter: dropList named: self class displayName , ' phase'.
	^ SpBoxLayout newTopToBottom
		add: 'Mouse phase:' expand: false;
		add: dropList expand: false;
		yourself
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
	self mousePhase = #click ifFalse: [
		stream nextPutAll: ' phase='; print: self mousePhase ].
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

{ #category : 'testing' }
ReplayClick >> sendsMouseDown [

	^ #(click down downUp) includes: self mousePhase
]

{ #category : 'testing' }
ReplayClick >> sendsMouseUp [

	^ #(click up downUp) includes: self mousePhase
]

{ #category : 'testing' }
ReplayClick >> sendsSyntheticClick [

	^ self mousePhase = #click
]

{ #category : 'editing' }
ReplayClick >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self mousePhasePresenterOn: editor) expand: false;
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
