"
I hold the ordered collection of macros persisted by ReplayMacroRegistry and provide conflict and installation helpers.
"
Class {
	#name : 'ReplayMacroLibrary',
	#superclass : 'Object',
	#instVars : [
		'macros'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'adding' }
ReplayMacroLibrary >> addMacro: aReplayMacro [

	self macros add: aReplayMacro.
	^ aReplayMacro
]

{ #category : 'adding' }
ReplayMacroLibrary >> addMacroForScenario: aReplayScenario [

	| macro scenarioTitle |
	macro := self newMacro.
	macro scenario: aReplayScenario.
	scenarioTitle := aReplayScenario title.
	(scenarioTitle isEmpty or: [ scenarioTitle = 'Unnamed Scenario' ]) ifFalse: [
		macro name: scenarioTitle ].
	^ self addMacro: macro
]

{ #category : 'adding' }
ReplayMacroLibrary >> addNewMacro [

	^ self addMacro: self newMacro
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> conflicts [

	^ self externalConflicts , self internalConflicts
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> externalConflicts [

	^ self macros flatCollect: [ :macro | macro conflicts ]
]

{ #category : 'keymapping' }
ReplayMacroLibrary >> install [

	^ self macros flatCollect: [ :macro | macro install ]
]

{ #category : 'keymapping' }
ReplayMacroLibrary >> installedMacroCount [

	^ self installedMacros size
]

{ #category : 'keymapping' }
ReplayMacroLibrary >> installedMacros [

	^ self macros select: [ :macro | macro installedCategories notEmpty ]
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> internalConflictCategoryNamesBetween: aReplayMacro and: anotherReplayMacro [

	^ ReplayMacroContext
		internalConflictCategoryNamesBetween: aReplayMacro contextNames
		and: anotherReplayMacro contextNames
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> internalConflicts [

	| conflicts |
	conflicts := OrderedCollection new.
	1 to: self macros size do: [ :index |
		index + 1 to: self macros size do: [ :otherIndex |
			conflicts addAll: (self
				internalConflictsBetween: (self macros at: index)
				and: (self macros at: otherIndex)) ] ].
	^ conflicts
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> internalConflictsBetween: aReplayMacro and: anotherReplayMacro [

	(aReplayMacro shortcut text isEmpty or: [ anotherReplayMacro shortcut text isEmpty ]) ifTrue: [ ^ #() ].
	(aReplayMacro shortcut sameShortcutAs: anotherReplayMacro shortcut) ifFalse: [ ^ #() ].
	^ (self internalConflictCategoryNamesBetween: aReplayMacro and: anotherReplayMacro)
		collect: [ :contextName |
			ReplayShortcutConflict
				category: (KMRepository default categoryForName: contextName)
				keymap: anotherReplayMacro keymap ]
]

{ #category : 'conflicts' }
ReplayMacroLibrary >> internalConflictsForMacro: aReplayMacro [

	| conflicts |
	conflicts := OrderedCollection new.
	self macros do: [ :otherMacro |
		otherMacro == aReplayMacro ifFalse: [
			conflicts addAll: (self
				internalConflictsBetween: aReplayMacro
				and: otherMacro) ] ].
	^ conflicts
]

{ #category : 'accessing' }
ReplayMacroLibrary >> macroForScenario: aReplayScenario [

	^ self macros
		detect: [ :macro | macro scenario == aReplayScenario ]
		ifNone: [ self addMacroForScenario: aReplayScenario ]
]

{ #category : 'accessing' }
ReplayMacroLibrary >> macros [

	^ macros ifNil: [ macros := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayMacroLibrary >> macros: aCollection [

	macros := aCollection asOrderedCollection
]

{ #category : 'adding' }
ReplayMacroLibrary >> newMacro [

	^ ReplayMacro new
		name: self nextMacroName;
		yourself
]

{ #category : 'adding' }
ReplayMacroLibrary >> nextMacroName [

	| index candidate |
	index := 1.
	[
		candidate := 'Macro ' , index asString.
		self macros anySatisfy: [ :macro | macro name = candidate ] ]
		whileTrue: [ index := index + 1 ].
	^ candidate
]

{ #category : 'removing' }
ReplayMacroLibrary >> removeMacro: aReplayMacro [

	aReplayMacro uninstall.
	self macros remove: aReplayMacro ifAbsent: [ ]
]

{ #category : 'keymapping' }
ReplayMacroLibrary >> uninstall [

	self macros do: [ :macro | macro uninstall ]
]
