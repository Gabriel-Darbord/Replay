"
I edit the character sequence for a ReplayShortcut with visible rows for printable and special key characters. I keep ReplayShortcut text as the serialized model while offering add, remove, and captured-shortcut adoption controls.
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
		'captureMorphPresenter',
		'captureMorph',
		'useCapturedShortcutButton'
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
			add: #keyDropList width: 160;
			add: #addKeyButton expand: false;
			yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			vAlignCenter;
			add: 'Add character:' expand: false;
			add: #characterTextPresenter;
			add: #addCharacterButton expand: false;
			yourself)
		expand: false;
		add: #keyList height: 90;
		add: (SpBoxLayout newLeftToRight
			spacing: 8;
			vAlignCenter;
			add: #removeKeyButton expand: false;
			add: 'Capture shortcut:' expand: false;
			add: #captureMorphPresenter width: 260;
			add: #useCapturedShortcutButton expand: false;
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
ReplayShortcutKeysPresenter >> captureMorph [

	^ captureMorph
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> captureMorphPresenter [

	^ captureMorphPresenter
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
		label: 'Add key';
		action: [ self addSelectedKey ];
		yourself.

	characterTextPresenter := self newText.
	characterTextPresenter help: 'Type printable character(s) to append to the shortcut sequence.'.
	addCharacterButton := self newButton
		label: 'Add character';
		action: [ self addCharacterText ];
		yourself.

	keyList := self newList.
	keyList display: [ :character | self displayStringForCharacter: character ].

	removeKeyButton := self newButton
		label: 'Remove selected key';
		action: [ self removeSelectedCharacter ];
		yourself.

	captureMorph := KMCatcherMorph new.
	captureMorph initialShortcut: self shortcut asKMShortcut.
	captureMorphPresenter := self newMorph.
	captureMorphPresenter morph: captureMorph.
	useCapturedShortcutButton := self newButton
		label: 'Use captured shortcut';
		action: [ self useCapturedShortcut ];
		yourself.

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
	anEditor registerReplayPresenter: useCapturedShortcutButton named: aPrefix , ' use captured shortcut button'
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
	aPresenterName = 'Shortcut use captured shortcut button' ifTrue: [ ^ useCapturedShortcutButton ].
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

{ #category : 'actions' }
ReplayShortcutKeysPresenter >> useCapturedShortcut [

	captureMorph ifNil: [ ^ self ].
	self shortcut beForShortcut: captureMorph shortcut.
	self refreshKeyList.
	self notifyChanged
]

{ #category : 'accessing' }
ReplayShortcutKeysPresenter >> useCapturedShortcutButton [

	^ useCapturedShortcutButton
]
