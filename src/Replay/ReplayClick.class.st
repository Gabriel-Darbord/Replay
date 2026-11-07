"
I simulate mouse button interactions on a resolved UI target. My mousePhase controls whether I send a full synthetic click, only mouse-down, only mouse-up, or a down/up pair. I can click at an offset from the top-left corner of the target, repeat to double-click, and hold several mouse buttons and keyboard modifiers.

All my events go to the morph that handles the mouse down, found up the owner chain of the target, so the mouse down and mouse up of a split click reach the same morph.

A simple left click on a Spec button, link or toolbar button that is enabled and visible runs natively, as the widget would on a click, even before the button is rendered.
"
Class {
	#name : 'ReplayClick',
	#superclass : 'ReplayPointerAction',
	#traits : 'TReplayActionWithDebugging',
	#classTraits : 'TReplayActionWithDebugging classTrait',
	#instVars : [
		'position',
		'clickCount',
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

{ #category : 'testing' }
ReplayClick >> canRunNativelyOn: anObject [

	^ self isSimpleLeftClick and: [
		  anObject isPresenter and: [ anObject replayCanClickNatively ] ]
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
			editor actionChanged: self ].
	editor registerReplayPresenter: input named: 'Action click count'.
	editor registerReplayPresenter: input named: self class displayName , ' count'.
	^ SpBoxLayout newTopToBottom
		add: 'Click count:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'running' }
ReplayClick >> clickOn: aMorph [

	| worldPoint hand target |
	worldPoint := self worldPointAt: self position in: aMorph.
	hand := self newHandAt: worldPoint.
	target := self
		          targetStartingAt: aMorph
		          handling: #handlesMouseDown:
		          with: (self mouseDownEventAt: worldPoint hand: hand).
	1 to: self clickCount do: [ :index |
		| downEvent |
		hand position: worldPoint.
		downEvent := self mouseDownEventAt: worldPoint hand: hand.
		self sendsMouseDown ifTrue: [
			hand mouseFocus: target.
			downEvent sentTo: target ].
		self sendsSyntheticClick ifTrue: [
			target click: downEvent.
			index = 2 ifTrue: [ target doubleClick: downEvent asPseudoDoubleClickEvent ] ].
		self sendsMouseUp ifTrue: [
			(self mouseUpEventAt: worldPoint hand: hand) sentTo: target ] ]
]

{ #category : 'debugging' }
ReplayClick >> debugClickIn: aReplayUIManager [
	"Resolve my target in the managed UI, then open a debugger on my run"

	self
		resolveTargetWith: aReplayUIManager
		thenDo: [ :resolved | self debug: [ resolved run: self ] ]
		onMissing: [ :error | error signal ]
]

{ #category : 'debugging' }
ReplayClick >> debugClickOn: editor [

	| builder |
	builder := ReplayUIBuilder on: editor scenario.

	builder whenDone: [ self debugClickIn: builder manager ].

	"We need to open the window for the UI to load correctly"
	(SpMorphPresenter new morph:
			 (builder uiForAction: self inStep: editor currentStep))
		asWindow
		title: 'Debugging Click Event';
		open;
		maximize
]

{ #category : 'testing' }
ReplayClick >> isClick [

	^ true
]

{ #category : 'testing' }
ReplayClick >> isSimpleLeftClick [

	^ self mousePhase = #click
		and: [ self buttons = MouseEvent redButton
			and: [ self modifiers = 0
				and: [ self position isNil
					and: [ self clickCount = 1 ] ] ] ]
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
				editor actionChanged: self ] ].
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

{ #category : 'accessing' }
ReplayClick >> position [
	"My offset from the top-left corner of the target, nil to click its center"

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

	^ self
		  offsetPresenterOn: editor
		  labeled: 'Offset from target top-left:'
		  named: 'click'
		  get: [ self positionOrZero ]
		  set: [ :point | self position: point ]
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
	self printButtonsAndModifiersOn: stream
]

{ #category : 'running' }
ReplayClick >> runOnMorph: aMorph [

	self clickOn: aMorph
]

{ #category : 'running' }
ReplayClick >> runOnNative: aPresenter [

	aPresenter replayClickNatively
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
