"
Headless tests for Replay recording and recorded-action timing normalization.
"
Class {
	#name : 'ReplayRecorderTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayRecorderTest >> keyboardEventType: eventType character: aCharacter buttons: buttons hand: hand [
	| code |
	code := aCharacter asInteger.
	^ KeyboardEvent new
		setType: eventType
		buttons: buttons
		position: 0 @ 0
		keyValue: code
		charCode: code
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : 'support' }
ReplayRecorderTest >> mouseButtonEventType: eventType position: aPoint which: button buttons: buttons hand: hand [
	^ MouseButtonEvent new
		setType: eventType
		position: aPoint
		which: button
		buttons: buttons
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : 'support' }
ReplayRecorderTest >> mouseMoveEventFrom: startPoint to: endPoint buttons: buttons hand: hand [
	^ MouseMoveEvent new
		setType: #mouseMove
		startPoint: startPoint
		endPoint: endPoint
		trail: { startPoint. endPoint }
		buttons: buttons
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : 'support' }
ReplayRecorderTest >> mouseWheelEventAt: aPoint direction: direction buttons: buttons hand: hand [
	^ MouseWheelEvent new
		setType: #mouseWheel
		position: aPoint
		direction: direction
		buttons: buttons
		hand: hand
		stamp: Time millisecondClockValue
]

{ #category : 'support' }
ReplayRecorderTest >> newRecorderOn: targetMorph [
	| manager recorder |
	manager := ReplayUIManager new manage: targetMorph.
	recorder := ReplayRecorder new
		manager: manager;
		preserveTiming: false;
		yourself.
	^ recorder
]

{ #category : 'tests' }
ReplayRecorderTest >> testEditorAppendsRecordedActionsToCurrentStep [
	| editor click type |
	editor := ReplayEditor new.
	click := ReplayClick new.
	type := ReplayType new text: 'abc'; yourself.
	editor addRecordedActions: { click. type }.
	self assert: editor model currentStep actions asArray equals: { click. type }.
	self assert: editor actions items asArray equals: { click. type }
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderCanRecordActionsWithoutTiming [
	| recorder first second recorded |
	recorder := ReplayRecorder new preserveTiming: false; yourself.
	first := ReplayClick new.
	second := ReplayType new text: 'a'; yourself.
	recorder recordAction: first.
	recorder recordAction: second.
	self assert: recorder actions asArray equals: { first. second }.
	recorded := recorder recordedActions.
	self assert: recorded size equals: 2.
	self assert: recorded first class equals: ReplayClick.
	self assert: recorded second class equals: ReplayType
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderCoalescesTypedCharactersForFocusedTarget [
	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keystroke character: $a buttons: 0 hand: hand).
		recorder recordEvent: (self keyboardEventType: #keystroke character: $b buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: recorder actions size equals: 1.
		self assert: action class equals: ReplayType.
		self assert: action text equals: 'ab'.
		self assert: action uiReference value equals: #(1) ]
		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderIgnoresMouseEventsInsideIgnoredMorph [
	| root target ignored recorder hand |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	ignored := Morph new bounds: (90 @ 10 extent: 50 @ 30).
	root addMorph: target.
	root addMorph: ignored.
	recorder := self newRecorderOn: root.
	recorder ignoreMorph: ignored.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseDown position: 95 @ 15 which: MouseEvent redButton buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 95 @ 15 which: MouseEvent redButton buttons: 0 hand: hand).
		self assert: recorder actions isEmpty ]
		ensure: [ recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderInsertsDelayBetweenActionsWhenTimingIsPreserved [
	| times recorder actions |
	times := OrderedCollection withAll: #(1000 2500).
	recorder := ReplayRecorder new
		preserveTiming: true;
		timeSource: [ times removeFirst ];
		yourself.
	recorder recordAction: ReplayClick new.
	recorder recordAction: ReplayType new.
	actions := recorder actions.
	self assert: actions size equals: 3.
	self assert: actions second class equals: ReplayDelay.
	self assert: actions second seconds equals: 1.5
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsDeleteTextForBackspace [
	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keystroke character: (Character value: 8) buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayDeleteText.
		self assert: action direction equals: #backward.
		self assert: action count equals: 1.
		self assert: action uiReference value equals: #(1) ]
		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsShortcutForModifiedKeyDown [
	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: $f buttons: UserInputEvent cmdKeyMask hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayShortcut.
		self assert: action text equals: 'f'.
		self assert: action flags equals: UserInputEvent cmdKeyMask.
		self assert: action uiReference value equals: #(1) ]
		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderStopShortcutInvokesStopBlockWithoutRecordingShortcut [
	| root target recorder hand previousFocus stopped |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	recorder stopShortcutText: 'r' flags: UserInputEvent cmdKeyMask do: [ stopped := true ].
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	stopped := false.
	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: $r buttons: UserInputEvent cmdKeyMask hand: hand).
		self assert: stopped.
		self assert: recorder actions isEmpty ]
		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderStripsRecordedTiming [
	| times recorder stripped |
	times := OrderedCollection withAll: #(1000 2500).
	recorder := ReplayRecorder new
		preserveTiming: true;
		timeSource: [ times removeFirst ];
		yourself.
	recorder recordAction: ReplayClick new.
	recorder recordAction: ReplayType new.
	stripped := recorder actionsWithoutRecordedTiming.
	self assert: stripped size equals: 2.
	self deny: (stripped anySatisfy: [ :action | action isKindOf: ReplayDelay ])
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderTranslatesMouseClickToReplayClick [
	| root target recorder hand action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseDown position: 25 @ 15 which: MouseEvent redButton buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 25 @ 15 which: MouseEvent redButton buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayClick.
		self assert: action uiReference isMorphicPath.
		self assert: action uiReference value equals: #(1).
		self assert: action position equals: 5 @ 5 ]
		ensure: [ recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderTranslatesMouseDragToReplayDrag [
	| root target recorder hand action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseDown position: 25 @ 15 which: MouseEvent redButton buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseMoveEventFrom: 25 @ 15 to: 35 @ 25 buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 35 @ 25 which: MouseEvent redButton buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayDrag.
		self assert: action uiReference value equals: #(1).
		self assert: action startPosition equals: 5 @ 5.
		self assert: action endPosition equals: 15 @ 15.
		self assert: action steps equals: 1 ]
		ensure: [ recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderTranslatesMouseWheelToReplayScroll [
	| root target recorder hand action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseWheelEventAt: 25 @ 15 direction: Character arrowUp buttons: UserInputEvent ctrlKeyMask hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayScroll.
		self assert: action direction equals: #up.
		self assert: action count equals: 1.
		self assert: action modifiers equals: UserInputEvent ctrlKeyMask.
		self assert: action position equals: 5 @ 5 ]
		ensure: [ recorder manager close ]
]
