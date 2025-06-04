"
Focus on a UI element. (WIP)
"
Class {
	#name : 'ReplayFocus',
	#superclass : 'ReplayUIHandler',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayFocus class >> displayName [

	^ 'Focus'
]

{ #category : 'running' }
ReplayFocus >> runOn: runner onUI: ui [
	"TODO really set focus, as if clicking but without the click event."

	ui keyboardFocusChange: true. "takeKeyboardFocus but without affecting the active hand"

	"Store the focused element on the runner so following actions may use it"
	runner focus: ui
]

{ #category : 'editing' }
ReplayFocus >> settingsPresenterOn: editor [
	"Nothing yet..."

	^ self noEditionPresenterOn: editor
]
