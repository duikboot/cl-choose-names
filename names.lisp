;;;; names.lisp

(in-package #:names)


(defparameter *original* "names.db")
(defparameter *remaining* "results.db")

(defvar *db* '())

(defmacro while (test &body body)
 `(do ()
   ((not ,test))
   ,@body))

(defun random-elt (choices)
  "Choose an element from a list at random."
  (elt choices (random (length choices))))

(defun one-of (set)
  "Pick one element of set, and make a list of it."
  (random-elt set))


(defun take-n-names (n)
  (let ((names '()))
   (dotimes (i n)
     (push (one-of *db*) names))
   names))

(defun print-n-names (n)
  "Print n names with number"
  (let ((names (take-n-names n)))
    (terpri)
    (dotimes (i n)
      (format t "(~2d) ~A~%" (1+ i) (nth i names)))
    names))

(defun remove-from-db (item)
  "Remove name from database"
  (setf *db* (remove item *db* :test #'string-equal)))

(defun remove-but-n (n names)
  "Remove everything from names but the nth"
  (dotimes (i (length names))
    (when (not (= i n))
      (remove-from-db (nth i names))))
 t)

(defun choose (n)
 (let ((names (print-n-names n)))
  (format *query-io* "~%Choose a number to keep de name. <q>quit the program,")
  (format *query-io* "~%0 the delete all names.")
  (format *query-io* "~%Choose a number: ")
  (force-output *query-io*)
  (let ((answer (read)))
    (if (integerp answer) (remove-but-n (1- answer) names) nil))))


(defun get-file (filename)
  "Read whole file"
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
          while line
          collect line)))


(defun load-database ()
  "Load file into memory."
  (if (probe-file *remaining*)
    (setf *db* (get-file *remaining*))
    (setf *db* (get-file *original*))))

(defun save-db (filename)
  "Save current *db* to file."
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede)
    (format out "~{~A~%~}" *db*)))


(defun format-totals ()
  (terpri)
  (terpri)
  (format t "================================~%")
  (format t "=~10d names left         =~%" (length *db*))
  (format t "================================~%")
  (terpri))

(defun run (n)
  (while (choose n)
    (format-totals)))

(defun print-usage ()
  (princ
   "Names
<number> is the number of names to process at a time.

Usage:
    $ names <number>
"))

(defun main (&optional n &rest argv)
  (declare (ignore argv))
  (load-database)
  (when n
    (format-totals)
    (run (parse-integer n))
    (save-db *remaining*)
    (format-totals)
    (uiop:quit 0))
  (print-usage)
  (uiop:quit 1))


;;; vim: set ft=lisp lisp: