
VAR
   fo : TEXT;
   i  : INTEGER;

BEGIN
   Assign(fo, 'COSTBL.INC');
   ReWrite(fo);
   WriteLn(fo, ';   Costable, angles 0-1023, Modulo 32767+32767 ------------');
   FOR i := 0 TO 1023 DO BEGIN
      IF (i MOD 12) = 0 THEN BEGIN
         WriteLn(fo);
         Write(fo, '        DW ');
      END ELSE
         Write(fo, ', ');
      Write(fo, WORD(ROUND(32767.0*Cos(i*PI/512.0))))
   END;
   WriteLn(fo);
   Close(fo)
END.