(defpackage :elisp
  (:use :common-lisp)
  (:export while
	   short-pi))

(in-package :elisp)


(defparameter unrch nil)

(defclass buffer-text ()
    ((dotloc :initarg :dotloc :initform nil :accessor dotloc)
     (p1 :initarg :p1 :initform nil :accessor p1)
     (p2 :initarg :p2 :initform nil :accessor p2)
     (size1 :initarg :size1 :initform nil :accessor size1)
     (size2 :initarg :size2 :initform nil :accessor size2)
     (tail-clip :initarg :tail-clip :initform nil :accessor tail-clip))
  )

(defclass elisp-t ()
  ())

(defclass elisp-object (elisp-t)
  ())

(defmethod readchar :around ((object elisp-object))
  (when unrch
    (let ((c unrch))
      (setf unrch nil)
      c)))

(defclass elisp-buffer (elisp-object)
    ((text :initarg :text :initform nil :accessor text)))

(defmethod readchar ((buffer elisp-buffer))
    (unless (call-next-method)
    (format t "got a value")))


(defmethod readchar ((buffer elisp-buffer))
  )

(defclass elisp-marker (elisp-object)
    ((text :initarg :text :initform nil :accessor text)))

(defmethod readchar ((marker elisp-marker))
  )

(defclass elisp-stream (elisp-object)
    ())

(defmethod readchar ((stream elisp-stream))
  )

(defclass elisp-string (elisp-object)
    ())

(defmethod readchar ((string elisp-string))
  )

(defclass elisp-function (elisp-object)
    ())

(defmethod readchar ((function elisp-function))
  (unless (call-next-method)
    (format t "got a value")))
