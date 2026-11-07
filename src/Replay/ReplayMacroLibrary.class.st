"
I am an ordered collection of macros, the unit saved and loaded by a ReplayMacroRegistry.

I also hold the library settings that are saved with the macros: whether the macros are installed when the image starts.
I install and uninstall my macros together, and detect shortcut conflicts between them.
"
Class {
	#name : 'ReplayMacroLibrary',
	#superclass : 'Object',
	#instVars : [
		'macros',
		'installsOnStartup'
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
	"A new macro running aReplayScenario, named after its title"

	^ self addMacro: (ReplayMacro new
			   scenario: aReplayScenario;
			   yourself)
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

{ #category : 'adding' }
ReplayMacroLibrary >> importMacro: aReplayMacro [
	"Add aReplayMacro from another library. It gets a new identifier if one of my macros has its own, so their keymaps stay apart."

	(self macros anySatisfy: [ :macro | macro identifier = aReplayMacro identifier ])
		ifTrue: [ aReplayMacro identifier: UUID new asString ].
	^ self addMacro: aReplayMacro
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

	| installedKeymapNames |
	installedKeymapNames := ReplayMacro installedKeymaps
		                        collect: [ :keymap | keymap name ]
		                        as: Set.
	^ self macros select: [ :macro |
		  installedKeymapNames includes: macro keymapName ]
]

{ #category : 'accessing' }
ReplayMacroLibrary >> installsOnStartup [
	"Whether the image installs my macros when it starts"

	^ installsOnStartup ifNil: [ false ]
]

{ #category : 'accessing' }
ReplayMacroLibrary >> installsOnStartup: aBoolean [
	"Not stored when false, so the default is not serialized"

	installsOnStartup := aBoolean ifTrue: [ true ]
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

	aReplayMacro hasKeyBinding ifFalse: [ ^ #(  ) ].
	aReplayMacro keyBinding = anotherReplayMacro keyBinding ifFalse: [ ^ #(  ) ].
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
ReplayMacroLibrary >> macroWithScenario: aReplayScenario [
	"The macro running aReplayScenario, or nil if none does"

	^ self macros detect: [ :macro | macro scenario == aReplayScenario ] ifNone: [ nil ]
]

{ #category : 'accessing' }
ReplayMacroLibrary >> macros [

	^ macros ifNil: [ macros := OrderedCollection new ]
]

{ #category : 'adding' }
ReplayMacroLibrary >> newMacro [
	"A macro whose new scenario has a name unused in this library"

	^ ReplayMacro new
		  scenario: (ReplayScenario new
				   title: self nextMacroName;
				   yourself);
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

	self installedMacros do: [ :macro | macro uninstall ]
]
