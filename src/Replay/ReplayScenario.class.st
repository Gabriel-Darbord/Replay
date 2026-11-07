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

	^ 'ReplayScenario{#title:''Example Scenario'',#steps:OrderedCollection[ReplayStep{#actions:OrderedCollection[ReplayBrowseClass{#target:#ReplayScenario},ReplayAnnotate{#target:ReplayUIReference{#kind:#morphicPath,#value:[3,6,1,3,7,1,3]},#text:''Where the magic happens.''}],#navigation:ReplayNavigate{#skip:false,#text:''Thus concludes this example.''}}]}'
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
