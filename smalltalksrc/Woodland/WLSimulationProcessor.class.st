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
		'memoryRegions',
		'executingPC'
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

{ #category : #initialization }
WLSimulationProcessor >> configureSimulator [

	simulator
		registerInvalidMemoryAccessHook: UcHookType invalidMemoryAccess
		doing: [ :type :address :size :value | 
			self invalidMemoryAccessOfType: type at: address ofSize: size withValue: value ].
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
		disassembled add: result.
		offset := offset + result size.
	].
	^ disassembled
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleCount: anInteger [

	^ self disassembleCount: anInteger atAddress: self pc
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleCount: anInteger atAddress: address [ 

	| codeRegion instructions |
	codeRegion := simulator memoryAt: address readNext: anInteger * 10.
	instructions := self disassemble: anInteger in: codeRegion.
	"the returned instructions are disasembled in adresses relative to the code region.
	We map them as absolutes in *address*"
	instructions do: [ :e | e mapToAddress: address - 1 ].
	^ instructions
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleInstructionAt: anInteger In: aCollection into: aBlockClosure [ 
	
	| result disassembled bytes |
	result := disassembler
		disassembleInstructionIn: (aCollection copyFrom: anInteger + 1 to: aCollection size)
		pc: anInteger.
	disassembled := result assembly.
	bytes := result size.
	(disassembled = 'lock')
		ifTrue: [ | lockNext |
			lockNext := disassembler disassembleInstructionIn: (aCollection allButFirst: bytes) pc: anInteger.
			disassembled := disassembled, ' ', lockNext assembly.
			bytes := bytes + lockNext size ].
	
	aBlockClosure
		value: disassembled
		value: bytes
]

{ #category : #disassembling }
WLSimulationProcessor >> disassembleInstructionAt: index in: aCollection [ 

	| result |
	result := disassembler
		disassembleInstructionIn: (aCollection copyFrom: index to: ((index + 10) min: aCollection size))
		pc: self pc.

	^ WLInstruction new
		address: index;
		size: result size;
		code: result assembly;
		yourself
]

{ #category : #testing }
WLSimulationProcessor >> formatConstantForInstruction: anInteger [ 

	^ anInteger printStringBase: 16
]

{ #category : #initialization }
WLSimulationProcessor >> initialize [
	super initialize.
	self setupSimulator.
	memoryRegions := OrderedCollection new.
]

{ #category : #memory }
WLSimulationProcessor >> installMemoryRegion: aMemoryRegion [

	memoryRegions add: aMemoryRegion.
	aMemoryRegion installInSimulator: simulator
]

{ #category : #initialization }
WLSimulationProcessor >> instantiateSimulator [
	
	self subclassResponsibility
]

{ #category : #'error-handling' }
WLSimulationProcessor >> invalidMemoryAccessOfType: anUcMemoryAccessType at: anInteger ofSize: anInteger3 withValue: anInteger4 [ 

	| opcode |
	opcode := simulator memoryAt: executingPC readNext: 1.
	opcode first = 232 ifTrue: [ | relativeJump |
		relativeJump := (simulator memoryAt: executingPC + 1 readNext: self wordSize) longAt: 1 bigEndian: false.
		(ProcessorSimulationTrap
				pc: executingPC
				nextpc: executingPC + 5
				address: (executingPC + 5 + relativeJump) signedIntToLong
				type: #call)
			signal
	].
	self halt.
]

{ #category : #memory }
WLSimulationProcessor >> mapHostMemory: aMemory atAddress: anAddress withPermissions: permissions [

	self installMemoryRegion: (WLMemoryRegion new
		address: anAddress;
		bytes: aMemory;
		permissions: permissions;
		yourself)
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

	self memoryFrom: address writeNBytes: 1 fromByteArray: (ByteArray with: anInteger)
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: address putAll: aByteArray [

	self memoryFrom: address writeNBytes: 1 fromByteArray: aByteArray
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: address readNext: size [

	^ simulator memoryAt: address readNext: size
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: address writeBytes: aByteArray [

	simulator memoryAt: address until: aByteArray size setTo: aByteArray
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: anAddress writeInteger: anInteger signed: aBoolean [

	| buffer |
	buffer := ByteArray new: self wordSize.
	buffer integerAt: 1 put: anInteger size: self wordSize signed: aBoolean.
	simulator memoryAt: anAddress write: buffer
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: anAddress writeSignedInt: aSignedInteger [

	self memoryAt: anAddress writeInteger: aSignedInteger signed: true
]

{ #category : #memory }
WLSimulationProcessor >> memoryAt: anAddress writeUnsignedInt: anUnsignedInteger [

	self memoryAt: anAddress writeInteger: anUnsignedInteger signed: false
]

{ #category : #memory }
WLSimulationProcessor >> memoryAtAllPut: anInteger [ 

	memoryRegions do: [ :e | e atAllPut: anInteger ]
]

{ #category : #memory }
WLSimulationProcessor >> memoryFrom: address writeNBytes: size fromByteArray: aByteArray [

	simulator memoryAt: address until: size setTo: aByteArray
]

{ #category : #testing }
WLSimulationProcessor >> opcodeSeparatorForTesting [

	^ String tab
]

{ #category : #accessing }
WLSimulationProcessor >> pc [

	self subclassResponsibility
]

{ #category : #accessing }
WLSimulationProcessor >> pc: anInteger [ 

	self subclassResponsibility
]

{ #category : #accessing }
WLSimulationProcessor >> push: anInteger [ 

	| buffer |
	buffer := ByteArray new: 4.
	buffer longAt: 1 put: anInteger bigEndian: false.
	self stackPointer: self stackPointer - buffer size.
	self memoryFrom: self stackPointer writeNBytes: buffer size fromByteArray: buffer.
]

{ #category : #memory }
WLSimulationProcessor >> readIntegerAt: anAddress signed: aBoolean [
	
	| buffer |
	buffer := simulator memoryAt: anAddress readNext: self wordSize.
	^ buffer integerAt: 1 size: self wordSize signed: aBoolean
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

{ #category : #memory }
WLSimulationProcessor >> readSignedIntAt: anAddress [
	
	^ self readIntegerAt: anAddress signed: true
]

{ #category : #memory }
WLSimulationProcessor >> readUnsignedIntAt: anAddress [
	
	^ self readIntegerAt: anAddress signed: false
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

{ #category : #initialization }
WLSimulationProcessor >> setupSimulator [

	simulator := self instantiateSimulator.
	self configureSimulator.
]

{ #category : #accessing }
WLSimulationProcessor >> simulator [
	^ simulator
]

{ #category : #simulating }
WLSimulationProcessor >> singleStep [

	self step
]

{ #category : #simulating }
WLSimulationProcessor >> singleStepIn: aMemory [

	| errorCode memory |
	self assert: aMemory size <= 4096.
	memory := ByteArray new: 4096.
	memory replaceFrom: 1 to: aMemory size with: aMemory.
	memory pinInMemory.
	
	simulator mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.

	executingPC := self pc.
	simulator startAt: self pc until: memory size timeout: 0 count: 1.
	
	simulator unmapMemoryAtAddress: 0 ofSize: memory size
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

{ #category : #accessing }
WLSimulationProcessor >> stackPointer [

	^ self subclassResponsibility
]

{ #category : #accessing }
WLSimulationProcessor >> stackPointer: anInteger [ 

	^ self subclassResponsibility
]

{ #category : #simulating }
WLSimulationProcessor >> step [

	| currentMemoryRegion |
	executingPC := self pc.
	currentMemoryRegion := (memoryRegions detect: [ :e | e containsAddress: executingPC ]).
	simulator startAt: executingPC until: currentMemoryRegion endAddress timeout: 0 count: 1.
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
