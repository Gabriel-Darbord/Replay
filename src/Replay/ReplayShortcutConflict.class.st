Class {
	#name : 'ReplayShortcutConflict',
	#superclass : 'Object',
	#instVars : [
		'category',
		'keymap'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'instance creation' }
ReplayShortcutConflict class >> category: aKMCategory keymap: aKMKeymap [

	^ self new
		category: aKMCategory;
		keymap: aKMKeymap;
		yourself
]

{ #category : 'formatting' }
ReplayShortcutConflict class >> displayNameForCategoryName: aSymbol [

	| technical readable |
	technical := aSymbol asString.
	readable := self readableNameForCategoryName: technical.
	^ readable = technical
		ifTrue: [ technical ]
		ifFalse: [ readable , ' (' , technical , ')' ]
]

{ #category : 'formatting' }
ReplayShortcutConflict class >> readableNameForCategoryName: aString [

	| source words |
	source := (aString beginsWith: 'Rub')
		ifTrue: [ aString allButFirst: 3 ]
		ifFalse: [ aString ].
	words := String streamContents: [ :stream |
		source withIndexDo: [ :character :index |
			(index > 1 and: [
				character isUppercase and: [
					(source at: index - 1) isLowercase
						or: [ index < source size and: [ (source at: index + 1) isLowercase ] ] ] ])
				ifTrue: [ stream space ].
			stream nextPut: character ] ].
	^ words asLowercase capitalized
]

{ #category : 'accessing' }
ReplayShortcutConflict >> category [

	^ category
]

{ #category : 'accessing' }
ReplayShortcutConflict >> category: aKMCategory [

	category := aKMCategory
]

{ #category : 'accessing' }
ReplayShortcutConflict >> categoryName [

	^ self category name
]

{ #category : 'accessing' }
ReplayShortcutConflict >> contextDisplayName [

	^ self class displayNameForCategoryName: self categoryName
]

{ #category : 'accessing' }
ReplayShortcutConflict >> description [

	^ self keymap description ifNil: [ '' ]
]

{ #category : 'accessing' }
ReplayShortcutConflict >> keymap [

	^ keymap
]

{ #category : 'accessing' }
ReplayShortcutConflict >> keymap: aKMKeymap [

	keymap := aKMKeymap
]

{ #category : 'accessing' }
ReplayShortcutConflict >> name [

	| replayPrefix |
	replayPrefix := 'Replay macro: '.
	(self description beginsWith: replayPrefix) ifTrue: [
		^ self description allButFirst: replayPrefix size ].
	^ self keymap name
]

{ #category : 'accessing' }
ReplayShortcutConflict >> shortcut [

	^ self keymap shortcut
]

{ #category : 'accessing' }
ReplayShortcutConflict >> shortcutString [

	^ self shortcut asString copyReplaceAll: 'Meta' with: 'Command'
]
