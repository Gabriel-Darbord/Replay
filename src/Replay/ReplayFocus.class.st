"
Focus on a UI element.
"
Class {
	#name : 'ReplayFocus',
	#superclass : 'ReplayUIHandler',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayFocus class >> displayName [

	^ 'Focus'
]

{ #category : 'running' }
ReplayFocus >> runOn: runner onUI: ui [
	"TODO really set focus, as if clicking but without the click event.
	Also maybe remember focused element on the runner?"

	ui keyboardFocusChange: true
]

{ #category : 'editing' }
ReplayFocus >> settingsPresenterOn: editor [

	^ SpPresenter new
		  layout: (SpBoxLayout newTopToBottom spacing: 10);
		  yourself
]
