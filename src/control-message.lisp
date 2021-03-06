(in-package :cleric)

;;; ControlMessage
;;
;; LINK:         {1, FromPid, ToPid}
;; SEND:         {2, Cookie, ToPid}
;; EXIT:         {3, FromPid, ToPid, Reason}
;; UNLINK:       {4, FromPid, ToPid}
;; NODE_LINK:    {5}
;; REG_SEND:     {6, FromPid, Cookie, ToName}
;; GROUP_LEADER: {7, FromPid, ToPid}
;; EXIT2:        {8, FromPid, ToPid, Reason}
;;
;; SEND_TT:     {12, Cookie, ToPid, TraceToken}
;; EXIT_TT:     {13, FromPid, ToPid, TraceToken, Reason}
;; REG_SEND_TT: {16, FromPid, Cookie, ToName, TraceToken}
;; EXIT2_TT:    {18, FromPid, ToPid, TraceToken, Reason}
;;

;;; Control message tags
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defconstant +cm-link+         1)
  (defconstant +cm-send+         2)
  (defconstant +cm-exit+         3)
  (defconstant +cm-unlink+       4)
  (defconstant +cm-node-link+    5)
  (defconstant +cm-reg-send+     6)
  (defconstant +cm-group-leader+ 7)
  (defconstant +cm-exit2+        8)
  ;; New control messages for distrvsn = 1 (OTP R4)
  (defconstant +cm-send-tt+     12)
  (defconstant +cm-exit-tt+     13)
  (defconstant +cm-reg-send-tt+ 16)
  (defconstant +cm-exit2-tt+    18)
  )


;;;
;;; Control message classes
;;;

(defclass control-message ()
  ((trace-token :reader trace-token :initarg :trace-token :initform nil)))

(defclass link (control-message)
  ((from-pid :reader from-pid :initarg :from-pid)
   (to-pid :reader to-pid :initarg :to-pid))
  (:documentation "LINK Control Message."))

(defclass send (control-message)
  ((cookie :reader cookie :initarg :cookie :initform '||)
   (to-pid :reader to-pid :initarg :to-pid)
   (message :reader message :initarg :message))
  (:documentation "SEND Control Message."))

(defclass exit (control-message)
  ((from-pid :reader from-pid :initarg :from-pid)
   (to-pid :reader to-pid :initarg :to-pid)
   (reason :reader reason :initarg :reason))
  (:documentation "EXIT Control Message."))

(defclass unlink (control-message)
  ((from-pid :reader from-pid :initarg :from-pid)
   (to-pid :reader to-pid :initarg :to-pid))
  (:documentation "UNLINK Control Message."))

(defclass node-link (control-message) ;; What is it used for?
  ()
  (:documentation "NODE_LINK Control Message."))

(defclass reg-send (control-message)
  ((from-pid :reader from-pid :initarg :from-pid)
   (cookie :reader cookie :initarg :cookie :initform '||)
   (to-name :reader to-name :initarg :to-name)
   (message :reader message :initarg :message))
  (:documentation "REG_SEND Control Message."))

(defclass group-leader (control-message)
  ((from-pid :reader from-pid :initarg :from-pid)
   (to-pid :reader to-pid :initarg :to-pid))
  (:documentation "GROUP_LEADER Control Message."))

(defclass exit2 (exit)
  ;; What is the difference between EXIT and EXIT2?
  ()
  (:documentation "EXIT2 Control Message."))


(defun make-control-message (tuple)
  (case (tuple-ref tuple 0)
    (#.+cm-link+
     (make-instance 'link
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)))
    (#.+cm-send+
     (make-instance 'send
                    :cookie (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)))
    (#.+cm-send-tt+
     (make-instance 'send
                    :cookie (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)
                    :trace-token (tuple-ref tuple 3)))
    (#.+cm-exit+
     (make-instance 'exit
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)
                    :reason (tuple-ref tuple 3)))
    (#.+cm-exit-tt+
     (make-instance 'exit
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)
                    :trace-token (tuple-ref tuple 3)
                    :reason (tuple-ref tuple 4)))
    (#.+cm-unlink+
     (make-instance 'unlink
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)))
    (#.+cm-node-link+
     (make-instance 'node-link))
    (#.+cm-reg-send+
     (make-instance 'reg-send
                    :from-pid (tuple-ref tuple 1)
                    :cookie (tuple-ref tuple 2)
                    :to-name (tuple-ref tuple 3)))
    (#.+cm-reg-send-tt+
     (make-instance 'reg-send
                    :from-pid (tuple-ref tuple 1)
                    :cookie (tuple-ref tuple 2)
                    :to-name (tuple-ref tuple 3)
                    :trace-token (tuple-ref tuple 4)))
    (#.+cm-group-leader+
     (make-instance 'group-leader
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)))
    (#.+cm-exit2+
     (make-instance 'exit2
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)
                    :reason (tuple-ref tuple 3)))
    (#.+cm-exit2-tt+
     (make-instance 'exit2
                    :from-pid (tuple-ref tuple 1)
                    :to-pid (tuple-ref tuple 2)
                    :trace-token (tuple-ref tuple 3)
                    :reason (tuple-ref tuple 4)))
    (otherwise
     (error 'unexpected-message-tag-error
            :received-tag (tuple-ref tuple 0)
            :expected-tags (list +cm-link+ +cm-send+ +cm-exit+
                                 +cm-unlink+ +cm-node-link+
                                 +cm-reg-send+ +cm-group-leader+
                                 +cm-exit2+ +cm-send-tt+ +cm-exit-tt+
                                 +cm-reg-send-tt+ +cm-exit2-tt+))) ))


