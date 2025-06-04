"
I am responsible for opening or interacting with UI.
"
Class {
	#name : 'ReplayUIAction',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayUIAction class >> isAbstract [

	^ self == ReplayUIAction
]

{ #category : 'editing' }
ReplayUIAction >> accumulate: accumulator viewPresentersOn: editor [
	"Hook for subclasses to manipulate its list of views.
	Key gives the view name and value is triggered when the view is selected."

	^ accumulator
		  add: self settingsViewName -> [ self settingsPresenterOn: editor ];
		  add: self uiViewName -> [ self tryUIEditionPresenterOn: editor ];
		  yourself
]

{ #category : 'editing' }
ReplayUIAction >> editionPresenterOn: editor [

	^ ReplayViewSwitcherPresenter new
		  owner: editor;
		  setViews:
			  (self accumulate: OrderedCollection new viewPresentersOn: editor);
		  yourself
]

{ #category : 'editing' }
ReplayUIAction >> settingsPresenterOn: editor [

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayUIAction >> settingsViewName [

	^ 'Edit settings'
]

{ #category : 'editing' }
ReplayUIAction >> tryUIEditionPresenterOn: editor [
	"The scenario can be in an incorrect state that prevents loading the UI.
	In that case, the error will take over with its helper presenter."

	^ [ self uiEditionPresenterOn: editor ]
		  on: ReplayError
		  do: [ :error | error helpPresenterOn: editor for: self ]
]

{ #category : 'editing' }
ReplayUIAction >> uiEditionPresenterOn: editor [

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayUIAction >> uiViewName [

	^ 'Edit UI interaction'
]
