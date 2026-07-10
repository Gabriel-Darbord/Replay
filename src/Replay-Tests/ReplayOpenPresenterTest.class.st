"
Headless tests for opening Spec presenters through Replay.
"
Class {
	#name : 'ReplayOpenPresenterTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayOpenPresenterTest >> testActionDisplayNameHandlesNonReplaySubclassNames [

	self assert: TestReplayAction displayName equals: 'TestReplayAction'
]

{ #category : 'tests' }
ReplayOpenPresenterTest >> testManagePresenterUsesPresenterContentNotNestedSpecWindow [

	| presenter manager |
	presenter := ReplayEditor new.
	manager := ReplayUIManager new managePresenter: presenter.

	self assert: manager managedUI isMorph.
	self deny: manager managedUI class name equals: #SpWindow
]

{ #category : 'tests' }
ReplayOpenPresenterTest >> testOpenPresenterRunUsesExplicitExtent [

	| scenario runner action requestedExtent |
	scenario := ReplayScenario new title: 'Replay open presenter test'.
	runner := ReplayRunner on: scenario.
	requestedExtent := 430 @ 210.
	action := ReplayOpenPresenter new
		script: 'ReplayEditor new';
		extent: requestedExtent;
		yourself.

	[
		self shouldnt: [ action runOn: runner ] raise: Error.
		20 timesRepeat: [ World doOneCycle. (Delay forMilliseconds: 10) wait ].
		self assert: runner manager ui extent equals: requestedExtent ]
		ensure: [ runner manager ifNotNil: [ :manager | manager close ] ]
]

{ #category : 'tests' }
ReplayOpenPresenterTest >> testUIManagerRemembersPresenterCreatedByScript [

	| action runner manager |
	action := ReplayOpenPresenter new script: 'ReplayEditor new'.
	runner := ReplayRunner new scenario: ReplayScenario new.
	manager := action uiManagerOn: runner.
	self assert: manager managedPresenter class equals: ReplayEditor.
	self assert: manager managedUI isMorph
]
