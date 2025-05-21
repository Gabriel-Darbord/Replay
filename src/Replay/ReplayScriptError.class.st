Class {
	#name : 'ReplayScriptError',
	#superclass : 'ReplayError',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'editing' }
ReplayScriptError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor aboutScript: self
]
