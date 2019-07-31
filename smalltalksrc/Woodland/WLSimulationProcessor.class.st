"
I'm a processor simulator compatible with Cog's Bochs and GDB-ARM simulators.
My implementation is based on the Unicorn library for simulation and LLVM for disassembling.

My main responsibility is to provide access to machine code execution, memory/register access, and disassembling.

My subclasses implement several accessors for specific architecture registers.
"
Class {
	#name : #WLSimulationProcessor,
	#superclass : #Object,
	#instVars : [
		'simulator',
		'disassembler',
		'bitsInWord',
		'memoryRegions'
	],
	#category : #Woodland
}

{ #category : #'instance-creation' }
WLSimulationProcessor class >> arm [
	
	^ WLARMSimulationProcessor new
]

{ #category : #'instance-creation' }
WLSimulationProcessor class >> x86 [
	
	^ WLX86SimulationProcessor new
]

{ #category : #'instance-creation' }
WLSimulationProcessor class >> x8664 [
	
	^ WLX8664SimulationProcessor new
]

{ #category : #accessing }
WLSimulationProcessor >> bitsInWord [

	^ bitsInWord
]

{ #category : #testing }
WLSimulationProcessor >> convertIntegerToInternal: anInteger [ 
	"Default conversion for 32-bit processors.  64-bit processors override."
	^anInteger signedIntToLong
]

{ #category : #testing }
WLSimulationProcessor >> convertInternalToInteger: unsigned [
	"Default conversion for 32-bit processors.  64-bit processors override."
	^unsigned signedIntFromLong
]

{ #category : #disassembling }
WLSimulationProcessor >> disassemble: anInteger in: aCollection [ 

	| offset disassembled |
	offset := 1.
	disassembled := OrderedCollection new.
	[ disassembled size < anInteger and: [ offset < aCollection size ]] whileTrue: [
		| result |
		result := self disassembleInstructionAt: offset in: aCollection.
		disassembled add: result first.
		offset := offset + result second.
	].
	^ disassembled
	
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleInstructionAt: anInteger In: aCollection into: aBlockClosure [ 
	
	| result disassembled bytes |
	result := disassembler
		disassembleInstructionIn: (aCollection copyFrom: anInteger + 1 to: aCollection size)
		pc: anInteger.
	disassembled := result first.
	bytes := result second.
	(result first = 'lock')
		ifTrue: [ | lockNext |
			lockNext := disassembler disassembleInstructionIn: (aCollection allButFirst: bytes) pc: anInteger.
			disassembled := disassembled, ' ', lockNext first.
			bytes := bytes + lockNext second ].
	
	aBlockClosure
		value: disassembled
		value: bytes
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleInstructionAt: index in: aCollection [ 

	| result disassembled bytes |
	result := disassembler
		disassembleInstructionIn: (aCollection copyFrom: index to: ((index + 10) min: aCollection size))
		pc: self pc.
	disassembled := result first.
	bytes := result second.
	^ { disassembled . bytes }
]

{ #category : #memory }
WLSimulationProcessor >> doMemorySetFrom: address to: size with: bytes [ 
	
	simulator memoryAt: address -1 until: size setTo: bytes
]

{ #category : #testing }
WLSimulationProcessor >> formatConstantForInstruction: anInteger [ 

	^ anInteger printStringBase: 16
]

{ #category : #initialization }
WLSimulationProcessor >> initialize [
	super initialize.
	memoryRegions := OrderedCollection new.
]

{ #category : #memory }
WLSimulationProcessor >> mapHostMemory: aMemory readExecuteOnlyBelow: anInteger [ 

	| errorCode writeMemory |
	self assert: anInteger < aMemory size.
	self assert: (aMemory size / 4096) isInteger. 
	
	aMemory pinInMemory.
	memoryRegions add: aMemory.
	
	writeMemory := aMemory copyFrom: anInteger + 1 to: aMemory size.
	writeMemory pinInMemory.
	memoryRegions add: writeMemory.
	
	errorCode := simulator
		doMapHostMemory: aMemory
		ofSize: anInteger
		atAddress: 0
		withPermissions: UnicornConstants permissionRead + UnicornConstants permissionExecute.
	simulator verifyErrorCode: errorCode.
	errorCode := simulator
		doMapHostMemory: writeMemory
		ofSize: writeMemory size
		atAddress: anInteger
		withPermissions: UnicornConstants permissionAll.
	simulator verifyErrorCode: errorCode.
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: address put: anInteger [

	self doMemorySetFrom: address to: 1 with: (ByteArray with: anInteger).
]

{ #category : #memory }
WLSimulationProcessor >> memoryAtAllPut: anInteger [ 

	memoryRegions do: [ :e | e atAllPut: anInteger ]
]

{ #category : #testing }
WLSimulationProcessor >> opcodeSeparatorForTesting [

	^ String tab
]

{ #category : #accessing }
WLSimulationProcessor >> readRegisterId: aRegisterId [

	| buffer |
	buffer := self readRegisterId: aRegisterId size: 4.
	^ buffer unsignedLongAt: 1 bigEndian: false
]

{ #category : #accessing }
WLSimulationProcessor >> readRegisterId: aRegisterId size: aSize [

	| buffer |
	buffer := ByteArray new: aSize.
	simulator register: aRegisterId value readInto: buffer.
	^ buffer
]

{ #category : #accessing }
WLSimulationProcessor >> readRegisterNamed: aString [ 
	
	^ self perform: aString asSymbol
]

{ #category : #accessing }
WLSimulationProcessor >> registerNames [

	self subclassResponsibility
]

{ #category : #accessing }
WLSimulationProcessor >> registers [

	^ self registerNames collect: [ :each | 
		WLSimulationRegister on: self named: each ]
]

{ #category : #initialization }
WLSimulationProcessor >> reset [
	
	self registers do: [ :each | each value: 0 ].
]

{ #category : #simulating }
WLSimulationProcessor >> singleStep [

	| errorCode |
	errorCode := simulator startAt: self pc until: self pc + 100 timeout: 0 count: 1.
	simulator verifyErrorCode: errorCode
]

{ #category : #simulating }
WLSimulationProcessor >> singleStepIn: aMemory [

	| errorCode memory |
	self assert: aMemory size <= 4096.
	memory := ByteArray new: 4096.
	memory replaceFrom: 1 to: aMemory size with: aMemory.
	memory pinInMemory.
	
	errorCode := simulator mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.
	simulator verifyErrorCode: errorCode.

	errorCode := simulator startAt: self pc until: memory size timeout: 0 count: 1.
	simulator verifyErrorCode: errorCode.
	
	errorCode := simulator unmapMemoryAtAddress: 0 ofSize: memory size.
	simulator verifyErrorCode: errorCode.
]

{ #category : #simulating }
WLSimulationProcessor >> singleStepIn: aMemory readExecuteOnlyBelow: anInteger [

	| errorCode writeMemory |
	self assert: anInteger < aMemory size.
	self assert: (aMemory size / 4096) isInteger. 
	
	aMemory pinInMemory.
	writeMemory := aMemory copyFrom: anInteger + 1 to: aMemory size.
	writeMemory pinInMemory.
	
	errorCode := simulator
		doMapHostMemory: aMemory
		ofSize: anInteger
		atAddress: 0
		withPermissions: UnicornConstants permissionRead + UnicornConstants permissionExecute.
	simulator verifyErrorCode: errorCode.
	errorCode := simulator
		doMapHostMemory: writeMemory
		ofSize: writeMemory size
		atAddress: anInteger
		withPermissions: UnicornConstants permissionAll.
	simulator verifyErrorCode: errorCode.

	errorCode := simulator startAt: self pc until: aMemory size timeout: 0 count: 1.
	simulator verifyErrorCode: errorCode.
	
	errorCode := simulator unmapMemoryAtAddress: 0 ofSize: aMemory size.
	simulator verifyErrorCode: errorCode.
	
	aMemory replaceFrom: anInteger + 1 to: aMemory size with: writeMemory.
]

{ #category : #testing }
WLSimulationProcessor >> stripDisassembledInstructionString: aString [ 
	
	^ aString
]

{ #category : #accessing }
WLSimulationProcessor >> write: aByteArray registerId: aRegisterId [

	simulator register: aRegisterId value write: aByteArray.
	^ aByteArray
]

{ #category : #writing }
WLSimulationProcessor >> writeInteger: anInteger registerId: anUcX86Registers [ 

	| buffer |
	buffer := ByteArray new: 4.
	buffer unsignedLongAt: 1 put: anInteger bigEndian: false.
	self write: buffer registerId: anUcX86Registers.
	^ anInteger
]

{ #category : #accessing }
WLSimulationProcessor >> writeRegisterNamed: aString value: anInteger [ 

	^ self perform: aString asMutator withArguments: { anInteger }
]
