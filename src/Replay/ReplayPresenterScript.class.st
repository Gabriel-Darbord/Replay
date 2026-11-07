"
I execute Smalltalk script with the managed Spec presenter as the receiver.

I act on the managed UI, so I also run when the editor rebuilds a UI preview, against the preview presenter.
"
Class {
	#name : 'ReplayPresenterScript',
	#superclass : 'ReplayScript',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayPresenterScript class >> editorClass [

	^ ReplayPresenterScriptEditor
]

{ #category : 'accessing' }
ReplayPresenterScript class >> displayName [

	^ 'Presenter Script'
]

{ #category : 'running' }
ReplayPresenterScript >> previewOn: aReplayUIBuilder [
	"Act on the preview presenter like at run time."

	self runOn: aReplayUIBuilder
]

{ #category : 'evaluating' }
ReplayPresenterScript >> scriptReceiverOn: runner [

	| receiver |
	receiver := runner manager ifNotNil: [ :manager |
		manager backend semanticScriptReceiver ].
	^ receiver ifNil: [
		ReplayMissingUIError new
			messageText: 'No semantic UI script receiver is available for presenter script.';
			subject: runner;
			signal ]
]
