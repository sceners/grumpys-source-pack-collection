
.comm source_width,4
.comm dest_width,4
.comm new_width,4

.comm horiz_code,4000


                .align 4,0x90
.globl do_zoom
do_zoom:
                movl %ebp,(source_width)
                andl $65535,(source_width)
                shrl $16,%ebp
                movl %ebp,(dest_width)

                subl %eax,%ebp

                movl %eax,(new_width)

                pusha

                call calc_horiz_code

                popa

                cld

                xorl %eax,%eax
                movl %edx,%ecx

next_vert:
                addl %ebx,%eax
                jle skip_vert_copy

                pushl %eax
                pushl %esi

                call horiz_code

                popl %esi
                popl %eax

                addl %ebp,%edi

                subl %edx,%eax

                jle skip_vert_copy

copy_next_vert:

                pushl %ecx
                pushl %esi

                movl %edi,%esi
                subl (dest_width),%esi
                movl (new_width),%ecx
                shrl $1,%ecx

                rep
                movsw

                jnc skip_movsb

                movsb
skip_movsb:

                popl %esi
                popl %ecx

                addl %ebp,%edi

                subl %edx,%eax

                jg copy_next_vert

skip_vert_copy:
                addl (source_width),%esi
                decl %ecx
                jnz next_vert

                ret


                .align 4,0x90

calc_horiz_code:

                xorl %ebp,%ebp
                leal horiz_code,%edi
                movl %ecx,%esi

next_horiz:
                addl %eax,%ebp
                jle skip_horiz_copy

                movl $0x0788068a,(%edi)
                movb $0x47,4(%edi)
                addl $5,%edi

                subl %esi,%ebp

                jle skip_horiz_copy

copy_next_horiz:

                movw $0x0788,(%edi)
                movb $0x47,2(%edi)
                addl $3,%edi

                subl %esi,%ebp

                jg copy_next_horiz

skip_horiz_copy:
                movb $0x46,(%edi)
                incl %edi
                decl %ecx
                jnz next_horiz

                movb $0xc3,(%edi)
                ret


