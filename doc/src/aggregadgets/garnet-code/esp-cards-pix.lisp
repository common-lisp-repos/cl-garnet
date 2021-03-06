(in-package "USER" :use '("LISP" "KR" "GARNET-DEBUG"))

(when (boundp 'WIN) (opal:destroy WIN))

(create-instance 'WIN inter:interactor-window
   (:left 700)(:top 10)(:width 340)(:height 120))
(s-value WIN :aggregate (create-instance 'TOP-AGG opal:aggregate))
(opal:update WIN)

;; This function generates an object that can be used as a label for
;; a component of ALIST.  Be careful not to choose a Garnet prototype
;; such as opal:circle for the item, since this function will use that
;; object as the label.
;;
(defun Get-Label-In-Aggrelist (agg)
  (let ((alist (g-value agg :parent)))
    (if alist  ;; The item-prototype has no parent
	(let* ((item (g-value agg :item))
	       (new-label (if (schema-p item)
			      (if (g-value item :parent)
				  ;; The item has been used already --
				  ;; Use it as a prototype
				  (create-instance NIL item)
				  ;; Use the item itself
				  item)
			      (create-instance NIL opal:text
				(:string item)
				(:font (opal:get-standard-font
					:sans-serif :bold :very-large))))))
	  (s-value new-label :left
		   (o-formula (+ (gvl :parent :left)
				 (round (- (gvl :parent :width)
					   (gvl :width)) 2))))
	  (s-value new-label :top
		   (o-formula (+ (gvl :parent :top)
				 (round (- (gvl :parent :height)
					   (gvl :height)) 2))))
	  new-label)
        ;; Give the item-prototype a bogus part
        (create-instance NIL opal:null-object))))


(create-instance 'CIRCLE-LABEL opal:circle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))

(create-instance 'SQUARE-LABEL opal:rectangle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))

(create-instance 'PLUS-LABEL opal:aggregadget
  (:width 30) (:height 30)
  (:parts
   `((:rect1 ,opal:rectangle
      (:left ,(o-formula (+ 10 (gvl :parent :left))))
      (:top ,(o-formula (gvl :parent :top)))
      (:width 10) (:height 30)
      (:line-style NIL) (:filling-style ,opal:black-fill))
     (:rect2 ,opal:rectangle
      (:left ,(o-formula (gvl :parent :left)))
      (:top ,(o-formula (+ 10 (gvl :parent :top))))
      (:width 30) (:height 10)
      (:line-style NIL) (:filling-style ,opal:black-fill)))))

(create-instance 'STAR-LABEL opal:polyline
  (:width 30) (:height 30)
  (:point-list (o-formula
		(let* ((width (gvl :width))    (width/5 (round width 5))
		       (height (gvl :height))  (x1 (gvl :left))
		       (x2 (+ x1 width/5))     (x3 (+ x1 (round width 2)))
		       (x5 (+ x1 width))       (x4 (- x5 width/5))
		       (y1 (gvl :top))         (y2 (+ y1 (round height 3)))
		       (y3 (+ y1 height)))
		  (list x3 y1  x2 y3  x5 y2  x1 y2  x4 y3  x3 y1))))
  (:line-style opal:line-2))
			    

(create-instance 'ALIST opal:aggrelist
  (:left 10) (:top 20)
  (:items (list CIRCLE-LABEL SQUARE-LABEL "W" PLUS-LABEL STAR-LABEL))
  (:direction :horizontal)
  (:item-prototype
   `(,opal:aggregadget
     (:item ,(o-formula (nth (gvl :rank) (gvl :parent :items))))
     (:width 60) (:height 80)
     (:parts
      ((:frame ,opal:rectangle
	       (:left ,(o-formula (gvl :parent :left)))
	       (:top ,(o-formula (gvl :parent :top)))
	       (:width ,(o-formula (gvl :parent :width)))
	       (:height ,(o-formula (gvl :parent :height))))
       (:label ,#'Get-Label-In-Aggrelist))))))

(opal:add-components TOP-AGG ALIST)
(opal:update WIN)
