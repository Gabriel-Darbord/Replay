"
I close the active managed UI and clear it from the runner.
"
Class {
	#name : 'ReplayCloseUI',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
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

	runner manager ifNotNil: [ :manager |
		manager close.
		runner manager: nil ]
]
