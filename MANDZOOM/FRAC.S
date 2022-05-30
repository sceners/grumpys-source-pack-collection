	.file	"frac.c"
gcc2_compiled.:
.globl _mand_data
.data
	.align 2
_mand_data:
	.long _array1
.globl _other_data
	.align 2
_other_data:
	.long _array2
.globl _m_x1
	.align 2
_m_x1:
	.long -13319411
.globl _m_y1
	.align 2
_m_y1:
	.long 10636271
.globl _m_x2
	.align 2
_m_x2:
	.long 8302812
.globl _m_y2
	.align 2
_m_y2:
	.long -5088882
.globl _frame
	.align 2
_frame:
	.long 0
.text
	.align 4
.globl _FixedMul
_FixedMul:
	pushl %ebp
	movl %esp,%ebp
/APP
	
        movl 8(%ebp),%eax
        imull 12(%ebp)
        
	shrd $22,%edx,%eax
/NO_APP
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _FixedDiv
_FixedDiv:
	pushl %ebp
	movl %esp,%ebp
/APP
	
        movl 8(%ebp),%eax
        movl %eax,%edx
        
	sar $10,%edx
	shl $22,%eax
	idivl 12(%ebp)
/NO_APP
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _zoom
_zoom:
	pushl %ebp
	movl %esp,%ebp
	cmpl $0,16(%ebp)
	je L3
	cmpl $0,20(%ebp)
	je L3
/APP
	
        pushl %esi
        pushl %edi
        pushl %ebx
        pushl %ebp

        movl  8(%ebp),%esi
        movl 12(%ebp),%edi
        movl 16(%ebp),%eax
        movl 20(%ebp),%ebx
        movl 24(%ebp),%ecx
        movl 28(%ebp),%edx
        movl 32(%ebp),%ebp
        shll $16,%ebp
        movw 52(%esp),%ebp

        call do_zoom

        popl %ebp
        popl %ebx
        popl %edi
        popl %esi
        
/NO_APP
L3:
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _Sync
_Sync:
	pushl %ebp
	movl %esp,%ebp
	.align 2,0x90
L7:
	pushl $986
	call _inportb
	addl $4,%esp
	andb $8,%al
	jne L7
	.align 2,0x90
L9:
	pushl $986
	call _inportb
	addl $4,%esp
	andb $8,%al
	je L9
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _ZoomScreen
_ZoomScreen:
	pushl %ebp
	movl %esp,%ebp
	subl $4,%esp
	pushl %edi
	pushl %esi
	pushl %ebx
	movl $335544320,-4(%ebp)
	.align 2,0x90
L16:
	movl -4(%ebp),%ecx
	pushl %ecx
	pushl $1342177280
	call _FixedDiv
	addl $8,%esp
	movl %eax,%edi
	movl %edi,%ebx
	sarl $22,%ebx
	leal (%ebx,%ebx,2),%eax
	leal (%ebx,%eax,8),%eax
	sall $3,%eax
	movl $320,%ecx
	cltd
	idivl %ecx
	movl %eax,%esi
	call _Sync
	pushl $320
	pushl $320
	pushl $200
	pushl $320
	pushl %esi
	pushl %ebx
	movl $320,%edx
	subl %ebx,%edx
	jns L14
	incl %edx
L14:
	sarl $1,%edx
	movl $200,%eax
	subl %esi,%eax
	jns L15
	incl %eax
L15:
	sarl $1,%eax
	leal (%eax,%eax,4),%eax
	sall $6,%eax
	leal -805306368(%edx,%eax),%eax
	pushl %eax
	pushl $_scrn_buff
	call _zoom
	addl $32,%esp
	addl $-1048576,-4(%ebp)
	cmpl $1342177279,%edi
	jle L16
	leal -16(%ebp),%esp
	popl %ebx
	popl %esi
	popl %edi
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4
.globl _EndZoom
_EndZoom:
	pushl %ebp
	movl %esp,%ebp
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl $64000
	pushl $_scrn_buff
	pushl $-805306368
	call _bcopy
	addl $12,%esp
	movl $320,%ebx
	movl $64000,%edi
	.align 2,0x90
