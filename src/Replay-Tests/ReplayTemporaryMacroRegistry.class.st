"
I am a ReplayMacroRegistry whose default file is chosen by tests.

My default registry is my own (class-instance variables are not shared with ReplayMacroRegistry), so tests can exercise loading the default registry on first access and at image startup without the user's macro file.
"
Class {
	#name : 'ReplayTemporaryMacroRegistry',
	#superclass : 'ReplayMacroRegistry',
	#classInstVars : [
		'DefaultFile'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'persistence' }
ReplayTemporaryMacroRegistry class >> defaultFile [

	^ DefaultFile
]

{ #category : 'persistence' }
ReplayTemporaryMacroRegistry class >> defaultFile: aFileReference [
	"Use aFileReference from now on, and forget the default registry on the previous file"

	DefaultFile := aFileReference.
	Default := nil
]
