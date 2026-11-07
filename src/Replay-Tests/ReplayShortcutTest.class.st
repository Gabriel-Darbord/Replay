"
I test ReplayShortcut as a key binding: conversions from and to Keymapping shortcuts, display, capture, and the ReplayShortcutKeysPresenter that edits its keys.
"
Class {
	#name : 'ReplayShortcutTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayShortcutTest >> testCanBeBuiltFromKeymap [

	| keymap shortcut |
	keymap := KMKeymap named: #save shortcut: $s command action: [ ].
	shortcut := ReplayShortcut fromKeymap: keymap.

	self assert: shortcut text equals: 's'.
	self assert: shortcut flags equals: 64.
	self assert: (shortcut matchesKeymap: keymap)
]

{ #category : 'tests' }
ReplayShortcutTest >> testCaptureListenerUsesRecorderConversion [

	| listener captured |
	listener := ReplayShortcutCaptureListener onHand: nil do: [ :shortcut | captured := shortcut ].
	listener handleListenEvent: (ReplayShortcut new keyDown: $a buttons: 0).

	self assert: captured text equals: 'a'.
	self assert: captured flags equals: 0
]

{ #category : 'tests' }
ReplayShortcutTest >> testCapturedShiftShortcutPreservesShiftedCharacter [

	| event catcher capturedShortcut |
	event := KeyboardEvent new.
	event
		setType: #keystroke
		buttons: 8
		position: 0 @ 0
		keyValue: $F asInteger
		charCode: $F asInteger
		hand: nil
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: $F).
	catcher := KMCatcherMorph new.
	[
		catcher keyStroke: event.
		capturedShortcut := ReplayShortcut fromShortcut: catcher shortcut ] ensure: [ catcher delete ].

	self assert: capturedShortcut text equals: 'F'.
	self assert: capturedShortcut flags equals: 8
]

{ #category : 'tests' }
ReplayShortcutTest >> testConvertsBackToKMShortcut [

	| original replay copy |
	original := $s command.
	replay := ReplayShortcut fromShortcut: original.
	copy := replay asKMShortcut.

	self assert: copy asString equals: original asString.
	self assert: (ReplayShortcut fromShortcut: copy) text equals: replay text.
	self assert: (ReplayShortcut fromShortcut: copy) flags equals: replay flags
]

{ #category : 'tests' }
ReplayShortcutTest >> testDisplayStringFallsBackForUnmappedCharacter [

	| shortcut display |
	shortcut := ReplayShortcut new
		            text: (String with: (Character value: 16rFFC3));
		            yourself.
	display := shortcut displayString.

	self assert: (display includesSubstring: 'Character value: 65475').
	self assert: (display includesSubstring: 'code 65475')
]

{ #category : 'tests' }
ReplayShortcutTest >> testKeysPresenterAddsAndRemovesKeys [

	| shortcut presenter changes leftChoice |
	changes := 0.
	shortcut := ReplayShortcut new.
	presenter := ReplayShortcutKeysPresenter on: shortcut whenChangedDo: [ changes := changes + 1 ].
	leftChoice := presenter keyDropList items detect: [ :association | association key = #left ].
	presenter keyDropList selectItem: leftChoice.
	presenter addSelectedKey.
	self assert: shortcut text equals: (String with: Character arrowLeft).
	self assert: changes equals: 1.
	presenter characterTextPresenter text: 'k'.
	presenter addCharacterText.
	self assert: shortcut text equals: (String with: Character arrowLeft with: $k).
	self assert: changes equals: 2.
	presenter keyList selectIndex: 1.
	presenter removeSelectedCharacter.
	self assert: shortcut text equals: 'k'.
	self assert: changes equals: 3.
	presenter clearCharacters.
	self assert: shortcut text equals: ''.
	self assert: presenter keyList items isEmpty.
	self assert: changes equals: 4
]

{ #category : 'tests' }
ReplayShortcutTest >> testKeysPresenterCapturesNextShortcut [

	| shortcut presenter listener |
	shortcut := ReplayShortcut new
		            text: 'z';
		            yourself.
	presenter := ReplayShortcutKeysPresenter on: shortcut.
	self assert: presenter captureShortcutButton label equals: 'Capture shortcut'.
	presenter startShortcutCapture.
	self assert: presenter captureShortcutButton label equals: 'Listening...'.
	listener := presenter captureListener.
	self assert: listener isActive.
	listener handleListenEvent: (ReplayShortcut new keyDown: $a buttons: 64).

	self assert: shortcut text equals: 'a'.
	self assert: shortcut flags equals: 64.
	self assert: presenter captureListener isNil.
	self assert: presenter captureShortcutButton label equals: 'Capture shortcut'
]

{ #category : 'tests' }
ReplayShortcutTest >> testKeysPresenterHasIconControls [

	| presenter |
	presenter := ReplayShortcutKeysPresenter on: ReplayShortcut new.

	self assert: presenter addKeyButton label equals: ''.
	self deny: presenter addKeyButton icon isNil.
	self assert: presenter addCharacterButton label equals: ''.
	self deny: presenter addCharacterButton icon isNil.
	self deny: presenter removeKeyButton icon isNil.
	self assert: (presenter removeKeyButton help includesSubstring: 'Delete').
	self assert: presenter clearKeysButton notNil
]

{ #category : 'tests' }
ReplayShortcutTest >> testKeysPresenterShowsSpecialCharacters [

	| presenter display |
	presenter := ReplayShortcutKeysPresenter on: (ReplayShortcut new
			              text: (String with: Character arrowLeft with: $k);
			              yourself).
	display := presenter displayStringForCharacter: presenter keyList items first.

	self assert: presenter keyList items asArray equals: { Character arrowLeft. $k }.
	self assert: (display includesSubstring: 'Left Arrow').
	self assert: (display includesSubstring: 'Character arrowLeft')
]

{ #category : 'tests' }
ReplayShortcutTest >> testKeysPresenterUsesShortcut [

	| shortcut presenter |
	shortcut := ReplayShortcut new.
	presenter := ReplayShortcutKeysPresenter on: shortcut.
	presenter useShortcut: (ReplayShortcut new
			 text: 'f';
			 flags: 64;
			 yourself).

	self assert: shortcut text equals: 'f'.
	self assert: shortcut flags equals: 64
]

{ #category : 'tests' }
ReplayShortcutTest >> testMatchesCaseInsensitively [

	| shortcut sameShortcutDifferentCase |
	shortcut := ReplayShortcut new
		            text: 'f';
		            addFlags: 64;
		            yourself.
	sameShortcutDifferentCase := ReplayShortcut new
		                             text: 'F';
		                             addFlags: 64;
		                             yourself.

	self assert: (shortcut sameShortcutAs: sameShortcutDifferentCase)
]
