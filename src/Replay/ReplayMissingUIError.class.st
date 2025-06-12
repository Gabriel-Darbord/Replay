Class {
	#name : 'ReplayMissingUIError',
	#superclass : 'ReplayError',
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'editing' }
ReplayMissingUIError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor aboutMissingUI: self
]
