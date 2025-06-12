Class {
	#name : 'ReplayScriptError',
	#superclass : 'ReplayError',
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'editing' }
ReplayScriptError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor aboutScript: self
]
