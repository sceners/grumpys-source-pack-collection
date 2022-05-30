; these are tables of values for defining object locations
; sizes of tables = maxobjects

        extrn xs:dword,    ys:dword,    zs:dword
        extrn xadds:dword, yadds:dword, zadds:dword
        extrn vxs:word,    vys:word,    vzs:word
        extrn vxadds:word, vyadds:word, vzadds:word
        extrn lcount:word, acount:word
        extrn whatshape:word, userotate:byte, onoff:byte

; these are single values for defining the camera location

        extrn eyex:dword,     eyey:dword,     eyez:dword
        extrn eyeax:word,     eyeay:word,     eyeaz:word
        extrn eyexadds:dword, eyeyadds:dword, eyezadds:dword
        extrn eyevxadds:word, eyevyadds:word, eyevzadds:word
        extrn eyelcount:word, eyeacount:word

; misc data

        extrn background:word

        extrn vmatrix:dword
        extrn ematrix:dword

        extrn use_clear:word
        extrn wfollow:word
        extrn wherelook:word

; irq driven frame speed thing (frames to skip)

        extrn traces_past:word
        extrn frame_number:dword

; for scale routine

        extrn bitmap:dword
        extrn destwidth:word
        extrn destheight:word
        extrn destx:word
        extrn desty:word

; for fakeline routine

        extrn x1:word
        extrn y1:word
        extrn x2:word
        extrn y2:word

; for calling poly_fill (after calling fakeline)

        extrn colq:byte
        extrn steel:byte

; for windowing

        extrn lxupdate:word
        extrn lyupdate:word
        extrn xupdate:word
        extrn yupdate:word
        extrn makeorder:word
        extrn oney:word
        extrn firstbyte:word
        extrn lastbyte:word
        extrn showing:word

; misc routines from 3d.asm

        extrn flip_page:near
        extrn initpages:near
        extrn flip_page:near
        extrn fakeline:near
        extrn poly_fill:near
        extrn clear_fill:near
        extrn move_si:near
        extrn newfollow:near
        extrn resetupd:near
        extrn updvectors:near
        extrn makeobjs:near
        extrn make1obj:near
        extrn setsincose:near
        extrn look_at_it:near
        extrn calc_angles:near
        extrn get_displacement:near
        extrn put_object:near
        extrn set_angle:near
        extrn set_shape:near
        extrn set_object_on:near
        extrn set_object_off:near
        extrn set_makeorder:near
        extrn dv_middle:near
        extrn set_clip_absolute:near
        extrn set_clip_offset:near
        extrn drawvect:near
        extrn sort_list:near

; xscale1.inc

        extrn xscale1:near
        extrn xscale2:near
        extrn draw_scale:near
        extrn tdraw_scale:near
        extrn repeat_bitmap:near

; math.inc

        extrn make3d:near
        extrn erotate:near
        extrn rotate:near
        extrn arctan:near
        extrn cosign:near
        extrn sign:near
        extrn setsincose:near
        extrn compound:near
        extrn sqrt:near
        extrn set_precal7:near
        extrn set_precal147:near
        extrn frotate:near
        extrn fzsolve:near
        extrn z16x:near
        extrn z16z:near

        extrn precal1:dword
        extrn precal4:dword
        extrn precal7:dword

