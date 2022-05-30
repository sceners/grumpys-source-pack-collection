;; **********************************************************************
;;
;;                LL_1.ASM - Unchained Video Mode Routines
;;
;;                Copyright (C) 1993 Logical Gaming Systems
;;                           All Rights Reserved
;;
;; **********************************************************************
;; Routines:
;;
;; void ll_init(); Hard code LL_HOR for video page width.
;;
;; **********************************************************************
.model huge,c
include LL_M.INC                ;; Include all of our MACROS
.data

	MM      equ     6
	LL_HOR  equ     320

	LL_SHOW dw      0       ;; Offset of Show Page
	LL_DRAW dw      16000   ;; Offset of Draw Page
	LL_BACK dw      32000   ;; Offset of Back Page

.code
include ll_init.inc             ;; ll_xinit()
include ll_land.inc             ;; land_clr() land_put(buf,x,y,w,a);
include ll_page.inc             ;; ll_page()
include ll_key.inc              ;; ll_keyswap() ll_keyget() ll_keyhit()
include ll_pal.inc              ;; Bunch of routines for pal manipulation.
include ll_sin.inc              ;; ll_sin() ll_cos()
include fractal.inc             ;; ll_data mesh data
	end

