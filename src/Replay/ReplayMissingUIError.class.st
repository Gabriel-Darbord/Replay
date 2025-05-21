Class {
	#name : 'ReplayMissingUIError',
	#superclass : 'ReplayError',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'editing' }
ReplayMissingUIError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor aboutMissingUI: self
]
