; externals for routines from xmouse.inc

        extrn  show_mouse:near    ; show_mouse(int x,int y)
        extrn  get_mouse_position:near
        extrn  plot_mouse:near
        extrn  remove_mouse:near
        extrn  instant_mouse:near

        extrn  mousex:word
        extrn  mousey:word
        extrn  mbuttons:word
        extrn  ismouse:word              ; 0 = mouse present

