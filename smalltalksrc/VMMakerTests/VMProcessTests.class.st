Class {
	#name : #VMProcessTests,
	#superclass : #VMInterpreterTests,
	#category : #'VMMakerTests-ObjectLayoutTests'
}

{ #category : #running }
VMProcessTests >> newSpaceSize [ 
 ^2 * 1024
]

{ #category : #running }
VMProcessTests >> setUp [

	super setUp.
	self setUpScheduler.
	interpreter preemptionYields: true
]

{ #category : #tests }
VMProcessTests >> testHigherPriorityProcessIsResumed [

	"PrimitiveResume should fail if we give higher priority than highest priority"
	|  currentActiveProcess newProcess |
	self setUpScheduler.
	interpreter preemptionYields: true.
	
	newProcess := self createNewProcessWithPriority: 2 asActiveProcess: false.
	stackBuilder addNewFrame
	method: (memory fetchPointer: MethodIndex ofObject: (memory fetchPointer: SuspendedContextIndex ofObject: memory memoryActiveProcess));
	receiver: newProcess.
	stackBuilder buildStack.
	interpreter primitiveResume.
	currentActiveProcess := memory memoryActiveProcess.
	
	self deny: interpreter failed.
	self assert: newProcess equals: currentActiveProcess. 
]

{ #category : #tests }
VMProcessTests >> testLonelyProcessShouldBeActiveProcess [

	"The ready list is empty. When the vm yield the activeProcess, it is put back into the list and since this is the only process in the list it is chossed again to be the activeProcess."
	| oldActiveProcess currentActiveProcess |
	self setUpScheduler.
	
	oldActiveProcess := memory memoryActiveProcess.
	stackBuilder addNewFrame; buildStack.
	interpreter primitiveYield.
	currentActiveProcess := memory memoryActiveProcess.
	
	self deny: interpreter failed.
	self assert: oldActiveProcess equals: currentActiveProcess. 
]
