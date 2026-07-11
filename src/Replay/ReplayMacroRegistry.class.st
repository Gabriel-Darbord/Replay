Class {
	#name : 'ReplayMacroRegistry',
	#superclass : 'Object',
	#instVars : [
		'library'
	],
	#classInstVars : [
		'Default'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayMacroRegistry class >> default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> defaultFile [

	^ FileLocator preferences / 'replay-macros.ston'
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> load [

	self default load
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> loadAndInstall [

	self default loadAndInstall
]

{ #category : 'editing' }
ReplayMacroRegistry class >> openEditor [
	<script>

	^ self default openEditor
]

{ #category : 'initialization' }
ReplayMacroRegistry class >> resetDefault [

	Default := nil
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> save [

	self default save
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> install [

	^ self library install
]

{ #category : 'accessing' }
ReplayMacroRegistry >> library [

	^ library ifNil: [ library := ReplayMacroLibrary new ]
]

{ #category : 'accessing' }
ReplayMacroRegistry >> library: aReplayMacroLibrary [

	library := aReplayMacroLibrary
]

{ #category : 'persistence' }
ReplayMacroRegistry >> load [

	self loadFromFile: self class defaultFile
]

{ #category : 'persistence' }
ReplayMacroRegistry >> loadAndInstall [

	self loadAndInstallFromFile: self class defaultFile
]

{ #category : 'persistence' }
ReplayMacroRegistry >> loadAndInstallFromFile: aFileReference [

	self loadFromFile: aFileReference.
	self install
]

{ #category : 'persistence' }
ReplayMacroRegistry >> loadFromFile: aFileReference [

	aFileReference exists ifFalse: [ ^ self ].
	aFileReference readStreamDo: [ :stream |
		self library: (STON fromStream: stream) ]
]

{ #category : 'editing' }
ReplayMacroRegistry >> openEditor [

	^ (ReplayMacroLibraryEditor onRegistry: self) open
]

{ #category : 'persistence' }
ReplayMacroRegistry >> save [

	self saveToFile: self class defaultFile
]

{ #category : 'persistence' }
ReplayMacroRegistry >> saveToFile: aFileReference [

	aFileReference writeStreamDo: [ :stream |
		STON put: self library onStreamPretty: stream ]
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> uninstall [

	self library uninstall
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> uninstallAllReplayMacros [

	ReplayMacro uninstallAllInstalledKeymaps
]
