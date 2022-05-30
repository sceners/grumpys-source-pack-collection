

TYPE
   TCfg = ARRAY [1..10] OF WORD;

VAR
   fi  : FILE OF TCfg;
   fo  : TEXT;
   cfg : TCfg;
   i   : INTEGER;

BEGIN
   Assign(fi, 'GLOBE.DAT');
   Reset(fi);

   Assign(fo, 'GLOBECFG.INC');
   ReWrite(fo);
   WriteLn(fo, ';  Default configurations for globe. ------------');
   WriteLn(fo);
   WriteLn(fo, ';     Phi    Alp    Rho IncPhi IncAlp IncRho GapPhi GapAlp  SizeH  SizeV');
   Write  (fo, ';   --------------------------------------------------------------------');
   WHILE NOT Eof(fi) DO BEGIN
      Read(fi, cfg);
      WriteLn(fo);
      Write(fo, ' DW ', cfg[1] : 5);
      FOR i := 2 TO 10 DO
         Write(fo, ', ', cfg[i] : 5);
   END;
   WriteLn(fo);
   Close(fo);
   Close(fi);
END.