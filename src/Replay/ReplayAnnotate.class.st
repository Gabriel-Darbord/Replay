"
Annotate a UI element.
"
Class {
	#name : 'ReplayAnnotate',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAnnotate class >> displayName [

	^ 'Annotate'
]

{ #category : 'testing' }
ReplayAnnotate >> allowsWorldTarget [
	^ false
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

	self currentWorld defer: [
		runner manager addOverlay:
			(ReplayAnnotation annotateMorph: ui label: self text) ]
]

{ #category : 'running' }
ReplayAnnotate >> runOn: runner resolvedUI: resolvedUI [

	| bounds |
	bounds := resolvedUI boundsInSurface.
	bounds ifNil: [ ^ super runOn: runner resolvedUI: resolvedUI ].
	self currentWorld defer: [
		runner manager addOverlay:
			(ReplayAnnotation annotate: bounds label: self text) ]
]

{ #category : 'editing' }
ReplayAnnotate >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetPresenterOn: editor) expand: false;
				add: (self
						textPresenterOn: editor
						labeled:
							'Write rich text display next annotated UI element:');
				yourself);
		yourself
]
