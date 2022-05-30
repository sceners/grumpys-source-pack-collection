program cursortest;
uses cursor1;
begin
 writeln(cursor1.maxSize);
 cursor1.setSize(cursor1.maxSize); readln;        {block}
 cursor1.setSize(0); readln;                     {hidden}
 cursor1.setSize(cursor1.maxSize div 2); readln;   {half}
 cursor1.setSize(2); readln;                     {normal}
 end.