(defsystem jeffrey
  :components ((:file "packages")
	       (:file "graph" :depends-on ("packages"))
	       (:file "read" :depends-on ("packages" "graph"))
	       (:file "predicates" :depends-on ("packages" "graph" "read"))
;;=	       (:file "read-forms" :depends-on ("packages" "graph" "read"))
;;	       (:file "draw" :depends-on ("packages" "read-book1"))
	       (:file "test" :depends-on ("packages" "graph" "read" "predicates"))))
