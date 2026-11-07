"
I am the abstract editor of the actions that send mouse events (ReplayPointerAction): I add the fields they share, the mouse buttons ('Action left button', 'Action right button', 'Action middle button') and the keyboard modifiers ('Action shift', 'Action control', 'Action alt option', 'Action command').
"
Class {
	#name : 'ReplayPointerActionEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'testing' }
ReplayPointerActionEditor class >> isAbstract [

	^ self == ReplayPointerActionEditor
]

{ #category : 'fields' }
ReplayPointerActionEditor >> buttonsField [
	"One check box per mouse button"

	| box |
	box := SpBoxLayout newLeftToRight spacing: 8.
	action class buttonChoices do: [ :association |
		ReplayKeyModifiersPresenter
			add: (self
					 checkBoxField: association value asLowercase , ' button'
					 label: association value
					 get: [ action hasButton: association key ]
					 set: [ :state | action setButton: association key to: state ])
			fittedTo: box ].
	^ self labeled: 'Mouse buttons:' field: box
]

{ #category : 'fields' }
ReplayPointerActionEditor >> modifiersField [

	^ self
		  modifiersField: 'Keyboard modifiers:'
		  get: [ action modifiers ]
		  set: [ :anInteger | action modifiers: anInteger ]
]
