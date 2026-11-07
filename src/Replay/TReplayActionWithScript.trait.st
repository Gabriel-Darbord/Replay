"
I add script storage, evaluation, and debugging support to actions that execute Smalltalk source.

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

{ #category : 'testing' }
TReplayActionWithScript >> hasScript [

	^ true
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
