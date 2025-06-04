"
I am responsible for opening a UI.
"
Class {
	#name : 'ReplayOpenUI',
	#superclass : 'ReplayUIAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayOpenUI class >> isAbstract [

	^ self == ReplayOpenUI
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
	manager openLabeled: runner scenario title
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
