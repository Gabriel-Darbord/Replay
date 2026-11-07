"
I list the keymaps of the Pharo keymap categories, one category at a time, so that a Shortcut action can adopt the key binding of an existing keymap. selectKeymapOf: selects the keymap that a key binding triggers.
"
Class {
	#name : 'ReplayShortcutDescriptionPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'shortcutList',
		'categoryDropList'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'layout' }
ReplayShortcutDescriptionPresenter class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: #categoryDropList withConstraints: [ :c | c height: 25 ];
		  add: #shortcutList;
		  yourself
]

{ #category : 'api' }
ReplayShortcutDescriptionPresenter >> categories: aCollectionOfSymbols [

	categoryDropList items: (aCollectionOfSymbols
			 collect: [ :e | KMRepository default categoryForName: e ]
			 thenReject: [ :e | e allEntries keymaps isEmpty ])
]

{ #category : 'accessing' }
ReplayShortcutDescriptionPresenter >> categoryDropList [

	^ categoryDropList
]

{ #category : 'initialization' }
ReplayShortcutDescriptionPresenter >> connectPresenters [

	categoryDropList transmitTo: shortcutList transform: [ :category |
		category model allEntries keymaps sorted:
			[ :keymap | keymap shortcut asString ] ascending ]
]

{ #category : 'initialization - deprecated' }
ReplayShortcutDescriptionPresenter >> initializeWidgets [

	categoryDropList := self newDropList.
	shortcutList := self newTable.

	categoryDropList display: [ :category | category name ].

	shortcutList
		addColumn:
			(SpStringTableColumn title: 'Shortcut' evaluated: #shortcut);
		addColumn: (SpStringTableColumn title: 'Name' evaluated: #name);
		addColumn:
			(SpStringTableColumn title: 'Description' evaluated: #description);
		beResizable
]

{ #category : 'api' }
ReplayShortcutDescriptionPresenter >> selectKeymapOf: aReplayKeyBinding [
	"Select the first keymap that aReplayKeyBinding triggers, and its category"

	aReplayKeyBinding isEmpty ifTrue: [ ^ self ].
	categoryDropList items do: [ :category |
		category allEntries keymaps
			detect: [ :keymap | aReplayKeyBinding matchesKeymap: keymap ]
			ifFound: [ :keymap |
				categoryDropList selectItem: category.
				shortcutList selectItem: keymap scrollToSelection: true.
				^ self ] ]
]

{ #category : 'accessing' }
ReplayShortcutDescriptionPresenter >> shortcutList [

	^ shortcutList
]