L22:
	movl %edi,%eax
	movl $320,%ecx
	cltd
	idivl %ecx
	movl %eax,%esi
	call _Sync
	pushl $320
	pushl $320
	pushl %esi
	pushl %ebx
	pushl $200
	pushl $320
	pushl $-805306368
	movl $320,%edx
	subl %ebx,%edx
	jns L20
	incl %edx
L20:
	sarl $1,%edx
	movl $200,%eax
	subl %esi,%eax
	movl %eax,%esi
	testl %esi,%esi
	jge L21
	incl %esi
L21:
	sarl $1,%esi
	leal (%esi,%esi,4),%eax
	sall $6,%eax
	leal _scrn_buff(%edx,%eax),%eax
	pushl %eax
	call _zoom
	addl $32,%esp
	addl $-800,%edi
	addl $-4,%ebx
	cmpl $1,%ebx
	jg L22
	leal -12(%ebp),%esp
	popl %ebx
	popl %esi
	popl %edi
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4
.globl _Mandel
_Mandel:
	pushl %ebp
	movl %esp,%ebp
	subl $4,%esp
	movl $255,-4(%ebp)
/APP
	
        pushl %esi
        pushl %edi
        pushl %ebx

        movl 8(%ebp),%esi
        movl 12(%ebp),%edi
LOOP:
        movl %esi,%eax
        imul %eax
        
	shrd $22,%edx,%eax
	
        movl %eax,%ebx

        movl %edi,%eax
        imul %eax
        
	shrd $22,%edx,%eax
	
        movl %eax,%ecx

        addl %ebx,%eax
        
	cmpl $16777216,%eax
	
        jg EXIT

        movl %edi,%eax
        imul %esi
        
	shrd $22,%edx,%eax
	
        movl %ebx,%esi
        subl %ecx,%esi
        addl 8(%ebp),%esi

        leal (%eax,%eax),%edi
        addl 12(%ebp),%edi

        decl -4(%ebp)
        jnz LOOP

EXIT:
        popl %ebx
        popl %edi
        popl %esi
        
/NO_APP
	movl -4(%ebp),%eax
	negb %al
	andl $255,%eax
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _ResetAll
_ResetAll:
	pushl %ebp
	movl %esp,%ebp
	pushl $16777216
	movl _m_x2,%eax
	subl _m_x1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	addl %eax,_m_x1
	subl %eax,_m_x2
	pushl $16777216
	movl _m_y2,%eax
	subl _m_y1,%eax
	pushl %eax
	call _FixedDiv
	addl %eax,_m_y1
	subl %eax,_m_y2
	movl _mand_data,%eax
	movl _other_data,%edx
	movl %edx,_mand_data
	movl %eax,_other_data
	movl $20971520,_ysz
	movl $33554432,_xsz
	movl $0,_ysrc
	movl $0,_xsrc
	movl $0,_frame
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _UpdateScreen
_UpdateScreen:
	pushl %ebp
	movl %esp,%ebp
/APP
	
        pushl %esi
        pushl %edi
        pushl %ebx
        cld
        
	movl $151,%edx
	movl $_screen_data,%esi
	
        movl 8(%ebp),%edi

update_back:
        
	movl $64,%ecx
	
        rep
        movsl
        
	addl $64,%edi
	
        decl %edx
        jnz update_back
        
	movl $_bits_graphic+32,%ebx
	
        movl $9,%edx

update_under:

        
	movl $256,%ecx
	

update_under_next:

        testb $-1,(%ebx)
        jnz update_skip

        movb (%esi),%al
        movb %al,(%edi)

update_skip:

        inc %esi
        inc %edi
        inc %ebx

        dec %ecx
        jnz update_under_next

        
	addl $64,%edi
	addl $64,%ebx
	

        decl %edx
        jnz update_under

        popl %ebx
        popl %edi
        popl %esi
        
