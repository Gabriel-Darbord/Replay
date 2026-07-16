"
I add a visual annotation around a resolved UI target. I use the active UI manager overlay so scenarios can explain widgets without modifying the managed UI.
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

{ #category : 'editing' }
ReplayAnnotate >> placementPresenterOn: editor [

	| dropList choices |
	choices := self class placementChoices.
	dropList := editor newDropList.
	dropList
		items: choices;
		display: [ :association | association value ];
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
				self placement: association key.
				editor actions rebuildLayout ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self placement ]
		ifNone: [ choices first ]).
	editor registerReplayPresenter: dropList named: 'Action annotation placement'.
	editor registerReplayPresenter: dropList named: self class displayName , ' placement'.
	^ SpBoxLayout newTopToBottom
		add: 'Label placement:' expand: false;
		add: dropList expand: false;
		yourself
]

{ #category : 'printing' }
ReplayAnnotate >> printOn: stream [

	super printOn: stream.
	text isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (text printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayAnnotate >> runOn: runner onUI: ui [

	runner manager defer: [
		runner manager addOverlay: (ReplayAnnotation
			annotate: ui bounds
			label: self text
			placement: self placement) ]
]

{ #category : 'running' }
ReplayAnnotate >> runOn: runner resolvedUI: resolvedUI [

	| bounds |
	bounds := resolvedUI boundsInSurface.
	bounds ifNil: [ ^ super runOn: runner resolvedUI: resolvedUI ].
	runner manager defer: [
		runner manager addOverlay: (ReplayAnnotation
			annotate: bounds
			label: self text
			placement: self placement) ]
]

{ #category : 'editing' }
ReplayAnnotate >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self placementPresenterOn: editor) expand: false;
			add: (self
				textPresenterOn: editor
				labeled: 'Write rich text display next annotated UI element:');
			yourself);
		yourself
]
