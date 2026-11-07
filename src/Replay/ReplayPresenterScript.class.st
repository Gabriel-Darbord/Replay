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

{ #category : 'accessing' }
ReplayPresenterScript class >> displayName [

	^ 'Presenter Script'
]

{ #category : 'debugging' }
ReplayPresenterScript >> debugScriptInEditor: editor [
	"Build a preview of the managed UI up to me, then debug the script on its presenter.
	The preview opens in a window so the UI loads correctly."

	| builder ui |
	builder := ReplayUIBuilder on: editor scenario.
	builder whenDone: [ self debugScriptOn: builder ].
	ui := [ builder uiForAction: self inStep: editor currentStep ]
		      on: ReplayError
		      do: [ :error | ^ self inform: error messageText ].
	(SpMorphPresenter new morph: ui) asWindow
		title: 'Debugging Presenter Script';
		open
]

{ #category : 'running' }
ReplayPresenterScript >> previewOn: aReplayUIBuilder [
	"Act on the preview presenter like at run time."

	self runOn: aReplayUIBuilder
]

{ #category : 'editing' }
ReplayPresenterScript >> scriptLabel [

	^ 'Script evaluated with the managed Spec presenter as self:'
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
