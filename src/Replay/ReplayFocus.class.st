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

	ui takeKeyboardFocus
]

{ #category : 'running' }
ReplayFocus >> runOn: runner resolvedUI: resolvedUI [

	| target |
	target := resolvedUI focusTarget.
	target ifNil: [ ^ super runOn: runner resolvedUI: resolvedUI ].
	target takeKeyboardFocus
]

{ #category : 'editing' }
ReplayFocus >> settingsPresenterOn: editor [
	"There's only the UI target to edit. Can target the World."

	^ self targetPresenterOn: editor
]
