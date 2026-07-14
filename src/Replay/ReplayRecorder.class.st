"
I record live user input events into Replay actions. I can preserve inter-action timing as ReplayDelay actions or normalize recorded actions by stripping timing.
"
Class {
	#name : 'ReplayRecorder',
	#superclass : 'Object',
	#instVars : [
		'actions',
		'manager',
		'preserveTiming',
		'timeSource',
		'lastRecordedMilliseconds',
		'listener',
		'hand',
		'mouseDownTarget',
		'mouseDownReference',
		'mouseDownPosition',
		'mouseDownButtons',
		'mouseDownModifiers',
		'mouseMoveCount',
		'mouseMoved',
		'ignoredShortcutText',
		'ignoredShortcutFlags',
		'ignoredMorphs',
		'stopShortcutText',
		'stopShortcutFlags',
		'stopBlock',
		'prologueActions',
		'pendingShortcutAction',
		'pendingKeyPressAction'
	],
	#category : 'Replay-Recording',
	#package : 'Replay',
	#tag : 'Recording'
}

{ #category : 'accessing' }
ReplayRecorder >> actions [
	^ actions ifNil: [ actions := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayRecorder >> actions: aCollection [
	actions := aCollection asOrderedCollection
]

{ #category : 'recording' }
ReplayRecorder >> actionsWithoutRecordedTiming [
	| stripped |
	stripped := OrderedCollection new.
	self actions do: [ :action |
		| copy |
		copy := action copyWithoutRecordedTiming.
		copy shouldRecordWhenTimingStripped ifTrue: [ stripped add: copy ] ].
	^ stripped
]

{ #category : 'recording' }
ReplayRecorder >> appendRecordedAction: aReplayAction [
	(self coalesceWithLastAction: aReplayAction) ifTrue: [ ^ aReplayAction ].
	self actions add: aReplayAction
]

{ #category : 'event handling' }
ReplayRecorder >> clearMouseGesture [
	mouseDownTarget := nil.
	mouseDownReference := nil.
	mouseDownPosition := nil.
	mouseDownButtons := nil.
	mouseDownModifiers := nil.
	mouseMoveCount := 0.
	mouseMoved := false
]

{ #category : 'event handling' }
ReplayRecorder >> clickActionFor: aReplayUIReference at: aPoint event: anEvent phase: aSymbol [

	^ ReplayClick new
		reference: aReplayUIReference;
		position: aPoint;
		flags: (mouseDownButtons ifNil: [ anEvent whichButton ]);
		modifiers: (mouseDownModifiers ifNil: [ self modifierFlagsFrom: anEvent ]);
		mousePhase: aSymbol;
		yourself
]

{ #category : 'recording' }
ReplayRecorder >> coalesceDeleteText: aReplayAction with: previousAction [
	(aReplayAction isKindOf: ReplayDeleteText) ifFalse: [ ^ false ].
	(previousAction isKindOf: ReplayDeleteText) ifFalse: [ ^ false ].
	(self sameReferenceOf: aReplayAction and: previousAction) ifFalse: [ ^ false ].
	aReplayAction direction = previousAction direction ifFalse: [ ^ false ].
	previousAction count: previousAction count + aReplayAction count.
	^ true
]

{ #category : 'recording' }
ReplayRecorder >> coalesceScroll: aReplayAction with: previousAction [
	(aReplayAction isKindOf: ReplayScroll) ifFalse: [ ^ false ].
	(previousAction isKindOf: ReplayScroll) ifFalse: [ ^ false ].
	(self sameReferenceOf: aReplayAction and: previousAction) ifFalse: [ ^ false ].
	aReplayAction direction = previousAction direction ifFalse: [ ^ false ].
	aReplayAction modifiers = previousAction modifiers ifFalse: [ ^ false ].
	aReplayAction position = previousAction position ifFalse: [ ^ false ].
	previousAction count: previousAction count + aReplayAction count.
	^ true
]

{ #category : 'recording' }
ReplayRecorder >> coalesceType: aReplayAction with: previousAction [
	(aReplayAction isKindOf: ReplayType) ifFalse: [ ^ false ].
	(previousAction isKindOf: ReplayType) ifFalse: [ ^ false ].
	(self sameReferenceOf: aReplayAction and: previousAction) ifFalse: [ ^ false ].
	previousAction appendText: aReplayAction text.
	^ true
]

{ #category : 'recording' }
ReplayRecorder >> coalesceWithLastAction: aReplayAction [
	self actions ifEmpty: [ ^ false ].
	(self coalesceType: aReplayAction with: self actions last) ifTrue: [ ^ true ].
	(self coalesceDeleteText: aReplayAction with: self actions last) ifTrue: [ ^ true ].
	(self coalesceScroll: aReplayAction with: self actions last) ifTrue: [ ^ true ].
	^ false
]

{ #category : 'accessing' }
ReplayRecorder >> currentMilliseconds [
	^ self timeSource value
]

{ #category : 'events' }
ReplayRecorder >> deleteDirectionFrom: anEvent [

	| character code |
	character := anEvent keyCharacter.
	character ifNil: [ ^ nil ].
	code := character asInteger.
	code = 8 ifTrue: [ ^ #backward ].
	code = 127 ifTrue: [ ^ #forward ].
	^ nil
]

{ #category : 'recording' }
ReplayRecorder >> discardPendingKeyPress [

	pendingKeyPressAction := nil
]

{ #category : 'recording' }
ReplayRecorder >> discardPendingShortcut [

	pendingShortcutAction := nil
]

{ #category : 'event handling' }
ReplayRecorder >> dragActionFor: aReplayUIReference endingAt: endPosition [
	^ ReplayDrag new
		reference: aReplayUIReference;
		startPosition: mouseDownPosition;
		endPosition: endPosition;
		steps: self mouseMoveCount;
		flags: (mouseDownButtons ifNil: [ MouseEvent redButton ]);
		modifiers: (mouseDownModifiers ifNil: [ 0 ]);
		yourself
]

{ #category : 'recording' }
ReplayRecorder >> flushPendingKeyPress [

	| action |
	pendingKeyPressAction ifNil: [ ^ self ].
	action := pendingKeyPressAction.
	pendingKeyPressAction := nil.
	self recordAction: action
]

{ #category : 'recording' }
ReplayRecorder >> flushPendingKeyboardActions [

	self flushPendingShortcut.
	self flushPendingKeyPress
]

{ #category : 'recording' }
ReplayRecorder >> flushPendingShortcut [

	| action |
	pendingShortcutAction ifNil: [ ^ self ].
	action := pendingShortcutAction.
	pendingShortcutAction := nil.
	self recordAction: action
]

{ #category : 'testing' }
ReplayRecorder >> hasManagedTarget [
	^ manager notNil and: [ manager managedUI notNil ]
]

{ #category : 'testing' }
ReplayRecorder >> hasPendingKeyPress [

	^ pendingKeyPressAction notNil
]

{ #category : 'testing' }
ReplayRecorder >> hasPendingShortcut [

	^ pendingShortcutAction notNil
]

{ #category : 'accessing' }
ReplayRecorder >> ignoreMorph: aMorph [
	aMorph ifNotNil: [ self ignoredMorphs add: aMorph ]
]

{ #category : 'accessing' }
ReplayRecorder >> ignoreShortcutText: aString flags: anInteger [
	ignoredShortcutText := aString asLowercase.
	ignoredShortcutFlags := anInteger
]

{ #category : 'accessing' }
ReplayRecorder >> ignoredMorphs [
	^ ignoredMorphs ifNil: [ ignoredMorphs := OrderedCollection new ]
]

{ #category : 'testing' }
ReplayRecorder >> ignoresMorph: aMorph [
	aMorph ifNil: [ ^ false ].
	^ self ignoredMorphs anySatisfy: [ :ignored |
		aMorph == ignored or: [ aMorph ownerChain includes: ignored ] ]
]

{ #category : 'testing' }
ReplayRecorder >> ignoresShortcutText: aString flags: anInteger [
	ignoredShortcutText ifNil: [ ^ false ].
	^ ignoredShortcutText = aString asLowercase and: [ ignoredShortcutFlags = anInteger ]
]

{ #category : 'testing' }
ReplayRecorder >> isNullShortcutText: aString [

	^ aString isEmpty or: [
		aString allSatisfy: [ :character | character asInteger = 0 ] ]
]

{ #category : 'testing' }
ReplayRecorder >> isTransientMouseTarget: aMorph [

	| current |
	current := aMorph.
	[ current notNil ] whileTrue: [
		current class name = #SpPopoverMorph ifTrue: [ ^ true ].
		current := current owner ].
	^ false
]

{ #category : 'testing' }
ReplayRecorder >> isUnmodifiedDeleteKeyboardEvent: anEvent [

	^ (self shortcutModifierFlagsFrom: anEvent) = 0
		and: [ (self deleteDirectionFrom: anEvent) notNil ]
]

{ #category : 'testing' }
ReplayRecorder >> isUnmodifiedKeyPressKeyboardEvent: anEvent [

	^ (self shortcutModifierFlagsFrom: anEvent) = 0
		and: [ (self keyPressSelectorFrom: anEvent) notNil ]
]

{ #category : 'events' }
ReplayRecorder >> keyPressSelectorFrom: anEvent [

	| character code |
	character := anEvent keyCharacter.
	character ifNil: [ ^ nil ].
	code := character asInteger.
	code = Character cr asInteger ifTrue: [ ^ #enter ].
	^ nil
]

{ #category : 'targeting' }
ReplayRecorder >> keyboardFocusReference [

	^ ReplayUIReference keyboardFocus
]

{ #category : 'accessing' }
ReplayRecorder >> listener [
	^ listener ifNil: [ listener := ReplayRecorderListener on: self ]
]

{ #category : 'targeting' }
ReplayRecorder >> managedIncludesMorph: aMorph [
	self hasManagedTarget ifFalse: [ ^ false ].
	^ aMorph notNil and: [ aMorph ownerChain includes: manager managedUI ]
]

{ #category : 'accessing' }
ReplayRecorder >> manager [
	^ manager
]

{ #category : 'accessing' }
ReplayRecorder >> manager: aReplayUIManager [
	manager := aReplayUIManager
]

{ #category : 'testing' }
ReplayRecorder >> matchesStopShortcutEvent: anEvent [

	| flags text |
	anEvent isKeyDown ifFalse: [ ^ false ].
	flags := self modifierFlagsFrom: anEvent.
	flags = 0 ifTrue: [ ^ false ].
	text := self shortcutTextFrom: anEvent.
	(self isNullShortcutText: text) ifTrue: [ ^ false ].
	^ self matchesStopShortcutText: text flags: flags
]

{ #category : 'testing' }
ReplayRecorder >> matchesStopShortcutText: aString flags: anInteger [
	stopShortcutText ifNil: [ ^ false ].
	^ stopShortcutText = aString asLowercase and: [ stopShortcutFlags = anInteger ]
]

{ #category : 'events' }
ReplayRecorder >> modifierFlagsFrom: anEvent [
	| modifiers |
	modifiers := 0.
	anEvent shiftPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent shiftKeyMask ].
	anEvent controlKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent ctrlKeyMask ].
	(anEvent optionKeyPressed or: [ anEvent altKeyPressed ]) ifTrue: [ modifiers := modifiers bitOr: UserInputEvent altKeyMask ].
	anEvent commandKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent cmdKeyMask ].
	^ modifiers
]

{ #category : 'accessing' }
ReplayRecorder >> mouseMoveCount [
	^ mouseMoveCount ifNil: [ 0 ]
]

{ #category : 'targeting' }
ReplayRecorder >> offsetForWorldPoint: aPoint inMorph: aMorph [
	| parent localPoint |
	parent := aMorph owner ifNil: [ aMorph ].
	localPoint := parent pointFromWorld: aPoint.
	^ localPoint - aMorph topLeft
]

{ #category : 'targeting' }
ReplayRecorder >> pathForMorph: aMorph [
	| path morph owner index |
	(self managedIncludesMorph: aMorph) ifFalse: [ ^ nil ].
	path := OrderedCollection new.
	morph := aMorph.
	[ morph == manager managedUI ] whileFalse: [
		owner := morph owner ifNil: [ ^ nil ].
		index := owner submorphs indexOf: morph ifAbsent: [ ^ nil ].
		path addFirst: index.
		morph := owner ].
	^ path asArray
]

{ #category : 'event handling' }
ReplayRecorder >> pendingKeyPressActionFor: anEvent [

	^ ReplayPressKey new
		reference: self keyboardFocusReference;
		keySelector: (self keyPressSelectorFrom: anEvent);
		flags: (self modifierFlagsFrom: anEvent);
		yourself
]

{ #category : 'accessing' }
ReplayRecorder >> preserveTiming [
	^ preserveTiming ifNil: [ false ]
]

{ #category : 'accessing' }
ReplayRecorder >> preserveTiming: aBoolean [
	preserveTiming := aBoolean = true
]

{ #category : 'accessing' }
ReplayRecorder >> prologueActions [

	^ prologueActions ifNil: [ #() ]
]

{ #category : 'accessing' }
ReplayRecorder >> prologueActions: aCollection [

	prologueActions := aCollection asOrderedCollection
]

{ #category : 'recording' }
ReplayRecorder >> recordAction: aReplayAction [
	self preserveTiming ifTrue: [ self recordDelayBeforeNextAction ].
	self appendRecordedAction: aReplayAction
]

{ #category : 'recording' }
ReplayRecorder >> recordDelayBeforeNextAction [
	| now deltaSeconds |
	now := self currentMilliseconds.
	lastRecordedMilliseconds ifNil: [ lastRecordedMilliseconds := now. ^ self ].
	deltaSeconds := (now - lastRecordedMilliseconds) / 1000.0.
	lastRecordedMilliseconds := now.
	deltaSeconds > 0 ifTrue: [ self actions add: (ReplayDelay seconds: deltaSeconds) ]
]

{ #category : 'event handling' }
ReplayRecorder >> recordDeleteTextOn: aReplayUIReference direction: directionSymbol [
	self recordAction: (ReplayDeleteText new
		reference: aReplayUIReference;
		direction: directionSymbol;
		yourself)
]

{ #category : 'event handling' }
ReplayRecorder >> recordEvent: anEvent [

	anEvent isMouse ifTrue: [
		self flushPendingKeyboardActions.
		(self shouldIgnoreMouseEvent: anEvent) ifTrue: [ ^ self clearMouseGesture ].
		anEvent isMouseDown ifTrue: [ ^ self recordMouseDown: anEvent ].
		anEvent isMouseMove ifTrue: [ ^ self recordMouseMove: anEvent ].
		anEvent isMouseUp ifTrue: [ ^ self recordMouseUp: anEvent ].
		anEvent isMouseWheel ifTrue: [ ^ self recordMouseWheel: anEvent ] ].
	anEvent isKeyboard ifTrue: [ ^ self recordKeyboardEvent: anEvent ].
	self flushPendingKeyboardActions
]

{ #category : 'event handling' }
ReplayRecorder >> recordKeyboardEvent: anEvent [

	| target |
	(self matchesStopShortcutEvent: anEvent) ifTrue: [ ^ self requestStop ].
	target := anEvent hand keyboardFocus.
	(self managedIncludesMorph: target) ifFalse: [ ^ self ].
	anEvent isKeystroke ifTrue: [
		self hasPendingShortcut ifTrue: [ self discardPendingShortcut ].
		self hasPendingKeyPress ifTrue: [ self discardPendingKeyPress ].
		^ self recordKeystroke: anEvent on: target ].
	(anEvent isKeyDown and: [ self isUnmodifiedDeleteKeyboardEvent: anEvent ]) ifTrue: [
		self flushPendingKeyboardActions.
		^ self recordDeleteTextOn: self keyboardFocusReference direction: (self deleteDirectionFrom: anEvent) ].
	(anEvent isKeyDown and: [ self isUnmodifiedKeyPressKeyboardEvent: anEvent ]) ifTrue: [
		self flushPendingShortcut.
		pendingKeyPressAction := self pendingKeyPressActionFor: anEvent.
		^ self ].
	(anEvent isKeyDown and: [ (self shortcutModifierFlagsFrom: anEvent) ~= 0 ]) ifTrue: [
		self flushPendingKeyPress.
		^ self recordShortcut: anEvent on: target ].
	anEvent isKeyUp ifTrue: [ ^ self flushPendingKeyboardActions ]
]

{ #category : 'event handling' }
ReplayRecorder >> recordKeystroke: anEvent on: targetMorph [
	| character code reference action |
	(self shortcutModifierFlagsFrom: anEvent) ~= 0 ifTrue: [ ^ self ].
	character := anEvent keyCharacter.
	code := character asInteger.
	reference := self keyboardFocusReference.
	code = 8 ifTrue: [ ^ self recordDeleteTextOn: reference direction: #backward ].
	code = 127 ifTrue: [ ^ self recordDeleteTextOn: reference direction: #forward ].
	code = 0 ifTrue: [ ^ self ].
	action := ReplayType new
		reference: reference;
		text: character asString;
		yourself.
	self recordAction: action
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseDown: anEvent [
	| target |
	target := self targetMorphAtWorldPoint: anEvent position.
	target ifNil: [ ^ self ].
	mouseDownTarget := target.
	mouseDownReference := self referenceForMorph: target.
	mouseDownReference ifNil: [ ^ self clearMouseGesture ].
	mouseDownPosition := self offsetForWorldPoint: anEvent position inMorph: target.
	mouseDownButtons := anEvent whichButton.
	mouseDownModifiers := self modifierFlagsFrom: anEvent.
	mouseMoveCount := 0.
	mouseMoved := false
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseMove: anEvent [
	mouseDownReference ifNil: [ ^ self ].
	anEvent anyButtonPressed ifFalse: [ ^ self ].
	mouseMoved := true.
	mouseMoveCount := self mouseMoveCount + 1
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseUp: anEvent [

	| target reference endPosition downAction upAction action |
	mouseDownTarget ifNil: [ ^ self clearMouseGesture ].
	target := mouseDownTarget.
	reference := mouseDownReference ifNil: [ self referenceForMorph: target ].
	reference ifNil: [ ^ self clearMouseGesture ].
	endPosition := self offsetForWorldPoint: anEvent position inMorph: target.
	mouseMoved = true ifTrue: [
		action := self dragActionFor: reference endingAt: endPosition.
		self clearMouseGesture.
		^ self recordAction: action ].
	mouseDownPosition ifNotNil: [
		downAction := self
			clickActionFor: reference
			at: mouseDownPosition
			event: anEvent
			phase: #down ].
	upAction := self
		clickActionFor: reference
		at: endPosition
		event: anEvent
		phase: #up.
	self clearMouseGesture.
	downAction ifNotNil: [ self recordAction: downAction ].
	self recordAction: upAction
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseWheel: anEvent [
	| target reference action |
	target := self targetMorphAtWorldPoint: anEvent position.
	target ifNil: [ ^ self ].
	reference := self referenceForMorph: target.
	reference ifNil: [ ^ self ].
	action := ReplayScroll new
		reference: reference;
		direction: (self scrollDirectionFrom: anEvent);
		modifiers: (self modifierFlagsFrom: anEvent);
		position: (self offsetForWorldPoint: anEvent position inMorph: target);
		yourself.
	self recordAction: action
]

{ #category : 'event handling' }
ReplayRecorder >> recordShortcut: anEvent on: targetMorph [

	| flags text action |
	flags := self modifierFlagsFrom: anEvent.
	text := self shortcutTextFrom: anEvent.
	(self isNullShortcutText: text) ifTrue: [ ^ self ].
	(self matchesStopShortcutText: text flags: flags) ifTrue: [ ^ self requestStop ].
	(self ignoresShortcutText: text flags: flags) ifTrue: [ ^ self ].
	action := self shortcutFromEvent: anEvent.
	(self shouldDeferShortcutWithFlags: flags) ifTrue: [
		self flushPendingShortcut.
		pendingShortcutAction := action.
		^ self ].
	self flushPendingShortcut.
	self recordAction: action
]

{ #category : 'recording' }
ReplayRecorder >> recordedActions [

	| recorded all |
	self flushPendingKeyboardActions.
	recorded := self preserveTiming
		ifTrue: [ self actions copy ]
		ifFalse: [ self actionsWithoutRecordedTiming ].
	recorded ifEmpty: [ ^ recorded ].
	all := OrderedCollection new.
	all addAll: self prologueActions.
	all addAll: recorded.
	^ all
]

{ #category : 'targeting' }
ReplayRecorder >> referenceForMorph: aMorph [
	| path |
	path := self pathForMorph: aMorph.
	path ifNil: [ ^ nil ].
	^ ReplayUIReference morphicPath: path
]

{ #category : 'recording' }
ReplayRecorder >> requestStop [
	stopBlock ifNotNil: [ stopBlock value ]
]

{ #category : 'testing' }
ReplayRecorder >> sameReferenceOf: firstAction and: secondAction [
	(firstAction isUIHandler and: [ secondAction isUIHandler ]) ifFalse: [ ^ false ].
	^ self sameUIReference: firstAction uiReference as: secondAction uiReference
]

{ #category : 'testing' }
ReplayRecorder >> sameUIReference: firstReference as: secondReference [
	firstReference class = secondReference class ifFalse: [ ^ false ].
	^ firstReference kind = secondReference kind and: [ firstReference value = secondReference value ]
]

{ #category : 'event handling' }
ReplayRecorder >> scrollDirectionFrom: anEvent [
	| direction |
	direction := anEvent direction.
	direction = Character arrowUp ifTrue: [ ^ #up ].
	direction = Character arrowLeft ifTrue: [ ^ #left ].
	direction = Character arrowRight ifTrue: [ ^ #right ].
	(#(#up #down #left #right) includes: direction) ifTrue: [ ^ direction ].
	^ #down
]

{ #category : 'events' }
ReplayRecorder >> shortcutFromEvent: anEvent [

	| text |
	text := self shortcutTextFrom: anEvent.
	(self isNullShortcutText: text) ifTrue: [ ^ nil ].
	^ ReplayShortcut new
		reference: self keyboardFocusReference;
		flags: (self modifierFlagsFrom: anEvent);
		text: text;
		yourself
]

{ #category : 'events' }
ReplayRecorder >> shortcutModifierFlagsFrom: anEvent [
	| modifiers |
	modifiers := 0.
	anEvent controlKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent ctrlKeyMask ].
	(anEvent optionKeyPressed or: [ anEvent altKeyPressed ]) ifTrue: [ modifiers := modifiers bitOr: UserInputEvent altKeyMask ].
	anEvent commandKeyPressed ifTrue: [ modifiers := modifiers bitOr: UserInputEvent cmdKeyMask ].
	^ modifiers
]

{ #category : 'events' }
ReplayRecorder >> shortcutTextFrom: anEvent [

	^ anEvent modifiedCharacter asString asLowercase
]

{ #category : 'testing' }
ReplayRecorder >> shouldDeferShortcutWithFlags: flags [

	| commandOrControlMask |
	commandOrControlMask := UserInputEvent cmdKeyMask bitOr: UserInputEvent ctrlKeyMask.
	^ ((flags bitAnd: UserInputEvent altKeyMask) ~= 0)
		and: [ (flags bitAnd: commandOrControlMask) = 0 ]
]

{ #category : 'testing' }
ReplayRecorder >> shouldIgnoreMouseEvent: anEvent [

	| target |
	target := self targetMorphAtWorldPoint: anEvent position.
	^ (self ignoresMorph: target)
		or: [ self isTransientMouseTarget: target ]
]

{ #category : 'recording' }
ReplayRecorder >> start [
	self startOnHand: World activeHand
]

{ #category : 'recording' }
ReplayRecorder >> startOnHand: aHandMorph [
	hand ifNotNil: [ self stop ].
	hand := aHandMorph.
	hand addEventListener: self listener
]

{ #category : 'recording' }
ReplayRecorder >> stop [
	hand ifNotNil: [
		hand removeEventListener: self listener.
		hand := nil ].
	^ self recordedActions
]

{ #category : 'accessing' }
ReplayRecorder >> stopShortcutText: aString flags: anInteger do: aBlock [
	stopShortcutText := aString asLowercase.
	stopShortcutFlags := anInteger.
	stopBlock := aBlock.
	self ignoreShortcutText: aString flags: anInteger
]

{ #category : 'targeting' }
ReplayRecorder >> targetMorphAtWorldPoint: aPoint [
	| managed localPoint candidates |
	self hasManagedTarget ifFalse: [ ^ nil ].
	managed := manager managedUI.
	localPoint := managed pointFromWorld: aPoint.
	candidates := managed morphsAt: localPoint.
	^ candidates ifEmpty: [ managed ] ifNotEmpty: [ candidates first ]
]

{ #category : 'accessing' }
ReplayRecorder >> timeSource [
	^ timeSource ifNil: [ [ Time millisecondClockValue ] ]
]

{ #category : 'accessing' }
ReplayRecorder >> timeSource: aBlock [
	timeSource := aBlock
]
