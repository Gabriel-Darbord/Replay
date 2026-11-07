"
I am the abstract base for actions that attach the runner to UI that already exists, instead of opening a new one.

I do not take ownership of the UI: when the runner stops or another UI replaces mine, the manager only removes what Replay added to the UI. Subclasses answer the manager in `uiManagerOn:`.

Editor previews never attach to live UI, so the actions following me cannot be previewed: the editor explains this instead.
"
Class {
	#name : 'ReplayAttach',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayAttach class >> isAbstract [

	^ self == ReplayAttach
]

{ #category : 'testing' }
ReplayAttach >> isUIOpener [

	^ true
]

{ #category : 'managing UI' }
ReplayAttach >> previewManagerOn: aReplayUIBuilder [
	"Previews must not change live UI, and attaching adds an overlay to it."

	^ ReplayMissingUIError new
		  messageText: self class displayName
			  , ' uses UI that already exists, it cannot be previewed while editing. Use an action that opens its own UI to edit targets visually.';
		  subject: self;
		  signal
]

{ #category : 'running' }
ReplayAttach >> runOn: runner [

	runner manager: (self uiManagerOn: runner)
]

{ #category : 'managing UI' }
ReplayAttach >> uiManagerOn: runner [
	"Answer a manager attached to the existing UI."

	self subclassResponsibility
]
