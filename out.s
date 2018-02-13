.global function
function:
movq	%RDI,%RSI
movq	%RSI,%R14

test:
cmpq	$0,(%RDI)
je	ret
addq	$8,%RDI
jmp	test

ret:
subq	%RSI,%RDI
movq	%RDI,%RDX
shrq	$3,%RDX
jmp	rev

rev:
shlq	$3,%RDX
subq	$8,%RDX
addq	%RDX,%R14
jmp	inc

inc:
cmpq	%RSI,%R14
je	ret_rev
cmpq	(%RSI),(%R14)
jl	swap
addq	$8,%RSI
subq	$8,%R14
jmp	inc

swap:
movq	(%RSI),%R12
movq	(%R14),%R13
movq	%R13,(%RSI)
movq	%R12,(%R14)
cmpq	%RSI,%R14
je	ret_rev
jmp	inc

ret_rev:
retq	

