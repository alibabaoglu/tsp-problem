(defpackage CSV-Reader
  (:use COMMON-LISP)
  (:nicknames CSV)
  (:export read_csv)
  )

(in-package CSV-Reader)
(defun read_csv (filename delim-char)
  (with-open-file (input filename)
    (loop :for line := (read-line input nil) :while line
          :collect (split(first (read-from-string
                    (substitute #\SPACE delim-char
                                (format nil "(~a)~%" line)))))))
)

(defun split (string &key (delimiterp #'delimiterp))
  (loop :for beg = (position-if-not delimiterp string)
    :then (position-if-not delimiterp string :start (1+ end))
    :for end = (and beg (position-if delimiterp string :start beg))
    :when beg :collect (subseq string beg end)
    :while end)
    
)
(defun delimiterp (c) (position c " ;/"))




