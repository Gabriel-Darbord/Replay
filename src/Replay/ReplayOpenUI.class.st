"
I am responsible for opening a UI.
"
Class {
	#name : 'ReplayOpenUI',
	#superclass : 'ReplayUIAction',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'testing' }
ReplayOpenUI class >> isAbstract [

	^ self == ReplayOpenUI
]

{ #category : 'testing' }
ReplayOpenUI >> isUIOpener [

	^ true
]

{ #category : 'managing UI' }
ReplayOpenUI >> managerOfUI [
	"Return the configured UI manager"

	^ ReplayUIManager new manage: self ui
]

{ #category : 'running' }
ReplayOpenUI >> runOn: runner [

	| manager |
	manager := self managerOfUI.
	runner manager: manager.
	manager openLabeled: runner scenario title
]

{ #category : 'managing UI' }
ReplayOpenUI >> ui [
	"Return the configured UI as a Morph"

	self subclassResponsibility
]

{ #category : 'editing' }
ReplayOpenUI >> uiEditionPresenterOn: editor [

	| manager |
	manager := self managerOfUI editor: editor.
	manager wrapForEdition.
	^ editor newMorph morph: manager ui
]

{ #category : 'accessing' }
ReplayOpenUI >> uiViewName [

	^ 'Add UI interaction'
]
