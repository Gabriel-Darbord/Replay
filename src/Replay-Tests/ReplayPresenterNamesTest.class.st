"
Tests for the names that Spec presenters give their subpresenters by default (see SpAbstractPresenter>>replayPresenterAt:ifAbsent:), and the names found for their widgets.
"
Class {
	#name : 'ReplayPresenterNamesTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayPresenterNamesTest >> testADottedPathNamesANestedSubpresenter [

	| pane |
	pane := ReplayNamedPanePresenter new.
	self
		assert: (pane replayPresenterAt: 'details.items' ifAbsent: [ nil ])
		identicalTo: pane details items.
	self
		assert: (pane replayPresenterAt: 'details.runButton' ifAbsent: [ nil ])
		identicalTo: pane details runButton.
	self assert: (pane replayPresenterAt: 'details.missing' ifAbsent: [ nil ]) isNil
]

{ #category : 'tests' }
ReplayPresenterNamesTest >> testANameNamesTheNearestSubpresenter [

	| pane |
	pane := ReplayNamedPanePresenter new.
	self assert: (pane replayPresenterAt: 'items' ifAbsent: [ nil ]) identicalTo: pane items.
	self
		assert: (pane replayPresenterAt: 'runButton' ifAbsent: [ nil ])
		identicalTo: pane details runButton
]

{ #category : 'tests' }
ReplayPresenterNamesTest >> testObservingASpecWindowUsesItsPresenter [

	| pane window manager |
	pane := ReplayNamedPanePresenter new.
	window := pane open.
	manager := ReplayUIManager new observe: window window.
	self assert: manager backend class equals: ReplaySpecBackend.
	self assert: manager managedPresenter identicalTo: pane.
	self assert: (ReplayUIManager new observe: Morph new) backend class equals: ReplayMorphicBackend
]

{ #category : 'tests' }
ReplayPresenterNamesTest >> testOverridesStillDecide [

	| presenter |
	presenter := ReplaySemanticPresenter new.
	self assert: (presenter replayPresenterAt: 'Field' ifAbsent: [ nil ]) identicalTo: presenter field
]

{ #category : 'tests' }
ReplayPresenterNamesTest >> testSpecSlotsAndOwnersAreNotNames [

	| pane |
	pane := ReplayNamedPanePresenter new.
	#( 'owner' 'layout' 'adapter' 'application' 'details.owner' ) do: [ :name |
		self assert: (pane replayPresenterAt: name ifAbsent: [ nil ]) isNil ]
]

{ #category : 'tests' }
ReplayPresenterNamesTest >> testWidgetsGetTheShortestNameThatFindsThem [

	| pane |
	pane := ReplayNamedPanePresenter new.
	pane open.
	self assert: (pane replayNameOfPresenterWith: pane items adapter widget) equals: 'items'.
	self
		assert: (pane replayNameOfPresenterWith: pane details runButton adapter widget)
		equals: 'runButton'.
	self
		assert: (pane replayNameOfPresenterWith: pane details items adapter widget)
		equals: 'details.items'.
	self assert: (pane replayNameOfPresenterWith: Morph new) isNil
]
