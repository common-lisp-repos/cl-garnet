;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: DEMO-ANIMATOR; Base: 10 -*-

(in-package :gem)

(defparameter agg nil)

(defun get-x-window-drawable (win)
  (gv win :drawable))

(defparameter *pixmap-array* nil)

(defun draw-on-window (pixmap-array x value)
    (setf (aref pixmap-array (* x 4)) (first value))
    (setf (aref pixmap-array (+ (* x 4) 1)) (second value))
    (setf (aref pixmap-array (+ (* x 4) 2)) (third value))
    (setf *pixmap-array* pixmap-array))

(defun transfer-surface-window (win cl-vector-image)
  (let* ((height (gv win :height))
	 (width (gv win :width))
	 (drawable (get-x-window-drawable win))
	 (pixmap-array (xlib:get-raw-image
			drawable
			:x 0
			:y 0
			:width width
			:height height
			:format :z-pixmap)))
    (dotimes (i (* height width))
      (draw-on-window
       pixmap-array
       i
       (list
	(row-major-aref cl-vector-image (* i 3))
	(row-major-aref cl-vector-image (+ (* i 3) 1))
	(row-major-aref cl-vector-image (+ (* i 3) 2)))))
    (xlib:put-raw-image (gv win :drawable)
    			(xlib:create-gcontext :drawable drawable)
    			pixmap-array
    			:depth (xlib:drawable-depth (get-x-window-drawable win))
    			:x 0
    			:y 0
    			:width width
    			:height height
    			:format :z-pixmap))
  (xlib:display-finish-output (gem::the-display win)))

(defun create-surface  (width height background-rgb)
  (let ((state (aa:make-state))
	(image (aa-misc:make-image width height background-rgb)))
  (values state image)))
