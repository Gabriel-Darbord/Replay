"
I describe one existing keymap that conflicts with a Replay macro shortcut in a specific context.
"
Class {
	#name : 'ReplayShortcutConflict',
	#superclass : 'Object',
	#instVars : [
		'category',
		'keymap'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'instance creation' }
ReplayShortcutConflict class >> category: aKMCategory keymap: aKMKeymap [

	^ self new
		category: aKMCategory;
		keymap: aKMKeymap;
		yourself
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

	^ ReplayMacroContext displayNameForCategoryName: self categoryName
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
	"The name of the conflicting action, or of the conflicting macro for a Replay keymap"

	^ (ReplayMacro isReplayKeymap: self keymap)
		  ifTrue: [ ReplayMacro macroNameOfKeymap: self keymap ]
		  ifFalse: [ self keymap name ]
]

{ #category : 'accessing' }
ReplayShortcutConflict >> shortcut [

	^ self keymap shortcut
]

{ #category : 'accessing' }
ReplayShortcutConflict >> shortcutString [

	^ self shortcut asString copyReplaceAll: 'Meta' with: 'Command'
]
