Class {
	#name : 'ReplayMacro',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'name',
		'shortcut',
		'scenario',
		'contextNames'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'keymapping' }
ReplayMacro class >> installedKeymapCount [

	^ self installedKeymapEntries size
]

{ #category : 'keymapping' }
ReplayMacro class >> installedKeymapEntries [

	| entries |
	entries := OrderedCollection new.
	KMRepository default categories values do: [ :category |
		category allEntries keymaps do: [ :keymap |
			(self isReplayKeymap: keymap) ifTrue: [ entries add: category -> keymap ] ] ].
	^ entries
]

{ #category : 'keymapping' }
ReplayMacro class >> installedKeymaps [

	^ self installedKeymapEntries collect: [ :association | association value ]
]

{ #category : 'keymapping' }
ReplayMacro class >> isLegacyReplayKeymap: aKMKeymap [

	^ (self isReplayKeymap: aKMKeymap)
		and: [ (self isStableReplayKeymap: aKMKeymap) not ]
]

{ #category : 'keymapping' }
ReplayMacro class >> isReplayKeymap: aKMKeymap [

	^ aKMKeymap description beginsWith: self keymapDescriptionPrefix
]

{ #category : 'keymapping' }
ReplayMacro class >> isStableReplayKeymap: aKMKeymap [

	^ aKMKeymap name asString beginsWith: self keymapNamePrefix
]

{ #category : 'keymapping' }
ReplayMacro class >> keymapDescriptionPrefix [

	^ 'Replay macro: '
]

{ #category : 'keymapping' }
ReplayMacro class >> keymapNamePrefix [

	^ 'ReplayMacro-'
]

{ #category : 'instance creation' }
ReplayMacro class >> named: aString shortcut: aReplayShortcut scenario: aReplayScenario [

	^ self new
		name: aString;
		shortcut: aReplayShortcut;
		scenario: aReplayScenario;
		yourself
]

{ #category : 'keymapping' }
ReplayMacro class >> uninstallAllInstalledKeymaps [

	KMRepository default categories values do: [ :category |
		category allEntries keymaps
			select: [ :keymap | self isReplayKeymap: keymap ]
			thenDo: [ :keymap | category removeKeymapEntry: keymap ] ]
]

{ #category : 'accessing' }
ReplayMacro >> addContextNamed: aSymbol [

	(self contextNames includes: aSymbol) ifFalse: [ self contextNames add: aSymbol ]
]

{ #category : 'conflicts' }
ReplayMacro >> conflictCategories [

	^ self conflictCategoryNames collect: [ :contextName |
		KMRepository default categoryForName: contextName ]
]

{ #category : 'conflicts' }
ReplayMacro >> conflictCategoryNames [

	^ ReplayMacroContext conflictCategoryNamesForCategoryNames: self contextNames
]

{ #category : 'conflicts' }
ReplayMacro >> conflicts [

	^ self conflictsInCategories: self conflictCategories
]

{ #category : 'conflicts' }
ReplayMacro >> conflictsInCategories: aCollectionOfKMCategories [

	^ aCollectionOfKMCategories flatCollect: [ :category |
		self conflictsInCategory: category ]
]

{ #category : 'conflicts' }
ReplayMacro >> conflictsInCategory: aKMCategory [

	^ (aKMCategory allEntries keymaps
		reject: [ :keymap | self isOwnKeymap: keymap ])
		select: [ :keymap | self shortcut matchesKeymap: keymap ]
		thenCollect: [ :keymap |
			ReplayShortcutConflict category: aKMCategory keymap: keymap ]
]

{ #category : 'conflicts' }
ReplayMacro >> conflictsInContextNamed: aSymbol [

	^ self conflictsInCategory: (KMRepository default categoryForName: aSymbol)
]

{ #category : 'accessing' }
ReplayMacro >> contextCategories [

	^ self contextNames collect: [ :contextName |
		KMRepository default categoryForName: contextName ]
]

{ #category : 'accessing' }
ReplayMacro >> contextNames [

	^ contextNames ifNil: [ contextNames := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayMacro >> contextNames: aCollection [

	contextNames := aCollection asOrderedCollection
]

{ #category : 'accessing' }
ReplayMacro >> identifier [

	^ identifier ifNil: [ identifier := UUID new asString ]
]

{ #category : 'accessing' }
ReplayMacro >> identifier: aString [

	identifier := aString
]

{ #category : 'keymapping' }
ReplayMacro >> install [

	^ self contextNames collect: [ :contextName |
		self installInContextNamed: contextName ]
]

{ #category : 'keymapping' }
ReplayMacro >> installInCategory: aKMCategory [

	| keymap |
	self removeOwnKeymapsFromCategory: aKMCategory.
	self removeLegacyConflictingKeymapsFromCategory: aKMCategory.
	keymap := self keymap.
	aKMCategory addKeymapEntry: keymap.
	^ keymap
]

{ #category : 'keymapping' }
ReplayMacro >> installInContextNamed: aSymbol [

	^ self installInCategory: (KMRepository default categoryForName: aSymbol)
]

{ #category : 'keymapping' }
ReplayMacro >> installedCategories [

	^ KMRepository default categories values select: [ :category |
	self installedInCategory: category ]
]

{ #category : 'keymapping' }
ReplayMacro >> installedContextNames [

	^ self installedCategories collect: [ :category | category name ]
]

{ #category : 'keymapping' }
ReplayMacro >> installedInCategory: aKMCategory [

	^ aKMCategory allEntries keymaps anySatisfy: [ :keymap |
	self isOwnKeymap: keymap ]
]

{ #category : 'keymapping' }
ReplayMacro >> installedInContextNamed: aSymbol [

	^ self installedInCategory: (KMRepository default categoryForName: aSymbol)
]

{ #category : 'conflicts' }
ReplayMacro >> isOwnKeymap: aKMKeymap [

	^ aKMKeymap name = self keymapName
]

{ #category : 'keymapping' }
ReplayMacro >> keymap [

	^ KMKeymap
		named: self keymapName
		shortcut: self shortcut asKMShortcut
		action: [ self run ]
		description: self keymapDescription
]

{ #category : 'keymapping' }
ReplayMacro >> keymapDescription [

	^ self class keymapDescriptionPrefix , self name
]

{ #category : 'keymapping' }
ReplayMacro >> keymapName [

	^ (self class keymapNamePrefix , self identifier) asSymbol
]

{ #category : 'accessing' }
ReplayMacro >> name [

	^ name ifNil: [ 'Unnamed Macro' ]
]

{ #category : 'accessing' }
ReplayMacro >> name: aString [

	name := aString
]

{ #category : 'printing' }
ReplayMacro >> printOn: stream [

	stream nextPutAll: self name.
	self shortcut text isEmpty ifTrue: [ ^ self ].
	stream
		nextPutAll: ' (';
		nextPutAll: self shortcut asKMShortcut asString;
		nextPut: $)
]

{ #category : 'keymapping' }
ReplayMacro >> removeLegacyConflictingKeymapsFromCategory: aKMCategory [

	aKMCategory allEntries keymaps
		select: [ :keymap |
			(self class isLegacyReplayKeymap: keymap)
				and: [ self shortcut matchesKeymap: keymap ] ]
		thenDo: [ :keymap | aKMCategory removeKeymapEntry: keymap ]
]

{ #category : 'keymapping' }
ReplayMacro >> removeOwnKeymapsFromCategory: aKMCategory [

	aKMCategory allEntries keymaps
		select: [ :keymap | self isOwnKeymap: keymap ]
		thenDo: [ :keymap | aKMCategory removeKeymapEntry: keymap ]
]

{ #category : 'running' }
ReplayMacro >> run [

	^ self scenario run
]

{ #category : 'accessing' }
ReplayMacro >> scenario [

	^ scenario ifNil: [ scenario := ReplayScenario new ]
]

{ #category : 'accessing' }
ReplayMacro >> scenario: aReplayScenario [

	scenario := aReplayScenario
]

{ #category : 'accessing' }
ReplayMacro >> shortcut [

	^ shortcut ifNil: [ shortcut := ReplayShortcut new ]
]

{ #category : 'accessing' }
ReplayMacro >> shortcut: aReplayShortcut [

	shortcut := aReplayShortcut
]

{ #category : 'accessing' }
ReplayMacro >> shortcutFromKeymap: aKMKeymap [

	self shortcut: (ReplayShortcut fromKeymap: aKMKeymap)
]

{ #category : 'keymapping' }
ReplayMacro >> uninstall [

	self installedCategories do: [ :category |
		self uninstallFromCategory: category ]
]

{ #category : 'keymapping' }
ReplayMacro >> uninstallFromCategory: aKMCategory [

	self removeOwnKeymapsFromCategory: aKMCategory
]

{ #category : 'keymapping' }
ReplayMacro >> uninstallFromContextNamed: aSymbol [

	self uninstallFromCategory: (KMRepository default categoryForName: aSymbol)
]

{ #category : 'keymapping' }
ReplayMacro >> updateInstalledKeymaps [

	| installedCategories targetCategories |
	installedCategories := self installedCategories asOrderedCollection.
	installedCategories ifNotEmpty: [
		targetCategories := self contextNames
			ifEmpty: [ installedCategories ]
			ifNotEmpty: [ self contextCategories ].
		installedCategories do: [ :category | self uninstallFromCategory: category ].
		targetCategories do: [ :category | self installInCategory: category ] ]
]
