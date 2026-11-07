"
I am the owner of a macro library, and optionally of the STON file it is saved to.

Changes to my library go through me so that they are saved and that no keymap keeps running a macro I no longer hold: replaceLibrary: uninstalls the keymaps of the old library before installing the same macros from the new one, and importString: adds macros pasted as STON.

My default instance is on the default file (in the preferences folder, shared by every image) and loads it on first access. Registries created otherwise have no file and never touch the disk unless given one with file:. I register with the SessionManager: when the image starts, the default registry reloads its file and installs the macros if the library says so, without ever breaking the startup.
"
Class {
	#name : 'ReplayMacroRegistry',
	#superclass : 'Object',
	#instVars : [
		'library',
		'file'
	],
	#classInstVars : [
		'default'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'accessing' }
ReplayMacroRegistry class >> default [
	"The registry on the default file, loaded on first access"

	^ default ifNil: [ default := self onFile: self defaultFile ]
]

{ #category : 'accessing' }
ReplayMacroRegistry class >> default: aReplayMacroRegistry [
	"Use aReplayMacroRegistry as the default one, for example a registry on another file"

	default := aReplayMacroRegistry
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> defaultFile [

	^ FileLocator preferences / 'replay-macros.ston'
]

{ #category : 'testing' }
ReplayMacroRegistry class >> hasDefault [
	"Whether the default registry exists, so that macros of its library can be in use"

	^ default isNotNil
]

{ #category : 'class initialization' }
ReplayMacroRegistry class >> initialize [

	(SessionManager default hasRegistered: self name) ifFalse: [
		SessionManager default registerUserClassNamed: self name ]
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> libraryFromFile: aFileReference [

	^ [ self libraryFromString: aFileReference contents ]
		  on: FileException
		  do: [ :error |
			  ReplayError new
				  subject: aFileReference;
				  signal: 'Cannot read ' , aFileReference fullName , ': ' , error messageText ]
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> libraryFromString: aString [
	"The macro library saved as STON in aString"

	| object |
	object := self objectFromString: aString.
	(object isKindOf: ReplayMacroLibrary) ifFalse: [
		ReplayError new
			subject: object;
			signal: 'Expected a Replay macro library, not ' , object class name ].
	^ object
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> macrosFromString: aString [
	"The macros saved as STON in aString, either one macro or a whole library"

	| object |
	object := self objectFromString: aString.
	(object isKindOf: ReplayMacro) ifTrue: [ ^ { object } ].
	(object isKindOf: ReplayMacroLibrary) ifTrue: [ ^ object macros asArray ].
	^ ReplayError new
		  subject: object;
		  signal: 'Expected a Replay macro or macro library, not ' , object class name
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> objectFromString: aString [

	^ [ STON fromString: aString ]
		  on: Error
		  do: [ :error |
			  ReplayError new
				  subject: aString;
				  signal: 'Not a valid STON string: ' , error messageText ]
]

{ #category : 'instance creation' }
ReplayMacroRegistry class >> onFile: aFileReference [
	"A registry saving to aFileReference, with the library already saved there if any"

	^ self new
		  file: aFileReference;
		  load;
		  yourself
]

{ #category : 'system startup' }
ReplayMacroRegistry class >> startUp: isImageStarting [
	"Reload the default library from its file, which other images may have changed, and install it if it says so.
	A missing or bad file never breaks the startup."

	isImageStarting ifFalse: [ ^ self ].
	[
		default
			ifNil: [ self default ]
			ifNotNil: [ :registry | registry load ].
		default installOnStartup ]
		on: Error
		do: [ :error | self traceCr: 'Replay macros were not loaded at startup: ' , error messageText ]
]

{ #category : 'accessing' }
ReplayMacroRegistry >> file [
	"The file my library is saved to, or nil"

	^ file
]

{ #category : 'accessing' }
ReplayMacroRegistry >> file: aFileReference [

	file := aFileReference
]

{ #category : 'adding' }
ReplayMacroRegistry >> importString: aString [
	"Add the macros of the STON aString, one macro or a whole library, and save.
	Answer the added macros. Signal a ReplayError without changing the library when aString holds no macro."

	| macros |
	macros := self class macrosFromString: aString.
	macros do: [ :macro | self library importMacro: macro ].
	self save.
	^ macros
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> install [

	^ self library install
]

{ #category : 'system startup' }
ReplayMacroRegistry >> installOnStartup [
	"Install my macros if my library says so, as when the image starts"

	self library installsOnStartup ifTrue: [ self install ]
]

{ #category : 'accessing' }
ReplayMacroRegistry >> library [

	^ library ifNil: [ library := ReplayMacroLibrary new ]
]

{ #category : 'persistence' }
ReplayMacroRegistry >> load [
	"Use the library saved in my file, if it exists. Signal a ReplayError without changing my library when it cannot be read."

	(file isNotNil and: [ file exists ]) ifFalse: [ ^ self ].
	self useLibrary: (self class libraryFromFile: file)
]

{ #category : 'adding' }
ReplayMacroRegistry >> replaceLibrary: aReplayMacroLibrary [
	"Use aReplayMacroLibrary from now on and save it"

	self useLibrary: aReplayMacroLibrary.
	self save
]

{ #category : 'persistence' }
ReplayMacroRegistry >> save [

	file ifNotNil: [ self saveToFile: file ]
]

{ #category : 'persistence' }
ReplayMacroRegistry >> saveToFile: aFileReference [
	"Write over the whole file: a write stream would leave the end of a longer previous content"

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
		STON put: self library onStreamPretty: stream ]
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> uninstall [

	self library uninstall
]

{ #category : 'private' }
ReplayMacroRegistry >> useLibrary: aReplayMacroLibrary [
	"No keymap may keep running a macro of my old library: uninstall them, then install the macros of the new library that replace them (same identifier)"

	| installedIdentifiers |
	installedIdentifiers := self library installedMacros collect: [ :macro | macro identifier ].
	self library uninstall.
	library := aReplayMacroLibrary.
	aReplayMacroLibrary macros
		select: [ :macro | installedIdentifiers includes: macro identifier ]
		thenDo: [ :macro | macro install ]
]
