"
I'm a processor simulator for x86-64.
See CogSimulationProcessor for more detail.
"
Class {
	#name : #WLX8664SimulationProcessor,
	#superclass : #WLX86SimulationProcessor,
	#category : #Woodland
}

{ #category : #testing }
WLX8664SimulationProcessor >> convertIntegerToInternal: anInteger [ 

	^anInteger signedIntToLong64
]

{ #category : #testing }
WLX8664SimulationProcessor >> convertInternalToInteger: unsigned [

	^unsigned signedIntFromLong64
]

{ #category : #initialization }
WLX8664SimulationProcessor >> initialize [
	super initialize.
	
	bitsInWord := 64.
	disassembler := LLVMDisassembler amd64
		setOptions: 2;
		yourself
]

{ #category : #initialization }
WLX8664SimulationProcessor >> instantiateSimulator [
	
	^ Unicorn x8664
]

{ #category : #testing }
WLX8664SimulationProcessor >> movByteOperationString [

	^ 'movabsb'
]

{ #category : #testing }
WLX8664SimulationProcessor >> movQuadWordOperationString [
	
	^ 'movabsq'
]

{ #category : #accessing }
WLX8664SimulationProcessor >> pc [

	^self rip
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r10 [
	^ self readRegisterId: UcX86Registers r10
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r10: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r10
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r11 [
	^ self readRegisterId: UcX86Registers r11
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r11: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r11
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r12 [
	^ self readRegisterId: UcX86Registers r12
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r12: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r12
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r13 [
	^ self readRegisterId: UcX86Registers r13
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r13: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r13
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r14 [
	^ self readRegisterId: UcX86Registers r14
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r14: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r14
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r15 [
	^ self readRegisterId: UcX86Registers r15
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r15: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r15
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r8 [
	^ self readRegisterId: UcX86Registers r8
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r8: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r8
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r9 [
	^ self readRegisterId: UcX86Registers r9
]

{ #category : #accessing }
WLX8664SimulationProcessor >> r9: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers r9
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rax [
	^ self readRegisterId: UcX86Registers rax
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rax: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rax
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rbp [
	^ self readRegisterId: UcX86Registers rbp
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rbp: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rbp
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rbx [
	^ self readRegisterId: UcX86Registers rbx
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rbx: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rbx
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rcx [
	^ self readRegisterId: UcX86Registers rcx
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rcx: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rcx
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rdi [
	^ self readRegisterId: UcX86Registers rdi
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rdi: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rdi
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rdx [
	^ self readRegisterId: UcX86Registers rdx
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rdx: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rdx
]

{ #category : #writing }
WLX8664SimulationProcessor >> readRegisterId: aRegisterId [

	| buffer |
	buffer := self readRegisterId: aRegisterId size: self wordSize.
	^ (buffer unsignedLongAt: 5 bigEndian: false) << 32 + (buffer unsignedLongAt: 1 bigEndian: false)
]

{ #category : #accessing }
WLX8664SimulationProcessor >> registerNames [

	^#(	rax rcx rdx rbx rsp rbp rsi rdi r8 r9 r10 r11 r12 r13 r14 r15
		rip rflags
		"xmm0low xmm1low xmm2low xmm3low
		xmm4low xmm5low xmm6low xmm7low
		xmm9low xmm9low xmm10low xmm11low
		xmm12low xmm13low xmm14low xmm15low")
]

{ #category : #testing }
WLX8664SimulationProcessor >> registerStateGetters [
	^#(	rax rcx rdx rbx rsp rbp rsi rdi r8 r9 r10 r11 r12 r13 r14 r15
		rip rflags
		"xmm0low xmm1low xmm2low xmm3low
		xmm4low xmm5low xmm6low xmm7low
		xmm9low xmm9low xmm10low xmm11low
		xmm12low xmm13low xmm14low xmm15low")
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rflags [
	^ self readRegisterId: UcX86Registers rflags
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rflags: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rflags
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rip [
	^ self readRegisterId: UcX86Registers rip
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rip: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rip
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rsi [
	^ self readRegisterId: UcX86Registers rsi
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rsi: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rsi
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rsp [
	^ self readRegisterId: UcX86Registers rsp
]

{ #category : #accessing }
WLX8664SimulationProcessor >> rsp: anInteger [
	^ self writeInteger: anInteger registerId: UcX86Registers rsp
]

{ #category : #accessing }
WLX8664SimulationProcessor >> wordSize [

	^ 8
]

{ #category : #writing }
WLX8664SimulationProcessor >> writeInteger: anInteger registerId: anUcX86Registers [ 

	| buffer |
	buffer := ByteArray new: self wordSize.
	buffer unsignedLongAt: 1 put: (anInteger bitAnd: 16rFFFFFFFF) bigEndian: false.
	buffer unsignedLongAt: 5 put: ((anInteger >> 32) bitAnd: 16rFFFFFFFF) bigEndian: false.
	self write: buffer registerId: anUcX86Registers.
	^ anInteger
]
