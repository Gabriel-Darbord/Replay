"
I am responsible for interacting with UI.
"
Class {
	#name : 'ReplayUIHandler',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'path'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'instance creation' }
ReplayUIHandler class >> fromUIPath: collection [

	^ self new path: collection
]

{ #category : 'testing' }
ReplayUIHandler class >> isAbstract [

	^ self == ReplayUIHandler
]

{ #category : 'testing' }
ReplayUIHandler class >> shouldBeMenuItem [

	^ true
]

{ #category : 'enumerating' }
ReplayUIHandler >> findElementIn: aMorph at: index deferCount: count thenDo: aBlock [
	"Asynchronously wait for the Morphs to be built to find the target element"

	(count > 0 and: [ count \\ 5 = 0 ]) ifTrue: [ "Prevent infinite loops.
		If you see this warning, the UI is taking suspiciously long to build.
		When you're reading this, it should be loaded, or the element does not exist."
		Warning signal:
			'Could not find target within 5 UI cycles. Try again?' ].

	(aMorph class == ClyQueryViewMorph and: [ aMorph areItemsLoaded not ])
		ifTrue: [ "This morph works asynchronously, so we have to dance with it"
			^ self currentWorld defer: [
				  [ "Fork to avoid blocking the UI process"
				  self
					  findElementIn: aMorph
					  at: index
					  deferCount: count + 1
					  thenDo: aBlock ] forkAt: Processor userSchedulingPriority - 1 ] ].

	aMorph submorphs
		ifNotEmpty: [ :submorphs |
			| element |
			element := submorphs at: (path at: index).
			index = path size
				ifTrue: [ "self currentWorld defer: [" "Found it, now wait for it to get drawn"
					aBlock value: element "]" ]
				ifFalse: [ "Element at index is present, continue down the path"
					self
						findElementIn: element
						at: index + 1
						deferCount: 0
						thenDo: aBlock ] ]
		ifEmpty: [ "Retry the same element on the next UI cycle"
			self currentWorld defer: [
				[ "Fork to avoid blocking the UI process"
				self
					findElementIn: aMorph
					at: index
					deferCount: count + 1
					thenDo: aBlock ] forkAt: Processor userSchedulingPriority - 1 ] ]
]

{ #category : 'enumerating' }
ReplayUIHandler >> findElementIn: aMorph thenDo: aBlock [
	"Asynchronously wait for the Morph to be built and then find the target element"

	path ifEmpty: [ ^ aBlock value: aMorph ].
	[
	self
		findElementIn: aMorph
		at: 1
		deferCount: 0
		thenDo: aBlock ] forkAt: Processor userSchedulingPriority - 1
]

{ #category : 'editing' }
ReplayUIHandler >> helpPresenterOn: editor aboutMissingUI: error [

	| buttons |
	buttons := SpGridLayout build: [ :grid |
		           ReplayAction actionsThatOpenUI do: [ :action |
			           grid add: (editor newButton
					            icon: (self iconNamed: #add);
					            label: action displayName;
					            action: [ editor addAction: action new before: self ]) ] ].

	^ editor newPresenter
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

{ #category : 'testing' }
ReplayUIHandler >> isUIHandler [

	^ true
]

{ #category : 'accessing' }
ReplayUIHandler >> path [

	^ path
]

{ #category : 'accessing' }
ReplayUIHandler >> path: aCollection [
	"Path through the owner chain, each element is a child index"

	path := aCollection
]

{ #category : 'editing' }
ReplayUIHandler >> pathStatePresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add:
					   (self iconNamed:
							    (path ifNil: [ #error ] ifNotNil: [ #smallOk ]))
				   expand: false;
				   add: (path
						    ifNil: [
							    'Missing target. Use the UI edition view to select one.' ]
						    ifNotNil: [ 'Target set.' ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner [
	"Has control of runner continuation"

	path ifNil: [ ^ self runWithoutPathOn: runner ].

	self findElementIn: runner manager managedUI thenDo: [ :ui |
		self runOn: runner onUI: ui.

		"Await UI process before continuing"
		self currentWorld defer: [ runner nextAction ] ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner onUI: ui [

	self subclassResponsibility
]

{ #category : 'running' }
ReplayUIHandler >> runWithoutPathOn: runner [
	"When path is nil, the default behavior is to skip the action.
	Has control of runner continuation."

	runner nextAction
]

{ #category : 'editing' }
ReplayUIHandler >> uiEditionPresenterOn: editor [
	"Presenter that highlights the current target and allows changing it"

	| builder |
	builder := ReplayUIBuilder on: editor model scenario.

	builder whenDone: [
		| manager highlight |
		manager := builder manager editor: editor.

		path ifNotNil: [ "Highlight the current target"
			self findElementIn: manager managedUI thenDo: [ :element |
				highlight := ReplayAnnotation annotateMorph: element.
				manager overlay addMorphBack: highlight ] ].

		manager clickBlock: [ :event :wrapper | "Update target highlight"
			highlight ifNotNil: [ highlight delete ].
			self path: wrapper path.
			highlight := ReplayAnnotation annotateMorph: wrapper.
			manager overlay addMorphBack: highlight ].

		manager wrapForEdition ].

	^ editor newMorph morph:
		  (builder uiForAction: self inStep: editor model currentStep)
]
