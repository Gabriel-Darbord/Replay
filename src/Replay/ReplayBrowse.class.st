"
I am responsible for browsing.
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

{ #category : 'printing' }
ReplayBrowse >> printOn: stream [

	super printOn: stream.
	target ifNotNil: [ stream << ': ' << target ]
]

{ #category : 'accessing' }
ReplayBrowse >> settingsViewName [

	^ 'Select ' , self targetType name
]

{ #category : 'accessing' }
ReplayBrowse >> targetType [

	self subclassResponsibility
]
