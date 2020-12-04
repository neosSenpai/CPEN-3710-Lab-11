; Quadratic function      (quadratic.asm)

;
.586
.model flat,C
public Quadratic					; quadratic can be called by external code
 
 .data
 epsilon	REAL4	0.0000001			; if input is less than this, assume it is zero
 determin	REAL4	?				; real value of discriminant D as a 32-bit (4-byte) IEEE short real
 deterInt	DWORD	4				; CONSTANT value used in the calculation of the discriminant
 rootInt	DWORD	2				; CONSTANT value used to calculate roots
.code
;-----------------------------------------------
Quadratic PROC 
;
; Finds roots of quadratic equations using
; the FPU
;
; Recieves: A, B, and C pointed to by the EBP register
; 
; Returns: 0 or -1 in EAX depending on if the
; roots are real (0) or complex (-1)
;-----------------------------------------------
	COMPLEX_ROOT = -1				; returns -1 if the roots are complex

	push	ebp					; save caller's base pointer
	mov		ebp, esp			; set up a new base pointer
	call	discriminant				; get the value of the discriminant D

	; Check to see if the discriminant is = 0, if so then there is only one real solution
	; since both roots will be the same value
	finit
	fld		epsilon				; ST(0) = epsilon	
	fld		determin			; ST(0) = discriminant, ST(1) = epsilon
	fsub	epsilon					; ST(0) = epsilon, ST(1) = discriminant, ST(2) = epsilon
	fabs
	fcomi ST(0),ST(1)				; Does D = 0?
	ja		L1				; if D > 0 go to L1 which  tests  for complex roots
	jmp		continue			; if D = 0 then get the root
L1:
	; is D < 0
	fld		epsilon				; ST(0) = epsilon	
	fld		determin			; ST(0) = determin, ST(1) = epsilon	
	fcomi	st(0),st(1)				; is d < 0
	ja		continue			; if yes we can get roots, if not then the equation is complex
	mov		eax,COMPLEX_ROOT		; returns -1 in eax if the root is complex
	pop		ebp				; restore previous base pointer
	ret						; return with eax = -1

continue:
	call	getRoots
	pop		ebp
	ret
Quadratic ENDP

;-----------------------------------------------
discriminant PROC 
;
; This procdure calculates the value of the
; discriminant
; 
; Recieves: A, B, and C pointed to by the EBP register
;
; Returns: determin (the Discriminant used for root calculations)
;-----------------------------------------------
	finit						; initializes the FPU
	fld		real4 ptr[ebp+12]		; ST(0) = b
	fld		real4 ptr[ebp+12]		; ST(0) = b, ST(1) = b
	fmul						; ST(0) = b*b
	fld		real4 ptr[ebp+8]		; ST(0) = a, ST(1) = b*b
	fld		real4 ptr[ebp+16]		; ST(0) = c, ST(1) = a, ST(2) = b*b
	fmul						; ST(0) = a*c, ST(1) = b*b
	fimul	deterInt				; ST(0) = 4*(a*c), ST(1) = b*b
	fsubp	st(1),st(0)				; ST(0) = b*b - (4*a*c)
	fstp	determin				; store discriminant in determin
	ret						; exit proc
discriminant ENDP

;-----------------------------------------------
getRoots PROC 
;
; This procdure calculates the roots of a 
; quadratic equation
; 
; Recieves:A, B, and C pointed to by the EBP register
;
; Returns: 0 in EAX
;-----------------------------------------------
	; (-b + sqrtD)/2a
	fld		real4 ptr[ebp+12]		; ST(0) = b
	fchs						; ST(0) = -b
	fld		determin			; ST(0) = D, ST(1) = -b
	fsqrt						; ST(0) = sqrtD, ST(1) = -b
	faddp	st(1),st(0)				; ST(0) = -b + sqrtD
	fld		real4 ptr[ebp+8]		; ST(0) = a, ST(1) = -b + sqrtD
	fimul	rootInt					; ST(0) = 2a, ST(1) = -b + sqrtD
	fdivp	st(1),st(0)				; ST(0) = (-b + sqrtD)/2a
	mov		edi,[ebp+20]			; get result pointer from stack frame at root1
	fstp	real4 ptr[edi]				; store the result in memory 
	; (-b - ?D)/2a
	fld		real4 ptr[ebp+12]		; ST(0) = b
	fchs						; ST(0) = -b
	fld		determin			; ST(0) = D, ST(1) = -b
	fsqrt						; ST(0) = sqrtD, ST(1) = -b
	fsubp	st(1),st(0)				; ST(0) = -b - sqrtD
	fld		real4 ptr[ebp+8]		; ST(0) = a, ST(1) = -b - sqrtD
	fimul	rootInt					; ST(0) = 2a, ST(1) = -b - sqrtD
	fdivp	st(1),st(0)				; ST(0) = (-b - sqrtD)/2a
	mov		edi,[ebp+24]			; get result pointer from stack frame at root2
	fstp	real4 ptr[edi]				; store the result in memory 
	xor		eax,eax				; signal success
	ret						; exit proc
getRoots ENDP
END

