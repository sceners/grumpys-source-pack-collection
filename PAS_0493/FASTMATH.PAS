{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 430 of 473
From : Erik Johnson                        1:104/28.0           13 Apr 93  19:52
To   : David Jirku
Subj : FAST MATH
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
>        I was just wondering how to speed up some math-intensive
>        routines I've got here. For example, I've got a function
>        that returns the distance between two objects:
>
>        Function Dist(X1,Y1,X2,Y2 : Integer) : Real;
>
>        BEGIN
>          Dist := Round(Sqrt(Sqr(X1-X2)+Sqr(Y1-Y2)));
>        END;
>
>        This is way to slow. I know assembly can speed it up, but
>        I know nothing about asm. so theres the problem. Please
>        help me out, any and all source/suggestions welcome!

X1, Y1, X2, Y2 are all integers.  Integer math is faster than Real (just
about anything is).  Sqr and Sqrt are not Integer functions.  Try for
fun...     }

Function Dist( X1, Y1, X2, Y2 : Integer ) : Real;
VAR XTemp, YTemp : INTEGER; {the allocation of these takes time.  If you
                             don't want that time taken, make them
                             global with care}
BEGIN
  XTemp := X1 - X2;
  YTemp := Y1 - Y2;
  Dist := Round( Sqrt( XTemp*XTemp + YTemp*YTemp ));
END;

If you have a math coprocessor or a 486dx, try using DOUBLE instead of
REAL, and make sure your compiler is set to compile for 287 (or 387).