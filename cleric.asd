(defpackage :common-lisp-erlang-interface-system
  (:nicknames :cleric-system)
  (:use :cl :asdf))

(in-package :cleric-system)

(defsystem :cleric
  :description "Common Lisp Erlang Interface - An implementation of the Erlang distribution protocol."
  :author "Markus Flambard <mflambard@common-lisp.net>"
  :version "0.0.2"
  :license "MIT License"
  :depends-on (:usocket :md5 :ieee-floats)
  :components ((:file "package")
	       (:file "generic-functions"
		      :depends-on ("package"
				   "constants"))
	       (:file "remote-node"
		      :depends-on ("package"
				   "atom-cache"
				   "special-variables"))
	       (:file "conditions"
		      :depends-on ("package"))
	       (:file "constants"
		      :depends-on ("package"))
	       (:file "atom-cache"
		      :depends-on ("package"))
	       (:file "special-variables"
		      :depends-on ("package"))
	       (:file "byte-functions"
		      :depends-on ("package"))
	       (:file "classes"
		      :depends-on ("package"
				   "special-variables"))
	       (:file "type-erlang-translatable"
		      :depends-on ("package"
				   "classes"))
	       (:file "distribution-header"
		      :depends-on ("package"
				   "constants"
				   "conditions"
				   "byte-functions"))
	       (:file "ieee-floats" ;; Needs IEEE-Floats library
		      :depends-on ("package"
				   "byte-functions"))
	       (:file "epmd"
		      :depends-on ("package"
				   "conditions"
				   "remote-node"
				   "byte-functions"
				   "constants"))
	       (:file "translation"
		      :depends-on ("package"
				   "conditions"
				   "byte-functions"
				   "generic-functions"
				   "constants"
				   "special-variables"
				   "classes"
				   "ieee-floats"
				   "md5"
				   "atom-cache"
				   "type-erlang-translatable"))
	       (:file "handshake"
		      :depends-on ("package"
				   "conditions"
				   "byte-functions"
				   "constants"))
	       (:file "md5" ;; Needs MD5 library
		      :depends-on ("package"))
	       (:file "control-message"
		      :depends-on ("package"
				   "generic-functions"
				   "constants"
				   "classes"))
	       (:file "node-protocol"
		      :depends-on ("package"
				   "conditions"
				   "distribution-header"
				   "classes"
				   "translation"
				   "byte-functions"
				   "control-message"
				   "remote-node"))
	       ))