/NO_APP
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _CalcColumn
_CalcColumn:
	pushl %ebp
	movl %esp,%ebp
	subl $52,%esp
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl $16777216
	movl _m_x2,%eax
	subl _m_x1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	addl _m_x1,%eax
	movl %eax,-4(%ebp)
	pushl $16777216
	movl _m_x2,%eax
	subl _m_x1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	movl _m_x2,%edx
	subl %eax,%edx
	movl %edx,-12(%ebp)
	pushl $16777216
	movl _m_y2,%eax
	subl _m_y1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	addl _m_y1,%eax
	movl %eax,-8(%ebp)
	pushl $16777216
	movl _m_y2,%eax
	subl _m_y1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	movl _m_y2,%ebx
	subl %eax,%ebx
	pushl $1073741824
	movl _xsrc,%eax
	sall $22,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	movl $4194304,%ecx
	subl %eax,%ecx
	movl %ecx,%eax
	pushl %eax
	movl _m_x2,%eax
	subl _m_x1,%eax
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,-16(%ebp)
	pushl $671088640
	movl _ysrc,%eax
	sall $22,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	movl $4194304,%edx
	subl %eax,%edx
	movl %edx,%eax
	pushl %eax
	movl _m_y2,%eax
	subl _m_y1,%eax
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,-20(%ebp)
	pushl $1073741824
	movl _xsrc,%eax
	sall $22,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	movl _m_x2,%eax
	subl _m_x1,%eax
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl _m_x1,%eax
	movl %eax,-24(%ebp)
	pushl $671088640
	movl _ysrc,%eax
	sall $22,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	movl _m_y2,%eax
	subl _m_y1,%eax
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl _m_y1,%eax
	movl %eax,-28(%ebp)
	subl -8(%ebp),%ebx
	movl %ebx,%eax
	sall $8,%eax
	movl $320,%ecx
	cltd
	idivl %ecx
	movl %eax,-40(%ebp)
	pushl $671088640
	movl -20(%ebp),%edx
	pushl %edx
	sarl $8,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,-44(%ebp)
	movl _frame,%ecx
	movl %ecx,%eax
	addl %ecx,%eax
	movl %eax,%edi
	addl _other_data,%edi
	movl %ecx,%eax
	addl $41088,%eax
	addl _mand_data,%eax
	xorl %ebx,%ebx
	.align 2,0x90
