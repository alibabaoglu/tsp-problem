;;;This program calculates the Nearest-Neighbour and the Optimal-Route for a given set of data 
;;;If you have problems with the program or do not know how to use the program then read the >>README.md <<.


(load "./csv.lisp")
(load "./gv_drawer.lisp")

(defun get_cities (data)
"This function gets as parameter a list in which cities are stored in the format(cityX cityY distance).
 then the whole list is searched and all upcoming cities are stored in the list cities and returned."
    (setq cities '())
    (dolist (n data)
        (push (first n) cities)
        (push (second n) cities))
    (remove-duplicates cities :test #'equal))

(defun nearest_neighbour_heuristik(cities city)
"Creates a tour according to the nearest sneighbour heuristic. 
 So the method searches for the nearest neighbor from any city and stores it in the variable NNH_route. 
 Then the next neighbor of the last found city is searched again. This process is repeated until all cities are visited."
    (let 
    ((besucht '())
    (NNH_route (list city))
    (counter 0))
    (loop while (< counter (list-length cities))
        do (setq min_cost MOST-POSITIVE-LONG-FLOAT )
        do (dolist (n *data*)
            (if (and (or (string= city (first n)) (string= city (second n))) (null (member-nested (first n) besucht))(null (member-nested (second n) besucht)))
                (cond ((< (parse-integer (third n))  min_cost)
                    (setq min_cost (parse-integer (third n)))
                    (setq next_neighbour (first n)) 
                    (cond ((string= city next_neighbour) 
                        (setq next_neighbour (second n))))))))

        (push next_neighbour NNH_route)
        (push city besucht )
        (setq city next_neighbour)
        (incf counter))

    (push (car (last NNH_route)) NNH_route)
    (setq NNH_route (reverse NNH_route))))


(defun get_optimal_tour(all_permutations start)
"Compare all combinations of a certain number of cities
regarding their costs. The tour with the lowest cost will be returned"

    (setq min_cost MOST-POSITIVE-LONG-FLOAT )
    (setq best_route '())
    (dolist (n all_permutations)
        (push start n)
        (setq n (reverse (append (list start) (reverse n))))
        (setq cost (get_distance_of_tour n))
        (cond ((< cost min_cost)
            (setq min_cost cost)
            (setq best_route n))))

    best_route)

(defun permutations (data)
  "Return a list of all the permutations of the input."
  (if (null data)
      '(())
      (mapcan #'(lambda (e)
                  (mapcar #'(lambda (p) (cons e p))
                          (permutations
                            (remove e data :count 1 :test #'eq))))
              data))) 

(defun get_distance(city1 city2 route)
  "Returns the distance between two cities"
    (cond 
    ((null route) nil)
    ((or (and (string= city1 (caar route)) (string= city2 (second (car route) )))
    (and (string= city1 (second (car route) )) (string= city2 (caar route))) )
        (third (car route)))
    (t (get_distance city1 city2 (cdr route)))))

(defun get_distance_of_tour(tour)
"Returns the total path-length of a tour"
    (cond 
    ((null (cdr tour)) 0)
    (t (+ (parse-integer (get_distance (first tour) (second tour) *data*)) (get_distance_of_tour (cdr tour))))))


    (defun member-nested (element list)
    "This function tests if a certain element is in a list"
      (cond
       ((null list) nil)
       ((equal element (car list)) t)
       ((consp (car list)) (or (member-nested element (car list))
                            (member-nested element (cdr list))))
       (t (member-nested element (cdr list)))))


(defun main ()
"Main method responsible for function calls and a user menu"
    (setf *random-state* (make-random-state t))
    (format t '"Enter file with path:~%")
    (setq csvfile-path (read))
    (defvar *data* (csv:read_csv csvfile-path #\;))
    (setq cities (get_cities *data*))
    (format t " Would you like to select the start ctiy?~%") 
    (format t " [1] yes  [0] random : ")
    (setq choice (read))
    (terpri)
    (setq start (nth (random (list-length cities))cities))
    (if (eql choice 1 )
        (progn
        (format t " Choose a city from the cities: ~A~% "
            cities)
        (format t "Choice:")
         (setq start (read-line))))
    (terpri)

    (setq cities (remove start cities :test #'string=))
    (setq NNH (nearest_neighbour_heuristik cities start))
    (format t "NNH-tour: ~A | Path-length: ~D~% "
           NNH (get_distance_of_tour NNH))
    (cond ((< (list-length cities) 8)
    (setq all_permutations (permutations cities))
    (setq optimale_tour (get_optimal_tour all_permutations start))
    (print '-------------------------------------------------------------------------------------------------------------------)
    (terpri)
    (format t "Optimal-tour: ~A | Path-length: ~D.~% "
             optimale_tour (get_distance_of_tour optimale_tour))
    (terpri)
    (format t "The difference between the two tours is: ~D KM~% "
            (- (get_distance_of_tour NNH)(get_distance_of_tour optimale_tour) ))
     (gv:draw_route NNH optimale_tour))
     (t (gv:draw_one_route NNH))))
(main)
