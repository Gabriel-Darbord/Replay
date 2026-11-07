"
I close the active managed UI and clear it from the runner. Owned UI is closed, attached UI is only detached from Replay.
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
	"The runner closes the manager it replaces."

	runner manager: nil
]
