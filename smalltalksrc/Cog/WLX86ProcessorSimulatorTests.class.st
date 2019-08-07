Class {
	#name : #WLX86ProcessorSimulatorTests,
	#superclass : #TestCase,
	#instVars : [
		'processor'
	],
	#category : #'Cog-Processors-Tests'
}

{ #category : #tests }
WLX86ProcessorSimulatorTests >> callTrapPerformance: n [
	"Call a function that is out-of-range.  Ensure the call is trapped."
	"self new testCallTrap"
	| memory |
	 "The address is out of range of memory every which way (whether relative or absolute and whether big-endian or little."
	memory := ByteArray new: 1024.
	memory replaceFrom: 1 to: 5 with: { self processor callOpcode. 0. 16r80. 16r80. 0. } asByteArray.
	self processor
			eip: 0;
			esp: (memory size - 4). "Room for return address"
	1 to: n do:
		[:ign|
		[self processor singleStepIn: memory]
			on: ProcessorSimulationTrap
			do: [:ex|]].

	"QSystemProfiler spyOn: [BochsIA32AlienTests new callTrapPerformance: 1024*128]"
	"Time millisecondsToRun: [BochsIA32AlienTests new callTrapPerformance: 1024*128] 2463"
	"Time millisecondsToRun: [1 to: 1024*1024*64 do: [:ign| nil yourself]] 636"
	"Time millisecondsToRun: [1 to: 1024*1024*64 do: [:ign| nil perform: #ifNotNilDo: with: nil]] 3639"
	"Time millisecondsToRun: [1 to: 1024*1024*64 do: [:ign| nil perform: #ifNotNilDo:ifNil: with: nil with: nil]] 12401"
]

{ #category : #accessing }
WLX86ProcessorSimulatorTests >> integerRegisterGetters [
	^#(eax ecx edx ebx esp ebp esi edi eip)
]

{ #category : #accessing }
WLX86ProcessorSimulatorTests >> integerRegisterSetters [
	^#(eax: ecx: edx: ebx: esp: ebp: esi: edi: eip:)
]

{ #category : #accessing }
WLX86ProcessorSimulatorTests >> nfib [
	"long fib(long n) { return n <= 1 ? 1 : fib(n-1) + fib(n-2) + 1; }
	 as compiled by Microsoft Visual C++ V6 (12.00.8804) cl /O2 /Fc"
	
	^#("00000" 16r56							"push    esi"
		"00001" 16r8B 16r74 16r24 16r08		"mov     esi, DWORD PTR _n$[esp]"
		"00005" 16r83 16rFE 16r01				"cmp     esi, 1"
		"00008" 16r7F 16r07						"jg      SHORT $L528"
		"0000a" 16rB8 16r01 16r00 16r00 16r00	"mov     eax, 1"
		"0000f" 16r5E							"pop     esi"
		"00010" 16rC3							"ret     0"
"
$L528:"
		"00011" 16r8D 16r46 16rFE				"lea     eax, DWORD PTR [esi-2]"
		"00014" 16r57							"push    edi"
		"00015" 16r50							"push    eax"
		"00016" 16rE8 16rE5 16rFF 16rFF 16rFF   "call    _fib"
		"0001b" 16r4E							"dec     esi"
		"0001c" 16r8B 16rF8						"mov     edi, eax"
		"0001e" 16r56							"push    esi"
		"0001f" 16rE8 16rDC 16rFF 16rFF 16rFF   "call    _fib"
		"00024" 16r83 16rC4 16r08				"add     esp, 8"
		"00027" 16r8D 16r44 16r07 16r01		"lea     eax, DWORD PTR [edi+eax+1]"
		"0002b" 16r5F							"pop     edi"
		"0002c" 16r5E							"pop     esi"
		"0002d" 16rC3							"ret     0")
]

{ #category : #accessing }
WLX86ProcessorSimulatorTests >> processor [
	processor ifNil:
		[processor := WLSimulationProcessor x86].
	^processor
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> runCaseManaged [

	^ self runCase
]

{ #category : #execution }
WLX86ProcessorSimulatorTests >> runNFib: n [
	| readOnlyMemory writeMemory memorySize returnAddress |
	"Run nfib wth the argument until a failure happens"
	readOnlyMemory := ByteArray new: 4096 withAll: self processor nopOpcode.
	readOnlyMemory replaceFrom: 1 to: self nfib size with: self nfib asByteArray startingAt: 1.
	
	returnAddress := self nfib size.
	writeMemory := ByteArray new: 4096 withAll: self processor nopOpcode.
	writeMemory
		longAt: writeMemory size - 3 put: n bigEndian: false; "argument n"
		longAt: writeMemory size - 7 put: returnAddress bigEndian: false.
	
	self processor
		mapHostMemory: readOnlyMemory
		atAddress: 0
		withPermissions: UnicornConstants permissionExecute + UnicornConstants permissionRead.

	self processor
		mapHostMemory: writeMemory
		atAddress: readOnlyMemory size
		withPermissions: UnicornConstants permissionAll.
	
	memorySize := readOnlyMemory size + writeMemory size.
	self processor
		eip: 0;
		esp: memorySize - 8. "Room for return address and argument n"
	"run until something goes wrong."

	[ self processor pc < returnAddress ]
		whileTrue:[ self processor step ]
]

{ #category : #execution }
WLX86ProcessorSimulatorTests >> runNFib: n disassemble: disassemble printRegisters: printRegisters [

	^ self runNFib: n
]

{ #category : #execution }
WLX86ProcessorSimulatorTests >> singleStepNFib: n disassemble: disassemble printRegisters: printRegisters [
	"Run nfib wth the argument. Answer the result."
	"self new runNFib: 5 disassemble: true printRegisters: true"
	| memory finalSP |
	memory := ByteArray new: 4096 * 2 withAll: self processor nopOpcode.
	finalSP := memory size - 4. "Stop when we return to the nop following nfib"
	memory
		replaceFrom: 1 to: self nfib size with: self nfib asByteArray startingAt: 1;
		longAt: memory size - 3 put: n bigEndian: false; "argument n"
		longAt: memory size - 7 put: self nfib size bigEndian: false.  "return address"
	self processor
			eip: 0;
			esp: (memory size - 8). "Room for return address and argument n"
	printRegisters ifTrue:
		[self processor printRegistersOn: Transcript.
		 Transcript cr; flush].
	[disassemble ifTrue:
		[Transcript nextPutAll: (self processor disassembleNextInstructionIn: memory); cr; flush].
	 self processor singleStepIn: memory readExecuteOnlyBelow: memory size / 2.
	 printRegisters ifTrue:
		[self processor printRegistersOn: Transcript.
		 Transcript cr; flush].
	 self processor esp ~= finalSP] whileTrue.
	^self processor eax
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testCPUHasSSE2 [
	"Use the CPUID instruction to check if SSE2 is supported.  Cog
	 uses SSE2 instructions for machine-code floating-point primitives."
	
	| memory |
	memory := ByteArray new: 4096 "4K".
	self processor mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.
	self processor memoryFrom: 0 writeNBytes: 3 fromByteArray: #[16r0F 16rA2 16r90]"cpuid;nop".
	self processor eax: 0. "get vendor identfication string"
	self processor eip: 0.

	self processor singleStep.
	self assert: self processor eip = 2.
	self assert: self processor eax >= 1.

	self processor eax: 1.
	self processor eip: 0.
	self processor singleStep.

	self assert: self processor eip = 2.
	self assert: (self processor edx bitAnd: 1 << 26) ~= 0
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testCPUID [
	| vendorString memory |
	memory := ByteArray new: 4096 "4K".
	self processor mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.
	self processor memoryFrom: 0 writeNBytes: 3 fromByteArray: #[16r0F 16rA2 16r90] "cpuid;nop".
	
	self processor
			eip: 0;
			eax: 0. "get vendor identfication string"
	self processor singleStep.
	
	self assert: self processor eip = 2.
	self assert: self processor eax ~= 0.
	
	vendorString := (ByteArray new: 12)
						longAt: 1 put: self processor ebx bigEndian: false;
						longAt: 5 put: self processor edx bigEndian: false;
						longAt: 9 put: self processor ecx bigEndian: false;
						asString.
	self assert: (vendorString = 'GenuineIntel'
				or: [vendorString = 'AuthenticAMD'])
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testCallTrap [
	"Call a function that is out-of-range.  Ensure the call is trapped."
	"self new testCallTrap"
	| memory |
	 "The address is out of range of memory every which way (whether relative or absolute and whether big-endian or little."
	memory := ByteArray new: 4096 "4K".
	self processor mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.
	self processor memoryFrom: 0 writeNBytes: 3 fromByteArray: { "callOpcode" 16rE8. 0. 16r80. 16r80. 0. } asByteArray. "cpuid;nop"
	
	self processor
			eip: 0;
			esp: (memory size - 4). "Room for return address"
	self should: [ self processor step ]
		raise: ProcessorSimulationTrap
		withExceptionDo:
			[:pst|
			self assert: pst address = ((memory longAt: 2 bigEndian: false) + 5 "length of call instr").
			self assert: pst pc = 0.
			self assert: pst type = #call].
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testExecutionTrap [
	"Execute a run of nops.  test executing beyond the executable limit is trapped."
	"self new testExecutionTrap"
	| memory |
	 "The address is out of range of memory every which way (whether relative or absolute and whether big-endian or little."
	memory := ByteArray new: 4096 * 2 withAll: self processor nopOpcode.
	self processor
			eip: 0;
			esp: (memory size - 4). "Room for return address"
	self should: [self processor runInMemory: memory minimumAddress: 0 readOnlyBelow: memory size / 2]
		raise: Error
		withExceptionDo:
			[:err|
			self assert: self processor pc = (memory size / 2).
			self assert: ('*EIP*> CS.limit*' match: err messageText)].
	self processor eip: 0.
	self should: [[self processor singleStepIn: memory minimumAddress: 0 readOnlyBelow: memory size / 2] repeat]
		raise: Error
		withExceptionDo:
			[:err|
			self assert: self processor pc = (memory size / 2).
			self assert: ('*EIP*> CS.limit*' match: err messageText)]
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testFibonacci: n [.
	
	self runNFib: n.
	
	"check the instruction pointer is not in the code range of the fibonacci function"
	self deny: (self processor eip between: 0 and: self nfib size - 1).
	self assert: self processor eax equals: n benchFib
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testMOVSD [
	"Test MOVSD indirecting through edx."
	"The address is out of range of memory every which way (whether relative or absolute and whether big-endian or little."
	| memory |
	memory := ByteArray new: 4096 "4K".
	self processor mapHostMemory: memory atAddress: 0 withPermissions: UnicornConstants permissionAll.
	self processor memoryFrom: 0 writeNBytes: 12 fromByteArray: {16rF2. 16r0F. 16r10. 16r42. 16r04. 16r90. 16r01. 16r02. 16r03. 16r04. 16r05. 16r06} asByteArray "movsd %ds:0x4(%edx), %xmm0;nop;garbage".
	
	self processor
		edx: 0;
		eip: 0;
		step. 
	self assert: self processor eip = 5.
	self assert: self processor xmm0low = 16r0605040302019004
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testNfib1 [
	
	self testFibonacci: 1
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testNfib16 [
	
	self testFibonacci: 16
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testNfib2 [
	
	self testFibonacci: 2
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testNfib4 [
	
	self testFibonacci: 4
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testResetCPU [
	"self new testResetCPU"
	self integerRegisterSetters do:
		[:setter|
		self processor perform: setter with: 16r55555555].
	self integerRegisterGetters do:
		[:getter|
		self assert: 16r55555555 = (self processor perform: getter)].
	self processor reset.
	self integerRegisterGetters do:
		[:getter|
		self assert: 0 = (self processor perform: getter)]
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testStepNfib1 [
	"self new testNfib1"
	self singleStepNFib: 1 disassemble: false printRegisters: false.
	self assert: self processor eip = self nfib size.
	self assert: self processor eax = 1 benchFib
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testStepNfib2 [
	"self new testNfib2"
	self singleStepNFib: 2 disassemble: false printRegisters: false.
	self assert: self processor eip = self nfib size.
	self assert: self processor eax = 2 benchFib
]

{ #category : #tests }
WLX86ProcessorSimulatorTests >> testStepNfib4 [
	"self new testNfib4"
	self singleStepNFib: 4 disassemble: false printRegisters: false.
	self assert: self processor eip = self nfib size.
	self assert: self processor eax = 4 benchFib
]
