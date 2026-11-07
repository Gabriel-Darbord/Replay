"
I test ReplayViewSwitcherPresenter: one radio button per view, the first view shown, and views built when selected.
"
Class {
	#name : 'ReplayViewSwitcherPresenterTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayViewSwitcherPresenterTest >> testShowsTheFirstViewAndBuildsOthersWhenSelected [

	| first second secondBuilds switcher |
	first := SpLabelPresenter new.
	second := SpLabelPresenter new.
	secondBuilds := 0.
	switcher := ReplayViewSwitcherPresenter new setViews: {
			            ('First' -> [ first ]).
			            ('Second' -> [
			             secondBuilds := secondBuilds + 1.
			             second ]) }.

	self assert: (switcher switcher presenters collect: [ :button | button label ] as: Array) equals: #( 'First' 'Second' ).
	self assert: switcher view identicalTo: first.
	self assert: secondBuilds equals: 0.
	(switcher switcher presenterAt: 2) state: true.
	self assert: switcher view identicalTo: second.
	self assert: secondBuilds equals: 1.
	self deny: (switcher switcher presenterAt: 1) state
]
