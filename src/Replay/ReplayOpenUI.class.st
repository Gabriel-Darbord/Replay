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
ReplayOpenUI >> managerOnUI [
	"Return the configured UI manager"

	^ ReplayUIManager new manage: self ui
]

{ #category : 'running' }
ReplayOpenUI >> runOn: runner [

	| manager |
	manager := self managerOnUI.
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
	manager := self managerOnUI editor: editor.
	manager wrapForEdition.
	^ SpMorphPresenter new morph: manager ui
]
