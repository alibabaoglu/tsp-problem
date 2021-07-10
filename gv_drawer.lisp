
(load "C:/Users/AliBa/quicklisp/setup.lisp")
(ql:quickload :inferior-shell)

(defpackage GV
  (:use COMMON-LISP)
  (:nicknames GV)
  (:export draw_route)
  (:export draw_one_route)
  
  )

(in-package GV)
(defun draw_one_route (NNH)
"This function receives NNH route. It then creates a .dot file with the content of the  NNH Route. 
After the .dot file is created, a shell command is used to create an image of the one route from the .dot file"
    (with-open-file (str "./graphRoute.dot"
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)
  (format str "digraph g {


A [shape=point,pos = \"4,-4!\"]
B [shape =point,pos = \"6,-4!\"]
A->B[label=\"NNH\",color=red]


~A [shape=box,style=filled]
~A  [color=red]
  }"
    (car NNH)
    (createRoute NNH)
   ))
(inferior-shell:run/ss "dot -Kfdp -n -Tpng -o sampl1e.png graphRoute.dot")
)

(defun draw_route (NNH OR)
"This function receives the optimal and NNH route. It then creates a .dot file with the contents of the optimal Route and NNH Route. 
After the .dot file is created, a shell command is used to create an image of the two routes from the .dot file"
    (with-open-file (str "./graphRoute.dot"
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)
  (format str "digraph g {


A [shape=point,pos = \"4,-4!\"]
B [shape =point,pos = \"6,-4!\"]
C [shape=point,pos = \"4,-3!\"]
D [shape =point,pos = \"6,-3!\"]
A->B[label=\"NNH\",color=red]
C->D[label=\"OR\",color=blue]

~A
~A [shape=box,style=filled]
~A  [color=red]
~A [color=blue]
  }"(createPos OR)
    (car NNH)
    (createRoute NNH)
    (createRoute OR)
   ))
(inferior-shell:run/ss "dot -Kfdp -n -Tpng -o sampl1e.png graphRoute.dot")
)

(defun createRoute(route)
"This function is passed a route. 
 From this route a new route is created according to the Graphviz format, i.e. city1 --> city2 --> city3 and so on."
  (format nil "~{~A~^->~}~%" route) 
)

(defun createPos(route)
"This function is passed a route. For a suitable representation, this route is displayed in a 
 rectangle. This format is then also written to the .dot file"
(setq list '(""))
(setq counter 0)
(setq x 0)
(setq y 0)
(setq length (list-length route))
(dolist (n route)
(if (< counter (/ length 2))
    (setq x(+ x 4))
   (progn
   (setq y -4) 
   (setq x(- x 4))
   ))
(push (format nil "~A~^[pos = \"~D,~D!\"] ~%" (car route) x y) list )
(setq route (cdr route))
(incf counter)
)
(format nil "~{~A~}" list)
)




