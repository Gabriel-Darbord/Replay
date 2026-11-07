"
I edit an action that evaluates a script (TReplayActionWithScript) and opens no UI of its own: its source, registered as 'Action script', and a button that debugs it with the receiver it has when the scenario runs. My subclasses tell what this receiver is (`scriptLabel`).
"
Class {
	#name : 'ReplayScriptEditor',
	#superclass : 'ReplayActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayScriptEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 codeField: 'script'
				 label: self scriptLabel
				 get: [ action script ]
				 set: [ :aString | action script: aString ]);
		add: (self debugButton: 'Debug script' action: [ self debugScript ]) expand: false
]

{ #category : 'debugging' }
ReplayScriptEditor >> debugScript [

	self class debugScriptOf: action in: self scenarioEditor
]

{ #category : 'accessing' }
ReplayScriptEditor >> scriptLabel [

	^ 'Script evaluated with the Replay runner as self:'
]
