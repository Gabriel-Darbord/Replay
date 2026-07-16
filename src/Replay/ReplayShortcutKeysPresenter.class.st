"
I edit ReplayShortcut character sequences as visible rows. I keep ReplayShortcut text as the serialized model and provide controls to add, delete, and capture shortcut characters.
"
Class {
	#name : 'ReplayShortcutKeysPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'shortcut',
		'changeBlock',
		'keyDropList',
		'characterTextPresenter',
		'addKeyButton',
		'addCharacterButton',
		'keyList',
		'removeKeyButton',
		'captureShortcutButton',
		'captureListener',
		'clearKeysButton'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'layout' }
ReplayShortcutKeysPresenter class >> defaultLayout [

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
		  yourself
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter class >> keyChoices [

	^ ReplayPressKey keyChoices
]

{ #category : 'instance creation' }
ReplayShortcutKeysPresenter class >> on: aReplayShortcut [

	^ self on: aReplayShortcut whenChangedDo: [ ]
]

{ #category : 'instance creation' }
ReplayShortcutKeysPresenter class >> on: aReplayShortcut whenChangedDo: aBlock [

	| presenter |
	presenter := self basicNew.
	presenter initializeModel: aReplayShortcut whenChangedDo: aBlock.
	presenter initialize.
	^ presenter
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> addCharacterButton [

	^ addCharacterButton
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> addCharacterText [

	| characters |
	characters := characterTextPresenter text.
	characters ifEmpty: [ ^ self ].
	self shortcut appendText: characters.
	characterTextPresenter text: ''.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> addKeyButton [

	^ addKeyButton
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> addSelectedKey [

	| association |
	association := keyDropList selectedItem.
	association ifNil: [ ^ self ].
	self appendCharacter: (self characterForKeySelector: association key)
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> appendCharacter: aCharacter [

	self shortcut appendText: aCharacter.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> captureListener [

	^ captureListener
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> captureShortcutButton [

	^ captureShortcutButton
]

{ #category : 'private' }
ReplayShortcutKeysPresenter >> characterForKeySelector: aSymbol [

	aSymbol = #left ifTrue: [ ^ Character arrowLeft ].
	aSymbol = #right ifTrue: [ ^ Character arrowRight ].
	aSymbol = #up ifTrue: [ ^ Character arrowUp ].
	aSymbol = #down ifTrue: [ ^ Character arrowDown ].
	aSymbol = #home ifTrue: [ ^ Character home ].
	aSymbol = #end ifTrue: [ ^ Character end ].
	aSymbol = #pageUp ifTrue: [ ^ Character pageUp ].
	aSymbol = #pageDown ifTrue: [ ^ Character pageDown ].
	aSymbol = #backspace ifTrue: [ ^ Character backspace ].
	aSymbol = #delete ifTrue: [ ^ Character delete ].
	aSymbol = #enter ifTrue: [ ^ Character cr ].
	aSymbol = #escape ifTrue: [ ^ Character escape ].
	aSymbol = #tab ifTrue: [ ^ Character tab ].
	aSymbol = #space ifTrue: [ ^ Character space ].
	self error: 'Unknown shortcut key selector: ' , aSymbol asString
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> characterTextPresenter [

	^ characterTextPresenter
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> clearCharacters [

	self text ifEmpty: [ ^ self ].
	self shortcut text: ''.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> clearKeysButton [

	^ clearKeysButton
]

{ #category : 'private' }
ReplayShortcutKeysPresenter >> displayStringForCharacter: aCharacter [

	^ String streamContents: [ :stream |
		stream nextPutAll: (self nameForCharacter: aCharacter).
		stream nextPutAll: ' - '.
		stream nextPutAll: aCharacter storeString.
		stream nextPutAll: ' (code '.
		stream print: aCharacter asInteger.
		stream nextPut: $) ]
]

{ #category : 'initialization' }
ReplayShortcutKeysPresenter >> initializeModel: aReplayShortcut whenChangedDo: aBlock [

	shortcut := aReplayShortcut.
	changeBlock := aBlock
]

{ #category : 'initialization' }
ReplayShortcutKeysPresenter >> initializePresenters [

	keyDropList := self newDropList.
	keyDropList
		items: self class keyChoices;
		display: [ :association | association value ].
	keyDropList items ifNotEmpty: [ keyDropList selectItem: keyDropList items first ].
	addKeyButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the selected special key to the shortcut sequence.';
		action: [ self addSelectedKey ];
		yourself.
	characterTextPresenter := self newText.
	characterTextPresenter help: 'Type printable character(s) to append to the shortcut sequence.'.
	addCharacterButton := self newButton
		icon: (self iconNamed: #add);
		help: 'Add the typed character(s) to the shortcut sequence.';
		action: [ self addCharacterText ];
		yourself.
	keyList := self newTable.
	keyList
		addColumn: (SpStringTableColumn title: 'Characters' evaluated: [ :character | self displayStringForCharacter: character ]);
		beResizable.
	removeKeyButton := self newButton
		icon: (self iconNamed: #remove);
		help: 'Delete the selected character from the shortcut sequence.';
		action: [ self removeSelectedCharacter ];
		yourself.
	clearKeysButton := self newButton
		icon: (self iconNamed: #delete);
		help: 'Delete every character from the shortcut sequence.';
		action: [ self clearCharacters ];
		yourself.
	captureShortcutButton := self newButton
		label: 'Capture shortcut';
		help: 'Click, then press a shortcut to replace the current sequence and modifiers. Click again to cancel listening.';
		action: [ self startShortcutCapture ];
		yourself.
	self updateCaptureShortcutButtonLabel.
	self refreshKeyList
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> keyDropList [

	^ keyDropList
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> keyList [

	^ keyList
]

{ #category : 'private' }
ReplayShortcutKeysPresenter >> nameForCharacter: aCharacter [

	aCharacter = Character arrowLeft ifTrue: [ ^ 'Left Arrow' ].
	aCharacter = Character arrowRight ifTrue: [ ^ 'Right Arrow' ].
	aCharacter = Character arrowUp ifTrue: [ ^ 'Up Arrow' ].
	aCharacter = Character arrowDown ifTrue: [ ^ 'Down Arrow' ].
	aCharacter = Character home ifTrue: [ ^ 'Home' ].
	aCharacter = Character end ifTrue: [ ^ 'End' ].
	aCharacter = Character pageUp ifTrue: [ ^ 'Page Up' ].
	aCharacter = Character pageDown ifTrue: [ ^ 'Page Down' ].
	aCharacter = Character backspace ifTrue: [ ^ 'Backspace' ].
	aCharacter = Character delete ifTrue: [ ^ 'Delete' ].
	aCharacter = Character cr ifTrue: [ ^ 'Enter' ].
	aCharacter = Character escape ifTrue: [ ^ 'Escape' ].
	aCharacter = Character tab ifTrue: [ ^ 'Tab' ].
	aCharacter = Character space ifTrue: [ ^ 'Space' ].
	((aCharacter asInteger < 32) or: [ aCharacter asInteger = 127 ]) ifTrue: [ ^ 'Control character' ].
	^ 'Character'
]

{ #category : 'updating' }
ReplayShortcutKeysPresenter >> notifyChanged [

	changeBlock ifNotNil: [ changeBlock value ]
]

{ #category : 'updating' }
ReplayShortcutKeysPresenter >> refreshKeyList [

	| selectedIndex textSize newSelection |
	keyList ifNil: [ ^ self ].
	selectedIndex := keyList selectedIndex ifNil: [ 0 ].
	keyList items: self text asOrderedCollection.
	textSize := self text size.
	textSize = 0 ifTrue: [ ^ self ].
	newSelection := selectedIndex = 0
		ifTrue: [ 1 ]
		ifFalse: [ selectedIndex min: textSize ].
	keyList selectIndex: newSelection
]

{ #category : 'replay' }
ReplayShortcutKeysPresenter >> registerReplayPresentersOn: anEditor named: aPrefix [

	anEditor registerReplayPresenter: self named: aPrefix , ' keys'.
	anEditor registerReplayPresenter: keyList named: aPrefix , ' key list'.
	anEditor registerReplayPresenter: keyDropList named: aPrefix , ' key chooser'.
	anEditor registerReplayPresenter: addKeyButton named: aPrefix , ' add key button'.
	anEditor registerReplayPresenter: characterTextPresenter named: aPrefix , ' character text'.
	anEditor registerReplayPresenter: addCharacterButton named: aPrefix , ' add character button'.
	anEditor registerReplayPresenter: removeKeyButton named: aPrefix , ' remove key button'.
	anEditor registerReplayPresenter: clearKeysButton named: aPrefix , ' clear keys button'.
	anEditor registerReplayPresenter: captureShortcutButton named: aPrefix , ' capture shortcut button'
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> removeKeyButton [

	^ removeKeyButton
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> removeSelectedCharacter [

	| selectedIndex newText |
	selectedIndex := keyList selectedIndex.
	(selectedIndex isNil or: [ selectedIndex = 0 ]) ifTrue: [ ^ self ].
	newText := String streamContents: [ :stream |
		self text withIndexDo: [ :character :index |
			index = selectedIndex ifFalse: [ stream nextPut: character ] ] ].
	self shortcut text: newText.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'replay' }
ReplayShortcutKeysPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

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

{ #category : 'updating' }
ReplayShortcutKeysPresenter >> setTextSilently: aString [

	self shortcut text: aString.
	self refreshKeyList
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> shortcut [

	^ shortcut ifNil: [ shortcut := ReplayShortcut new ]
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> startShortcutCapture [

	| hand |
	captureListener ifNotNil: [
		self stopShortcutCapture.
		^ self ].
	hand := World activeHand.
	hand ifNil: [ ^ self ].
	captureListener := ReplayShortcutCaptureListener
		onHand: hand
		do: [ :capturedShortcut |
			self useShortcut: capturedShortcut.
			captureListener := nil.
			self updateCaptureShortcutButtonLabel ].
	self updateCaptureShortcutButtonLabel
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> stopShortcutCapture [

	captureListener ifNotNil: [
		captureListener stop.
		captureListener := nil ].
	self updateCaptureShortcutButtonLabel
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> text [

	^ self shortcut text
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> text: aString [

	self shortcut text: aString.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'updating' }
ReplayShortcutKeysPresenter >> updateCaptureShortcutButtonLabel [

	captureShortcutButton ifNil: [ ^ self ].
	captureShortcutButton label: (captureListener
		ifNil: [ 'Capture shortcut' ]
		ifNotNil: [ 'Listening...' ])
]

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> useShortcut: aReplayShortcut [

	self shortcut
		text: aReplayShortcut text;
		flags: aReplayShortcut flags.
	self refreshKeyList.
	self notifyChanged
]
