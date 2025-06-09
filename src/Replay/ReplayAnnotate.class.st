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

{ #category : 'editing' }
ReplayAnnotate >> pathPresenterOn: editor [
	"Can't target the World"

	^ self pathStatePresenterOn: editor
]

{ #category : 'editing' }
ReplayAnnotate >> pathUnsetPresenterOn: editor [

	^ self pathRequiredPresenterOn: editor
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

	runner manager addOverlay:
		(ReplayAnnotation annotateMorph: ui label: self text)
]

{ #category : 'editing' }
ReplayAnnotate >> settingsPresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (self pathPresenterOn: editor) expand: false;
				   add: (self
						    textPresenterOn: editor
						    labeled: 'Write the rich text to display with the element:');
				   yourself);
		  yourself
]
