"
I load, save, install, uninstall, and run macros from the persisted Replay macro library.
"
Class {
	#name : 'ReplayMacroRegistry',
	#superclass : 'Object',
	#instVars : [
		'library'
	],
	#classInstVars : [
		'Default',
		'InstallSavedMacrosOnStartup'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'accessing' }
ReplayMacroRegistry class >> default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'persistence' }
ReplayMacroRegistry class >> defaultFile [

	^ FileLocator preferences / 'replay-macros.ston'
]

{ #category : 'startup' }
ReplayMacroRegistry class >> disableStartupInstallation [

	<script>
	self startupInstallationEnabled: false
]

{ #category : 'startup' }
ReplayMacroRegistry class >> enableStartupInstallation [

	<script>
	self startupInstallationEnabled: true
]

{ #category : 'startup' }
ReplayMacroRegistry class >> installSavedMacrosOnStartup [

	<script>
	self default installSavedMacrosOnStartup
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

{ #category : 'startup' }
ReplayMacroRegistry class >> startupInstallationEnabled [

	^ InstallSavedMacrosOnStartup = true
]

{ #category : 'startup' }
ReplayMacroRegistry class >> startupInstallationEnabled: aBoolean [

	InstallSavedMacrosOnStartup := aBoolean = true
]

{ #category : 'startup' }
ReplayMacroRegistry class >> startupInstallationScriptText [

	^ 'ReplayMacroRegistry installSavedMacrosOnStartup'
]

{ #category : 'keymapping' }
ReplayMacroRegistry >> install [

	^ self library install
]

{ #category : 'startup' }
ReplayMacroRegistry >> installSavedMacrosOnStartup [

	self class startupInstallationEnabled ifFalse: [ ^ self ].
	self loadAndInstall
]

{ #category : 'startup' }
ReplayMacroRegistry >> installSavedMacrosOnStartupFromFile: aFileReference [

	self class startupInstallationEnabled ifFalse: [
		self loadFromFile: aFileReference.
		^ self ].
	self loadAndInstallFromFile: aFileReference
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
	self uninstallAllReplayMacros.
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
