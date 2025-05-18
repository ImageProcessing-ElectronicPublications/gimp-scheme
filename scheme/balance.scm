;
; (gimp-layer-set-mode layer-base SCREEN-MODE)
; NORMAL-MODE 0
; DISSOLVE-MODE 1
; BEHIND-MODE 2
; MULTIPLY-MODE 3
; SCREEN-MODE 4
; OVERLAY-MODE 5
; DIFFERENCE 6
; ADDITION-MODE 7
; SUBTRACT-MODE 8
; DARKEN-ONLY-MODE 9
; LIGHTEN-ONLY-MODE10
; HUE-MODE 11
; SATURATION-MODE 12
; COLOR-MODE 13
; VALUE-MODE 14
; DIVIDE-MODE 15
; DODGE-MODE 16
; BURN-MODE 17
; HARDLIGHT-MODE 18
; SOFTLIGHT-MODE 19
; GRAIN-EXTRACT-MODE 20
; GRAIN-MERGE-MODE 21
; COLOR-ERASE-MODE 22

(define (balance image 
                 drawable
                 radius)
    (let*
        (
            (drawable  (car (gimp-image-active-drawable image)))
            (layer-base (car (gimp-layer-copy drawable TRUE)))
            (layer-blur1 (car (gimp-layer-copy drawable TRUE)))
            (layer-blur2 (car (gimp-layer-copy drawable TRUE)))
            (radius2 (+ radius radius))
            (layer-blur1n (car (gimp-layer-copy drawable TRUE)))
            (layer-blur2n (car (gimp-layer-copy drawable TRUE)))
        )
    
        (gimp-image-undo-group-start image)
    
        (set! layer-base (car (gimp-layer-new-from-visible image image "balance")))
        (set! layer-blur1 (car (gimp-layer-copy layer-base TRUE)))
        (set! layer-blur2 (car (gimp-layer-copy layer-base TRUE)))
        (gimp-image-insert-layer image layer-base 0 -1)
        (gimp-image-insert-layer image layer-blur1 0 -1)
        (gimp-image-insert-layer image layer-blur2 0 -1)
        (plug-in-gauss TRUE image layer-blur1 radius radius 0)
        (plug-in-gauss TRUE image layer-blur2 radius2 radius2 0)
        (set! layer-blur1n (car (gimp-layer-copy layer-blur1 TRUE)))
        (gimp-image-insert-layer image layer-blur1n 0 -1)
        (gimp-drawable-invert layer-blur1n FALSE)
        (set! layer-blur2n (car (gimp-layer-copy layer-blur2 TRUE)))
        (gimp-image-insert-layer image layer-blur2n 0 -1)
        (gimp-drawable-invert layer-blur2n FALSE)
        (gimp-image-lower-item image layer-blur1n)
        (gimp-image-lower-item image layer-blur2n)
        (gimp-image-lower-item image layer-blur2n)
        (gimp-image-lower-item image layer-blur2n)
        (gimp-layer-set-mode layer-blur1 OVERLAY-MODE)
        (set! layer-blur1 (car (gimp-image-merge-down image layer-blur1 EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode layer-blur2 OVERLAY-MODE)
        (set! layer-blur2 (car (gimp-image-merge-down image layer-blur2 EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode layer-blur1 OVERLAY-MODE)
        (set! layer-base (car (gimp-image-merge-down image layer-blur1 EXPAND-AS-NECESSARY)))
        (gimp-layer-set-mode layer-blur2 OVERLAY-MODE)
        (set! layer-base (car (gimp-image-merge-down image layer-blur2 EXPAND-AS-NECESSARY)))

        (gimp-displays-flush)

        (gimp-image-undo-group-end image)
    )
)

(script-fu-register "balance"
                    "_Balance"
                    "Balance filter"
                    "zvezdochiot https://github.com/zvezdochiot"
                    "This is free and unencumbered software released into the public domain."
                    "2025-05-13"
                    "*"
                    SF-IMAGE       "Image"       0
                    SF-DRAWABLE    "Drawable"    0
                    SF-VALUE       "Radius"      "25"
)

(script-fu-menu-register "balance" "<Image>/Colors/Auto")
