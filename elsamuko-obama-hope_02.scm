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
    ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    ; GNU General Public License for more details.
    ;
    ; You should have received a copy of the GNU General Public License
    ; along with this program; if not, write to the Free Software
    ; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
    ; http://www.gnu.org/licenses/gpl-3.0.html 
    ;
    ; Copyright (C) 2008 elsamuko <elsamuko@web.de>
    ;
    ; Version 0.1 - First hack
    ; Version 0.2 - Seperated smoothness option to corn and smoothness
    ;
    
    
(define (elsamuko-obama-hope aimg adraw
                    smooth
                    corn
                    frame ;thickness
                    yellow
                    threshold1 color1 pattern
                    threshold2 color2
                    threshold3 color3
                    threshold4 color4
                                                )
    (let* (
            (img (car (gimp-drawable-get-image adraw)))
            (owidth (car (gimp-image-width img)))
            (oheight (car (gimp-image-height img)))
            (yellowlayer (car (gimp-layer-new img
                            owidth
                            oheight
                            1
                            "Yellow"
                            100
                            LAYER-MODE-NORMAL)))
            (framelayer (car (gimp-layer-new img
                                owidth
                                oheight
                                1
                                "Frame"
                                100
                                LAYER-MODE-NORMAL)))
            ;treshholds
            (layer1 0)
            (layer2 0)
            (layer3 0)
            (layer4 0)
            ;selections
            (layer1b (car (gimp-layer-new img owidth oheight
                                1
                                "1 Fill"
                                100
                                LAYER-MODE-NORMAL)))
            (layer2b (car (gimp-layer-new img
                                owidth
                                oheight
                                1
                                "2 Fill"
                                100
                                LAYER-MODE-NORMAL)))
            (layer3b (car (gimp-layer-new img
                                owidth
                                oheight
                                1
                                "3 Fill"
                                100
                                LAYER-MODE-NORMAL)))
            (layer4b (car (gimp-layer-new img
                                owidth
                                oheight
                                1
                                "4 Fill"
                                100
                                LAYER-MODE-NORMAL)))
        )
        
        ;init
        (gimp-context-push)
        (gimp-image-undo-group-start img)
        (if (= (car (gimp-drawable-has-alpha adraw )) FALSE)
            (gimp-layer-add-alpha adraw)
        )
        (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
            (gimp-image-convert-rgb img)
        )
        (gimp-context-set-foreground yellow)
        (gimp-context-set-background '(255 255 255))
        
        ;copy and add blurred original
        (if (> smooth 0)
            (plug-in-gauss 1 img adraw smooth smooth 0)
        )
        (set! layer1 (car(gimp-layer-copy adraw FALSE)))
        (set! layer2 (car(gimp-layer-copy adraw FALSE)))
        (set! layer3 (car(gimp-layer-copy adraw FALSE)))
        (set! layer4 (car(gimp-layer-copy adraw FALSE)))
        (gimp-image-insert-layer img layer1 0 -1)
        (gimp-image-insert-layer img layer2 0 -1)
        (gimp-image-insert-layer img layer3 0 -1)
        (gimp-image-insert-layer img layer4 0 -1)
        (gimp-drawable-set-name layer1 "1")
        (gimp-drawable-set-name layer2 "2")
        (gimp-drawable-set-name layer3 "3")
        (gimp-drawable-set-name layer4 "4")
        
        ;add yellow color layer
        (gimp-context-set-foreground yellow)
        (gimp-image-insert-layer img yellowlayer 0 -1)
        (gimp-drawable-fill yellowlayer FILL-TRANSPARENT)
        (gimp-selection-all img)
        (gimp-edit-bucket-fill yellowlayer BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ;add image layers
        (gimp-image-insert-layer img layer1b 0 -1)
        (gimp-drawable-fill layer1b FILL-TRANSPARENT)
        (gimp-image-insert-layer img layer2b 0 -1)
        (gimp-drawable-fill layer2b FILL-TRANSPARENT)
        (gimp-image-insert-layer img layer3b 0 -1)
        (gimp-drawable-fill layer3b FILL-TRANSPARENT)
        (gimp-image-insert-layer img layer4b 0 -1)
        (gimp-drawable-fill layer4b FILL-TRANSPARENT)
        
        ;stripes layer
        (gimp-threshold layer1 threshold1 255)
        ;;(gimp-by-color-select layer1 '(0 0 0) 0 CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
        (gimp-image-select-color img CHANNEL-OP-REPLACE layer1  '(0 0 0) )
        (if (> corn 0)
            (gimp-selection-grow img corn)
            (gimp-selection-shrink img corn)
        )
        (gimp-context-set-pattern pattern)
        (gimp-edit-bucket-fill layer1b BUCKET-FILL-PATTERN LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        ;;(gimp-by-color-select layer1b '(0 0 0) 0 CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
        (gimp-image-select-color img CHANNEL-OP-REPLACE layer1b '(0 0 0) )
        (gimp-context-set-foreground color1)
        (gimp-edit-bucket-fill layer1b FG-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ;2nd layer
        (gimp-threshold layer2 threshold2 255)
        (gimp-by-color-select layer2 '(0 0 0) 0 CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
        (if (> corn 0)
            (gimp-selection-grow img corn)
            (gimp-selection-shrink img corn)
        )
        (gimp-context-set-foreground color2)
        (gimp-edit-bucket-fill layer2b BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ;3rd layer
        (gimp-threshold layer3 threshold3 255)
        ;;(gimp-by-color-select layer3 '(0 0 0) 0 CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
        (gimp-image-select-color img CHANNEL-OP-REPLACE layer3 '(0 0 0) )
        (if (> corn 0)
            (gimp-selection-grow img corn)
            (gimp-selection-shrink img corn)
        )
        (gimp-context-set-foreground color3)
        (gimp-edit-bucket-fill layer3b BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ;4th layer
        (gimp-threshold layer4 threshold4 255)
        ;;(gimp-by-color-select layer4 '(0 0 0) 0 CHANNEL-OP-REPLACE TRUE FALSE 0 FALSE)
        (gimp-image-select-color img CHANNEL-OP-REPLACE  layer4 '(0 0 0) )
        (if (> corn 0)
            (gimp-selection-grow img corn)
            (gimp-selection-shrink img corn)
        )
        (gimp-context-set-foreground color4)
        (gimp-edit-bucket-fill layer4b BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ;add frame layer
        (gimp-context-set-foreground yellow)
        (gimp-image-insert-layer img framelayer 0 -1)
        (gimp-drawable-fill framelayer FILL-TRANSPARENT)
        (gimp-selection-all img)
        (gimp-selection-shrink img frame)
        (gimp-selection-invert img)
        (gimp-edit-bucket-fill framelayer BUCKET-FILL-FG LAYER-MODE-NORMAL 100 0 FALSE 0 0)
        (gimp-selection-none img)
        
        ; tidy up
        (gimp-selection-none img)
        (gimp-image-undo-group-end img)
        (gimp-displays-flush)
        (gimp-context-pop)
    )
)
 
(script-fu-register "elsamuko-obama-hope"
    "Obama Hope"
    "Shadow Style Portrait. Similar to Obama Hope poster.\n
    file: elsamuko-obama-hope_02.scm"
    "elsamuko <elsamuko@web.de>"
    "elsamuko"
    "20.02.2009"
    "*"
    SF-IMAGE "Input image"          0
    SF-DRAWABLE "Input drawable"    0
    SF-ADJUSTMENT _"Smoothness"     '(10 0 50 1 10 0 0)
    SF-ADJUSTMENT _"Corn Size"      '(2 0 50 1 10 0 0)
    SF-ADJUSTMENT _"Frame Thickness"    '(16 1 500 1 10 0 0)
    SF-COLOR _"Basic Color"             '(253 229 169) ;yellow
    SF-ADJUSTMENT _"Threshold 1"        '(220 0 255 1 10 0 0)
    SF-COLOR _"Color 1"                 '(113 150 159) ;blue
    SF-PATTERN "Pattern"                "Stripes Fine"
    SF-ADJUSTMENT _"Threshold 2"        '(200 0 255 1 10 0 0)
    SF-COLOR _"Color 2"                 '(113 150 159) ;blue
    SF-ADJUSTMENT _"Threshold 3"        '(150 0 255 1 10 0 0)
    SF-COLOR _"Color 3"                 '(215 26 33) ;red
    SF-ADJUSTMENT _"Threshold 4"        '(100 0 255 1 10 0 0)
    SF-COLOR _"Color 4"                 '( 0 50 77) ;dark
)
    
(script-fu-menu-register "elsamuko-obama-hope" "<Image>/Script-Fu/Artistic")

;end of script 