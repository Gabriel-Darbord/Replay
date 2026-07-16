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
ReplayRecorderTest >> testAttachActiveWindowObservesFocusedWindowWithoutOverlay [

	| root target window hand previousFocus runner action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	window := root openInWindowLabeled: 'Replay attach target'.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	runner := ReplayRunner on: ReplayScenario new.
	action := ReplayAttachActiveWindow new.

	[
		hand keyboardFocus: target.
		action runOn: runner.
		self assert: runner manager managedUI equals: window.
		self assert: runner manager overlay isNil.
		runner manager close ]

		ensure: [
			hand keyboardFocus: previousFocus.
			window delete ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testAttachActiveWindowUsesFocusedWindow [

	| root target window hand previousFocus resolved |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	window := root openInWindowLabeled: 'Replay recorder target'.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		resolved := ReplayAttachActiveWindow activeWindowMorphFromHand: hand.
		self assert: resolved equals: window ]

		ensure: [
			hand keyboardFocus: previousFocus.
			window delete ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testAttachWorldObservesWorldWithoutOverlay [

	| runner action |
	runner := ReplayRunner on: ReplayScenario new.
	action := ReplayAttachWorld new.
	action runOn: runner.
	self assert: runner manager managedUI equals: World.
	self assert: runner manager overlay isNil.
	runner manager close
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
ReplayRecorderTest >> testEditorRecordedWorldActionsBeginWithAttachWorld [

	| editor activeRecorder recorded |
	editor := ReplayEditor new.

	[
		editor startRecording.
		activeRecorder := editor instVarNamed: 'recorder'.
		activeRecorder recordAction: ReplayClick new.
		recorded := editor stopRecording.
		self assert: recorded first class equals: ReplayAttachWorld.
		self assert: editor model currentStep actions first class equals: ReplayAttachWorld ]

		ensure: [ editor isRecording ifTrue: [ editor stopRecording ] ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testEditorRecordsWorldByDefault [
	| editor |
	editor := ReplayEditor new.
	self assert: editor recordingTargetMorph equals: World
]

{ #category : 'tests' }
ReplayRecorderTest >> testEditorStartRecordingObservesWorldWithoutOverlay [
	| editor activeRecorder |
	editor := ReplayEditor new.
	[
		editor startRecording.
		activeRecorder := editor instVarNamed: 'recorder'.
		self assert: activeRecorder manager managedUI equals: World.
		self assert: activeRecorder manager overlay isNil ]
		ensure: [ editor stopRecording ]
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
ReplayRecorderTest >> testRecorderCapturesControlShortcutWithKeyValue [

	| event recorder shortcut |
	recorder := ReplayRecorder new.
	event := KeyboardEvent new
		         setType: #keyDown
		         buttons: UserInputEvent ctrlKeyMask
		         position: 0 @ 0
		         keyValue: 12
		         hand: nil
		         stamp: 0.
	shortcut := recorder shortcutFromEvent: event.
	self assert: shortcut text equals: 'l'.
	self assert: shortcut flags equals: UserInputEvent ctrlKeyMask
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
		self assert: action uiReference isKeyboardFocus ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderCoalescesTypingWhenFocusedMorphPathChanges [
	| root filler target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	filler := Morph new bounds: (5 @ 5 extent: 10 @ 10).
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: filler.
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keystroke character: $a buttons: 0 hand: hand).
		filler delete.
		recorder recordEvent: (self keyboardEventType: #keystroke character: $b buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: recorder actions size equals: 1.
		self assert: action class equals: ReplayType.
		self assert: action text equals: 'ab'.
		self assert: action uiReference isKeyboardFocus ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderDiscardsPendingAltShortcutWhenKeystrokeProducesText [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: (Character value: 0) buttons: UserInputEvent altKeyMask hand: hand).
		recorder recordEvent: (self keyboardEventType: #keyDown character: $3 buttons: UserInputEvent altKeyMask hand: hand).
		recorder recordEvent: (self keyboardEventType: #keystroke character: $# buttons: 0 hand: hand).
		self assert: recorder actions size equals: 1.
		action := recorder actions first.
		self assert: action class equals: ReplayType.
		self assert: action text equals: '#' ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderDiscardsPendingEnterKeyPressWhenKeystrokeProducesText [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: Character cr buttons: 0 hand: hand).
		recorder recordEvent: (self keyboardEventType: #keystroke character: Character cr buttons: 0 hand: hand).
		self assert: recorder actions size equals: 1.
		action := recorder actions first.
		self assert: action class equals: ReplayType.
		self assert: action text equals: Character cr asString ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderFlushesPendingAltShortcutWhenRecordingEnds [

	| root target recorder hand previousFocus recorded action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: $x buttons: UserInputEvent altKeyMask hand: hand).
		self assert: recorder actions isEmpty.
		recorded := recorder recordedActions asArray.
		self assert: recorded size equals: 1.
		action := recorded first.
		self assert: action class equals: ReplayShortcut.
		self assert: action text equals: 'x'.
		self assert: action flags equals: UserInputEvent altKeyMask ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderIgnoresModifierOnlyShortcutEvent [

	| event recorder |
	recorder := ReplayRecorder new.
	event := KeyboardEvent new
		         setType: #keyDown
		         buttons: UserInputEvent ctrlKeyMask
		         position: 0 @ 0
		         keyValue: 0
		         hand: nil
		         stamp: 0.
	self assert: (recorder shortcutFromEvent: event) isNil
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderIgnoresModifierOnlyShortcutKeyDown [

	| root target recorder hand previousFocus |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: (Character value: 0) buttons: UserInputEvent cmdKeyMask hand: hand).
		self assert: recorder actions isEmpty ]

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
ReplayRecorderTest >> testRecorderIgnoresMouseEventsInsideSpecPopover [

	| root popover target recorder hand |
	root := Morph new extent: 200 @ 100.
	popover := SpPopoverMorph new bounds: (20 @ 10 extent: 80 @ 50).
	target := Morph new bounds: (5 @ 5 extent: 30 @ 20).
	popover addMorph: target.
	root addMorph: popover.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseDown position: 30 @ 20 which: MouseEvent redButton buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 30 @ 20 which: MouseEvent redButton buttons: 0 hand: hand).
		self assert: recorder actions isEmpty ]
		ensure: [ recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderIgnoresMouseUpWithoutRecordedMouseDown [

	| root target recorder hand |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 25 @ 15 which: MouseEvent redButton buttons: 0 hand: hand).
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
ReplayRecorderTest >> testRecorderPrependsPrologueOnlyWhenActionsWereRecorded [

	| recorder recorded |
	recorder := ReplayRecorder new
		preserveTiming: false;
		prologueActions: { ReplayAttachWorld new };
		yourself.
	self assert: recorder recordedActions isEmpty.
	recorder recordAction: ReplayClick new.
	recorded := recorder recordedActions.
	self assert: recorded first class equals: ReplayAttachWorld.
	self assert: recorded second class equals: ReplayClick
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsArrowKeyDownAsPressKeyWhenKeyUpArrives [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self
				 keyboardEventType: #keyDown
				 character: Character arrowLeft
				 buttons: 0
				 hand: hand).
		self assert: recorder actions isEmpty.
		recorder recordEvent: (self
				 keyboardEventType: #keyUp
				 character: Character arrowLeft
				 buttons: 0
				 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayPressKey.
		self assert: action keySelector equals: #left.
		self assert: action flags equals: 0.
		self assert: action uiReference isKeyboardFocus ] ensure: [
			hand keyboardFocus: previousFocus.
			recorder manager close ]
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
		self assert: action uiReference isKeyboardFocus ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsEnterKeyDownAsPressKeyWhenKeyUpArrives [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: Character cr buttons: 0 hand: hand).
		self assert: recorder actions isEmpty.
		recorder recordEvent: (self keyboardEventType: #keyUp character: Character cr buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayPressKey.
		self assert: action keySelector equals: #enter.
		self assert: action flags equals: 0.
		self assert: action uiReference isKeyboardFocus ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsKeyDownBackspaceAsDeleteText [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self keyboardEventType: #keyDown character: (Character value: 8) buttons: 0 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayDeleteText.
		self assert: action direction equals: #backward.
		self assert: action count equals: 1.
		self assert: action uiReference isKeyboardFocus ]

		ensure: [ hand keyboardFocus: previousFocus. recorder manager close ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecorderRecordsModifiedArrowKeyAsPressKey [

	| root target recorder hand previousFocus action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		recorder recordEvent: (self
				 keyboardEventType: #keyDown
				 character: Character arrowRight
				 buttons: UserInputEvent cmdKeyMask
				 hand: hand).
		self assert: recorder actions isEmpty.
		recorder recordEvent: (self
				 keyboardEventType: #keyUp
				 character: Character arrowRight
				 buttons: UserInputEvent cmdKeyMask
				 hand: hand).
		action := recorder actions first.
		self assert: action class equals: ReplayPressKey.
		self assert: action keySelector equals: #right.
		self assert: action flags equals: UserInputEvent cmdKeyMask.
		self assert: action uiReference isKeyboardFocus ] ensure: [
			hand keyboardFocus: previousFocus.
			recorder manager close ]
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
		self assert: action uiReference isKeyboardFocus ]

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
ReplayRecorderTest >> testRecorderStopShortcutWorksWithoutKeyboardFocus [
	| root recorder hand previousFocus stopped |
	root := Morph new extent: 200 @ 100.
	recorder := self newRecorderOn: root.
	recorder stopShortcutText: 'r' flags: UserInputEvent cmdKeyMask do: [ stopped := true ].
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	stopped := false.
	[
		hand keyboardFocus: nil.
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

	| root target recorder hand actions downAction upAction |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	recorder := self newRecorderOn: root.
	hand := World activeHand.
	[
		recorder recordEvent: (self mouseButtonEventType: #mouseDown position: 25 @ 15 which: MouseEvent redButton buttons: MouseEvent redButton hand: hand).
		recorder recordEvent: (self mouseButtonEventType: #mouseUp position: 25 @ 15 which: MouseEvent redButton buttons: 0 hand: hand).
		actions := recorder actions asArray.
		self assert: actions size equals: 2.
		downAction := actions first.
		upAction := actions second.
		self assert: downAction class equals: ReplayClick.
		self assert: downAction mousePhase equals: #down.
		self assert: downAction uiReference isMorphicPath.
		self assert: downAction uiReference value equals: #(1).
		self assert: downAction position equals: 5 @ 5.
		self assert: upAction class equals: ReplayClick.
		self assert: upAction mousePhase equals: #up.
		self assert: upAction uiReference value equals: #(1).
		self assert: upAction position equals: 5 @ 5 ]
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

{ #category : 'tests' }
ReplayRecorderTest >> testRecordingToggleListenerIgnoresMouseEvents [

	| editor listener event |
	editor := ReplayEditor new.
	listener := ReplayRecordingToggleListener on: editor.
	event := self
		mouseButtonEventType: #mouseDown
		position: 10 @ 10
		which: MouseEvent redButton
		buttons: MouseEvent redButton
		hand: World activeHand.

	self shouldnt: [ listener handleListenEvent: event ] raise: MessageNotUnderstood.
	self deny: editor isRecording
]

{ #category : 'tests' }
ReplayRecorderTest >> testRecordingToggleListenerStartsAndStopsFromShortcut [

	| root target window hand previousFocus editor listener startEvent stopEvent |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	window := root openInWindowLabeled: 'Replay listener recording target'.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	editor := ReplayEditor new.
	listener := ReplayRecordingToggleListener on: editor.
	startEvent := self
		keyboardEventType: #keyDown
		character: $r
		buttons: editor recordingShortcutFlags
		hand: hand.
	stopEvent := self
		keyboardEventType: #keyDown
		character: $r
		buttons: editor recordingShortcutFlags
		hand: hand.

	[
		hand keyboardFocus: target.
		listener handleListenEvent: startEvent.
		self assert: editor isRecording.
		self assert: (editor instVarNamed: 'recorder') manager managedUI equals: window.
		listener handleListenEvent: stopEvent.
		self deny: editor isRecording ]

		ensure: [
			editor isRecording ifTrue: [ editor stopRecording ].
			hand keyboardFocus: previousFocus.
			window delete ]
]

{ #category : 'tests' }
ReplayRecorderTest >> testShortcutStartedRecordingTargetsFocusedWindow [

	| root target window hand previousFocus editor event activeRecorder recorded |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	window := root openInWindowLabeled: 'Replay shortcut recording target'.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.
	editor := ReplayEditor new.
	event := self
		keyboardEventType: #keyDown
		character: $r
		buttons: editor recordingShortcutFlags
		hand: hand.

	[
		hand keyboardFocus: target.
		editor startRecordingFromShortcutEvent: event.
		activeRecorder := editor instVarNamed: 'recorder'.
		self assert: activeRecorder manager managedUI equals: window.
		activeRecorder recordAction: ReplayClick new.
		recorded := editor stopRecording.
		self assert: recorded first class equals: ReplayAttachActiveWindow ]

		ensure: [
			editor isRecording ifTrue: [ editor stopRecording ].
			hand keyboardFocus: previousFocus.
			window delete ]
]
