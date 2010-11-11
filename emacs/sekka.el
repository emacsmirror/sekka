;; -*- coding: iso-2022-jp -*-
;;
;; "sekka.el" is a client for Sekka server
;;
;;   Copyright (C) 2010 Kiyoka Nishiyama
;;   This program was derived from sumibi.el and yc.el-4.0.13(auther: knak)
;;
;;
;; This file is part of Sekka
;;
;; Sekka is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; Sumibi is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with Sumibi; see the file COPYING.
;;

;;; Code:
(require 'cl)

;;; 
;;;
;;; customize variables
;;;
(defgroup sekka nil
  "Sekka client."
  :group 'input-method
  :group 'Japanese)

(defcustom sekka-server-url "http://localhost:12929/"
  "Sekka$B%5!<%P!<$N(BURL$B$r;XDj$9$k!#(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-server-timeout 10
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N%?%$%`%"%&%H$r;XDj$9$k!#(B($BIC?t(B)"
  :type  'integer
  :group 'sekka)
 
(defcustom sekka-stop-chars ";(){}<> "
  "*$B4A;zJQ49J8;zNs$r<h$j9~$`;~$KJQ49HO0O$K4^$a$J$$J8;z$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-curl "curl"
  "curl$B%3%^%s%I$N@dBP%Q%9$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-use-viper nil
  "*Non-nil $B$G$"$l$P!"(BVIPER $B$KBP1~$9$k(B"
  :type 'boolean
  :group 'sekka)

(defcustom sekka-realtime-guide-running-seconds 30
  "$B%j%"%k%?%$%`%,%$%II=<($N7QB3;~4V(B($BIC?t(B)$B!&%<%m$G%,%$%II=<(5!G=$,L58z$K$J$k(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-limit-lines 5
  "$B:G8e$KJQ49$7$?9T$+$i(B N $B9TN%$l$?$i%j%"%k%?%$%`%,%$%II=<($,;_$^$k(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-interval  0.2
  "$B%j%"%k%?%$%`%,%$%II=<($r99?7$9$k;~4V4V3V(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-roman-method "normal"
  "$B%m!<%^;zF~NOJ}<0$H$7$F!$(Bnormal($BDL>o%m!<%^;z(B)$B$+!"(BAZIK($B3HD%%m!<%^;z(B)$B$N$I$A$i$N2r<a$rM%@h$9$k$+(B"
  :type '(choice (const :tag "normal" "normal")
		 (const :tag "AZIK"   "azik"  ))
  :group 'sekka)


(defface sekka-guide-face
  '((((class color) (background light)) (:background "#E0E0E0" :foreground "#F03030")))
  "$B%j%"%k%?%$%`%,%$%I$N%U%'%$%9(B($BAu>~!"?'$J$I$N;XDj(B)"
  :group 'sekka)


(defvar sekka-sticky-shift nil     "*Non-nil $B$G$"$l$P!"(BSticky-Shift$B$rM-8z$K$9$k(B")
(defvar sekka-mode nil             "$B4A;zJQ49%H%0%kJQ?t(B")
(defvar sekka-mode-line-string     " Sekka")
(defvar sekka-select-mode nil      "$B8uJdA*Br%b!<%IJQ?t(B")
(or (assq 'sekka-mode minor-mode-alist)
    (setq minor-mode-alist (cons
			    '(sekka-mode        sekka-mode-line-string)
			    minor-mode-alist)))


;; $B%m!<%^;z4A;zJQ49;~!"BP>]$H$9$k%m!<%^;z$r@_Dj$9$k$?$a$NJQ?t(B
(defvar sekka-skip-chars "a-zA-Z0-9.,@:`\\-+!\\[\\]?")
(defvar sekka-mode-map        (make-sparse-keymap)         "$B4A;zJQ49%H%0%k%^%C%W(B")
(defvar sekka-select-mode-map (make-sparse-keymap)         "$B8uJdA*Br%b!<%I%^%C%W(B")
(defvar sekka-rK-trans-key "\C-j"
  "*$B4A;zJQ49%-!<$r@_Dj$9$k(B")
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list (cons 'sekka-mode         sekka-mode-map)
			(cons 'sekka-select-mode  sekka-select-mode-map))
		  minor-mode-map-alist)))

;;;
;;; hooks
;;;
(defvar sekka-mode-hook nil)
(defvar sekka-select-mode-hook nil)
(defvar sekka-select-mode-end-hook nil)

(defconst sekka-login-name   (user-login-name))

(defconst sekka-kind-index   3)
(defconst sekka-id-index     4)

;;--- $B%G%P%C%0%a%C%;!<%8=PNO(B
(defvar sekka-psudo-server nil)         ; $B%/%i%$%"%s%HC1BN$G2>A[E*$K%5!<%P!<$K@\B3$7$F$$$k$h$&$K$7$F%F%9%H$9$k%b!<%I(B

;;--- $B%G%P%C%0%a%C%;!<%8=PNO(B
(defvar sekka-debug nil)		; $B%G%P%C%0%U%i%0(B
(defun sekka-debug-print (string)
  (if sekka-debug
      (let
	  ((buffer (get-buffer-create "*sekka-debug*")))
	(with-current-buffer buffer
	  (goto-char (point-max))
	  (insert string)))))


;;; sekka basic output
(defvar sekka-fence-start nil)          ; fence $B;OC<0LCV(B
(defvar sekka-fence-end nil)            ; fence $B=*C<0LCV(B
(defvar sekka-henkan-separeter " ")     ; fence mode separeter
(defvar sekka-henkan-buffer nil)        ; $BI=<(MQ%P%C%U%!(B
(defvar sekka-henkan-length nil)        ; $BI=<(MQ%P%C%U%!D9(B
(defvar sekka-henkan-revpos nil)        ; $BJ8@a;OC<0LCV(B
(defvar sekka-henkan-revlen nil)        ; $BJ8@aD9(B

;;; sekka basic local
(defvar sekka-cand-cur 0)               ; $B%+%l%s%H8uJdHV9f(B
(defvar sekka-cand-cur-backup 0)        ; $B%+%l%s%H8uJdHV9f(B(UNDO$BMQ$KB`Hr$9$kJQ?t(B)
(defvar sekka-cand-len nil)             ; $B8uJd?t(B
(defvar sekka-last-fix "")              ; $B:G8e$K3NDj$7$?J8;zNs(B
(defvar sekka-henkan-kouho-list nil)    ; $BJQ497k2L%j%9%H(B($B%5!<%P$+$i5"$C$F$-$?%G!<%?$=$N$b$N(B)
(defvar sekka-markers '())              ; $BJ8@a3+;O!"=*N;0LCV$N(Bpair: $B<!$N$h$&$J7A<0(B ( 1 . 2 )
(defvar sekka-timer    nil)             ; $B%$%s%?!<%P%k%?%$%^!<7?JQ?t(B
(defvar sekka-timer-rest  0)            ; $B$"$H2?2s8F=P$5$l$?$i!"%$%s%?!<%P%k%?%$%^$N8F=P$r;_$a$k$+(B
(defvar sekka-last-lineno 0)            ; $B:G8e$KJQ49$r<B9T$7$?9THV9f(B
(defvar sekka-guide-overlay   nil)      ; $B%j%"%k%?%$%`%,%$%I$K;HMQ$9$k%*!<%P!<%l%$(B
(defvar sekka-last-request-time 0)      ; Sekka$B%5!<%P!<$K%j%/%(%9%H$7$?:G8e$N;~9o(B($BC10L$OIC(B)
(defvar sekka-guide-lastquery  "")      ; Sekka$B%5!<%P!<$K%j%/%(%9%H$7$?:G8e$N%/%(%jJ8;zNs(B
(defvar sekka-guide-lastresult '())     ; Sekka$B%5!<%P!<$K%j%/%(%9%H$7$?:G8e$N%/%(%jJ8;zNs(B


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Skicky-shift
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar sticky-key ";")
(defvar sticky-list
  '(("a" . "A")("b" . "B")("c" . "C")("d" . "D")("e" . "E")("f" . "F")("g" . "G")
    ("h" . "H")("i" . "I")("j" . "J")("k" . "K")("l" . "L")("m" . "M")("n" . "N")
    ("o" . "O")("p" . "P")("q" . "Q")("r" . "R")("s" . "S")("t" . "T")("u" . "U")
    ("v" . "V")("w" . "W")("x" . "X")("y" . "Y")("z" . "Z")
    ("1" . "!")("2" . "\"")("3" . "#")("4" . "$")("5" . "%")("6" . "&")("7" . "'")
    ("8" . "(")("9" . ")")
    ("`" . "@")("[" . "{")("]" . "}")("-" . "=")("^" . "~")("\\" . "|")("." . ">")
    ("/" . "?")(";" . ";")(":" . "*")("@" . "`")
    ("\C-h" . "")
    ))
(defvar sticky-map (make-sparse-keymap))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $BI=<(7O4X?t72(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar sekka-use-fence t)
(defvar sekka-use-color nil)

(defvar sekka-init nil)

;;
;; $B=i4|2=(B
;;
(defun sekka-init ()
  ;; $B:G=i$N(B n $B7o$N%j%9%H$r<hF@$9$k(B
  (defun sekka-take (arg-list n)
    (let ((lst '()))
      (dotimes (i n (reverse lst))
        (let ((item (nth i arg-list)))
	  (when item
	    (push item lst))))))
  
  (when (not sekka-init)
    ;; $B%f!<%6!<8lWC$N%m!<%I(B + $B%5!<%P!<$X$NEPO?(B
    (sekka-register-userdict-internal)

    ;; Emacs$B=*N;;~$N=hM}(B
    (add-hook 'kill-emacs-hook
	      (lambda ()
		;; $B2?$b$9$k$3$H$OL5$$(B
		t))
    ;; $B=i4|2=40N;(B
    (setq sekka-init t)))


(defun sekka-construct-curl-argstr (arg-alist)
  (apply 'concat
	 (mapcar
	  (lambda (x)
	    (format "--data '%s=%s' " (car x) (cdr x)))
	  arg-alist)))

;; test-code
(when nil
  (sekka-construct-curl-argstr
   '(
     ("yomi"   .  "kanji")
     ("limit"  .  2)
     ("method" .  "normal")
     )))

;;
;; $B%m!<%^;z$G=q$+$l$?J8>O$r(BSekka$B%5!<%P!<$r;H$C$FJQ49$9$k(B
;;
;; arg-alist$B$N0z?t$N7A<0(B
;;  $BNc(B:
;;   '(
;;     ("yomi"   .  "kanji")
;;     ("limit"  .  2)
;;     ("method" .  "normal")
;;    )
(defun sekka-rest-request (func-name arg-alist)
  (if sekka-psudo-server
      ;; $B%/%i%$%"%s%HC1BN$G2>A[E*$K%5!<%P!<$K@\B3$7$F$$$k$h$&$K$7$F%F%9%H$9$k%b!<%I(B
      "((\"$BJQ49(B\" nil \"$B$X$s$+$s(B\" j 0) (\"$BJQ2=(B\" nil \"$B$X$s$+(B\" j 1) (\"$B%X%s%+%s(B\" nil \"$B$X$s$+$s(B\" k 2) (\"$B$X$s$+$s(B\" nil \"$B$X$s$+$s(B\" h 3))"
      ;;"((\"$BJQ49(B\" nil \"$B$X$s$+$s(B\" j 0) (\"$BJQ2=(B\" nil \"$B$X$s$+(B\" j 1))"
    ;; $B<B:]$N%5!<%P$K@\B3$9$k(B
    (let ((command
	   (concat
	    sekka-curl " --silent --show-error "
	    (format " --max-time %d " sekka-server-timeout)
	    " --insecure "
	    " --header 'Content-Type: application/x-www-form-urlencoded' "
	    (format "%s%s " sekka-server-url func-name)
	    (sekka-construct-curl-argstr arg-alist)
	    (format "--data 'userid=%s' " sekka-login-name))))
      
      (sekka-debug-print (format "curl-command :%s\n" command))
      
      (let (
	    (result
	     (shell-command-to-string
	      command)))
	
	(sekka-debug-print (format "curl-result-sexp :%s\n" result))
	result))))
      
;;
;; $B8=:_;~9o$r(BUNIX$B%?%$%`$rJV$9(B($BC10L$OIC(B)
;;
(defun sekka-current-unixtime ()
  (let (
	(_ (current-time)))
    (+
     (* (car _)
	65536)
     (cadr _))))


;;
;; $B%m!<%^;z$G=q$+$l$?J8>O$r(BSekka$B%5!<%P!<$r;H$C$FJQ49$9$k(B
;;
(defun sekka-henkan-request (yomi limit)
  (sekka-debug-print (format "henkan-input :[%s]\n"  yomi))

  ;;(message "Requesting to sekka server...")
  
  (let (
	(result (sekka-rest-request "henkan" `((yomi   . ,yomi)
					       (limit  . ,limit)
					       (method . ,sekka-roman-method)))))
    (sekka-debug-print (format "henkan-result:%S\n" result))
    (if (eq (string-to-char result) ?\( )
	(progn
	  (message nil)
	  (condition-case err
	      (read result)
	    (end-of-file
	     (progn
	       (message "Parse error for parsing result of Sekka Server.")
	       nil))))
      (progn
	(message result)
	nil))))

;;
;; $B3NDj$7$?C18l$r%5!<%P!<$KEAC#$9$k(B
;;
(defun sekka-kakutei-request (key tango)
  (sekka-debug-print (format "henkan-kakutei key=[%s] tango=[%s]\n" key tango))
  
  (message "Requesting to sekka server...")
  
  (let ((result (sekka-rest-request "kakutei" `(
						(key   . ,key)
						(tango . ,tango)))))
    (sekka-debug-print (format "kakutei-result:%S\n" result))
    (message result)
    t))

;;
;; $B%f!<%6!<8lWC$r%5!<%P!<$K:FEYEPO?$9$k!#(B
;;
(defun sekka-register-userdict (&optional arg)
  "$B%f!<%6!<<-=q$r%5!<%P!<$K:FEY%"%C%W%m!<%I$9$k(B"
  (interactive "P")
  (sekka-register-userdict-internal))

  
;;
;; $B%f!<%6!<8lWC$r%5!<%P!<$KEPO?$9$k!#(B
;;
(defun sekka-register-userdict-internal ()
  (let ((str (sekka-get-jisyo-str "~/.sekka-jisyo")))
    (when str
      (message "Requesting to sekka server...")
      (sekka-debug-print (format "register [%s]\n" str))
      (let ((result (sekka-rest-request "register" `((dict . ,str)))))
	(sekka-debug-print (format "register-result:%S\n" result))
	(message result)
	t))))


(defun sekka-get-jisyo-str (file &optional nomsg)
  "FILE $B$r3+$$$F(B SKK $B<-=q%P%C%U%!$r:n$j!"%P%C%U%!$rJV$9!#(B
$B%*%W%7%g%s0z?t$N(B NOMSG $B$r;XDj$9$k$H%U%!%$%kFI$_9~$_$N:]$N%a%C%;!<%8$rI=<($7$J(B
$B$$!#(B"
  (when file
    (let* ((file (or (car-safe file)
		     file))
	   (file (expand-file-name file)))
      (if (not (file-exists-p file))
	  (progn
	    (message (format "SKK $B<-=q(B %s $B$,B8:_$7$^$;$s(B..." file))
	    nil)
	(let ((str "")
	      (buf-name (file-name-nondirectory file)))
	  (save-excursion
	    (find-file-read-only file)
	    (setq str (with-current-buffer (get-buffer buf-name)
			(buffer-substring-no-properties (point-min) (point-max))))
	    (message (format "SKK $B<-=q(B %s $B$r3+$$$F$$$^$9(B...$B40N;!*(B" (file-name-nondirectory file)))
	    (kill-buffer-if-not-modified (get-buffer buf-name)))
	  str)))))

;;(sekka-get-jisyo-str "~/.sekka-jisyo")


;; $B%]!<%?%V%kJ8;zNsCV49(B( Emacs$B$H(BXEmacs$B$NN>J}$GF0$/(B )
(defun sekka-replace-regexp-in-string (regexp replace str)
  (cond ((featurep 'xemacs)
	 (replace-in-string str regexp replace))
	(t
	 (replace-regexp-in-string regexp replace str))))
	

;; $B%j!<%8%g%s$r%m!<%^;z4A;zJQ49$9$k4X?t(B
(defun sekka-henkan-region (b e)
  "$B;XDj$5$l$?(B region $B$r4A;zJQ49$9$k(B"
  (sekka-init)
  (when (/= b e)
    (let* (
	   (yomi (buffer-substring-no-properties b e))
	   (henkan-list (sekka-henkan-request yomi 0)))
      
      (if henkan-list
	  (condition-case err
	      (progn
		(setq
		 ;; $BJQ497k2L$NJ];}(B
		 sekka-henkan-kouho-list henkan-list
		 ;; $BJ8@aA*Br=i4|2=(B
		 sekka-cand-cur 0
		 ;; 
		 sekka-cand-len (length henkan-list))
		
		(sekka-debug-print (format "sekka-henkan-kouho-list:%s \n" sekka-henkan-kouho-list))
		(sekka-debug-print (format "sekka-cand-cur:%s \n" sekka-cand-cur))
		(sekka-debug-print (format "sekka-cand-len:%s \n" sekka-cand-len))
		;;
		t)
	    (sekka-trap-server-down
	     (beep)
	     (message (error-message-string err))
	     (setq sekka-select-mode nil))
	    (run-hooks 'sekka-select-mode-end-hook))
	nil))))


;; $B%+!<%=%kA0$NJ8;z<o$rJV5Q$9$k4X?t(B
(eval-and-compile
  (if (>= emacs-major-version 20)
      (progn
	(defalias 'sekka-char-charset (symbol-function 'char-charset))
	(when (and (boundp 'byte-compile-depth)
		   (not (fboundp 'char-category)))
	  (defalias 'char-category nil))) ; for byte compiler
    (defun sekka-char-charset (ch)
      (cond ((equal (char-category ch) "a") 'ascii)
	    ((equal (char-category ch) "k") 'katakana-jisx0201)
	    ((string-match "[SAHK]j" (char-category ch)) 'japanese-jisx0208)
	    (t nil) )) ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo $B>pJs$N@)8f(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo buffer $BB`HrMQJQ?t(B
(defvar sekka-buffer-undo-list nil)
(make-variable-buffer-local 'sekka-buffer-undo-list)
(defvar sekka-buffer-modified-p nil)
(make-variable-buffer-local 'sekka-buffer-modified-p)

(defvar sekka-blink-cursor nil)
(defvar sekka-cursor-type nil)
;; undo buffer $B$rB`Hr$7!"(Bundo $B>pJs$NC_@Q$rDd;_$9$k4X?t(B
(defun sekka-disable-undo ()
  (when (not (eq buffer-undo-list t))
    (setq sekka-buffer-undo-list buffer-undo-list)
    (setq sekka-buffer-modified-p (buffer-modified-p))
    (setq buffer-undo-list t)))

;; $BB`Hr$7$?(B undo buffer $B$rI|5"$7!"(Bundo $B>pJs$NC_@Q$r:F3+$9$k4X?t(B
(defun sekka-enable-undo ()
  (when (not sekka-buffer-modified-p) (set-buffer-modified-p nil))
  (when sekka-buffer-undo-list
    (setq buffer-undo-list sekka-buffer-undo-list)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B8=:_$NJQ49%(%j%"$NI=<($r9T$&(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-get-display-string ()
  ;; $BJQ497k2LJ8;zNs$rJV$9!#(B
  (let* ((kouho      (nth sekka-cand-cur sekka-henkan-kouho-list))
	 (_          (sekka-debug-print (format "sekka-cand-cur=%s\n" sekka-cand-cur)))
	 (_          (sekka-debug-print (format "kouho=%s\n" kouho)))
	 (word       (car kouho))
	 (annotation (cadr kouho)))
    (sekka-debug-print (format "word:[%d] %s(%s)\n" sekka-cand-cur word annotation))
    word))

(defun sekka-display-function (b e select-mode)
  (setq sekka-henkan-separeter (if sekka-use-fence " " ""))
  (when sekka-henkan-kouho-list
    ;; UNDO$BM^@)3+;O(B
    (sekka-disable-undo)
    
    (delete-region b e)

    ;; $B%j%9%H=i4|2=(B
    (setq sekka-markers '())

    (setq sekka-last-fix "")

    ;; $BJQ49$7$?(Bpoint$B$NJ];}(B
    (setq sekka-fence-start (point-marker))
    (when select-mode (insert "|"))
    
    (let* (
	   (start       (point-marker))
	   (_cur        sekka-cand-cur)
	   (_len        sekka-cand-len)
	   (insert-word (sekka-get-display-string)))
      (progn
	(insert insert-word)
	(message (format "[%s] candidate (%d/%d)" insert-word (+ _cur 1) _len))
	(let* ((end         (point-marker))
	       (ov          (make-overlay start end)))
	    
	  ;; $B3NDjJ8;zNs$N:n@.(B
	  (setq sekka-last-fix insert-word)
	   
	  ;; $BA*BrCf$N>l=j$rAu>~$9$k!#(B
	  (overlay-put ov 'face 'default)
	  (when select-mode
	    (overlay-put ov 'face 'highlight))
	  (setq sekka-markers (cons start end))
	  (sekka-debug-print (format "insert:[%s] point:%d-%d\n" insert-word (marker-position start) (marker-position end))))))

    ;; fence$B$NHO0O$r@_Dj$9$k(B
    (when select-mode (insert "|"))
    (setq sekka-fence-end   (point-marker))
    
    (sekka-debug-print (format "total-point:%d-%d\n"
			       (marker-position sekka-fence-start)
			       (marker-position sekka-fence-end)))
    ;; UNDO$B:F3+(B
    (sekka-enable-undo)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $BJQ498uJdA*Br%b!<%I(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((i 0))
  (while (<= i ?\177)
    (define-key sekka-select-mode-map (char-to-string i)
      'sekka-kakutei-and-self-insert)
    (setq i (1+ i))))
(define-key sekka-select-mode-map "\C-m"                   'sekka-select-kakutei)
(define-key sekka-select-mode-map "\C-g"                   'sekka-select-cancel)
(define-key sekka-select-mode-map "q"                      'sekka-select-cancel)
(define-key sekka-select-mode-map "\C-b"                   'sekka-select-prev-word)
(define-key sekka-select-mode-map "\C-f"                   'sekka-select-next-word)
(define-key sekka-select-mode-map "\C-a"                   'sekka-select-first-word)
(define-key sekka-select-mode-map "\C-e"                   'sekka-select-last-word)
(define-key sekka-select-mode-map "\C-p"                   'sekka-select-prev)
(define-key sekka-select-mode-map "\C-n"                   'sekka-select-next)
(define-key sekka-select-mode-map sekka-rK-trans-key       'sekka-select-next)
(define-key sekka-select-mode-map " "                      'sekka-select-next)
(define-key sekka-select-mode-map "\C-u"                   'sekka-select-hiragana)
(define-key sekka-select-mode-map "\C-i"                   'sekka-select-katakana)


;; $BJQ49$r3NDj$7F~NO$5$l$?%-!<$r:FF~NO$9$k4X?t(B
(defun sekka-kakutei-and-self-insert (arg)
  "$B8uJdA*Br$r3NDj$7!"F~NO$5$l$?J8;z$rF~NO$9$k(B"
  (interactive "P")
  (sekka-select-kakutei)
  (setq unread-command-events (list last-command-event)))

;; $B8uJdA*Br>uBV$G$NI=<(99?7(B
(defun sekka-select-update-display ()
  (sekka-display-function
   (marker-position sekka-fence-start)
   (marker-position sekka-fence-end)
   sekka-select-mode))


;; $B8uJdA*Br$r3NDj$9$k(B
(defun sekka-select-kakutei ()
  "$B8uJdA*Br$r3NDj$9$k(B"
  (interactive)
  ;; $B8uJdHV9f%j%9%H$r%P%C%/%"%C%W$9$k!#(B
  (setq sekka-cand-cur-backup sekka-cand-cur)
  ;; $B%5!<%P!<$K3NDj$7$?C18l$rEA$($k(B($B<-=q3X=,(B)
  (let* ((kouho      (nth sekka-cand-cur sekka-henkan-kouho-list))
	 (_          (sekka-debug-print (format "2:sekka-cand-cur=%s\n" sekka-cand-cur)))
	 (_          (sekka-debug-print (format "2:kouho=%s\n" kouho)))
	 (tango      (car kouho))
	 (key        (caddr kouho))
	 (kind (nth sekka-kind-index kouho)))
    (when (eq 'j kind)
      (sekka-kakutei-request key tango)))
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))


;; $B8uJdA*Br$r%-%c%s%;%k$9$k(B
(defun sekka-select-cancel ()
  "$B8uJdA*Br$r%-%c%s%;%k$9$k(B"
  (interactive)
  ;; $B%+%l%s%H8uJdHV9f$r%P%C%/%"%C%W$7$F$$$?8uJdHV9f$GI|85$9$k!#(B
  (setq sekka-cand-cur sekka-cand-cur-backup)
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))

;; $BA0$N8uJd$K?J$a$k(B
(defun sekka-select-prev ()
  "$BA0$N8uJd$K?J$a$k(B"
  (interactive)
  ;; $BA0$N8uJd$K@Z$j$+$($k(B
  (decf sekka-cand-cur)
  (when (> 0 sekka-cand-cur)
    (setq sekka-cand-cur (- sekka-cand-len 1)))
  (sekka-select-update-display))

;; $B<!$N8uJd$K?J$a$k(B
(defun sekka-select-next ()
  "$B<!$N8uJd$K?J$a$k(B"
  (interactive)
  ;; $B<!$N8uJd$K@Z$j$+$($k(B
  (setq sekka-cand-cur
	(if (< sekka-cand-cur (- sekka-cand-len 1))
	    (+ sekka-cand-cur 1)
	  0))
  (sekka-select-update-display))

;; $B;XDj$5$l$?(B type $B$N8uJd$rH4$-=P$9(B
(defun sekka-select-by-type-filter ( _type )
  (let ((lst '()))
    (mapcar
     (lambda (x)
       (let ((sym (nth sekka-kind-index x)))
	 (when (eq sym _type)
	   (push x lst))))
     sekka-henkan-kouho-list)
    (sekka-debug-print (format "filterd-lst = %S" lst))
    (car lst)))
    
;; $B;XDj$5$l$?(B type $B$N8uJd$K6/@)E*$K@Z$j$+$($k(B
(defun sekka-select-by-type ( _type )
  (let ((kouho (sekka-select-by-type-filter _type)))
    (if (null kouho)
	(cond 
	 ((eq _type 'h)
	  (message "Sekka: $B$R$i$,$J$N8uJd$O$"$j$^$;$s!#(B"))
	 ((eq _type 'k)
	  (message "Sekka: $B%+%?%+%J$N8uJd$O$"$j$^$;$s!#(B")))
      (let ((num   (nth sekka-id-index kouho)))
	(setq sekka-cand-cur num)
	(sekka-select-update-display)))))

(defun sekka-select-kanji ()
  "$B4A;z8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'j))

(defun sekka-select-hiragana ()
  "$B$R$i$,$J8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'h))

(defun sekka-select-katakana ()
  "$B%+%?%+%J8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'k))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B%m!<%^;z4A;zJQ494X?t(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-rK-trans ()
  "$B%m!<%^;z4A;zJQ49$r$9$k!#(B
$B!&%+!<%=%k$+$i9TF,J}8~$K%m!<%^;zNs$,B3$/HO0O$G%m!<%^;z4A;zJQ49$r9T$&!#(B"
  (interactive)
;  (print last-command)			; DEBUG

  (cond 
   ;; $B%?%$%^!<%$%Y%s%H$r@_Dj$7$J$$>r7o(B
   ((or
     sekka-timer
     (> 1 sekka-realtime-guide-running-seconds)
     ))
   (t
    ;; $B%?%$%^!<%$%Y%s%H4X?t$NEPO?(B
    (progn
      (let 
	  ((ov-point
	    (save-excursion
	      (forward-line 1)
	      (point))))
	  (setq sekka-guide-overlay
			(make-overlay ov-point ov-point (current-buffer))))
      (setq sekka-timer
			(run-at-time 0.1 sekka-realtime-guide-interval
						 'sekka-realtime-guide)))))

  ;; $B%,%$%II=<(7QB32s?t$N99?7(B
  (when (< 0 sekka-realtime-guide-running-seconds)
    (setq sekka-timer-rest  
	  (/ sekka-realtime-guide-running-seconds
	     sekka-realtime-guide-interval)))

  ;; $B:G8e$KJQ49$7$?9THV9f$N99?7(B
  (setq sekka-last-lineno (line-number-at-pos (point)))

  (cond
   (sekka-select-mode
    ;; $BJQ49Cf$K8F=P$5$l$?$i!"8uJdA*Br%b!<%I$K0\9T$9$k!#(B
    (funcall (lookup-key sekka-select-mode-map sekka-rK-trans-key)))


   (t
    (cond

     ((eq (sekka-char-charset (preceding-char)) 'ascii)
      ;; $B%+!<%=%kD>A0$,(B alphabet $B$@$C$?$i(B
      (let ((end (point))
	    (gap (sekka-skip-chars-backward)))
	(when (/= gap 0)
	  ;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$GJQ49$9$k(B
	  (let (
		(b (+ end gap))
		(e end))
	    (when (sekka-henkan-region b e)
	      (if (eq (char-before b) ?/)
		  (setq b (- b 1)))
	      (delete-region b e)
	      (goto-char b)
	      (insert (sekka-get-display-string))
	      (setq e (point))
	      (sekka-display-function b e nil)
	      (sekka-select-kakutei)
	      )))))

     
     ((sekka-kanji (preceding-char))
    
      ;; $B%+!<%=%kD>A0$,(B $BA43Q$G4A;z0J30(B $B$@$C$?$i8uJdA*Br%b!<%I$K0\9T$9$k!#(B
      ;; $B$^$?!":G8e$K3NDj$7$?J8;zNs$HF1$8$+$I$&$+$b3NG'$9$k!#(B
      (when (and
	     (<= (marker-position sekka-fence-start) (point))
	     (<= (point) (marker-position sekka-fence-end))
	     (string-equal sekka-last-fix (buffer-substring 
					   (marker-position sekka-fence-start)
					   (marker-position sekka-fence-end))))
	;; $BD>A0$KJQ49$7$?(Bfence$B$NHO0O$KF~$C$F$$$?$i!"JQ49%b!<%I$K0\9T$9$k!#(B
	(setq sekka-select-mode t)
	(sekka-debug-print "henkan mode ON\n")

	;; $BI=<(>uBV$r8uJdA*Br%b!<%I$K@ZBX$($k!#(B
	(sekka-display-function
	 (marker-position sekka-fence-start)
	 (marker-position sekka-fence-end)
	 t))))
     )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B%-%c%T%?%i%$%:(B/$B%"%s%-%c%T%?%i%$%:JQ49(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-capitalize-trans ()
  "$B%-%c%T%?%i%$%:JQ49$r9T$&(B
$B!&%+!<%=%k$+$i9TF,J}8~$K%m!<%^;zNs$r8+$D$1!"@hF,J8;z$NBgJ8;z>.J8;z$rH?E>$9$k(B"
  (interactive)

  (cond
   (sekka-select-mode
    ;; $B8uJdA*Br%b!<%I$G$OH?1~$7$J$$!#(B
    ;; do nothing
    )
   ((eq (sekka-char-charset (preceding-char)) 'ascii)
    ;; $B%+!<%=%kD>A0$,(B alphabet $B$@$C$?$i(B
    (sekka-debug-print "capitalize(2)!\n")

    (let ((end (point))
	  (gap (sekka-skip-chars-backward)))
      (when (/= gap 0)
	;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$GJQ49$9$k(B
	(let* (
	       (b (+ end gap))
	       (e end)
	       (roman-str (buffer-substring-no-properties b e)))
	  (sekka-debug-print (format "capitalize %d %d [%s]" b e roman-str))
	  (setq case-fold-search nil)
	  (cond
	   ((string-match-p "^[A-Z]" roman-str)
	    (downcase-region b (+ b 1)))
	   ((string-match-p "^[a-z]" roman-str)
	    (upcase-region   b (+ b 1))))))))
   ))


;; $BA43Q$G4A;z0J30$NH=Dj4X?t(B
(defun sekka-nkanji (ch)
  (and (eq (sekka-char-charset ch) 'japanese-jisx0208)
       (not (string-match "[$B0!(B-$Bt$(B]" (char-to-string ch)))))

(defun sekka-kanji (ch)
  (eq (sekka-char-charset ch) 'japanese-jisx0208))


;; $B%m!<%^;z4A;zJQ49;~!"JQ49BP>]$H$9$k%m!<%^;z$rFI$_Ht$P$94X?t(B
(defun sekka-skip-chars-backward ()
  (let* (
	 (skip-chars
	  (if auto-fill-function
	      ;; auto-fill-mode $B$,M-8z$K$J$C$F$$$k>l9g2~9T$,$"$C$F$b(Bskip$B$rB3$1$k(B
	      (concat sekka-skip-chars "\n")
	    ;; auto-fill-mode$B$,L58z$N>l9g$O$=$N$^$^(B
	    sekka-skip-chars))
	    
	 ;; $B%^!<%/$5$l$F$$$k0LCV$r5a$a$k!#(B
	 (pos (or (and (markerp (mark-marker)) (marker-position (mark-marker)))
		  1))

	 ;; $B>r7o$K%^%C%A$9$k4V!"A0J}J}8~$K%9%-%C%W$9$k!#(B
	 (result (save-excursion
		   (skip-chars-backward skip-chars (and (< pos (point)) pos))))
	 (limit-point 0))

    (if auto-fill-function
	;; auto-fill-mode$B$,M-8z$N;~(B
	(progn
	  (save-excursion
	    (backward-paragraph)
	    (when (< 1 (point))
	      (forward-line 1))
	    (goto-char (point-at-bol))
	    (let (
		  (start-point (point)))
	      (setq limit-point
		    (+
		     start-point
		     (skip-chars-forward (concat "\t " sekka-stop-chars) (point-at-eol))))))

	  ;; (sekka-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	  ;; (sekka-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

	  ;; $B%Q%i%0%i%U0LCV$G%9%H%C%W$9$k(B
	  (if (< (+ (point) result) limit-point)
	      (- 
	       limit-point
	       (point))
	    result))

      ;; auto-fill-mode$B$,L58z$N;~(B
      (progn
	(save-excursion
	  (goto-char (point-at-bol))
	  (let (
		(start-point (point)))
	    (setq limit-point
		  (+ 
		   start-point
		   (skip-chars-forward (concat "\t " sekka-stop-chars) (point-at-eol))))))

	;; (sekka-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	;; (sekka-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

	(if (< (+ (point) result) limit-point)
	    ;; $B%$%s%G%s%H0LCV$G%9%H%C%W$9$k!#(B
	    (- 
	     limit-point
	     (point))
	  result)))))

  
;;;
;;; with viper
;;;
;; code from skk-viper.el
(defun sekka-viper-normalize-map ()
  (let ((other-buffer
	 (if (featurep 'xemacs)
	     (local-variable-p 'minor-mode-map-alist nil t)
	   (local-variable-if-set-p 'minor-mode-map-alist))))
    ;; for current buffer and buffers to be created in the future.
    ;; substantially the same job as viper-harness-minor-mode does.
    (viper-normalize-minor-mode-map-alist)
    (setq-default minor-mode-map-alist minor-mode-map-alist)
    (when other-buffer
      ;; for buffers which are already created and have
      ;; the minor-mode-map-alist localized by Viper.
      (dolist (buf (buffer-list))
	(with-current-buffer buf
	  (unless (assq 'sekka-mode minor-mode-map-alist)
	    (setq minor-mode-map-alist
		  (append (list (cons 'sekka-mode sekka-mode-map)
				(cons 'sekka-select-mode
				      sekka-select-mode-map))
			  minor-mode-map-alist)))
	  (viper-normalize-minor-mode-map-alist))))))

(defun sekka-viper-init-function ()
  (sekka-viper-normalize-map)
  (remove-hook 'sekka-mode-hook 'sekka-viper-init-function))

(defun sekka-sticky-shift-init-function ()
  ;; sticky-shift
  (define-key global-map sticky-key sticky-map)
  (mapcar (lambda (pair)
	    (define-key sticky-map (car pair)
	      `(lambda()(interactive)
		 (if ,(< 0 (length (cdr pair)))
		     (setq unread-command-events
			   (cons ,(string-to-char (cdr pair)) unread-command-events))
		   nil))))
	  sticky-list)
  (define-key sticky-map sticky-key '(lambda ()(interactive)(insert sticky-key))))

(defun sekka-realtime-guide ()
  "$B%j%"%k%?%$%`$GJQ49Cf$N%,%$%I$r=P$9(B
sekka-mode$B$,(BON$B$N4VCf8F$S=P$5$l$k2DG=@-$,$"$k!#(B"
  (cond
   ((or (null sekka-mode)
	(> 1 sekka-timer-rest))
    (cancel-timer sekka-timer)
    (setq sekka-timer nil)
    (delete-overlay sekka-guide-overlay))
   (sekka-guide-overlay
    ;; $B;D$j2s?t$N%G%/%j%a%s%H(B
    (setq sekka-timer-rest (- sekka-timer-rest 1))

    ;; $B%+!<%=%k$,(Bsekka-realtime-guide-limit-lines $B$r$O$_=P$7$F$$$J$$$+%A%'%C%/(B
    (sekka-debug-print (format "sekka-last-lineno [%d] : current-line" sekka-last-lineno (line-number-at-pos (point))))
    (when (< 0 sekka-realtime-guide-limit-lines)
      (let ((diff-lines (abs (- (line-number-at-pos (point)) sekka-last-lineno))))
	(when (<= sekka-realtime-guide-limit-lines diff-lines)
	  (setq sekka-timer-rest 0))))

    (let* (
	   (end (point))
	   (gap (sekka-skip-chars-backward)))
      (if 
	  (or 
	   (when (fboundp 'minibufferp)
	     (minibufferp))
	   (= gap 0))
	  ;; $B>e2<%9%Z!<%9$,L5$$(B $B$^$?$O(B $BJQ49BP>]$,L5$7$J$i%,%$%I$OI=<($7$J$$!#(B
	  (overlay-put sekka-guide-overlay 'before-string "")
	;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$G%,%$%I$rI=<($9$k!#(B
	(let* (
	       (b (+ end gap))
	       (e end)
	       (str (buffer-substring-no-properties b e))
	       (lst (if (string-match "^[\s\t]+$" str)
			'()
		      (if (string= str sekka-guide-lastquery)
			  sekka-guide-lastresult
			(progn
			  (setq sekka-guide-lastquery str)
			  (setq sekka-guide-lastresult (sekka-henkan-request str 1))
			  sekka-guide-lastresult))))
	       (mess
		(if (< 0 (length lst))
		    (concat "[" (caar lst) "]")
		  "")))
	  (sekka-debug-print (format "realtime guide [%s]" str))
	  (move-overlay sekka-guide-overlay 
			;; disp-point (min (point-max) (+ disp-point 1))
			b e
			(current-buffer))
	  (overlay-put sekka-guide-overlay 'before-string mess))))
    (overlay-put sekka-guide-overlay 'face 'sekka-guide-face))))


;;;
;;; human interface
;;;
(define-key sekka-mode-map sekka-rK-trans-key 'sekka-rK-trans)
(define-key sekka-mode-map "\M-j" 'sekka-capitalize-trans)
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list 
		   (cons 'sekka-mode         sekka-mode-map))
		  minor-mode-map-alist)))



;; sekka-mode $B$N>uBVJQ994X?t(B
;;  $B@5$N0z?t$N>l9g!">o$K(B sekka-mode $B$r3+;O$9$k(B
;;  {$BIi(B,0}$B$N0z?t$N>l9g!">o$K(B sekka-mode $B$r=*N;$9$k(B
;;  $B0z?tL5$7$N>l9g!"(Bsekka-mode $B$r%H%0%k$9$k(B

;; buffer $BKh$K(B sekka-mode $B$rJQ99$9$k(B
(defun sekka-mode (&optional arg)
  "Sekka mode $B$O(B $B%m!<%^;z$+$iD>@\4A;zJQ49$9$k$?$a$N(B minor mode $B$G$9!#(B
$B0z?t$K@5?t$r;XDj$7$?>l9g$O!"(BSekka mode $B$rM-8z$K$7$^$9!#(B

Sekka $B%b!<%I$,M-8z$K$J$C$F$$$k>l9g(B \\<sekka-mode-map>\\[sekka-rK-trans] $B$G(B
point $B$+$i9TF,J}8~$KF1<o$NJ8;zNs$,B3$/4V$r4A;zJQ49$7$^$9!#(B

$BF1<o$NJ8;zNs$H$O0J2<$N$b$N$r;X$7$^$9!#(B
$B!&H>3Q%+%?%+%J$H(Bsekka-stop-chars $B$K;XDj$7$?J8;z$r=|$/H>3QJ8;z(B
$B!&4A;z$r=|$/A43QJ8;z(B"
  (interactive "P")
  (sekka-mode-internal arg nil))

;; $BA4%P%C%U%!$G(B sekka-mode $B$rJQ99$9$k(B
(defun global-sekka-mode (&optional arg)
  "Sekka mode $B$O(B $B%m!<%^;z$+$iD>@\4A;zJQ49$9$k$?$a$N(B minor mode $B$G$9!#(B
$B0z?t$K@5?t$r;XDj$7$?>l9g$O!"(BSekka mode $B$rM-8z$K$7$^$9!#(B

Sekka $B%b!<%I$,M-8z$K$J$C$F$$$k>l9g(B \\<sekka-mode-map>\\[sekka-rK-trans] $B$G(B
point $B$+$i9TF,J}8~$KF1<o$NJ8;zNs$,B3$/4V$r4A;zJQ49$7$^$9!#(B

$BF1<o$NJ8;zNs$H$O0J2<$N$b$N$r;X$7$^$9!#(B
$B!&H>3Q%+%?%+%J$H(Bsekka-stop-chars $B$K;XDj$7$?J8;z$r=|$/H>3QJ8;z(B
$B!&4A;z$r=|$/A43QJ8;z(B"
  (interactive "P")
  (sekka-mode-internal arg t))


;; sekka-mode $B$rJQ99$9$k6&DL4X?t(B
(defun sekka-mode-internal (arg global)
  (or (local-variable-p 'sekka-mode (current-buffer))
      (make-local-variable 'sekka-mode))
  (if global
      (progn
	(setq-default sekka-mode (if (null arg) (not sekka-mode)
				    (> (prefix-numeric-value arg) 0)))
	(sekka-kill-sekka-mode))
    (setq sekka-mode (if (null arg) (not sekka-mode)
			(> (prefix-numeric-value arg) 0))))
  (when sekka-use-viper
    (add-hook 'sekka-mode-hook 'sekka-viper-init-function))
  (when sekka-sticky-shift
    (add-hook 'sekka-mode-hook 'sekka-sticky-shift-init-function))
  (when sekka-mode (run-hooks 'sekka-mode-hook)))


;; buffer local $B$J(B sekka-mode $B$r:o=|$9$k4X?t(B
(defun sekka-kill-sekka-mode ()
  (let ((buf (buffer-list)))
    (while buf
      (set-buffer (car buf))
      (kill-local-variable 'sekka-mode)
      (setq buf (cdr buf)))))


;; $BA4%P%C%U%!$G(B sekka-input-mode $B$rJQ99$9$k(B
(defun sekka-input-mode (&optional arg)
  "$BF~NO%b!<%IJQ99(B"
  (interactive "P")
  (if (< 0 arg)
      (progn
	(setq inactivate-current-input-method-function 'sekka-inactivate)
	(setq sekka-mode t))
    (setq inactivate-current-input-method-function nil)
    (setq sekka-mode nil)))


;; input method $BBP1~(B
(defun sekka-activate (&rest arg)
  (sekka-input-mode 1))
(defun sekka-inactivate (&rest arg)
  (sekka-input-mode -1))
(register-input-method
 "japanese-sekka" "Japanese" 'sekka-activate
 "" "Roman -> Kanji&Kana"
 nil)

;; input-method $B$H$7$FEPO?$9$k!#(B
(set-language-info "Japanese" 'input-method "japanese-sekka")
(setq default-input-method "japanese-sekka")

(defconst sekka-version
  " $Date: 2007/07/23 15:40:49 $ on CVS " ;;VERSION;;
  )
(defun sekka-version (&optional arg)
  "$BF~NO%b!<%IJQ99(B"
  (interactive "P")
  (message sekka-version))

(provide 'sekka)
