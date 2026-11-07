"
I move the keyboard focus to a resolved UI target. I give it to the native element when it takes keyboard focus, as Spec presenters do, otherwise to the Morphic widget.
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

{ #category : 'testing' }
ReplayFocus >> canRunNativelyOn: anObject [

	^ anObject respondsTo: #takeKeyboardFocus
]

{ #category : 'running' }
ReplayFocus >> runOnMorph: aMorph [

	aMorph takeKeyboardFocus
]

{ #category : 'running' }
ReplayFocus >> runOnNative: anObject [

	anObject takeKeyboardFocus
]

{ #category : 'editing' }
ReplayFocus >> settingsPresenterOn: editor [
	"There's only the UI target to edit. Can target the World."

	^ self targetPresenterOn: editor
]
