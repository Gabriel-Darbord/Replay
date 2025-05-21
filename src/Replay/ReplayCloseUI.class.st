"
Closes the active window.
I am not a UI action, because I don't depend on UI.
"
Class {
	#name : 'ReplayCloseUI',
	#superclass : 'ReplayAction',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayCloseUI class >> displayName [

	^ 'Close UI'
]

{ #category : 'testing' }
ReplayCloseUI >> isUICloser [

	^ true
]

{ #category : 'running' }
ReplayCloseUI >> runOn: runner [

	runner manager ifNotNil: [ :manager | manager close ]
]
