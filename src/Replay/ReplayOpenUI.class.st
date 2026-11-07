"
I am the abstract base for actions that create a new UI and open it in a window owned by the runner.

My placement (a ReplayPlacement, or nil) requests where the window opens and how large it is. The runner manager closes the window when the scenario stops or when another UI replaces it. Editor previews build a fresh copy of my UI, so they never touch live windows.
"
Class {
	#name : 'ReplayOpenUI',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'placement'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayOpenUI class >> editorClass [

	^ ReplayOpenUIEditor
]

{ #category : 'testing' }
ReplayOpenUI class >> isAbstract [

	^ self == ReplayOpenUI
]

{ #category : 'testing' }
ReplayOpenUI >> isUIOpener [

	^ true
]

{ #category : 'accessing' }
ReplayOpenUI >> placement [
	"Answer the requested window placement, or nil to let Morphic place the window at the UI natural extent."

	^ placement
]

{ #category : 'accessing' }
ReplayOpenUI >> placement: aReplayPlacement [
	"An empty placement requests nothing, it is kept as nil."

	placement := (aReplayPlacement isNil or: [ aReplayPlacement isEmpty ])
		ifTrue: [ nil ]
		ifFalse: [ aReplayPlacement ]
]

{ #category : 'managing UI' }
ReplayOpenUI >> previewManagerOn: aReplayUIBuilder [
	"Answer a manager on a fresh copy of my UI for an editor preview."

	^ self uiManagerOn: aReplayUIBuilder
]

{ #category : 'running' }
ReplayOpenUI >> runOn: runner [

	| manager |
	manager := self uiManagerOn: runner.
	runner manager: manager.
	manager openLabeled: runner scenario title placement: self placement
]

{ #category : 'managing UI' }
ReplayOpenUI >> uiManagerOn: runner [

	^ ReplayUIManager new manage: (self uiOn: runner)
]

{ #category : 'managing UI' }
ReplayOpenUI >> uiOn: runner [
	"Return the configured UI as a Morph"

	self subclassResponsibility
]
