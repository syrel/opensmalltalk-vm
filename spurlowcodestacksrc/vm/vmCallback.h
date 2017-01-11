/* Automatically generated by
	CCodeGeneratorGlobalStructure * VMMaker.oscog-eem.2082 uuid: f987e1db-f4c0-40ed-86ec-7a478cb89067
 */

#define VM_CALLBACK_INC 1

typedef struct _VMCallbackContext {
	void *thunkp;
	sqIntptr_t *stackp;
	sqIntptr_t *intregargsp;
	double *floatregargsp;
	void *savedCStackPointer;
	void *savedCFramePointer;
	union {
							sqIntptr_t valword;
							struct { int low, high; } valleint64;
							struct { int high, low; } valbeint64;
							double valflt64;
							struct { void *addr; sqIntptr_t size; } valstruct;
						}	rvs;
	jmp_buf	trampoline;
	jmp_buf	savedReenterInterpreter;
 } VMCallbackContext;

/* The callback return type codes */
#define retword 1
#define retword64 2
#define retdouble 3
#define retstruct 4


