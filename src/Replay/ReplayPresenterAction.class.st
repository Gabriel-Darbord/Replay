"
I am the base class for Replay actions that operate on a semantic presenter receiver exposed by a UI backend.
"
Class {
	#name : 'ReplayPresenterAction',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayPresenterAction class >> isAbstract [

	^ self = ReplayPresenterAction
]

{ #category : 'running' }
ReplayPresenterAction >> missingSemanticReceiverMessage [

	^ 'No semantic UI script receiver is available for presenter action.'
]

{ #category : 'running' }
ReplayPresenterAction >> semanticReceiverOn: runner [

	^ runner manager ifNotNil: [ :manager |
		manager backend ifNotNil: [ :backend |
			backend semanticScriptReceiver ] ]
]

{ #category : 'running' }
ReplayPresenterAction >> semanticReceiverOn: runner ifAbsent: absentBlock [

	| receiver |
	receiver := self semanticReceiverOn: runner.
	receiver ifNil: [ ^ absentBlock value ].
	^ receiver
]

{ #category : 'running' }
ReplayPresenterAction >> signalMissingSemanticReceiverOn: runner [

	^ ReplayMissingUIError new
		messageText: self missingSemanticReceiverMessage;
		tag: runner;
		signal
]
