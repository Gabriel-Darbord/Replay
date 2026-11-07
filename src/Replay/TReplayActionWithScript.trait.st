"
I add script storage, evaluation, editing UI, and debugging support to actions that execute Smalltalk source.

My users choose the receiver of the script with `scriptReceiverOn:` (the runner by default). The same receiver is used to run and to debug the script. Compilation errors, runtime errors, and unexpected results are all signaled as ReplayScriptError, keeping the original error as cause.
"
Trait {
	#name : 'TReplayActionWithScript',
	#instVars : [
		'script'
	],
	#traits : 'TReplayActionWithDebugging',
	#classTraits : 'TReplayActionWithDebugging classTrait',
	#category : 'Replay-Traits',
	#package : 'Replay',
	#tag : 'Traits'
}

{ #category : 'evaluating' }
TReplayActionWithScript >> compileScriptFor: receiver [
	"Answer my script compiled as a doit for the receiver."

	| compiler |
	compiler := Smalltalk compiler
		receiver: receiver;
		isScripting: true;
		permitFaulty: false;
		permitUndeclared: false;
		yourself.
	^ [
		compiler ast: (compiler parse: self script) asDoit.
		compiler compile ]
		on: Error
		do: [ :error | self signalScriptError: error ]
]

{ #category : 'debugging' }
TReplayActionWithScript >> debugScriptInEditor: editor [
	"Debug my script from the editor, with the receiver it would have when running the edited scenario."

	self debugScriptOn: (ReplayRunner on: editor model scenario)
]

{ #category : 'debugging' }
TReplayActionWithScript >> debugScriptOn: runner [
	"Open a debugger stopped at the start of my script, evaluated with the same receiver as when running."

	^ (self scriptDebugRequestOn: runner)
		  submit;
		  debugSession
]

{ #category : 'evaluating' }
TReplayActionWithScript >> evaluateScriptOn: runner [
	"Evaluate my script with the receiver chosen for the runner, and answer its result."

	| receiver method |
	receiver := self scriptReceiverOn: runner.
	method := self compileScriptFor: receiver.
	^ [ method valueWithReceiver: receiver arguments: #(  ) ]
		  on: Error
		  do: [ :error | self signalScriptError: error ]
]

{ #category : 'editing' }
TReplayActionWithScript >> helpPresenterOn: editor aboutScript: error [
	"Explain why the script failed and offer to debug it"

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
						    add: (error cause
								     ifNil: [ 'Printing the unexpected value:' ]
								     ifNotNil: [ 'Original error:' ])
						    expand: false;
						    add: (editor newText
								     beWrapWord;
								     editable: false;
								     text: (error cause
										      ifNil: [ error subject printString ]
										      ifNotNil: [ :cause | cause description ]));
						    yourself);
				   add: (self
						    debugButtonPresenterOn: editor
						    labeled: 'Debug the script'
						    action: [ self debugScriptInEditor: editor ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'printing' }
TReplayActionWithScript >> printOn: stream [

	super printOn: stream.
	self printDetail: script on: stream
]

{ #category : 'accessing' }
TReplayActionWithScript >> script [

	^ script ifNil: [ '' ]
]

{ #category : 'accessing' }
TReplayActionWithScript >> script: aString [

	script := aString
]

{ #category : 'editing' }
TReplayActionWithScript >> scriptPresenterOn: editor labeled: label [

	| codePresenter |
	(codePresenter := editor newCode)
		text: self script;
		whenTextChangedDo: [ :aString |
			self script: aString.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: codePresenter named: 'Action script'.
	editor registerReplayPresenter: codePresenter named: self scriptTargetName.

	^ SpBoxLayout newTopToBottom
		 add: label expand: false;
		 add: codePresenter;
		 yourself
]

{ #category : 'debugging' }
TReplayActionWithScript >> scriptDebugRequestOn: runner [
	"Answer a request to debug my script, evaluated with the same receiver as when running.
	Once submitted, the debugger steps to the start of the script."

	| receiver method process |
	receiver := self scriptReceiverOn: runner.
	method := self compileScriptFor: receiver.
	process := [ method valueWithReceiver: receiver arguments: #(  ) ] newProcess.
	^ (OupsDebugRequest newForContext: process suspendedContext)
		  process: process;
		  compiledMethod: method;
		  label: 'Debug script: ' , self class displayName;
		  yourself
]

{ #category : 'evaluating' }
TReplayActionWithScript >> scriptReceiverOn: runner [
	"Answer the object my script is evaluated with as self, when run or debugged."

	^ runner
]

{ #category : 'editing' }
TReplayActionWithScript >> scriptTargetName [

	self class displayName = 'Script' ifTrue: [ ^ 'Script source' ].
	^ self class displayName , ' script'
]

{ #category : 'error handling' }
TReplayActionWithScript >> signalScriptError: anError [
	"Wrap an error raised while compiling or running my script, keeping it as the cause.
	Replay errors are already meaningful and go through unchanged."

	(anError isKindOf: ReplayError) ifTrue: [ ^ anError pass ].
	^ ReplayScriptError new
		  action: self;
		  cause: anError;
		  messageText: 'The script failed: ' , anError description;
		  signal
]

{ #category : 'error handling' }
TReplayActionWithScript >> unexpectedScriptResult: anObject expected: aString [

	^ ReplayScriptError new
		  action: self;
		  subject: anObject;
		  messageText: 'Expected the script to return ' , aString , ', but got an instance of '
			  , anObject className , '.';
		  signal
]
