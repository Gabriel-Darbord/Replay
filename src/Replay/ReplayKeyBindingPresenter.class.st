"
I edit a ReplayKeyBinding: its chords are visible rows that I add, delete and capture, and my modifier check boxes (a ReplayKeyModifiersPresenter) show and edit the modifiers of the selected chord. A new chord takes the modifiers shown by the check boxes, so Cmd + T then Cmd + S is entered by checking Command once.

Capture shortcut listens to the next key press on my hand (a ReplayShortcutCaptureListener). The capture is cancelled by a second click, by Escape, by stopShortcutCapture (sent when the pane that shows me is replaced or its window closes), and in any case by a key press once I am no longer shown.

A key binding is an immutable value: each edit makes a new binding, which I keep and give to the block of on:whenChangedDo:. keyBinding: shows another binding and also notifies.
"
Class {
	#name : 'ReplayKeyBindingPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'keyBinding',
		'changeBlock',
		'keyDropList',
		'characterTextPresenter',
		'addKeyButton',
		'addCharacterButton',
		'keyList',
		'removeKeyButton',
		'captureShortcutButton',
		'captureListener',
		'hand',
		'clearKeysButton',
		'modifiersPresenter'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'layout' }
ReplayKeyBindingPresenter class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 6;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignCenter;
				   add: 'Add key:' expand: false;
				   add: #keyDropList width: 110;
				   add: #addKeyButton width: 40;
				   add: 'Add character:' expand: false;
				   add: #characterTextPresenter width: 170;
				   add: #addCharacterButton width: 40;
				   add: #captureShortcutButton width: 190;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignStart;
				   add: (SpBoxLayout newTopToBottom
						    add: #keyList height: 81;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    spacing: 4;
						    vAlignStart;
						    add: #removeKeyButton height: 37;
						    add: #clearKeysButton height: 37;
						    yourself)
				   width: 40;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   vAlignCenter;
				   add: 'Modifiers of the selected key:' expand: false;
				   add: #modifiersPresenter;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'instance creation' }
ReplayKeyBindingPresenter class >> on: aReplayKeyBinding [

	^ self on: aReplayKeyBinding whenChangedDo: [ :binding | ]
]

