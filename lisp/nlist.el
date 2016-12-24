(provide 'nlist)
;; provide support for intelligent cycling through lists.
;; list structure:
;; 	(compareFunction placeHolder list)
;;      
;;(defun nlist--get-compare-function(list)
;;  (car list))
;;(defun nlist--get-place-holder(list)
;;  (cadr list))
(defun nlist--get-contents(list)
  (cddr list))
;;(defun nlist--set-compare-function(list compareFunction)
;;  (setcar list compareFunction))
;;(defun nlist--set-place-holder(list placeHolder)
;;  (setcar (cdr list) placeHolder))
(defun nlist--set-contents(list contents)
  (setcdr (cdr list) contents))

(defun nlist-create(&optional compareFunction)
  ;;  (if (not compareFunction)
  ;;      (setq compareFunction 'string=))
  
  (setq compareFunction nil)
  
  
  (list compareFunction nil)
  )

(defun nlist-pop(list)
  (let(
       (contents	(nlist--get-contents list))
       top
       )
    (setq top (car contents))
    (nlist--set-contents list
                         (cdr contents)
                         )
    top
    )
  )
(defun nlist-current(list)
  (car (nlist--get-contents list))
  )
(defun nlist-raise-or-push(list item)
  (nlist-delete list item)
  (nlist-push list item)
  )
(defun nlist-push(list item)
  (let(
       (contents	(nlist--get-contents list))
       )
    (nlist--set-contents list
                         (if contents
                             (cons item contents)
                           (list item)
                           )
                         )
    )
  list
  )
(defun nlist-bury(list &optional item)
  (if (not item)
      (setq item (nlist-pop list))
    (nlist-delete list item)
    )
  (let(
       (contents	(nlist--get-contents list))
       )
    (nlist--set-contents list
                         (append contents
                                 (list item)
                                 )
                         )
    )
  list
  )
(defun nlist-delete(list item)
  (nlist--set-contents list
                       (delete item (nlist--get-contents list))
                       )
  )
(defun nlist-rotate2(L)
  (if (not L)
      nil
    (append (cdr L)
            (list (car L))
            )
    )
  )
(defun nlist-rotate(list &optional firstRotation)
  (let(
       (oldPrimary	(nlist-pop list))
       newPrimary
       contents
       newContents
       )
    (if firstRotation
        (progn
          (nlist-delete list "_PLACE_HOLDER_")
          (nlist-push list "_PLACE_HOLDER_")
          )
      )
    (setq contents	(nlist--get-contents list))
    (n-trace-list "contents initial" contents)
    (n-trace "\n")
    (while (not (equal  "_PLACE_HOLDER_" (car contents)))
      (or contents
          (error "nlist-rotate: no placeholder")
          )
      (n-trace-list "contents while top" contents)
      (n-trace "\n")
      (setq
       newContents	(cons
                         (car contents)
                         newContents
                         )
       contents 	(cdr contents)
       )
      )
    (setq newContents (cons oldPrimary newContents)
          contents	(cdr contents)	; advance past placeholder
          )
    (if contents
        (progn
          (setq newPrimary	(car contents)
                contents	(cdr contents)
                )
          )
      )
    (setq newContents	(nreverse newContents)
          newContents 	(append
                         (if newPrimary
                             (list newPrimary))
                         newContents
                         (list "_PLACE_HOLDER_")	;new placeholder
                         contents
                         )
          )
    (nlist--set-contents list newContents)
    (if (not newPrimary)
        (setq newPrimary (car newContents)))
    newPrimary
    )
  )
(defun nlist-uniq(li)
  (let(
       a
       )
    (while li
      (if (not (assoc (car li) a))
	  (setq a (cons (cons (car li)
			      nil
			      )
			a
			)
		)
	)
      (setq li (cdr li))
      )
    
    (nlist-get-keys-from-assoc a)
    ) 
  )

(defun nlist-get-keys-from-assoc(a)
  (let(
       li
       )
    (while a
      (setq li (cons (caar a) li)
	    a  (cdr a)
	    )
      )
    li
    )
  )


(defun nlist-set-elt(l1 n val)
  (let(
       (j 0)
       l2
       )
    (while l1
      (if (eq n j)
	  (setcar l1 val))
      (setq l2 (cons (car l1)
		     l2
		     )
	    l1	(cdr l1)
	    j	(1+ j)
	    )
      )
    (nreverse l2)
    )
  )
;;(nlist-set-elt (list "a" "b" "c") 0 nil)
;;(nlist-set-elt (list "a" "b" "c") 1 nil)
;;(nlist-set-elt (list "a" "b" "c") 2 nil)

(defun nlist-zip1(l1 l2)
  "given 2 lists L1 and L2, create a new list composed of cons's of elts from the two lists"
  (let(
       combined-list
       )
    (while (and l1 l2)
      (setq combined-list (cons
			   (cons (car l1) (car l2))
			   combined-list
			   )
	    l1 (cdr l1)
	    l2 (cdr l2)
	    )
      )
    (nreverse combined-list)
    )
  )
(defun nlist-zip(l1 l2)
  "given 2 lists L1 and L2, create a new list composed of intermixed elts from the two lists"
  (let(
       combined-list
       )
    (while (and l1 l2)
      (setq combined-list (append
                           (list (car l2))
                           (list (car l1))
			   combined-list
			   )
	    l1 (cdr l1)
	    l2 (cdr l2)
	    )
      )
    (nreverse combined-list)
    )
  )
;;(nlist-zip1 (list "a" "b") (list "1" "2")) -> (list (cons "a" "1") (cons "b" "2"))
;;(nlist-zip  (list "a" "b") (list "1" "2")) -> (list "a" "1" "b" "2")

(defun nlist-funcall(l1 func)
  (let(
       l2
       )
    (while l1
      (setq l2 (cons (funcall func (car l1))
		     l2
		     )
	    l1 (cdr l1)
	    )
      )
    (nreverse l2)
    )
  )
(defun nlist-cycle( List )
  "n3.el: given LIST, move its car to its end"
  (if (cdr List)
      (append (cdr List) (list (car List )))
    List
    )
  )
(defun nlist-make-assoc-via-function-mapping(keys_itemsOrFunc values_itemsOrFunc)
  "make an assoc with KEYS and VALUES.  If either one of these parameters is a function, apply this function to the other list to create a new list.  So for example if I wanted to have a hash of integers to their squares, I would use the following invocation: (nlist-make-assoc-via-function-mapping (list 1 2 3) '((lambda(n) (* n n))))"
  (let(
       (keys	(cond
		 ((functionp keys_itemsOrFunc)
		  (nlist-funcall values_itemsOrFunc keys_itemsOrFunc)
		  )
		 ((listp keys_itemsOrFunc)
		  keys_itemsOrFunc
		  )
		 (t
		  (error "nlist-make-assoc: keys_itemsOrFunc should be either a function or a list")
		  )
		 )
		)
       (values	(cond
		 ((functionp values_itemsOrFunc)
		  (nlist-funcall keys_itemsOrFunc values_itemsOrFunc)
		  )
		 ((listp values_itemsOrFunc)
		  values_itemsOrFunc
		  )
		 (t
		  (error "nlist-make-assoc: values_itemsOrFunc should be either a function or a list")
		  )
		 )
		)
       )
    (nlist-make-assoc keys values)
    )
  )
;;(nlist-make-assoc-via-function-mapping (list 1 2 3) '(lambda(n) (* n n)))

(defun nlist-make-assoc(keys values)
  "make an assoc with KEYS and VALUES."
  (let(
       assoc
       )
    (while keys
      (setq assoc (cons (cons (car keys)
			      (car values)
			      )
			assoc
			)
	    keys (cdr keys)
	    values (cdr values)
	    )
      )
    assoc
    )
  )
;;(assoc 1 (nlist-make-assoc (list 1 2 3) (list "hello" "world" "goodbye")))

(defun nlist-assoc-keys(assoc)
  (let(
       keys
       )
    (while assoc
      (setq keys (cons (caar assoc) keys)
	    assoc (cdr assoc)
	    )
      )
    keys
    )
  )
(defun nlist-assoc-unique-add-val(key data association)
  "add a key/data pair to an assoc, assuming that the data are unique, i.e., there are no duplicate keys.  So if
the key is already represented by a cons in the association, that cons is overwritten"
  (let(
       (setting-pair (assoc key association))
       setting
       )
    (if setting-pair
        (setcdr setting-pair data)
      (setq association (cons (cons key data)
			      association)
            )
      )
    )
  association
  )
(defun nlist-assoc-n-add-val(key data association)
  "add a key/data pair to an assoc, not assuming that the data are unique, i.e., there can be multiple data for a single key."
  (if (not (nlist-assoc-n-contains key data association))
      (let(
	   (setting-pair (assoc key association))
	   setting
	   )
	(if setting-pair
	    (setcdr setting-pair
		    (cons data
			  (cdr setting-pair)
			  )
		    )
	  (setq association (cons (list key data)
				  association)
		)
	  )
	)
    )
  association
  )
(defun nlist-assoc-n-contains(key data association)
  (let(
       (setting-pair (assoc key association))
       dataList
       hit
       )
    (if setting-pair
	(progn
	  (setq dataList (cdr setting-pair))
	  (while dataList
	    (if (equal data (car dataList))
		(setq hit t
		      dataList nil
		      )
	      (setq dataList (cdr dataList))
	      )
	    )
	  )
      )
    hit
    )
  )
(defun nlist-assoc-n-has-single-val(key association)
  (let(
       (setting-pair (assoc key association))
       dataList
       )
    (if (not setting-pair)
	(error "nlist-assoc-n-has-single-val: no val")
      (setq dataList (cdr setting-pair))
      (> 1 (length dataList))
      )
    )
  )
(defun nlist-randomly-scramble(l)
  (sort l '(lambda(elt1 elt2) (< (random) 0)))
  )

(defun nlist-call-process(input program &rest args)
  (let(
       (outStr (apply 'nstr-call-process nil input program args))
       )
    (nstr-split outStr "\n")
    )
  )

(defun nlist-make-vector(seq)
  (let(
       (v (make-vector (length seq) nil))
       (j 0)
       )
    (while (car seq)
      (aset v j (car seq))
      (setq seq (cdr seq)
            j (1+ j)
            )
      )
    v
    )
  )
(defun nlist-slice(v start &optional len mightEndUpWithLessThanLen)
  (let(
       seq
       (j start)
       )
    (if (or (not len)
            (> len (- (length v) start))
            )
        (if (or (not len) mightEndUpWithLessThanLen)
            (setq len (- (length v) start))
          (error "nlist-slice: list too short")
          )
      )
    (while (> len 0)
      (setq seq (cons (elt v j) seq)
            j (1+ j)
            len (1- len)
            )
      )
    (reverse seq)
    )
  )
(defun nlist-test()
  (setq association nil)
  (setq association (nlist-assoc-unique-add-val "key1" "val1" association))
  (assoc "key1" association)
  (setq association (nlist-assoc-unique-add-val "key2" "val2" association))
  (setq association (nlist-assoc-unique-add-val "key2" "val2b" association))

  (setq association nil)
  (setq association (nlist-assoc-n-add-val "key1" "val1" association))
  (assoc "key1" association)
  (setq association (nlist-assoc-n-add-val "key2" "val2" association))
  (setq association (nlist-assoc-n-add-val "key2" "val2b" association))
  (nlist-assoc-n-contains "key2" "val2" association)
  (nlist-assoc-n-contains "key2" "val2b" association)
  (nlist-assoc-n-contains "key2" "val2b_lskdfjslkdfj" association)
  (nlist-randomly-scramble (list "1" "2" "3" "4" "5" "6" "7"))
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 2)
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 2 2)
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 2 0)
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 0 2)
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 9)
  (nlist-slice (list "1" "2" "3" "4" "5" "6" "7") 9 2 t)
  )
