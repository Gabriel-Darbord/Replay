"
I add a one-shot capture callback to KMCatcherMorph for Replay shortcut editors.
"
Class {
	#name : 'ReplayShortcutCaptureMorph',
	#superclass : 'KMCatcherMorph',
	#instVars : [
		'captureBlock',
		'capturing'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'capturing' }
ReplayShortcutCaptureMorph >> captureNextShortcutThenDo: aBlock [

	self clear.
	captureBlock := aBlock.
	capturing := true
]

{ #category : 'testing' }
ReplayShortcutCaptureMorph >> isCapturing [

	^ capturing ifNil: [ false ]
]

{ #category : 'event handling' }
ReplayShortcutCaptureMorph >> keyStroke: aKeyStroke [

	super keyStroke: aKeyStroke.
	capturing ifTrue: [
		capturing := false.
		captureBlock ifNotNil: [ :block | block cull: self shortcut ] ]
]
