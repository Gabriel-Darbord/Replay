"
I am a test morph that can pretend to still be loading my submorphs, like a Calypso query view, to test that Replay paths wait for me.
"
Class {
	#name : 'ReplayLoadingMorph',
	#superclass : 'Morph',
	#instVars : [
		'loading'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'accessing' }
ReplayLoadingMorph >> loading: aBoolean [

	loading := aBoolean
]

{ #category : 'testing' }
ReplayLoadingMorph >> replayIsStillLoading [

	^ loading = true
]
