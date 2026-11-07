"
I add a visual annotation around a resolved UI target, with an optional label and its placement. I use the overlay of the active UI manager so scenarios can explain widgets without modifying the managed UI.

I need a target: annotating the whole World is refused.
"
Class {
	#name : 'ReplayAnnotate',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#instVars : [
		'placement'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayAnnotate class >> editorClass [

	^ ReplayAnnotateEditor
]

{ #category : 'accessing' }
ReplayAnnotate class >> displayName [

	^ 'Annotate'
]

{ #category : 'accessing' }
ReplayAnnotate class >> placementChoices [

	^ {
		#automatic -> 'Automatic'.
		#right -> 'Right'.
		#left -> 'Left'.
		#below -> 'Below'.
		#above -> 'Above'.
		#belowRight -> 'Below right'.
		#aboveRight -> 'Above right'.
		#belowLeft -> 'Below left'.
		#aboveLeft -> 'Above left' }
]

{ #category : 'testing' }
ReplayAnnotate >> allowsWorldTarget [
	^ false
]

{ #category : 'accessing' }
ReplayAnnotate >> placement [

	^ placement ifNil: [ #automatic ]
]

{ #category : 'accessing' }
ReplayAnnotate >> placement: aSymbol [

	placement := aSymbol ifNil: [ #automatic ] ifNotNil: [ aSymbol asSymbol ]
]

{ #category : 'printing' }
ReplayAnnotate >> printOn: stream [

	super printOn: stream.
	text isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (text printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayAnnotate >> runOnMorph: aMorph [
	"Not sent: see runOn:resolvedUI:"
]

{ #category : 'running' }
ReplayAnnotate >> runOn: runner resolvedUI: resolvedUI [
	"Highlight the widget of my target in the overlay of the managed UI, once the UI has processed the previous actions"

	| bounds |
	resolvedUI morphRequiredFor: self.
	bounds := resolvedUI boundsInSurface.
	runner manager defer: [
		runner manager addOverlay: (ReplayAnnotation
			annotate: bounds
			label: self text
			placement: self placement) ]
]