{ #category : 'instance creation' }
ReplayKeyBindingPresenter class >> on: aReplayKeyBinding whenChangedDo: aBlock [
	"aBlock receives the new binding after each edit"

	^ self basicNew
		  setKeyBinding: aReplayKeyBinding whenChangedDo: aBlock;
		  initialize;
		  yourself
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> addCharacterButton [

	^ addCharacterButton
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> addCharacterText [
	"Add a chord per typed character, skipping the characters no key types"

	| chords |
	chords := characterTextPresenter text asArray
		          collect: [ :character |
		          ReplayKeyChord character: character modifiers: modifiersPresenter modifiers ]
		          thenSelect: [ :chord | chord notNil ].
	characterTextPresenter text: ''.
	chords ifEmpty: [ ^ self ].
	self editKeyBinding: (chords inject: self keyBinding into: [ :binding :chord | binding copyWith: chord ]).
	keyList selectIndex: self keyBinding chords size
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> addKeyButton [

	^ addKeyButton
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> addSelectedKey [

	| association |
	association := keyDropList selectedItem.
	association ifNil: [ ^ self ].
	self editKeyBinding: (self keyBinding copyWith:
			 ((ReplayKeyChord namedKey: association key) withModifiers: modifiersPresenter modifiers)).
	keyList selectIndex: self keyBinding chords size
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> captureListener [

	^ captureListener
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> captureShortcutButton [

	^ captureShortcutButton
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> characterTextPresenter [

	^ characterTextPresenter
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> clearChords [

	self keyBinding isEmpty ifTrue: [ ^ self ].
	self editKeyBinding: ReplayKeyBinding new
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> clearKeysButton [

	^ clearKeysButton
]

{ #category : 'updating' }
ReplayKeyBindingPresenter >> editKeyBinding: aReplayKeyBinding [
	"Keep, show and notify an edited binding"

	keyBinding := aReplayKeyBinding.
	self refreshKeyList.
	changeBlock ifNotNil: [ changeBlock value: keyBinding ]
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> editSelectedChordModifiers: anInteger [
	"Without a selected chord, the modifiers only apply to the next added chords"

	| index |
	index := keyList selectedIndex.
	(index isNil or: [ index = 0 ]) ifTrue: [ ^ self ].
	self editKeyBinding: (self keyBinding
			 copyReplacingChordAt: index
			 with: ((self keyBinding chords at: index) withModifiers: anInteger))
]

{ #category : 'initialization' }
ReplayKeyBindingPresenter >> initializePresenters [

	keyDropList := self newDropList.
	keyDropList
		items: ReplayKeyChord keyChoices;
		display: [ :association | association value ].
	keyDropList items ifNotEmpty: [ keyDropList selectItem: keyDropList items first ].
	addKeyButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the selected special key to the key sequence.';
		action: [ self addSelectedKey ];
		yourself.
	characterTextPresenter := self newText.
	characterTextPresenter help: 'Type printable character(s) to append to the key sequence.'.
	addCharacterButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the keys of the typed character(s) to the key sequence.';
		action: [ self addCharacterText ];
		yourself.
	keyList := self newTable.
	keyList
		addColumn: (SpStringTableColumn title: 'Keys' evaluated: [ :chord | chord displayString ]);
		beResizable;
		whenSelectionChangedDo: [ self showSelectedChordModifiers ].
	removeKeyButton := self newButton
		icon: (self iconNamed: #remove);
		help: 'Delete the selected key from the key sequence.';
		action: [ self removeSelectedChord ];
		yourself.
	clearKeysButton := self newButton
		icon: (self iconNamed: #delete);
		help: 'Delete every key from the key sequence.';
		action: [ self clearChords ];
		yourself.
	captureShortcutButton := self newButton
		label: 'Capture shortcut';
		help: 'Click, then press a shortcut to replace the current key sequence. Click again to cancel listening.';
		action: [ self startShortcutCapture ];
		yourself.
	modifiersPresenter := self instantiate: ReplayKeyModifiersPresenter.
	modifiersPresenter whenChangedDo: [ :modifiers | self editSelectedChordModifiers: modifiers ].
	self updateCaptureShortcutButtonLabel.
	self refreshKeyList
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> hand [
	"The hand that captures shortcuts"

	^ hand ifNil: [ self currentWorld activeHand ]
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> hand: aHandMorph [

	hand := aHandMorph
]

{ #category : 'testing' }
ReplayKeyBindingPresenter >> isShown [
	"Whether my widget is in a world: false once my window closed or the pane that showed me was replaced"

	^ self adapter
		  ifNil: [ false ]
		  ifNotNil: [ :adapter | adapter widget notNil and: [ adapter widget world notNil ] ]
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> keyBinding [

	^ keyBinding ifNil: [ keyBinding := ReplayKeyBinding new ]
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> keyBinding: aReplayKeyBinding [

	self editKeyBinding: aReplayKeyBinding
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> keyDropList [

	^ keyDropList
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> keyList [

	^ keyList
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> modifiersPresenter [

	^ modifiersPresenter
]

{ #category : 'updating' }
ReplayKeyBindingPresenter >> refreshKeyList [

	| selectedIndex chords |
	keyList ifNil: [ ^ self ].
	selectedIndex := keyList selectedIndex ifNil: [ 0 ].
	chords := self keyBinding chords.
	keyList items: chords.
	chords ifEmpty: [ ^ self ].
	keyList selectIndex: (selectedIndex = 0
			 ifTrue: [ 1 ]
			 ifFalse: [ selectedIndex min: chords size ]).
	self showSelectedChordModifiers
]

{ #category : 'replay' }
ReplayKeyBindingPresenter >> registerReplayPresentersOn: anEditor named: aPrefix [

	anEditor registerReplayPresenter: self named: aPrefix , ' keys'.
	anEditor registerReplayPresenter: keyList named: aPrefix , ' key list'.
	anEditor registerReplayPresenter: keyDropList named: aPrefix , ' key chooser'.
	anEditor registerReplayPresenter: addKeyButton named: aPrefix , ' add key button'.
	anEditor registerReplayPresenter: characterTextPresenter named: aPrefix , ' character text'.
	anEditor registerReplayPresenter: addCharacterButton named: aPrefix , ' add character button'.
	anEditor registerReplayPresenter: removeKeyButton named: aPrefix , ' remove key button'.
	anEditor registerReplayPresenter: clearKeysButton named: aPrefix , ' clear keys button'.
	anEditor registerReplayPresenter: captureShortcutButton named: aPrefix , ' capture shortcut button'.
	modifiersPresenter registerReplayPresentersOn: anEditor named: aPrefix
]

{ #category : 'accessing' }
ReplayKeyBindingPresenter >> removeKeyButton [

	^ removeKeyButton
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> removeSelectedChord [

	| selectedIndex |
	selectedIndex := keyList selectedIndex.
	(selectedIndex isNil or: [ selectedIndex = 0 ]) ifTrue: [ ^ self ].
	self editKeyBinding: (self keyBinding copyWithoutChordAt: selectedIndex)
]

{ #category : 'replay' }
ReplayKeyBindingPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Shortcut keys' ifTrue: [ ^ self ].
	aPresenterName = 'Shortcut key list' ifTrue: [ ^ keyList ].
	aPresenterName = 'Shortcut key chooser' ifTrue: [ ^ keyDropList ].
	aPresenterName = 'Shortcut add key button' ifTrue: [ ^ addKeyButton ].
	aPresenterName = 'Shortcut character text' ifTrue: [ ^ characterTextPresenter ].
	aPresenterName = 'Shortcut add character button' ifTrue: [ ^ addCharacterButton ].
	aPresenterName = 'Shortcut remove key button' ifTrue: [ ^ removeKeyButton ].
	aPresenterName = 'Shortcut clear keys button' ifTrue: [ ^ clearKeysButton ].
	aPresenterName = 'Shortcut capture shortcut button' ifTrue: [ ^ captureShortcutButton ].
	^ absentBlock value
]

{ #category : 'initialization' }
ReplayKeyBindingPresenter >> setKeyBinding: aReplayKeyBinding whenChangedDo: aBlock [

	keyBinding := aReplayKeyBinding.
	changeBlock := aBlock
]

{ #category : 'updating' }
ReplayKeyBindingPresenter >> showSelectedChordModifiers [
	"Without a selected chord, keep the modifiers for the next added chords"

	keyList selectedItem ifNotNil: [ :chord | modifiersPresenter modifiers: chord modifiers ]
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> startShortcutCapture [
	"Capture the next key press as my binding; a second click, Escape or hiding me cancels"

	captureListener ifNotNil: [ ^ self stopShortcutCapture ].
	captureListener := ReplayShortcutCaptureListener new
		                   captureWhile: [ self isShown ];
		                   whenCapturedDo: [ :capturedBinding |
			                   captureListener := nil.
			                   self updateCaptureShortcutButtonLabel.
			                   self editKeyBinding: capturedBinding ];
		                   whenCancelledDo: [
			                   captureListener := nil.
			                   self updateCaptureShortcutButtonLabel ];
		                   startOnHand: self hand;
		                   yourself.
	self updateCaptureShortcutButtonLabel
]

{ #category : 'actions' }
ReplayKeyBindingPresenter >> stopShortcutCapture [

	captureListener ifNotNil: [ :listener | listener cancel ].
	captureListener := nil.
	self updateCaptureShortcutButtonLabel
]

{ #category : 'updating' }
ReplayKeyBindingPresenter >> updateCaptureShortcutButtonLabel [

	captureShortcutButton ifNil: [ ^ self ].
	captureShortcutButton label: (captureListener
		ifNil: [ 'Capture shortcut' ]
		ifNotNil: [ 'Listening...' ])
]
