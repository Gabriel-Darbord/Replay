"
I edit an action that acts on a target UI element (a ReplayUIHandler). My settings are a template: the target section, then the fields of the action (`addFieldsTo:`). The actions that only have a target, such as Focus, use me directly.

The target section shows the target (a semantic name, a Morphic path, or the World), offers to target the World when the action allows it, and edits the semantic target name: the name is committed when accepted (Enter), so that typing does not wipe a recorded path.

My UI view previews the UI up to my action, highlights the current target, resolved through the manager of the preview like at run time, and lets the user pick another target by clicking a wrapper of the edit session (a ReplayUIEditSession). When the target cannot be found in the preview, a notice says so.
"
Class {
	#name : 'ReplayUIHandlerEditor',
	#superclass : 'ReplayUIActionEditor',
	#instVars : [
		'targetStateLayout',
		'targetNameInput',
		'targetNotice',
		'editSession'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'target' }
ReplayUIHandlerEditor >> acceptTargetName [
	"Target the presenter named by the target name input. An empty name clears a semantic target."

	action targetName: targetNameInput text.
	self targetChanged
]

{ #category : 'target' }
ReplayUIHandlerEditor >> editTargetIn: aReplayUIManager [
	"Highlight the current target in the preview of aReplayUIManager, and let a click on a wrapper choose another target"

	| session highlight |
	session := editSession := ReplayUIEditSession on: aReplayUIManager editor: self scenarioEditor.
	action hasSpecificTarget ifTrue: [
		action
			resolveTargetWith: aReplayUIManager
			thenDo: [ :resolved |
				resolved hasMorph
					ifTrue: [
						highlight ifNil: [
							highlight := self highlight: resolved boundsInSurface in: aReplayUIManager ] ]
					ifFalse: [ self showTargetNotice: 'The target has no widget to highlight in this preview.' ] ]
			onMissing: [ :error |
				highlight ifNil: [
					self showTargetNotice: 'Target not found in this preview: ' , action target description , '.' ] ] ].
	session clickBlock: [ :event :wrapper |
		highlight ifNotNil: [ highlight delete ].
		action target: wrapper reference.
		highlight := self highlight: wrapper bounds in: aReplayUIManager.
		self showTargetNotice: ''.
		self targetChanged ].
	session wrapForEdition.
	^ session
]

{ #category : 'accessing' }
ReplayUIHandlerEditor >> editSession [
	"The edit session of my UI view, once its preview is built, or nil"

	^ editSession
]

{ #category : 'help' }
ReplayUIHandlerEditor >> helpAboutMissingUI: error [
	"Offer to add an action that opens a UI before mine"

	| buttons |
	buttons := SpGridLayout build: [ :grid |
		           ReplayAction actionsThatOpenUI do: [ :actionClass |
			           grid add: (self newButton
					            icon: (self iconNamed: #add);
					            label: actionClass displayName;
					            action: [ self scenarioEditor addAction: actionClass new before: action ]) ] ].
	^ self newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #error) expand: false;
						    add: error messageText;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    spacing: -15;
						    add: 'Choose an action that opens a UI:' expand: false;
						    add: buttons;
						    yourself);
				   yourself);
		  yourself
]

{ #category : 'target' }
ReplayUIHandlerEditor >> highlight: aRectangle in: aReplayUIManager [

	| highlight |
	highlight := ReplayAnnotation annotate: aRectangle.
	aReplayUIManager overlay addMorphBack: highlight.
	^ highlight
]

{ #category : 'building' }
ReplayUIHandlerEditor >> newFieldsLayout [
	"The target section, then the fields of my action"

	| layout |
	layout := SpBoxLayout newTopToBottom
		          spacing: 10;
		          yourself.
	layout add: self newTargetSection expand: false.
	self addFieldsTo: layout.
	^ layout
]

{ #category : 'target' }
ReplayUIHandlerEditor >> newTargetSection [

	| controls |
	controls := SpBoxLayout newLeftToRight
		            vAlignStart;
		            spacing: 10;
		            yourself.
	action allowsWorldTarget ifTrue: [
		controls add: (self register: (self newButton
					  icon: (self iconNamed: #edit);
					  label: 'Target World';
					  action: [ self targetWorld ];
					  yourself)
				 as: 'target world')
			expand: false ].
	targetStateLayout := SpBoxLayout newLeftToRight.
	targetStateLayout add: self newTargetState.
	controls add: targetStateLayout.
	targetNameInput := self register: (self newTextInput
			                    text: action targetName;
			                    placeholder: 'Press Enter to target the presenter with this name';
			                    whenSubmitDo: [ :aString | self acceptTargetName ];
			                    yourself)
		                   as: 'target name'.
	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: controls expand: false;
		  add: (self labeled: 'Semantic target name:' field: targetNameInput) expand: false;
		  yourself
]

{ #category : 'target' }
ReplayUIHandlerEditor >> newTargetState [

	| icon text |
	icon := #smallOk.
	action target isNamed
		ifTrue: [ text := 'Semantic target: ' , action targetName ]
		ifFalse: [
			action target isMorphicPath
				ifTrue: [ text := 'Target set.' ]
				ifFalse: [
					action allowsWorldTarget
						ifTrue: [
							icon := #smallInfo.
							text := 'Targeting current World. Use UI edition view to change target.' ]
						ifFalse: [
							icon := #error.
							text := 'Missing target. Use UI edition view to select one.' ] ] ].
	^ self newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: (self iconNamed: icon) expand: false;
				   add: text expand: false;
				   yourself);
		  yourself
]

{ #category : 'building' }
ReplayUIHandlerEditor >> newUIEditionPresenter [
	"Preview the UI up to my action, then edit its target there"

	| builder ui |
	builder := ReplayUIBuilder on: self scenario.
	builder whenDone: [ self editTargetIn: builder manager ].
	ui := builder uiForAction: action.
	targetNotice := self register: self newLabel as: 'target notice'.
	^ self newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: targetNotice expand: false;
				   add: (self newMorph morph: ui);
				   yourself);
		  yourself
]

{ #category : 'target' }
ReplayUIHandlerEditor >> showTargetNotice: aString [

	targetNotice ifNotNil: [ targetNotice label: aString ]
]

{ #category : 'target' }
ReplayUIHandlerEditor >> targetChanged [
	"Show the new target of my action, then notify"

	targetStateLayout ifNotNil: [
		targetStateLayout removeAll.
		targetStateLayout add: self newTargetState ].
	targetNameInput ifNotNil: [ targetNameInput text: action targetName ].
	self actionChanged
]

{ #category : 'target' }
ReplayUIHandlerEditor >> targetNotice [
	"The label of my UI view that says when the target is not found in the preview"

	^ targetNotice
]

{ #category : 'target' }
ReplayUIHandlerEditor >> targetWorld [

	action targetWorld.
	self targetChanged
]
