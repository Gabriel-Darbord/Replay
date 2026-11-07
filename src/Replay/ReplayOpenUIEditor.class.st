"
I edit an action that opens its own UI (a ReplayOpenUI): its settings end with its window placement, and my UI view shows a preview of the UI it opens, where clicking a widget adds an action targeting it (see ReplayUIEditSession).
"
Class {
	#name : 'ReplayOpenUIEditor',
	#superclass : 'ReplayUIActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayOpenUIEditor >> addFieldsTo: aLayout [

	aLayout add: (self placementField: [ action placement ] set: [ :placement | action placement: placement ]) expand: false
]

{ #category : 'building' }
ReplayOpenUIEditor >> newUIEditionPresenter [
	"A preview of the UI my action opens, built without side effects, where clicks add actions"

	| manager |
	manager := action previewManagerOn: (ReplayUIBuilder on: self scenario).
	(ReplayUIEditSession on: manager editor: self scenarioEditor) wrapForEdition.
	^ self newMorph
		  morph: manager ui;
		  yourself
]

{ #category : 'accessing' }
ReplayOpenUIEditor >> uiViewName [

	^ 'Add UI interaction'
]
