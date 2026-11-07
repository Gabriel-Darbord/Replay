"
I edit a ReplayOpenPresenter: the script that creates its Spec presenter, and its window placement.
"
Class {
	#name : 'ReplayOpenPresenterEditor',
	#superclass : 'ReplayOpenUIEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayOpenPresenterEditor >> addFieldsTo: aLayout [

	aLayout add: (self
			 codeField: 'script'
			 label: 'Write the script that creates and returns the Spec presenter:'
			 get: [ action script ]
			 set: [ :aString | action script: aString ]).
	super addFieldsTo: aLayout
]

{ #category : 'accessing' }
ReplayOpenPresenterEditor >> settingsViewName [

	^ 'Presenter settings'
]
