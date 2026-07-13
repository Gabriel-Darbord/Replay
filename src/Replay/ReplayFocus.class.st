"
I move keyboard focus to a resolved UI target.
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

	ui takeKeyboardFocus
]

{ #category : 'running' }
ReplayFocus >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runFocus: self
]

{ #category : 'editing' }
ReplayFocus >> settingsPresenterOn: editor [
	"There's only the UI target to edit. Can target the World."

	^ self targetPresenterOn: editor
]
