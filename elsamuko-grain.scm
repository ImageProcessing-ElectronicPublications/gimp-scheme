; The GIMP -- an image manipulation program  
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
; http://www.gnu.org/licenses/gpl-3.0.html
;
; Copyright (C) 2008 elsamuko <elsamuko@web.de>
;
; Version 0.1 - Adding Film Grain after: http://www.gimpguru.org/Tutorials/FilmGrain/
;


(define (elsamuko-grain aimg adraw holdness value strength grainblur blackwhite)
  (let* (
            (img (car (gimp-item-get-image adraw)))
            (owidth (car (gimp-image-width img)))
            (oheight (car (gimp-image-height img)))
            (bw-layer (car (gimp-layer-copy adraw FALSE)))
            (grainlayer (car (gimp-layer-new img
                                          owidth 
                                          oheight
                                          1
                                          "Grain" 
                                          100 
                                          LAYER-MODE-OVERLAY)))
            (grainlayermask (car (gimp-layer-create-mask grainlayer ADD-MASK-WHITE)))
            (floatingsel 0)
        )
        
    ; init
    (define (set-pt a index x y)
        (begin
            (aset a (* index 2) x)
            (aset a (+ (* index 2) 1) y)
        )
    )
    (define (splineValue)
      (let* ((a (cons-array 6 'double)))
        (set-pt a 0 0 0) ; was 0 0
        (set-pt a 1 0.501 (/ strength 255)) ; was 128 and strength
        (set-pt a 2 1.00 0.00) ; was 255 0
        a
      )
    )
    
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
    )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    
    ;optional b/w
    (if(= blackwhite TRUE)
        (begin
            (gimp-image-insert-layer img bw-layer 0 -1)
            (gimp-item-set-name bw-layer "B/W")
            (gimp-drawable-desaturate bw-layer DESATURATE-LIGHTNESS)
        )
    )
    
    ;fill new layer with neutral gray
    (gimp-image-insert-layer img grainlayer 0 -1)
    (gimp-drawable-fill grainlayer FILL-TRANSPARENT)
    (gimp-context-set-foreground '(128 128 128))
    (gimp-selection-all img)
    (gimp-edit-bucket-fill grainlayer BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
    (gimp-selection-none img)
    
    ;add grain and blur it
    (plug-in-hsv-noise 1 img grainlayer holdness 0 0 value) ;was scatter-hsv
    (if (> grainblur 0)
        (begin
            (plug-in-gauss 1 img grainlayer grainblur grainblur 1)
        )
    )
    (gimp-layer-add-mask grainlayer grainlayermask)
    
    ;select the original image, copy and paste it as a layer mask into the grain layer
    (gimp-selection-all img)
    (gimp-edit-copy adraw)
    (set! floatingsel (car (gimp-edit-paste grainlayermask TRUE)))
    (gimp-floating-sel-anchor floatingsel)
    
    ;set color curves of layer mask, so that only gray areas become grainy
    (gimp-drawable-curves-spline grainlayermask  HISTOGRAM-VALUE  6 (splineValue))
    
    ; tidy up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    (gc) ; garbage collect as an array was used.
  )
)

(script-fu-register "elsamuko-grain"
                    "Film Grain"
                    "Simulating Film Grain.
\nfile:elsamuk-grain.scm"
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "13/08/08"
                    "*"
                    SF-IMAGE        "Input image"          0
                    SF-DRAWABLE     "Input drawable"       0
                    SF-ADJUSTMENT   "Holdness"      '(2 1 8 1 2 0 0)
                    SF-ADJUSTMENT   "Value"         '(100 0 255 1 10 0 0)
                    SF-ADJUSTMENT   "Strength"      '(128 0 255 1 10 0 0)
                    SF-ADJUSTMENT   "Grain Blur"    '(1 0 3 0.1 0.2  1 0)
                    SF-TOGGLE       "Desaturate Image" FALSE
)

(script-fu-menu-register "elsamuko-grain" "<Toolbox>/Script-Fu/Noise")

;end of script