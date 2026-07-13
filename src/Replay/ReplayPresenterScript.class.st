"
I execute Smalltalk script with the managed Spec presenter as the receiver.
"
Class {
	#name : 'ReplayPresenterScript',
	#superclass : 'ReplayScript',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayPresenterScript class >> displayName [

	^ 'Presenter Script'
]

{ #category : 'running' }
ReplayPresenterScript >> runOn: runner [

	| receiver compiler method |
	receiver := runner manager ifNotNil: [ :manager |
		manager backend ifNotNil: [ :backend |
			backend semanticScriptReceiver ] ].
	receiver ifNil: [
		ReplayMissingUIError new
			messageText: 'No semantic UI script receiver is available for presenter script.';
			tag: runner;
			signal ].
	compiler := Smalltalk compiler isScripting: true.
	compiler ast: (compiler parse: self script) asDoit.
	method := compiler compile.
	method valueWithReceiver: receiver arguments: #( )
]
