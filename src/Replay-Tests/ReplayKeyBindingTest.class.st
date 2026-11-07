"
I test ReplayKeyBinding and ReplayKeyChord: conversions from and to Keymapping combinations, STON, Shift semantics, decoding keyboard events and capture, and the ReplayKeyBindingPresenter that edits a binding.
"
Class {
	#name : 'ReplayKeyBindingTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayKeyBindingTest >> command: aCharacter [

	^ ReplayKeyChord character: aCharacter modifiers: ReplayKeyModifiers command
]

{ #category : 'support' }
ReplayKeyBindingTest >> keyDownEventFor: aCharacter modifiers: anInteger [

	^ (ReplayKeyChord character: aCharacter modifiers: anInteger) keyboardEventOfType: #keyDown
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testCanBeBuiltFromKeymap [

	| keymap binding |
	keymap := KMKeymap named: #save shortcut: $s command action: [ ].
	binding := ReplayKeyBinding fromKeymap: keymap.

	self assert: binding equals: (ReplayKeyBinding chords: { self command: $s }).
	self assert: (binding matchesKeymap: keymap).
	self deny: (ReplayKeyBinding new matchesKeymap: (KMKeymap named: #none shortcut: KMNoShortcut new action: [ ]))
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testCaptureListenerDecodesTheKeyBinding [

	| listener captured |
	listener := ReplayShortcutCaptureListener onHand: nil do: [ :binding | captured := binding ].
	listener handleListenEvent: (self keyDownEventFor: $a modifiers: 0).

	self assert: captured equals: (ReplayKeyBinding character: $a modifiers: 0)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testCapturedShiftShortcutHoldsShift [

	| event catcher captured |
	event := KeyboardEvent new.
	event
		setType: #keystroke
		buttons: ReplayKeyModifiers shift
		position: 0 @ 0
		keyValue: $F asInteger
		charCode: $F asInteger
		hand: nil
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: $F).
	catcher := KMCatcherMorph new.
	[
		catcher keyStroke: event.
		captured := ReplayKeyBinding fromKMCombination: catcher shortcut ] ensure: [ catcher delete ].

	self assert: captured equals: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers shift).
	self assert: captured equals: (ReplayKeyBinding character: $F modifiers: 0)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testChoiceConvertsToItsAlternatives [

	| choice keymap |
	choice := $a ctrl | $b ctrl.
	keymap := KMKeymap named: #choice shortcut: choice action: [ ].

	self assert: (ReplayKeyBinding fromKMCombination: choice) equals: (ReplayKeyBinding character: $a modifiers: ReplayKeyModifiers control).
	self assert: ((ReplayKeyBinding character: $a modifiers: ReplayKeyModifiers control) matchesKeymap: keymap).
	self assert: ((ReplayKeyBinding character: $b modifiers: ReplayKeyModifiers control) matchesKeymap: keymap).
	self deny: ((ReplayKeyBinding character: $c modifiers: ReplayKeyModifiers control) matchesKeymap: keymap)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testConvertsBackToKMShortcut [

	| original binding copy |
	original := $s command.
	binding := ReplayKeyBinding fromKMCombination: original.
	copy := binding asKMShortcut.

	self assert: copy asString equals: original asString.
	self assert: (ReplayKeyBinding fromKMCombination: copy) equals: binding.
	self assert: ReplayKeyBinding new asKMShortcut class equals: KMNoShortcut
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testConvertsComposedModifiers [

	| binding |
	binding := ReplayKeyBinding fromKMCombination: $s command shift ctrl.

	self assert: binding chords size equals: 1.
	self assert: binding chords first key equals: #S.
	self
		assert: binding chords first modifiers
		equals: ((ReplayKeyModifiers command bitOr: ReplayKeyModifiers shift) bitOr: ReplayKeyModifiers control).
	self assert: (ReplayKeyBinding fromKMCombination: binding asKMShortcut) equals: binding.
	self assert: (binding matchesKeymap: (KMKeymap named: #composed shortcut: $s ctrl shift command action: [ ]))
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testConversionSkipsWhatItCannotRepresent [

	| otherPlatform currentPlatform |
	self assert: (ReplayKeyBinding fromKMCombination: KMModifier shift) isNil.
	otherPlatform := KMPlatformSpecificKeyCombination new
		                 shortcut: $a ctrl;
		                 platform: #NotAPlatform;
		                 yourself.
	self assert: (ReplayKeyBinding fromKMCombination: otherPlatform) isNil.
	self deny: ((ReplayKeyBinding character: $a modifiers: ReplayKeyModifiers control) matchesKeymap:
			 (KMKeymap named: #other shortcut: otherPlatform action: [ ])).
	currentPlatform := KMPlatformSpecificKeyCombination new
		                   shortcut: $a ctrl;
		                   platform: OSPlatform current platformFamily;
		                   yourself.
	self
		assert: (ReplayKeyBinding fromKMCombination: currentPlatform)
		equals: (ReplayKeyBinding character: $a modifiers: ReplayKeyModifiers control)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testConvertsEveryInstalledKeymap [
	"The shortcut description panel converts every keymap of the image: none may fail"

	KMRepository default categories do: [ :category |
		category allEntries keymaps do: [ :keymap |
			self shouldnt: [ ReplayKeyBinding fromKeymap: keymap ] raise: Error ] ]
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testConvertsKeysWithoutCharacter [

	| binding |
	binding := ReplayKeyBinding fromKMCombination: KMModifier command + KeyboardKey F6 asKeyCombination.

	self assert: binding chords first key equals: #F6.
	self assert: binding isKeymappable.
	self assert: (ReplayKeyBinding fromKMCombination: binding asKMShortcut) equals: binding
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testDecodesKeyboardEvents [

	| shiftedEvent |
	self
		assert: (ReplayKeyBinding fromKeyboardEvent: (self keyDownEventFor: $a modifiers: ReplayKeyModifiers command))
		equals: (ReplayKeyBinding chords: { self command: $a }).
	self
		assert: (ReplayKeyBinding fromKeyboardEvent: (self keyDownEventFor: Character arrowLeft modifiers: 0))
		equals: (ReplayKeyBinding chords: { ReplayKeyChord namedKey: #left }).
	"A modifier key pressed alone"
	self assert: (ReplayKeyBinding fromKeyboardEvent: (KeyboardEvent new
				  setType: #keyDown
				  buttons: ReplayKeyModifiers command
				  position: 0 @ 0
				  keyValue: 0
				  charCode: 0
				  hand: nil
				  stamp: 0;
				  yourself)) isNil.
	"The modifiers of the event, not the case of its character, tell whether Shift is held"
	shiftedEvent := KeyboardEvent new
		                setType: #keyDown
		                buttons: ReplayKeyModifiers shift
		                position: 0 @ 0
		                keyValue: $F asInteger
		                charCode: $F asInteger
		                hand: nil
		                stamp: 0;
		                yourself.
	self
		assert: (ReplayKeyBinding fromKeyboardEvent: shiftedEvent)
		equals: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers shift).
	shiftedEvent setType: #keyDown buttons: 0 position: 0 @ 0 keyValue: $F asInteger charCode: $F asInteger hand: nil stamp: 0.
	self assert: (ReplayKeyBinding fromKeyboardEvent: shiftedEvent) equals: (ReplayKeyBinding character: $f modifiers: 0)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testDisplayStringToleratesUnknownKey [

	| binding |
	binding := ReplayKeyBinding chords: {
			           (ReplayKeyChord key: #NOT_A_KEY modifiers: ReplayKeyModifiers control).
			           (self command: $s) }.

	self assert: binding displayString equals: 'Control + NOT_A_KEY, ' , (self command: $s) asKMShortcut asString.
	self assert: binding asKMShortcut isNil.
	self deny: binding isKeymappable
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testKeysPresenterAddsAndRemovesKeys [

	| binding presenter changes leftChoice |
	changes := 0.
	presenter := ReplayKeyBindingPresenter on: ReplayKeyBinding new whenChangedDo: [ :newBinding |
		             binding := newBinding.
		             changes := changes + 1 ].
	leftChoice := presenter keyDropList items detect: [ :association | association key = #left ].
	presenter keyDropList selectItem: leftChoice.
	presenter addSelectedKey.
	self assert: binding equals: (ReplayKeyBinding chords: { ReplayKeyChord namedKey: #left }).
	self assert: changes equals: 1.
	presenter characterTextPresenter text: 'kA'.
	presenter addCharacterText.
	self assert: binding chords equals: {
			(ReplayKeyChord namedKey: #left).
			(ReplayKeyChord character: $k).
			(ReplayKeyChord character: $a modifiers: ReplayKeyModifiers shift) }.
	self assert: presenter characterTextPresenter text isEmpty.
	self assert: changes equals: 2.
	presenter keyList selectIndex: 1.
	presenter removeSelectedChord.
	self assert: binding chords first equals: (ReplayKeyChord character: $k).
	self assert: changes equals: 3.
	presenter clearChords.
	self assert: binding isEmpty.
	self assert: presenter keyList items isEmpty.
	self assert: changes equals: 4
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testKeysPresenterCaptureUpdatesModifiers [

	| binding presenter listener |
	presenter := ReplayKeyBindingPresenter
		             on: (ReplayKeyBinding character: $z modifiers: 0)
		             whenChangedDo: [ :newBinding | binding := newBinding ].
	presenter hand: HandMorph new.
	presenter open.
	self deny: presenter modifiersPresenter commandCheckBox state.
	self assert: presenter captureShortcutButton label equals: 'Capture shortcut'.
	presenter startShortcutCapture.
	self assert: presenter captureShortcutButton label equals: 'Listening...'.
	listener := presenter captureListener.
	self assert: listener isActive.
	listener handleListenEvent: (self keyDownEventFor: $a modifiers: ReplayKeyModifiers command).

	self assert: binding equals: (ReplayKeyBinding chords: { self command: $a }).
	self assert: presenter keyBinding equals: binding.
	self assert: presenter modifiersPresenter commandCheckBox state.
	self deny: presenter modifiersPresenter shiftCheckBox state.
	self assert: presenter captureListener isNil.
	self assert: presenter captureShortcutButton label equals: 'Capture shortcut'
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testKeysPresenterEditsTheModifiersOfEachChord [

	| binding presenter |
	presenter := ReplayKeyBindingPresenter
		             on: (ReplayKeyBinding chords: { ReplayKeyChord character: $t })
		             whenChangedDo: [ :newBinding | binding := newBinding ].
	presenter keyList selectIndex: 1.
	presenter modifiersPresenter commandCheckBox toggleState.
	self assert: binding equals: (ReplayKeyBinding chords: { self command: $t }).
	"A new chord takes the modifiers shown"
	presenter characterTextPresenter text: 's'.
	presenter addCharacterText.
	self assert: binding equals: (ReplayKeyBinding chords: { self command: $t. self command: $s }).
	self assert: presenter keyList selectedIndex equals: 2.
	presenter modifiersPresenter commandCheckBox toggleState.
	self assert: binding equals: (ReplayKeyBinding chords: { self command: $t. ReplayKeyChord character: $s }).
	presenter keyList selectIndex: 1.
	self assert: presenter modifiersPresenter commandCheckBox state
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testKeysPresenterHasIconControls [

	| presenter |
	presenter := ReplayKeyBindingPresenter on: ReplayKeyBinding new.

	self assert: presenter addKeyButton label equals: ''.
	self deny: presenter addKeyButton icon isNil.
	self assert: presenter addCharacterButton label equals: ''.
	self deny: presenter addCharacterButton icon isNil.
	self deny: presenter removeKeyButton icon isNil.
	self assert: (presenter removeKeyButton help includesSubstring: 'Delete').
	self assert: presenter clearKeysButton notNil
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testKeysPresenterShowsSpecialKeys [

	| binding presenter |
	binding := ReplayKeyBinding chords: {
			           (ReplayKeyChord namedKey: #left).
			           (ReplayKeyChord character: $k) }.
	presenter := ReplayKeyBindingPresenter on: binding.

	self assert: presenter keyList items asArray equals: binding chords.
	self assert: (presenter keyList items collect: [ :chord | chord displayString ]) asArray equals: #( 'LEFT' 'K' )
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testRoundTripsChordSequences [
	"Each chord keeps its own modifiers: Cmd + T then S is not Cmd + T then Cmd + S"

	| sequence binding |
	sequence := $t meta , $s.
	binding := ReplayKeyBinding fromKMCombination: sequence.

	self assert: binding chords equals: { self command: $t. ReplayKeyChord character: $s }.
	self assert: binding displayString equals: (self command: $t) asKMShortcut asString , ', S'.
	self assert: (ReplayKeyBinding fromKMCombination: binding asKMShortcut) equals: binding.
	self assert: (binding matchesKeymap: (KMKeymap named: #sequence shortcut: sequence action: [ ])).
	self deny: (binding matchesKeymap: (KMKeymap named: #sequence shortcut: $t meta , $s meta action: [ ]))
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testRoundTripsThroughSton [

	| binding ston |
	binding := ReplayKeyBinding chords: { self command: $t. ReplayKeyChord namedKey: #left }.
	ston := STON toString: binding.

	self assert: ston equals: 'ReplayKeyBinding[ReplayKeyChord[#T,64],ReplayKeyChord[#LEFT]]'.
	self assert: (STON fromString: ston) equals: binding.
	self assert: (STON fromString: (STON toString: ReplayKeyBinding new)) equals: ReplayKeyBinding new
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testShiftIsAModifierNotACase [

	self
		assert: (ReplayKeyBinding character: $F modifiers: 0)
		equals: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers shift).
	self deny: (ReplayKeyBinding character: $F modifiers: 0) = (ReplayKeyBinding character: $f modifiers: 0).
	self
		assert: (ReplayKeyBinding character: $F modifiers: 0) hash
		equals: (ReplayKeyBinding character: $f modifiers: ReplayKeyModifiers shift) hash.
	self assert: (ReplayKeyBinding fromKMCombination: $A asKeyCombination) equals: (ReplayKeyBinding character: $A modifiers: 0)
]

{ #category : 'tests' }
ReplayKeyBindingTest >> testShortcutActionStonHoldsItsKeyBinding [

	| action copy ston |
	action := ReplayShortcut keyBinding: (ReplayKeyBinding chords: { self command: $s }).
	ston := STON toString: action.
	copy := STON fromString: ston.

	self assert: copy keyBinding equals: action keyBinding.
	self deny: (ston includesSubstring: 'flags').
	self deny: (ston includesSubstring: 'text')
]