;;;;
;;;; ENCODE-CONTROL-MESSAGE - For encoding Control Messages
;;;;

(defgeneric encode-control-message (control-message &key version-tag atom-cache-entries)
  (:documentation "Encodes the Control Message to a vector of bytes."))


(defmethod encode-control-message ((object link) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid to-pid) object
    (encode
     (tuple +cm-link+ from-pid to-pid)
     :atom-cache-entries atom-cache-entries)))


(defmethod encode-control-message ((object send) &key atom-cache-entries &allow-other-keys)
  (with-slots (cookie to-pid trace-token message) object
    (concatenate '(vector octet)
                 (encode (if trace-token
                             (tuple +cm-send-tt+
                                    cookie
                                    to-pid
                                    trace-token)
                             (tuple +cm-send+
                                    cookie
                                    to-pid))
                         :atom-cache-entries atom-cache-entries)
                 (encode message :atom-cache-entries atom-cache-entries))))


(defmethod encode-control-message ((object exit) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid to-pid trace-token reason) object
    (encode (if trace-token
                (tuple +cm-exit-tt+
                       from-pid
                       to-pid
                       trace-token
                       reason)
                (tuple +cm-exit+
                       from-pid
                       to-pid
                       reason))
            :atom-cache-entries atom-cache-entries)))

(defmethod encode-control-message ((object unlink) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid to-pid) object
    (encode (tuple +cm-unlink+
                   from-pid
                   to-pid)
            :atom-cache-entries atom-cache-entries)))

(defmethod encode-control-message ((object node-link) &key atom-cache-entries &allow-other-keys)
  (declare (ignorable object))
  (encode (tuple +cm-node-link+)
          :atom-cache-entries atom-cache-entries))

(defmethod encode-control-message ((object reg-send) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid cookie to-name trace-token message) object
    (concatenate '(vector octet)
                 (encode (if trace-token
                             (tuple +cm-reg-send-tt+
                                    from-pid
                                    cookie
                                    to-name
                                    trace-token)
                             (tuple +cm-reg-send+
                                    from-pid
                                    cookie
                                    to-name))
                         :atom-cache-entries atom-cache-entries)
                 (encode message :atom-cache-entries atom-cache-entries))))

(defmethod encode-control-message ((object group-leader) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid to-pid) object
    (encode (tuple +cm-group-leader+
                   from-pid
                   to-pid)
            :atom-cache-entries atom-cache-entries)))

(defmethod encode-control-message ((object exit2) &key atom-cache-entries &allow-other-keys)
  (with-slots (from-pid to-pid trace-token reason) object
    (encode (if trace-token
                (tuple +cm-exit2-tt+
                       from-pid
                       to-pid
                       trace-token
                       reason)
                (tuple +cm-exit2+
                       from-pid
                       to-pid
                       reason))
            :atom-cache-entries atom-cache-entries)))


(defun decode-control-message (bytes &key (start 0) (version-tag nil))
  "Decode a sequence of bytes to a Control Message."
  (multiple-value-bind (tuple pos)
      (decode bytes :start start :version-tag version-tag)
    ;; TODO: Make sure TUPLE is actually a tuple
    (let ((cm (make-control-message tuple)))
      (when (typep cm '(or send reg-send))
        (assert (< pos (length bytes)))
        (setf (slot-value cm 'message)
              (decode bytes :start pos :version-tag version-tag)) )
      cm)))
