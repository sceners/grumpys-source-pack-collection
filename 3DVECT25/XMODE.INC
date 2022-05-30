; externals for routines from xmode.inc

        extrn  screen_width:word
        extrn  screen_height:word

        extrn  last_page:word
        extrn  page_addr:word

        extrn  page_size:word

        extrn  display_page:word
        extrn  active_page:word

        extrn  current_page:dword

        extrn  current_xoffset:word
        extrn  current_yoffset:word

        extrn  current_moffset:dword

        extrn  max_xoffset:word
        extrn  max_yoffset:word

        extrn  charset_low:dword
        extrn  charset_hi:dword

        extrn  left_clip_mask:byte
        extrn  right_clip_mask:byte

        extrn  set_vga_modex:near
        extrn  set_modex:near
        extrn  clear_vga_screen:near
        extrn  set_point:near
        extrn  read_point:near
        extrn  fill_block:near
        extrn  draw_line:near
        extrn  set_dac_register:near
        extrn  load_dac_registers:near
        extrn  read_dac_registers:near
        extrn  set_active_page:near
        extrn  get_active_page:near
        extrn  set_display_page:near
        extrn  get_display_page:near
        extrn  get_x_offset:near
        extrn  get_y_offset:near
        extrn  sync_display:near
        extrn  gprintc:near
        extrn  tgprintc:near
        extrn  print_str:near
        extrn  tprint_str:near
        extrn  set_display_font:near
        extrn  draw_bitmap:near
        extrn  tdraw_bitmap:near
        extrn  copy_page:near
        extrn  copy_bitmap:near
        extrn  mode03:near
        extrn  wipeoffpalette:near
        extrn  fadeoffpalette:near
        extrn  fadeonpalette:near
        extrn  turn_screen_off:near
        extrn  turn_screen_on:near

