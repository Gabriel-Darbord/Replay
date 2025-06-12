Class {
	#name : 'ReplayError',
	#superclass : 'Error',
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'editing' }
ReplayError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor about: self
]

{ #category : 'accessing' }
ReplayError >> tag [
	"Can be used to hold an arbitrary object"

	^ tag
]
