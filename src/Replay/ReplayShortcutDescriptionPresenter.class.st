"
I display available Pharo keymaps so shortcut actions and macro editors can inspect and adopt existing shortcuts.
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

{ #category : 'instance creation' }
ReplayShortcutDescriptionPresenter class >> descriptionText [

	^ 'Describes the shortcuts in the system'
]

{ #category : 'accessing' }
ReplayShortcutDescriptionPresenter class >> icon [

	^ self iconNamed: #keymapBrowser
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

{ #category : 'initialization' }
ReplayShortcutDescriptionPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Shortcuts description';
		initialExtent: 600 @ 350
]

{ #category : 'accessing' }
ReplayShortcutDescriptionPresenter >> shortcutList [

	^ shortcutList
]
