;Convert DOS Dump format to assembler DB format

;Use: From command line, c:>dump file.bin>file.txt
;then c:>qb convert>file.asm

;File must be in DOS Dump format to convert to DB assembler format

;File to transfer? gamecolr.rqd

gamecolr:
    db 000h,000h,000h,000h,000h,02Ah,000h,02Ah
    db 000h,000h,02Ah,02Ah,02Ah,000h,000h,02Ah
    db 000h,02Ah,02Ah,015h,000h,02Ah,02Ah,02Ah
    db 015h,015h,015h,015h,015h,03Fh,015h,03Fh
    db 015h,015h,03Fh,03Fh,03Fh,015h,015h,03Fh
    db 015h,03Fh,03Fh,03Fh,015h,03Fh,03Fh,03Fh

    db 000h,000h,000h,00Ah,00Ah,00Ah,00Eh,00Eh
    db 00Eh,012h,012h,012h,015h,015h,015h,019h
    db 019h,019h,01Dh,01Dh,01Dh,021h,021h,021h
    db 025h,025h,025h,028h,028h,028h,02Ch,02Ch
    db 02Ch,030h,030h,030h,034h,034h,034h,037h
    db 037h,037h,03Bh,03Bh,03Bh,03Fh,03Fh,03Fh

    db 03Fh,000h,000h,03Bh,004h,000h,037h,008h
    db 000h,032h,00Dh,000h,02Eh,011h,000h,02Ah
    db 015h,000h,026h,019h,000h,022h,01Dh,000h
    db 01Dh,022h,000h,019h,026h,000h,015h,02Ah
    db 000h,011h,02Eh,000h,00Dh,032h,000h,008h
    db 037h,000h,004h,03Bh,000h,000h,03Fh,000h

    db 011h,000h,000h,014h,000h,000h,017h,000h
    db 000h,01Ah,000h,000h,01Dh,000h,000h,020h
    db 000h,000h,023h,000h,000h,026h,000h,000h
    db 02Ah,000h,000h,02Dh,000h,000h,030h,000h
    db 000h,033h,000h,000h,036h,000h,000h,039h
    db 000h,000h,03Ch,000h,000h,03Fh,000h,000h

    db 03Fh,000h,000h,03Bh,000h,004h,037h,000h
    db 008h,032h,000h,00Dh,02Eh,000h,011h,02Ah
    db 000h,015h,026h,000h,019h,022h,000h,01Dh
    db 01Dh,000h,022h,019h,000h,026h,015h,000h
    db 02Ah,011h,000h,02Eh,00Dh,000h,032h,008h
    db 000h,037h,004h,000h,03Bh,000h,000h,03Fh

    db 000h,011h,000h,000h,014h,000h,000h,017h
    db 000h,000h,01Ah,000h,000h,01Dh,000h,000h
    db 020h,000h,000h,023h,000h,000h,026h,000h
    db 000h,02Ah,000h,000h,02Dh,000h,000h,030h
    db 000h,000h,033h,000h,000h,036h,000h,000h
    db 039h,000h,000h,03Ch,000h,000h,03Fh,000h

    db 000h,000h,03Fh,000h,004h,03Bh,000h,008h
    db 037h,000h,00Dh,032h,000h,011h,02Eh,000h
    db 015h,02Ah,000h,019h,026h,000h,01Dh,022h
    db 000h,022h,01Dh,000h,026h,019h,000h,02Ah
    db 015h,000h,02Eh,011h,000h,032h,00Dh,000h
    db 037h,008h,000h,03Bh,004h,000h,03Fh,000h

    db 000h,000h,011h,000h,000h,014h,000h,000h
    db 017h,000h,000h,01Ah,000h,000h,01Dh,000h
    db 000h,020h,000h,000h,023h,000h,000h,026h
    db 000h,000h,02Ah,000h,000h,02Dh,000h,000h
    db 030h,000h,000h,033h,000h,000h,036h,000h
    db 000h,039h,000h,000h,03Ch,000h,000h,03Fh

    db 03Fh,03Fh,000h,03Fh,03Bh,004h,03Fh,037h
    db 008h,03Fh,032h,00Dh,03Fh,02Eh,011h,03Fh
    db 02Ah,015h,03Fh,026h,019h,03Fh,022h,01Dh
    db 03Eh,01Dh,022h,03Eh,019h,026h,03Eh,015h
    db 02Ah,03Eh,011h,02Eh,03Eh,00Dh,032h,03Eh
    db 008h,037h,03Eh,004h,03Bh,03Eh,000h,03Fh

    db 011h,011h,000h,014h,014h,000h,017h,017h
    db 000h,01Ah,01Ah,000h,01Dh,01Dh,000h,020h
    db 020h,000h,023h,023h,000h,026h,026h,000h
    db 02Ah,02Ah,000h,02Dh,02Dh,000h,030h,030h
    db 000h,033h,033h,000h,036h,036h,000h,039h
    db 039h,000h,03Ch,03Ch,000h,03Fh,03Fh,000h

    db 03Fh,03Fh,000h,03Bh,03Fh,004h,037h,03Fh
    db 008h,032h,03Fh,00Dh,02Eh,03Fh,011h,02Ah
    db 03Fh,015h,026h,03Fh,019h,022h,03Fh,01Dh
    db 01Dh,03Fh,022h,019h,03Fh,026h,015h,03Fh
    db 02Ah,011h,03Fh,02Eh,00Dh,03Fh,032h,008h
    db 03Fh,037h,004h,03Fh,03Bh,000h,03Fh,03Fh

    db 011h,000h,011h,014h,000h,014h,017h,000h
    db 017h,01Ah,000h,01Ah,01Dh,000h,01Dh,020h
    db 000h,020h,023h,000h,023h,026h,000h,026h
    db 029h,000h,02Ah,02Ch,000h,02Dh,02Fh,000h
    db 030h,032h,000h,033h,035h,000h,036h,038h
    db 000h,039h,03Bh,000h,03Ch,03Eh,000h,03Fh

    db 000h,03Fh,03Fh,004h,03Bh,03Fh,008h,037h
    db 03Fh,00Ch,032h,03Fh,011h,02Eh,03Fh,015h
    db 02Ah,03Fh,019h,026h,03Fh,01Dh,022h,03Fh
    db 021h,01Dh,03Fh,025h,019h,03Fh,029h,015h
    db 03Fh,02Dh,011h,03Fh,032h,00Dh,03Fh,036h
    db 008h,03Fh,03Ah,004h,03Fh,03Eh,000h,03Fh

    db 000h,011h,011h,000h,014h,014h,000h,017h
    db 017h,000h,01Ah,01Ah,000h,01Dh,01Dh,000h
    db 020h,020h,000h,023h,023h,000h,026h,026h
    db 000h,02Ah,02Ah,000h,02Dh,02Dh,000h,030h
    db 030h,000h,033h,033h,000h,036h,036h,000h
    db 039h,039h,000h,03Ch,03Ch,000h,03Fh,03Fh

    db 03Fh,000h,000h,03Fh,000h,00Dh,03Fh,000h
    db 019h,03Eh,000h,026h,03Eh,000h,032h,03Eh
    db 000h,03Fh,032h,000h,03Fh,025h,000h,03Fh
    db 019h,000h,03Fh,00Ch,000h,03Fh,000h,000h
    db 03Fh,000h,00Dh,03Fh,000h,019h,03Fh,000h
    db 026h,03Fh,000h,032h,03Fh,000h,03Fh,03Fh

    db 000h,03Fh,032h,000h,03Fh,026h,000h,03Fh
    db 019h,000h,03Fh,00Dh,000h,03Fh,000h,00Dh
    db 03Fh,000h,019h,03Fh,000h,026h,03Fh,000h
    db 032h,03Fh,000h,03Fh,03Fh,000h,03Fh,032h
    db 000h,03Fh,026h,000h,03Fh,019h,000h,03Fh
    db 00Dh,000h,03Fh,000h,000h,000h,000h,000h
