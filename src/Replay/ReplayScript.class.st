"
Executes the configured script.
"
Class {
	#name : 'ReplayScript',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayScript class >> displayName [

	^ 'Script'
]

{ #category : 'editing' }
ReplayScript >> editionPresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (self
						    scriptPresenterOn: editor
						    labeled: 'Write the script that will be executed:');
				   add: (self
						    debugButtonPresenterOn: editor
						    labeled: 'Debug the script'
						    action: [ self debugScript ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'printing' }
ReplayScript >> printOn: stream [

	super printOn: stream.
	script isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (script printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayScript >> runOn: runner [

	| compiler method |
	compiler := Smalltalk compiler isScripting: true.
	compiler ast: (compiler parse: self script) asDoit.
	method := compiler compile.
	method valueWithReceiver: runner arguments: #(  )
]
