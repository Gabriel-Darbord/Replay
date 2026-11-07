"
I record live user input events into Replay actions. I can preserve inter-action timing as ReplayDelay actions or normalize recorded actions by stripping timing.

I record from the time I start on a hand (startOnHand:) until I stop, which answers the recorded actions. I do not record the events on the morphs I ignore (ignoreMorph:), nor the key binding I ignore (ignoreKeyBinding:), such as the one that stops me.
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
		'ignoredMorphs',
		'ignoredKeyBinding',
		'prologueActions',
		'pendingShortcutAction',
		'pendingKeyPressAction',
		'menuItemDown'
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
		target: aReplayUIReference;
		position: aPoint;
		buttons: (mouseDownButtons ifNil: [ anEvent whichButton ]);
		modifiers: (mouseDownModifiers ifNil: [ ReplayKeyModifiers fromEvent: anEvent ]);
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

{ #category : 'targeting' }
ReplayRecorder >> anchorFor: aMorph handling: aSelector with: anEvent [
	"The morph to target for anEvent on aMorph.
	Replay sends the event to the first morph handling it up the owner chain of the target, so any morph from aMorph up to that one works as target: I answer the first of them that has a semantic name, which survives layout changes, or else aMorph."

	| current |
	current := aMorph.
	[ current isNil or: [ current == manager managedUI ] ] whileFalse: [
		(manager backend nameOfMorph: current) ifNotNil: [ ^ current ].
		(current replayHandles: anEvent with: aSelector) ifTrue: [ ^ aMorph ].
		current := current owner ].
	^ aMorph
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
		target: aReplayUIReference;
		startPosition: mouseDownPosition;
		endPosition: endPosition;
		steps: self mouseMoveCount;
		buttons: (mouseDownButtons ifNil: [ MouseEvent redButton ]);
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
ReplayRecorder >> ignoreKeyBinding: aReplayKeyBinding [
	"Do not record the presses of aReplayKeyBinding, such as the one that stops recording"

	ignoredKeyBinding := aReplayKeyBinding
]

{ #category : 'accessing' }
ReplayRecorder >> ignoreMorph: aMorph [
	aMorph ifNotNil: [ self ignoredMorphs add: aMorph ]
]

{ #category : 'accessing' }
ReplayRecorder >> ignoredMorphs [
	^ ignoredMorphs ifNil: [ ignoredMorphs := OrderedCollection new ]
]

{ #category : 'testing' }
ReplayRecorder >> ignoresKeyboardEvent: anEvent [

	ignoredKeyBinding ifNil: [ ^ false ].
	(anEvent isKeyDown or: [ anEvent isKeystroke ]) ifFalse: [ ^ false ].
	^ (ReplayKeyBinding fromKeyboardEvent: anEvent) = ignoredKeyBinding
]

{ #category : 'testing' }
ReplayRecorder >> ignoresMorph: aMorph [
	aMorph ifNil: [ ^ false ].
	^ self ignoredMorphs anySatisfy: [ :ignored |
		aMorph == ignored or: [ aMorph ownerChain includes: ignored ] ]
]

{ #category : 'testing' }
ReplayRecorder >> isRecording [

	^ hand notNil
]

{ #category : 'testing' }
ReplayRecorder >> isKeyPressKeyboardEvent: anEvent [

	^ (self keyPressSelectorFrom: anEvent) notNil
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

	^ (self isShortcutEvent: anEvent) not
		and: [ (self deleteDirectionFrom: anEvent) notNil ]
]

{ #category : 'events' }
ReplayRecorder >> keyPressSelectorFrom: anEvent [

	"Backspace and Delete are recorded as text deletions, Space as typed text"

	| character selector |
	character := anEvent keyCharacter.
	character ifNil: [ ^ nil ].
	selector := ReplayKeyChord keySelectorForCharacter: character.
	(#( #backspace #delete #space ) includes: selector) ifTrue: [ ^ nil ].
	^ selector
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
ReplayRecorder >> isShortcutEvent: anEvent [
	"Whether anEvent holds a modifier that makes its key a shortcut instead of typing"

	^ ReplayKeyModifiers hasShortcutModifier: (ReplayKeyModifiers fromEvent: anEvent)
]

{ #category : 'accessing' }
ReplayRecorder >> mouseMoveCount [
	^ mouseMoveCount ifNil: [ 0 ]
]

{ #category : 'targeting' }
ReplayRecorder >> menuItemAtWorldPoint: aPoint [
	"The item of a menu open in the World under aPoint, or nil. Menus open outside the managed UI, over it."

	| morph |
	morph := (self currentWorld morphsAt: aPoint) ifEmpty: [ ^ nil ] ifNotEmpty: #first.
	^ morph withAllOwners
		  detect: [ :each | (each isKindOf: MenuItemMorph) and: [ each owner isKindOf: MenuMorph ] ]
		  ifNone: [ nil ]
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
		target: self keyboardFocusReference;
		keySelector: (self keyPressSelectorFrom: anEvent);
		modifiers: (ReplayKeyModifiers fromEvent: anEvent);
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
		target: aReplayUIReference;
		direction: directionSymbol;
		yourself)
]

{ #category : 'event handling' }
ReplayRecorder >> recordEvent: anEvent [

	anEvent isMouse ifTrue: [
		self flushPendingKeyboardActions.
		((self menuItemAtWorldPoint: anEvent position) ifNotNil: [ :item |
			 self recordMouseEvent: anEvent onMenuItem: item ]) == true ifTrue: [ ^ self ].
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
	(self ignoresKeyboardEvent: anEvent) ifTrue: [ ^ self ].
	target := anEvent hand keyboardFocus.
	(self managedIncludesMorph: target) ifFalse: [ ^ self ].
	anEvent isKeystroke ifTrue: [
			self hasPendingShortcut ifTrue: [ self discardPendingShortcut ].
			self hasPendingKeyPress ifTrue: [ self discardPendingKeyPress ].
			^ self recordKeystroke: anEvent on: target ].
	(anEvent isKeyDown and: [ self isUnmodifiedDeleteKeyboardEvent: anEvent ]) ifTrue: [
			self flushPendingKeyboardActions.
			^ self recordDeleteTextOn: self keyboardFocusReference direction: (self deleteDirectionFrom: anEvent) ].
	(anEvent isKeyDown and: [ self isKeyPressKeyboardEvent: anEvent ]) ifTrue: [
			self flushPendingShortcut.
			pendingKeyPressAction := self pendingKeyPressActionFor: anEvent.
			^ self ].
	(anEvent isKeyDown and: [ self isShortcutEvent: anEvent ]) ifTrue: [
			self flushPendingKeyPress.
			^ self recordShortcut: anEvent on: target ].
	anEvent isKeyUp ifTrue: [ ^ self flushPendingKeyboardActions ]
]

{ #category : 'event handling' }
ReplayRecorder >> recordKeystroke: anEvent on: targetMorph [
	| character code reference action |
	(self isShortcutEvent: anEvent) ifTrue: [ ^ self ].
	character := anEvent keyCharacter.
	code := character asInteger.
	reference := self keyboardFocusReference.
	code = 8 ifTrue: [ ^ self recordDeleteTextOn: reference direction: #backward ].
	code = 127 ifTrue: [ ^ self recordDeleteTextOn: reference direction: #forward ].
	code = 0 ifTrue: [ ^ self ].
	action := ReplayType new
		target: reference;
		text: character asString;
		yourself.
	self recordAction: action
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseEvent: anEvent onMenuItem: aMenuItemMorph [
	"Record a click on aMenuItemMorph, of a menu open in the World, as a Choose menu item. Answer whether anEvent is recorded this way, otherwise it is an event of a gesture that started outside the menu, such as the mouse up of the right click that opened it."

	anEvent isMouseDown ifTrue: [
		self clearMouseGesture.
		menuItemDown := aMenuItemMorph.
		^ true ].
	menuItemDown ifNil: [ ^ false ].
	anEvent isMouseUp ifTrue: [
		(menuItemDown == aMenuItemMorph and: [ aMenuItemMorph subMenu isNil ]) ifTrue: [
			self recordAction: (ReplayChooseMenuItem labels: (ReplayChooseMenuItem labelsOfItem: aMenuItemMorph)) ].
		menuItemDown := nil ].
	^ true
]

{ #category : 'event handling' }
ReplayRecorder >> recordMouseDown: anEvent [
	| target |
	target := self targetMorphAtWorldPoint: anEvent position.
	target ifNil: [ ^ self ].
	target := self anchorFor: target handling: #handlesMouseDown: with: anEvent.
	mouseDownTarget := target.
	mouseDownReference := self referenceForMorph: target.
	mouseDownReference ifNil: [ ^ self clearMouseGesture ].
	mouseDownPosition := self offsetForWorldPoint: anEvent position inMorph: target.
	mouseDownButtons := anEvent whichButton.
	mouseDownModifiers := ReplayKeyModifiers fromEvent: anEvent.
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
	target := self anchorFor: target handling: #handlesMouseWheel: with: anEvent.
	reference := self referenceForMorph: target.
	reference ifNil: [ ^ self ].
	action := ReplayScroll new
		target: reference;
		direction: (self scrollDirectionFrom: anEvent);
		modifiers: (ReplayKeyModifiers fromEvent: anEvent);
		position: (self offsetForWorldPoint: anEvent position inMorph: target);
		yourself.
	self recordAction: action
]

{ #category : 'event handling' }
ReplayRecorder >> recordShortcut: anEvent on: targetMorph [

	| action |
	action := (self shortcutFromEvent: anEvent) ifNil: [ ^ self ].
	(self shouldDeferShortcut: action keyBinding) ifTrue: [
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
	"The semantic name of aMorph when it has one, which survives layout changes, or else its Morphic path from the managed UI"

	| path |
	(self managedIncludesMorph: aMorph) ifFalse: [ ^ nil ].
	(manager backend nameOfMorph: aMorph) ifNotNil: [ :name |
		^ ReplayUIReference named: name ].
	path := self pathForMorph: aMorph.
	path ifNil: [ ^ nil ].
	^ ReplayUIReference morphicPath: path
]

{ #category : 'testing' }
ReplayRecorder >> sameReferenceOf: firstAction and: secondAction [
	(firstAction isUIHandler and: [ secondAction isUIHandler ]) ifFalse: [ ^ false ].
	^ firstAction target = secondAction target
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
	"The Shortcut action pressing the key of anEvent on the keyboard focus, or nil when it presses no key"

	^ (ReplayKeyBinding fromKeyboardEvent: anEvent) ifNotNil: [ :binding |
		  ReplayShortcut new
			  target: self keyboardFocusReference;
			  keyBinding: binding;
			  yourself ]
]

{ #category : 'testing' }
ReplayRecorder >> shouldDeferShortcut: aReplayKeyBinding [
	"Alt without Command or Control may type a character, as Option does on macOS: wait for the keystroke to tell"

	| modifiers |
	modifiers := aReplayKeyBinding chords first modifiers.
	^ (modifiers bitAnd: ReplayKeyModifiers alt) ~= 0 and: [
		  (modifiers bitAnd: (ReplayKeyModifiers command bitOr: ReplayKeyModifiers control)) = 0 ]
]

{ #category : 'testing' }
ReplayRecorder >> shouldIgnoreMouseEvent: anEvent [

	| target |
	target := self targetMorphAtWorldPoint: anEvent position.
	^ (self ignoresMorph: target)
		or: [ self isTransientMouseTarget: target ]
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
