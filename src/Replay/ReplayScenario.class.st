"
I am a named sequence of ReplayStep objects that can be edited, saved as STON, and run.

My title and description have defaults that are answered but not stored, so they are not serialized.
"
Class {
	#name : 'ReplayScenario',
	#superclass : 'Object',
	#instVars : [
		'title',
		'steps',
		'description'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'examples' }
ReplayScenario class >> example [
	"Scenarios are conveniently stored as STON strings"

	<example>
	(STON fromString: self exampleSton) run
]

{ #category : 'examples' }
ReplayScenario class >> exampleSton [

	^ 'ReplayScenario{#title:''Example Scenario'',#steps:OrderedCollection[ReplayStep{#actions:OrderedCollection[ReplayBrowseClass{#target:#ReplayScenario},ReplayAnnotate{#path:[3,6,1,3,7,1,3],#text:''Where the magic happens.''}],#navigation:ReplayNavigate{#skip:false,#text:''Thus concludes this example.''}}]}'
]

{ #category : 'adding' }
ReplayScenario >> addStep: step [

	^ self steps add: step
]

{ #category : 'accessing' }
ReplayScenario >> description [

	^ description ifNil: [ '' ]
]

{ #category : 'accessing' }
ReplayScenario >> description: aString [

	description := aString
]

{ #category : 'editing' }
ReplayScenario >> edit [

	^ ReplayEditor openOn: self
]

{ #category : 'editing' }
ReplayScenario >> editionPresenterOn: editor [

	| titlePresenter descriptionPresenter |
	(titlePresenter := editor newText)
		text: self title;
		whenTextChangedDo: [ :aString | self title: aString ].
	editor registerReplayPresenter: titlePresenter named: 'Scenario title'.

	(descriptionPresenter := editor newText)
		text: self description;
		whenTextChangedDo: [ :aString | self description: aString ].
	editor registerReplayPresenter: descriptionPresenter named: 'Scenario description'.

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   add: 'Title:' expand: false;
				   add: titlePresenter expand: false;
				   add: 'Description:' expand: false;
				   add: descriptionPresenter;
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayScenario >> run [

	^ (ReplayRunner on: self) run
]

{ #category : 'accessing' }
ReplayScenario >> steps [

	^ steps ifNil: [ steps := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayScenario >> steps: aCollection [

	steps := aCollection
]

{ #category : 'accessing' }
ReplayScenario >> title [

	^ title ifNil: [ 'Unnamed Scenario' ]
]

{ #category : 'accessing' }
ReplayScenario >> title: aString [

	title := aString
]