L30:
	movb (%eax),%dl
	movb %dl,(%edi)
	incl %ebx
	addl $1024,%edi
	addl $512,%eax
	cmpl $159,%ebx
	jle L30
	movl -12(%ebp),%eax
	subl -4(%ebp),%eax
	pushl %eax
	pushl $1073741824
	movl _frame,%eax
	sall $23,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl -4(%ebp),%eax
	movl %eax,-36(%ebp)
	pushl $1073741824
	movl -16(%ebp),%ecx
	pushl %ecx
	subl -24(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	sarl $22,%eax
	movl %eax,-48(%ebp)
	movl _frame,%edx
	movl %edx,%eax
	addl %edx,%eax
	addl $512,%eax
	movl %eax,%edi
	addl _other_data,%edi
	movl -8(%ebp),%eax
	sall $8,%eax
	addl -40(%ebp),%eax
	movl %eax,-32(%ebp)
	pushl $671088640
	movl -20(%ebp),%ecx
	pushl %ecx
	sarl $8,%eax
	subl -28(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,%esi
	xorl %ebx,%ebx
	.align 2,0x90
L40:
	movl -48(%ebp),%eax
	incl %eax
	cmpl $254,%eax
	jg L34
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+514(%eax),%dl
	cmpb %dl,_screen_data(%eax)
	jne L38
	cmpb %dl,_screen_data+2(%eax)
	jne L38
	cmpb %dl,_screen_data+512(%eax)
	jne L38
	movb _screen_data+514(%eax),%al
	jmp L39
	.align 4,0x90
L34:
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+257(%eax),%dl
	cmpb %dl,_screen_data+1(%eax)
	jne L38
	cmpb %dl,_screen_data+513(%eax)
	jne L38
	movb _screen_data+257(%eax),%al
	jmp L39
	.align 4,0x90
L38:
	movl -32(%ebp),%eax
	sarl $8,%eax
	pushl %eax
	movl -36(%ebp),%ecx
	pushl %ecx
	call _Mandel
	addl $8,%esp
L39:
	movb %al,(%edi)
	incl %ebx
	addl $1024,%edi
	movl -32(%ebp),%ecx
	movl -40(%ebp),%edx
	leal (%ecx,%edx,2),%ecx
	movl %ecx,-32(%ebp)
	movl -44(%ebp),%edx
	leal (%esi,%edx,2),%esi
	cmpl $156,%ebx
	jle L40
	movl -12(%ebp),%eax
	subl -4(%ebp),%eax
	pushl %eax
	pushl $1073741824
	movl _frame,%eax
	sall $23,%eax
	addl $4194304,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl -4(%ebp),%eax
	movl %eax,-36(%ebp)
	pushl $1073741824
	movl -16(%ebp),%ecx
	pushl %ecx
	subl -24(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	sarl $22,%eax
	movl %eax,-48(%ebp)
	movl _frame,%edx
	movl %edx,%eax
	addl %edx,%eax
	incl %eax
	movl %eax,%edi
	addl _other_data,%edi
	movl -8(%ebp),%ecx
	sall $8,%ecx
	movl %ecx,-32(%ebp)
	pushl $671088640
	movl -20(%ebp),%edx
	pushl %edx
	movl %ecx,%eax
	sarl $8,%eax
	subl -28(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,%esi
	xorl %ebx,%ebx
	.align 2,0x90
L50:
	movl -48(%ebp),%eax
	incl %eax
	cmpl $254,%eax
	jg L44
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+514(%eax),%cl
	cmpb %cl,_screen_data(%eax)
	jne L48
	cmpb %cl,_screen_data+2(%eax)
	jne L48
	cmpb %cl,_screen_data+512(%eax)
	jne L48
	movb _screen_data+514(%eax),%al
	jmp L49
	.align 4,0x90
L44:
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+257(%eax),%cl
	cmpb %cl,_screen_data+1(%eax)
	jne L48
	cmpb %cl,_screen_data+513(%eax)
	jne L48
	movb _screen_data+257(%eax),%al
	jmp L49
	.align 4,0x90
L48:
	movl -32(%ebp),%eax
	sarl $8,%eax
	pushl %eax
	movl -36(%ebp),%edx
	pushl %edx
	call _Mandel
	addl $8,%esp
L49:
	movb %al,(%edi)
	incl %ebx
	addl $512,%edi
	movl -40(%ebp),%ecx
	addl %ecx,-32(%ebp)
	addl -44(%ebp),%esi
	cmpl $317,%ebx
	jle L50
	movl _frame,%eax
	addl $128,%eax
	addl %eax,%eax
	movl %eax,%edi
	addl _other_data,%edi
	movl _frame,%eax
	addl $41216,%eax
	addl _mand_data,%eax
	xorl %ebx,%ebx
	.align 2,0x90
L54:
	movb (%eax),%dl
	movb %dl,(%edi)
	incl %ebx
	addl $1024,%edi
	addl $512,%eax
	cmpl $159,%ebx
	jle L54
	movl -12(%ebp),%eax
	subl -4(%ebp),%eax
	pushl %eax
	pushl $1073741824
	movl _frame,%eax
	addl $128,%eax
	sall $23,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl -4(%ebp),%eax
	movl %eax,-36(%ebp)
	pushl $1073741824
	movl -16(%ebp),%ecx
	pushl %ecx
	subl -24(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	sarl $22,%eax
	movl %eax,-48(%ebp)
	movl _frame,%eax
	addl $128,%eax
	leal 512(,%eax,2),%eax
	movl %eax,%edi
	addl _other_data,%edi
	movl -8(%ebp),%eax
	sall $8,%eax
	addl -40(%ebp),%eax
	movl %eax,-32(%ebp)
	pushl $671088640
	movl -20(%ebp),%edx
	pushl %edx
	sarl $8,%eax
	subl -28(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,%esi
	xorl %ebx,%ebx
	.align 2,0x90
L64:
	movl -48(%ebp),%eax
	incl %eax
	cmpl $254,%eax
	jg L58
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+514(%eax),%cl
	cmpb %cl,_screen_data(%eax)
	jne L62
	cmpb %cl,_screen_data+2(%eax)
	jne L62
	cmpb %cl,_screen_data+512(%eax)
	jne L62
	movb _screen_data+514(%eax),%al
	jmp L63
	.align 4,0x90
L58:
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+257(%eax),%cl
	cmpb %cl,_screen_data+1(%eax)
	jne L62
	cmpb %cl,_screen_data+513(%eax)
	jne L62
	movb _screen_data+257(%eax),%al
	jmp L63
	.align 4,0x90
L62:
	movl -32(%ebp),%eax
	sarl $8,%eax
	pushl %eax
	movl -36(%ebp),%edx
	pushl %edx
	call _Mandel
	addl $8,%esp
L63:
	movb %al,(%edi)
	incl %ebx
	addl $1024,%edi
	movl -32(%ebp),%edx
	movl -40(%ebp),%ecx
	leal (%edx,%ecx,2),%edx
	movl %edx,-32(%ebp)
	movl -44(%ebp),%ecx
	leal (%esi,%ecx,2),%esi
	cmpl $156,%ebx
	jle L64
	movl -12(%ebp),%eax
	subl -4(%ebp),%eax
	pushl %eax
	pushl $1073741824
	movl _frame,%eax
	sall $23,%eax
	addl $1077936128,%eax
	sarl $1,%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	addl -4(%ebp),%eax
	movl %eax,-36(%ebp)
	pushl $1073741824
	movl -16(%ebp),%edx
	pushl %edx
	subl -24(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	sarl $22,%eax
	movl %eax,-48(%ebp)
	movl _frame,%eax
	addl $128,%eax
	leal 1(,%eax,2),%eax
	movl %eax,%edi
	addl _other_data,%edi
	movl -8(%ebp),%ecx
	sall $8,%ecx
	movl %ecx,-32(%ebp)
	pushl $671088640
	movl -20(%ebp),%edx
	pushl %edx
	movl %ecx,%eax
	sarl $8,%eax
	subl -28(%ebp),%eax
	pushl %eax
	call _FixedDiv
	addl $8,%esp
	pushl %eax
	call _FixedMul
	addl $8,%esp
	movl %eax,%esi
	xorl %ebx,%ebx
	.align 2,0x90
L74:
	movl -48(%ebp),%eax
	incl %eax
	cmpl $254,%eax
	jg L68
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+514(%eax),%cl
	cmpb %cl,_screen_data(%eax)
	jne L72
	cmpb %cl,_screen_data+2(%eax)
	jne L72
	cmpb %cl,_screen_data+512(%eax)
	jne L72
	movb _screen_data+514(%eax),%al
	jmp L73
	.align 4,0x90
L68:
	movl %esi,%eax
	sarl $22,%eax
	sall $8,%eax
	addl -48(%ebp),%eax
	movb _screen_data+257(%eax),%cl
	cmpb %cl,_screen_data+1(%eax)
	jne L72
	cmpb %cl,_screen_data+513(%eax)
	jne L72
	movb _screen_data+257(%eax),%al
	jmp L73
	.align 4,0x90
L72:
	movl -32(%ebp),%eax
	sarl $8,%eax
	pushl %eax
	movl -36(%ebp),%edx
	pushl %edx
	call _Mandel
	addl $8,%esp
L73:
	movb %al,(%edi)
	incl %ebx
	addl $512,%edi
	movl -40(%ebp),%ecx
	addl %ecx,-32(%ebp)
	addl -44(%ebp),%esi
	cmpl $317,%ebx
	jle L74
	leal -64(%ebp),%esp
	popl %ebx
	popl %esi
	popl %edi
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4
.globl _SetCols
_SetCols:
	pushl %ebp
	movl %esp,%ebp
	pushl %ebx
	pushl $0
	pushl $968
	call _outportb
	addl $8,%esp
	xorl %ebx,%ebx
	.align 2,0x90
L79:
	movzbl _palette(%ebx),%eax
	pushl %eax
	pushl $969
	call _outportb
	addl $8,%esp
	incl %ebx
	cmpl $767,%ebx
	jle L79
	movl -4(%ebp),%ebx
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4
.globl _PutText
_PutText:
	pushl %ebp
	movl %esp,%ebp
/APP
	
        pushl %esi
        pushl %edi
        cld

        movl 12(%ebp),%edx
        movl 8(%ebp),%esi
        movl 16(%ebp),%edi

next_row_left:

        movl $8,%ecx
        rep
        movsl

        addl $288,%edi
        decl %edx
        jnz next_row_left

        popl %edi
        popl %esi
        
/NO_APP
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _PutGraphic
_PutGraphic:
	pushl %ebp
	movl %esp,%ebp
/APP
	
        pushl %esi
        pushl %edi
        
	movl $_bits_graphic,%esi
	movl $_scrn_buff+49600,%edi
	movl $14400,%ecx
	

put_graphic_next:

        testb $-1,(%esi)
        jz put_graphic_skip

        movb (%esi),%al
        movb %al,(%edi)

put_graphic_skip:

        incl %esi
        incl %edi
        decl %ecx
        jnz put_graphic_next

        popl %edi
        popl %esi
        
/NO_APP
	movl %ebp,%esp
	popl %ebp
	ret
	.align 4,0x90
	.align 4
.globl _main
_main:
	pushl %ebp
	movl %esp,%ebp
	subl $36,%esp
	pushl %ebx
	call ___main
	movl $19,-32(%ebp)
	leal -32(%ebp),%eax
	pushl %eax
	pushl %eax
	pushl $16
	call _int86
	addl $12,%esp
	pushl $33
	call _inportb
	addl $4,%esp
	movb %al,-36(%ebp)
	pushl $254
	pushl $33
	call _outportb
	addl $8,%esp
	call _SetCols
	pushl $_scrn_buff
	pushl $161
	pushl $_lefttext
	call _PutText
	addl $12,%esp
	pushl $_scrn_buff+288
	pushl $161
	pushl $_righttext
	call _PutText
	addl $12,%esp
	call _PutGraphic
	movl $0,_ysrc
	movl $20971520,_ysz
	movl $33554432,_xsz
	pushl $512
	pushl $256
	pushl $320
	pushl $512
	pushl $160
	pushl $256
	pushl $_screen_data
	movl _mand_data,%ecx
	pushl %ecx
	call _zoom
	addl $32,%esp
	pushl $_scrn_buff+1312
	call _UpdateScreen
	addl $4,%esp
	call _ZoomScreen
	movl $1450,%ebx
	.align 2,0x90
L90:
	pushl $96
	call _inportb
	addl $4,%esp
	cmpb $1,%al
	je L84
	addl $-131072,_xsz
	addl $-81920,_ysz
	movl $33554432,%eax
	subl _xsz,%eax
	jns L87
	incl %eax
L87:
	sarl $17,%eax
	movl %eax,_xsrc
	movl $20971520,%eax
	subl _ysz,%eax
	jns L88
	incl %eax
L88:
	movl %eax,%edx
	sarl $17,%edx
	movl %edx,_ysrc
	pushl $512
	pushl $256
	movl _ysz,%eax
	sarl $16,%eax
	pushl %eax
	movl _xsz,%eax
	sarl $16,%eax
	pushl %eax
	pushl $160
	pushl $256
	pushl $_screen_data
	movl _mand_data,%eax
	addl _xsrc,%eax
	sall $9,%edx
	addl %edx,%eax
	pushl %eax
	call _zoom
	addl $32,%esp
	call _CalcColumn
	pushl $-805305056
	call _UpdateScreen
	addl $4,%esp
	incl _frame
	cmpl $16777216,_xsz
	jne L85
	call _ResetAll
L85:
	decl %ebx
	testl %ebx,%ebx
	jg L90
L84:
	call _EndZoom
	movl $3,-32(%ebp)
	leal -32(%ebp),%eax
	pushl %eax
	pushl %eax
	pushl $16
	call _int86
	addl $12,%esp
	movzbl -36(%ebp),%eax
	pushl %eax
	pushl $33
	call _outportb
	xorl %eax,%eax
	movl -40(%ebp),%ebx
	movl %ebp,%esp
	popl %ebp
	ret
.comm _array2,163840
.comm _screen_data,40960
.comm _ysrc,4
.comm _xsrc,4
.comm _ysz,4
.comm _xsz,4
.comm _scrn_buff,64000
