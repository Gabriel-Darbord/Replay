"
I am responsible for opening a UI.
"
Class {
	#name : 'ReplayOpenUI',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'extent',
		'bounds'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayOpenUI class >> isAbstract [

	^ self == ReplayOpenUI
]

{ #category : 'accessing' }
ReplayOpenUI >> bounds [
	"Answer the requested window bounds, or nil to let Morphic place the window."

	^ bounds
]

{ #category : 'accessing' }
ReplayOpenUI >> bounds: aRectangle [
	"Set the requested window bounds. Nil lets Morphic place the window."

	bounds := aRectangle
]

{ #category : 'accessing' }
ReplayOpenUI >> clearPlacement [
	"Forget explicit size and placement requests."

	extent := nil.
	bounds := nil.
	^ self
]

{ #category : 'accessing' }
ReplayOpenUI >> extent [
	"Answer the requested managed UI extent, or nil to keep the UI's natural extent."

	^ extent
]

{ #category : 'accessing' }
ReplayOpenUI >> extent: aPoint [
	"Set the requested managed UI extent. Nil keeps the UI's natural extent."

	extent := aPoint
]

{ #category : 'testing' }
ReplayOpenUI >> isUIOpener [

	^ true
]

{ #category : 'running' }
ReplayOpenUI >> runOn: runner [

	| manager |
	manager := self uiManagerOn: runner.
	runner manager: manager.
	manager
		openLabeled: runner scenario title
		extent: self extent
		bounds: self bounds
]

{ #category : 'editing' }
ReplayOpenUI >> uiEditionPresenterOn: editor [

	| manager |
	manager := (self uiManagerOn: ReplayRunner new) editor: editor.
	manager wrapForEdition.
	^ editor newMorph morph: manager ui
]

{ #category : 'running' }
ReplayOpenUI >> uiManagerOn: runner [

	^ ReplayUIManager new manage: (self uiOn: runner)
]

{ #category : 'managing UI' }
ReplayOpenUI >> uiOn: runner [
	"Return the configured UI as a Morph"

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayOpenUI >> uiViewName [

	^ 'Add UI interaction'
]
