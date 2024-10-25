(defpackage :terminal-text-display-tools                                                                                                                                                                                                                                                                                  
  (:use :cl)                                                                                                                                                                                                                                                                                                              
  (:nicknames :ttdt)                                                                                                                                                                                                                                                                                                      
  (:export :prepare-for-display                                                                                                                                                                                                                                                                                           
           :order-of-simulation                                                                                                                                                                                                                                                                                           
           :safe-char-p                                                                                                                                                                                                                                                                                                   
           :diplomatic-banter                                                                                                                                                                                                                                                                                             
           :start-repl                                                                                                                                                                                                                                                                                                    
           :with-side-effects))                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                          
(in-package :terminal-text-display-tools)                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                          
(defvar *character-id* nil)                                                                                                                                                                                                                                                                                               
(defvar *system-config* nil)                                                                                                                                                                                                                                                                                              
(defvar *order-of-simulation* 0)                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                          
(defun safe-char-p (char)                                                                                                                                                                                                                                                                                                 
  (or (char<= #\space char #\~)                                                                                                                                                                                                                                                                                           
      (char<= #\u00c0 char #\u017f) ;; latin-1 supplement and latin extended-a                                                                                                                                                                                                                                            
      (char<= #\u0370 char #\u03ff) ;; greek and coptic                                                                                                                                                                                                                                                                   
      (char<= #\u0400 char #\u04ff) ;; cyrillic                                                                                                                                                                                                                                                                           
      (char= char #\newline)                                                                                                                                                                                                                                                                                              
      (char= char #\tab)))                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                          
(defgeneric prepare-for-display (object)                                                                                                                                                                                                                                                                                  
  (:documentation "prepare to display at terminal."))                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object number))                                                                                                                                                                                                                                                                          
  (list object))                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object string))                                                                                                                                                                                                                                                                          
  (let ((safe-string (remove-if-not #'safe-char-p object)))                                                                                                                                                                                                                                                               
    (list safe-string)))                                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object character))                                                                                                                                                                                                                                                                       
  (list object))                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object list))                                                                                                                                                                                                                                                                            
  (mapcar #'prepare-for-display object))                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object vector))                                                                                                                                                                                                                                                                          
  (prepare-for-display (coerce object 'list)))                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object array))                                                                                                                                                                                                                                                                           
  (prepare-for-display (coerce object 'list)))                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                          
(defmethod prepare-for-display ((object t))                                                                                                                                                                                                                                                                               
  (unwind-protect                                                                                                                                                                                                                                                                                                         
       (error object "is not preparable for terminal display")))                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
(defun order-of-simulation (n)                                                                                                                                                                                                                                                                                            
  (let* ((abs-n (abs n))                                                                                                                                                                                                                                                                                                  
         (sign (cond ((plusp n) "+")                                                                                                                                                                                                                                                                                      
                     ((minusp n) "-")                                                                                                                                                                                                                                                                                     
                     (t "")))                                                                                                                                                                                                                                                                                             
         (abs-n-str (write-to-string abs-n)))                                                                                                                                                                                                                                                                             
    (concatenate 'string "order of simulation: "                                                                                                                                                                                                                                                                          
                 (cond ((zerop n) "0.")                                                                                                                                                                                                                                                                                   
                       (t (concatenate 'string sign " " abs-n-str "."))))))                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                          
(defmacro with-side-effects (&body body)                                                                                                                                                                                                                                                                                  
  `(progn ,@body))                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                          
(defun start-repl ()                                                                                                                                                                                                                                                                                                      
  (let ((menu '((#\a . ((check idler status) . #'check-idler-status))                                                                                                                                                                                                                                                     
                (#\b . ((view character sheet) . (#'view-character-sheet . *character-id*)))                                                                                                                                                                                                                              
                (#\c . ((change #'name-of-system config) . #'system-config)))))                                                                                                                                                                                                                                           
    (with-side-effects                                                                                                                                                                                                                                                                                                    
      (loop                                                                                                                                                                                                                                                                                                               
        (with-side-effects                                                                                                                                                                                                                                                                                                
          (format t "~%menu:~%")                                                                                                                                                                                                                                                                                          
          (dolist (item menu)                                                                                                                                                                                                                                                                                             
            (format t "~a. ~a~%" (car item) (caadr item)))                                                                                                                                                                                                                                                                
          (format t "enter your choice: "))                                                                                                                                                                                                                                                                               
        (let ((choice (read-char)))                                                                                                                                                                                                                                                                                       
          (terpri)                                                                                                                                                                                                                                                                                                        
          (cond ((assoc choice menu)                                                                                                                                                                                                                                                                                      
                 (let ((action (cdr (assoc choice menu))))                                                                                                                                                                                                                                                                
                   (funcall (cdadr action) (cddadr action))))                                                                                                                                                                                                                                                             
                (t (format t "invalid choice. please try again.~%"))))))))

(defun check-idler-status ()                                                                                                                                                                                                                                                                                              
  (with-side-effects                                                                                                                                                                                                                                                                                                      
    (format t "checking idler status...~%")))                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                          
(defun view-character-sheet (character-id)                                                                                                                                                                                                                                                                                
  (with-side-effects                                                                                                                                                                                                                                                                                                      
    (format t "viewing character sheet for character id ~a...~%" character-id)))                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                          
(defun system-config ()                                                                                                                                                                                                                                                                                                   
  (with-side-effects                                                                                                                                                                                                                                                                                                      
    (format t "changing system configuration...~%")))                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                          
#|                                                                                                                                                                                                                                                                                                                        
;; example usage                                                                                                                                                                                                                                                                                                          
(prepare-for-display (order-of-simulation 0)) ; returns ("order of simulation: 0.")                                                                                                                                                                                                                                       
(prepare-for-display (order-of-simulation 5)) ; returns ("order of simulation: + 5.")                                                                                                                                                                                                                                     
(prepare-for-display (order-of-simulation -3)) ; returns ("order of simulation: - 3.")                                                                                                                                                                                                                                    
(start-repl) ; starts the repl with the menu                                                                                                                                                                                               