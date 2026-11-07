"
I am the abstract open action for code browsers. Concrete subclasses provide the class, method, or package browser target, stored by name in my target. A missing or unknown target signals a ReplayError.
"
Class {
	#name : 'ReplayBrowse',
	#superclass : 'ReplayOpenUI',
	#instVars : [
		'target'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayBrowse class >> isAbstract [

	^ self == ReplayBrowse
]

{ #category : 'instance creation' }
ReplayBrowse >> browser [
	"Use the Calypso browser, free from existing context.
	For example, an existing package filter would normally transfer to a new window."

	^ ClyFullBrowserMorph onDefaultEnvironment
]

{ #category : 'error handling' }
ReplayBrowse >> missingTarget: aString [

	^ ReplayError new
		  messageText: aString;
		  subject: target;
		  signal
]

{ #category : 'printing' }
ReplayBrowse >> printOn: stream [

	super printOn: stream.
	target ifNotNil: [ stream << ': ' << target ]
]

{ #category : 'accessing' }
ReplayBrowse >> target [
	"Answer the name of the browsed class, method, or package, or nil when none is chosen."

	^ target
]
