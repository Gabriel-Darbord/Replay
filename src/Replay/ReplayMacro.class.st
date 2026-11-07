"
I am a keyboard macro: a scenario run by a key binding (a ReplayKeyBinding) in keymap contexts (KMCategory names).

My name is the title of my scenario. My identifier is assigned when I am created and saved with me, so the keymaps I install keep the same name across saves and loads. Installing me adds one keymap per context to the Keymapping repository; such keymaps are recognized by their name prefix.
"
Class {
	#name : 'ReplayMacro',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'keyBinding',
		'scenario',
		'contextNames'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'keymapping' }
ReplayMacro class >> installedKeymapEntries [
	"Every installed Replay macro keymap, as category -> keymap associations"

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
ReplayMacro class >> isReplayKeymap: aKMKeymap [

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

{ #category : 'keymapping' }
ReplayMacro class >> macroNameOfKeymap: aKMKeymap [
	"The name of the macro that installed aKMKeymap, as written in its description"

	| description |
	description := aKMKeymap description ifNil: [ '' ].
	^ (description beginsWith: self keymapDescriptionPrefix)
		  ifTrue: [ description allButFirst: self keymapDescriptionPrefix size ]
		  ifFalse: [ description ]
]

{ #category : 'instance creation' }
ReplayMacro class >> scenario: aReplayScenario keyBinding: aReplayKeyBinding [

	^ self new
		  scenario: aReplayScenario;
		  keyBinding: aReplayKeyBinding;
		  yourself
]

{ #category : 'keymapping' }
ReplayMacro class >> uninstallAllInstalledKeymaps [
	"Maintenance: remove every Replay macro keymap from the image, including stale ones whose macro is in no library"

	<script>
	KMRepository default categories values do: [ :category |
		category allEntries keymaps
			select: [ :keymap | self isReplayKeymap: keymap ]
			thenDo: [ :keymap | category removeKeymapEntry: keymap ] ]
]

{ #category : 'accessing' }
ReplayMacro >> addContextNamed: aSymbol [

	(self contextNames includes: aSymbol) ifFalse: [ self contextNames add: aSymbol ]
]

{ #category : 'testing' }
ReplayMacro >> canInstall [

	^ self hasKeyBinding and: [ self hasInstallContexts ]
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
		select: [ :keymap | self keyBinding matchesKeymap: keymap ]
		thenCollect: [ :keymap |
			ReplayShortcutConflict category: aKMCategory keymap: keymap ]
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

{ #category : 'testing' }
ReplayMacro >> hasInstallContexts [

	^ self contextNames notEmpty
]

{ #category : 'testing' }
ReplayMacro >> hasKeyBinding [
	"Whether my key binding can be installed"

	^ self keyBinding isKeymappable
]

{ #category : 'accessing' }
ReplayMacro >> identifier [

	^ identifier
]

{ #category : 'accessing' }
ReplayMacro >> identifier: aString [

	identifier := aString
]

{ #category : 'initialization' }
ReplayMacro >> initialize [

	super initialize.
	identifier := UUID new asString
]

{ #category : 'keymapping' }
ReplayMacro >> install [

	self canInstall ifFalse: [ ^ #(  ) ].
	^ self contextCategories collect: [ :category | self installInCategory: category ]
]

{ #category : 'keymapping' }
ReplayMacro >> installInCategory: aKMCategory [

	| keymap |
	self hasKeyBinding ifFalse: [ ^ nil ].
	self removeOwnKeymapsFromCategory: aKMCategory.
	keymap := self keymap.
	aKMCategory addKeymapEntry: keymap.
	^ keymap
]

{ #category : 'keymapping' }
ReplayMacro >> installedCategories [

	^ KMRepository default categories values select: [ :category |
		  self installedInCategory: category ]
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

{ #category : 'keymapping' }
ReplayMacro >> installedKeymaps [

	^ self installedCategories flatCollect: [ :category |
		  category allEntries keymaps select: [ :keymap | self isOwnKeymap: keymap ] ]
]

{ #category : 'keymapping' }
ReplayMacro >> isInstalled [

	^ self installedCategories notEmpty
]

{ #category : 'conflicts' }
ReplayMacro >> isOwnKeymap: aKMKeymap [

	^ aKMKeymap name = self keymapName
]

{ #category : 'keymapping' }
ReplayMacro >> keymap [

	^ KMKeymap
		named: self keymapName
		shortcut: self keyBinding asKMShortcut
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
ReplayMacro >> keyBinding [

	^ keyBinding ifNil: [ keyBinding := ReplayKeyBinding new ]
]

{ #category : 'accessing' }
ReplayMacro >> keyBinding: aReplayKeyBinding [

	keyBinding := aReplayKeyBinding
]

{ #category : 'accessing' }
ReplayMacro >> name [
	"I am named after my scenario"

	^ self scenario title
]

{ #category : 'printing' }
ReplayMacro >> printOn: stream [

	stream nextPutAll: self name.
	self keyBinding isEmpty ifTrue: [ ^ self ].
	stream
		nextPutAll: ' (';
		nextPutAll: self keyBinding displayString;
		nextPut: $)
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

{ #category : 'keymapping' }
ReplayMacro >> uninstall [

	self installedCategories do: [ :category |
		self removeOwnKeymapsFromCategory: category ]
]

{ #category : 'keymapping' }
ReplayMacro >> updateInstalledKeymaps [
	"After a change of my key binding or contexts, move my installed keymaps to match it.
	I stay uninstalled when I was not installed, and I am uninstalled when I can no longer install."

	| installedCategories |
	installedCategories := self installedCategories.
	installedCategories ifEmpty: [ ^ self ].
	installedCategories do: [ :category | self removeOwnKeymapsFromCategory: category ].
	self install
]

{ #category : 'keymapping' }
ReplayMacro >> updateKeymapDescriptions [
	"After a change of my name, show it in the description of my installed keymaps"

	self installedKeymaps do: [ :keymap | keymap description: self keymapDescription ]
]
