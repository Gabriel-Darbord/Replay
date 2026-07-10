"
Headless tests for semantic presenter scripts.
"
Class {
	#name : 'ReplayPresenterScriptTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayPresenterScriptTest >> testRunExecutesScriptWithManagedPresenterAsReceiver [

	| presenter manager runner action |
	presenter := ReplayScriptablePresenter new.
	manager := ReplayUIManager new
		           managedPresenter: presenter;
		           yourself.
	runner := ReplayRunner new manager: manager.
	action := ReplayPresenterScript new script: 'self record: #ran'.
	action runOn: runner.
	self assert: presenter log asArray equals: #( ran )
]

{ #category : 'tests' }
ReplayPresenterScriptTest >> testRunWithManagerWithoutBackendRaisesReplayMissingUIError [

	| runner action |
	runner := ReplayRunner new manager: ReplayUIManager new.
	action := ReplayPresenterScript new script: '1 + 1'.

	self
		should: [ action runOn: runner ]
		raise: ReplayMissingUIError
		whoseDescriptionIncludes: 'No semantic UI script receiver'
		description: 'Presenter scripts require semantic receiver backend'
]

{ #category : 'tests' }
ReplayPresenterScriptTest >> testRunWithoutManagedPresenterRaisesReplayMissingUIError [

	| action |
	action := ReplayPresenterScript new script: '1 + 1'.
	self
		should: [ action runOn: ReplayRunner new ]
		raise: ReplayMissingUIError
		whoseDescriptionIncludes: 'No semantic UI script receiver'
		description: 'Presenter scripts require a backend semantic script receiver'
]
