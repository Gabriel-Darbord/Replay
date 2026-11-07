"
I edit a ReplayPresenterScript, whose script is evaluated with the managed Spec presenter as self. To debug it, I preview the UI up to the action in a window, so that the presenter exists.
"
Class {
	#name : 'ReplayPresenterScriptEditor',
	#superclass : 'ReplayScriptEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'debugging' }
ReplayPresenterScriptEditor class >> debugScriptOf: anAction in: aReplayEditor [
	"Build a preview of the managed UI up to anAction, then debug its script on the preview presenter.
	The preview opens in a window so the UI loads correctly."

	| builder ui |
	builder := ReplayUIBuilder on: aReplayEditor scenario.
	builder whenDone: [ anAction debugScriptOn: builder ].
	ui := [ builder uiForAction: anAction ]
		      on: ReplayError
		      do: [ :error | ^ self inform: error messageText ].
	(SpMorphPresenter new morph: ui) asWindow
		title: 'Debugging Presenter Script';
		open
]

{ #category : 'accessing' }
ReplayPresenterScriptEditor >> scriptLabel [

	^ 'Script evaluated with the managed Spec presenter as self:'
]
