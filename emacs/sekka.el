;;;-*- mode: lisp-interaction; syntax: elisp ; coding: iso-2022-jp -*-"
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
;;

;;;     $BG[I[>r7o(B: GPL
;;; $B:G?7HGG[I[85(B: 
;;; 
;;; $BITL@$JE@$d2~A1$7$?$$E@$,$"$l$P(BSumibi$B$N%a!<%j%s%0%j%9%H$K;22C$7$F%U%#!<%I%P%C%/$r$*$M$,$$$7$^$9!#(B
;;;
;;; $B$^$?!"(BSekka$B$K6=L#$r;}$C$F$$$?$@$$$?J}$O$I$J$?$G$b(B
;;; $B5$7Z$K%W%m%8%'%/%H$K$4;22C$/$@$5$$!#(B
;;;
;;;

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

(defcustom sekka-server-url "https://sekka.org/cgi-bin/sekka/testing/sekka.cgi"
  "Sekka$B%5!<%P!<$N(BURL$B$r;XDj$9$k!#(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-server-cert-data
  "-----BEGIN CERTIFICATE-----
MIIE3jCCA8agAwIBAgICAwEwDQYJKoZIhvcNAQEFBQAwYzELMAkGA1UEBhMCVVMx
ITAfBgNVBAoTGFRoZSBHbyBEYWRkeSBHcm91cCwgSW5jLjExMC8GA1UECxMoR28g
RGFkZHkgQ2xhc3MgMiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0wNjExMTYw
MTU0MzdaFw0yNjExMTYwMTU0MzdaMIHKMQswCQYDVQQGEwJVUzEQMA4GA1UECBMH
QXJpem9uYTETMBEGA1UEBxMKU2NvdHRzZGFsZTEaMBgGA1UEChMRR29EYWRkeS5j
b20sIEluYy4xMzAxBgNVBAsTKmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5j
b20vcmVwb3NpdG9yeTEwMC4GA1UEAxMnR28gRGFkZHkgU2VjdXJlIENlcnRpZmlj
YXRpb24gQXV0aG9yaXR5MREwDwYDVQQFEwgwNzk2OTI4NzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMQt1RWMnCZM7DI161+4WQFapmGBWTtwY6vj3D3H
KrjJM9N55DrtPDAjhI6zMBS2sofDPZVUBJ7fmd0LJR4h3mUpfjWoqVTr9vcyOdQm
VZWt7/v+WIbXnvQAjYwqDL1CBM6nPwT27oDyqu9SoWlm2r4arV3aLGbqGmu75RpR
SgAvSMeYddi5Kcju+GZtCpyz8/x4fKL4o/K1w/O5epHBp+YlLpyo7RJlbmr2EkRT
cDCVw5wrWCs9CHRK8r5RsL+H0EwnWGu1NcWdrxcx+AuP7q2BNgWJCJjPOq8lh8BJ
6qf9Z/dFjpfMFDniNoW1fho3/Rb2cRGadDAW/hOUoz+EDU8CAwEAAaOCATIwggEu
MB0GA1UdDgQWBBT9rGEyk2xF1uLuhV+auud2mWjM5zAfBgNVHSMEGDAWgBTSxLDS
kdRMEXGzYcs9of7dqGrU4zASBgNVHRMBAf8ECDAGAQH/AgEAMDMGCCsGAQUFBwEB
BCcwJTAjBggrBgEFBQcwAYYXaHR0cDovL29jc3AuZ29kYWRkeS5jb20wRgYDVR0f
BD8wPTA7oDmgN4Y1aHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNvbS9yZXBv
c2l0b3J5L2dkcm9vdC5jcmwwSwYDVR0gBEQwQjBABgRVHSAAMDgwNgYIKwYBBQUH
AgEWKmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5jb20vcmVwb3NpdG9yeTAO
BgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQEFBQADggEBANKGwOy9+aG2Z+5mC6IG
OgRQjhVyrEp0lVPLN8tESe8HkGsz2ZbwlFalEzAFPIUyIXvJxwqoJKSQ3kbTJSMU
A2fCENZvD117esyfxVgqwcSeIaha86ykRvOe5GPLL5CkKSkB2XIsKd83ASe8T+5o
0yGPwLPk9Qnt0hCqU7S+8MxZC9Y7lhyVJEnfzuz9p0iRFEUOOjZv2kWzRaJBydTX
RE4+uXR21aITVSzGh6O1mawGhId/dQb8vxRMDsxuxN89txJx9OjxUUAiKEngHUuH
qDTMBqLdElrRhjZkAzVvb3du6/KFUJheqwNTrZEjYx8WnM25sgVjOuH0aBsXBTWV
U+4=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIE+zCCBGSgAwIBAgICAQ0wDQYJKoZIhvcNAQEFBQAwgbsxJDAiBgNVBAcTG1Zh
bGlDZXJ0IFZhbGlkYXRpb24gTmV0d29yazEXMBUGA1UEChMOVmFsaUNlcnQsIElu
Yy4xNTAzBgNVBAsTLFZhbGlDZXJ0IENsYXNzIDIgUG9saWN5IFZhbGlkYXRpb24g
QXV0aG9yaXR5MSEwHwYDVQQDExhodHRwOi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAe
BgkqhkiG9w0BCQEWEWluZm9AdmFsaWNlcnQuY29tMB4XDTA0MDYyOTE3MDYyMFoX
DTI0MDYyOTE3MDYyMFowYzELMAkGA1UEBhMCVVMxITAfBgNVBAoTGFRoZSBHbyBE
YWRkeSBHcm91cCwgSW5jLjExMC8GA1UECxMoR28gRGFkZHkgQ2xhc3MgMiBDZXJ0
aWZpY2F0aW9uIEF1dGhvcml0eTCCASAwDQYJKoZIhvcNAQEBBQADggENADCCAQgC
ggEBAN6d1+pXGEmhW+vXX0iG6r7d/+TvZxz0ZWizV3GgXne77ZtJ6XCAPVYYYwhv
2vLM0D9/AlQiVBDYsoHUwHU9S3/Hd8M+eKsaA7Ugay9qK7HFiH7Eux6wwdhFJ2+q
N1j3hybX2C32qRe3H3I2TqYXP2WYktsqbl2i/ojgC95/5Y0V4evLOtXiEqITLdiO
r18SPaAIBQi2XKVlOARFmR6jYGB0xUGlcmIbYsUfb18aQr4CUWWoriMYavx4A6lN
f4DD+qta/KFApMoZFv6yyO9ecw3ud72a9nmYvLEHZ6IVDd2gWMZEewo+YihfukEH
U1jPEX44dMX4/7VpkI+EdOqXG68CAQOjggHhMIIB3TAdBgNVHQ4EFgQU0sSw0pHU
TBFxs2HLPaH+3ahq1OMwgdIGA1UdIwSByjCBx6GBwaSBvjCBuzEkMCIGA1UEBxMb
VmFsaUNlcnQgVmFsaWRhdGlvbiBOZXR3b3JrMRcwFQYDVQQKEw5WYWxpQ2VydCwg
SW5jLjE1MDMGA1UECxMsVmFsaUNlcnQgQ2xhc3MgMiBQb2xpY3kgVmFsaWRhdGlv
biBBdXRob3JpdHkxITAfBgNVBAMTGGh0dHA6Ly93d3cudmFsaWNlcnQuY29tLzEg
MB4GCSqGSIb3DQEJARYRaW5mb0B2YWxpY2VydC5jb22CAQEwDwYDVR0TAQH/BAUw
AwEB/zAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLmdv
ZGFkZHkuY29tMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jZXJ0aWZpY2F0ZXMu
Z29kYWRkeS5jb20vcmVwb3NpdG9yeS9yb290LmNybDBLBgNVHSAERDBCMEAGBFUd
IAAwODA2BggrBgEFBQcCARYqaHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNv
bS9yZXBvc2l0b3J5MA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQUFAAOBgQC1
QPmnHfbq/qQaQlpE9xXUhUaJwL6e4+PrxeNYiY+Sn1eocSxI0YGyeR+sBjUZsE4O
WBsUs5iB0QQeyAfJg594RAoYC5jcdnplDQ1tgMQLARzLrUc+cb53S8wGd9D0Vmsf
SxOaFIqII6hR8INMqzW/Rn453HWkrugp++85j09VZw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIC5zCCAlACAQEwDQYJKoZIhvcNAQEFBQAwgbsxJDAiBgNVBAcTG1ZhbGlDZXJ0
IFZhbGlkYXRpb24gTmV0d29yazEXMBUGA1UEChMOVmFsaUNlcnQsIEluYy4xNTAz
BgNVBAsTLFZhbGlDZXJ0IENsYXNzIDIgUG9saWN5IFZhbGlkYXRpb24gQXV0aG9y
aXR5MSEwHwYDVQQDExhodHRwOi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAeBgkqhkiG
9w0BCQEWEWluZm9AdmFsaWNlcnQuY29tMB4XDTk5MDYyNjAwMTk1NFoXDTE5MDYy
NjAwMTk1NFowgbsxJDAiBgNVBAcTG1ZhbGlDZXJ0IFZhbGlkYXRpb24gTmV0d29y
azEXMBUGA1UEChMOVmFsaUNlcnQsIEluYy4xNTAzBgNVBAsTLFZhbGlDZXJ0IENs
YXNzIDIgUG9saWN5IFZhbGlkYXRpb24gQXV0aG9yaXR5MSEwHwYDVQQDExhodHRw
Oi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAeBgkqhkiG9w0BCQEWEWluZm9AdmFsaWNl
cnQuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDOOnHK5avIWZJV16vY
dA757tn2VUdZZUcOBVXc65g2PFxTXdMwzzjsvUGJ7SVCCSRrCl6zfN1SLUzm1NZ9
WlmpZdRJEy0kTRxQb7XBhVQ7/nHk01xC+YDgkRoKWzk2Z/M/VXwbP7RfZHM047QS
v4dk+NoS/zcnwbNDu+97bi5p9wIDAQABMA0GCSqGSIb3DQEBBQUAA4GBADt/UG9v
UJSZSWI4OB9L+KXIPqeCgfYrx+jFzug6EILLGACOTb2oWH+heQC1u+mNr0HZDzTu
IYEZoDJJKPTEjlbVUjP9UNV+mWwD5MlM/Mtsq2azSiGM5bUMMj4QssxsodyamEwC
W/POuZ6lcg5Ktz885hZo+L7tdEy8W9ViH0Pd
-----END CERTIFICATE-----
"
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N(BSSL$B>ZL@=q%G!<%?!#(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-server-use-cert t
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N(BSSL$B>ZL@=q$r;H$&$+$I$&$+!#(B"
  :type  'symbol
  :group 'sekka)

(defcustom sekka-server-timeout 10
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N%?%$%`%"%&%H$r;XDj$9$k!#(B($BIC?t(B)"
  :type  'integer
  :group 'sekka)
 
(defcustom sekka-stop-chars ";:(){}<>"
  "*$B4A;zJQ49J8;zNs$r<h$j9~$`;~$KJQ49HO0O$K4^$a$J$$J8;z$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-replace-keyword-list '(
					 ("no" . "no.h")
					 ("ha" . "ha.h")
					 ("ga" . "ga.h")
					 ("wo" . "wo.h")
					 ("ni" . "ni.h")
					 ("de" . "de.h"))

  "Sekka$B%5!<%P!<$KJ8;zNs$rAw$kA0$KCV49$9$k%-!<%o!<%I$r@_Dj$9$k(B"
  :type  'sexp
  :group 'sekka)

(defcustom sekka-curl "curl"
  "curl$B%3%^%s%I$N@dBP%Q%9$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-use-viper nil
  "*Non-nil $B$G$"$l$P!"(BVIPER $B$KBP1~$9$k(B"
  :type 'boolean
  :group 'sekka)

(defcustom sekka-realtime-guide-running-seconds 60
  "$B%j%"%k%?%$%`%,%$%II=<($N7QB3;~4V(B($BIC?t(B)$B!&%<%m$G%,%$%II=<(5!G=$,L58z$K$J$k(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-interval  0.5
  "$B%j%"%k%?%$%`%,%$%II=<($r99?7$9$k;~4V4V3V(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-history-filename  "~/.sekka_history"
  "$B%f!<%6!<8GM-$NJQ49MzNr$rJ]B8$9$k%U%!%$%kL>(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-history-feature  t
  "Non-nil$B$G$"$l$P!"%f!<%6!<8GM-$NJQ49MzNr$rM-8z$K$9$k(B"
  :type  'boolean
  :group 'sekka)

(defcustom sekka-history-max  100
  "$B%f!<%6!<8GM-$NJQ49MzNr$N:GBgJ]B87o?t$r;XDj$9$k(B($B:G?7$+$i;XDj7o?t$N$_$,J]B8$5$l$k(B)"
  :type  'integer
  :group 'sekka)


(defface sekka-guide-face
  '((((class color) (background light)) (:background "#E0E0E0" :foreground "#F03030")))
  "$B%j%"%k%?%$%`%,%$%I$N%U%'%$%9(B($BAu>~!"?'$J$I$N;XDj(B)"
  :group 'sekka)


(defvar sekka-mode nil             "$B4A;zJQ49%H%0%kJQ?t(B")
(defvar sekka-mode-line-string     " Sekka")
(defvar sekka-select-mode nil      "$B8uJdA*Br%b!<%IJQ?t(B")
(or (assq 'sekka-mode minor-mode-alist)
    (setq minor-mode-alist (cons
			    '(sekka-mode        sekka-mode-line-string)
			    minor-mode-alist)))


;; $B%m!<%^;z4A;zJQ49;~!"BP>]$H$9$k%m!<%^;z$r@_Dj$9$k$?$a$NJQ?t(B
(defvar sekka-skip-chars "a-zA-Z0-9 .,\\-+!\\[\\]?")
(defvar sekka-mode-map        (make-sparse-keymap)         "$B4A;zJQ49%H%0%k%^%C%W(B")
(defvar sekka-select-mode-map (make-sparse-keymap)         "$B8uJdA*Br%b!<%I%^%C%W(B")
(defvar sekka-rK-trans-key "\C-j"
  "*$B4A;zJQ49%-!<$r@_Dj$9$k(B")
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list (cons 'sekka-mode         sekka-mode-map)
			(cons 'sekka-select-mode  sekka-select-mode-map))
		  minor-mode-map-alist)))

;; $B%f!<%6!<3X=,<-=q(B
(defvar sekka-kakutei-history          '())    ;; ( ( unix$B;~4V(B $BC18l(BID$B$N%j%9%H(B ) ( unix$B;~4V(B 9412 1028 ) )
(defvar sekka-kakutei-history-saved    '())    ;; $B%U%!%$%k$KJ]B8$5$l$?$[$&$N%R%9%H%j%G!<%?(B)

;;;
;;; hooks
;;;
(defvar sekka-mode-hook nil)
(defvar sekka-select-mode-hook nil)
(defvar sekka-select-mode-end-hook nil)

(defconst sekka-kind-index   0)
(defconst sekka-tango-index  1)
(defconst sekka-id-index     2)
(defconst sekka-wordno-index 3)
(defconst sekka-candno-index 4)
(defconst sekka-spaces-index 5)

(defconst sekka-hiragana->katakana-table
  (mapcar
   (lambda (c)
     (cons
      (char-to-string c)
      (char-to-string
       (+ c
	  (- 
	   (string-to-char "$B%"(B")
	   (string-to-char "$B$"(B"))))))
   (string-to-list
    (concat 
     "$B$"$$$&$($*(B"
     "$B$!$#$%$'$)(B"
     "$B$+$-$/$1$3(B"
     "$B$,$.$0$2$4(B"
     "$B$5$7$9$;$=(B"
     "$B$6$8$:$<$>(B"
     "$B$?$A$D$F$H(B"
     "$B$@$E$E$G$I(B"
     "$B$J$K$L$M$N(B"
     "$B$O$R$U$X$[(B"
     "$B$P$S$V$Y$\(B"
     "$B$Q$T$W$Z$](B"
     "$B$^$_$`$a$b(B"
     "$B$d$f$h(B"
     "$B$c$e$g(B"
     "$B$i$j$k$l$m(B"
     "$B$o$r(B"
     "$B$C$s(B"))))


(defconst sekka-roman->kana-table
  '(("kkya" . "$B$C$-$c(B")
    ("kkyu" . "$B$C$-$e(B")
    ("kkyo" . "$B$C$-$g(B")
    ("ggya" . "$B$C$.$c(B")
    ("ggyu" . "$B$C$.$e(B")
    ("ggyo" . "$B$C$.$g(B")
    ("sshi" . "$B$C$7(B")
    ("ssha" . "$B$C$7$c(B")
    ("sshu" . "$B$C$7$e(B")
    ("sshe" . "$B$C$7$'(B")
    ("ssho" . "$B$C$7$g(B")
    ("cchi" . "$B$C$A(B")
    ("ccha" . "$B$C$A$c(B")
    ("cchu" . "$B$C$A$e(B")
    ("cche" . "$B$C$A$'(B")
    ("ccho" . "$B$C$A$g(B")
    ("ddya" . "$B$C$B$c(B")
    ("ddyu" . "$B$C$B$e(B")
    ("ddye" . "$B$C$B$'(B")
    ("ddyo" . "$B$C$B$g(B")
    ("ttsu" . "$B$C$D(B")
    ("hhya" . "$B$C$R$c(B")
    ("hhyu" . "$B$C$R$e(B")
    ("hhyo" . "$B$C$R$g(B")
    ("bbya" . "$B$C$S$c(B")
    ("bbyu" . "$B$C$S$e(B")
    ("bbyo" . "$B$C$S$g(B")
    ("ppya" . "$B$C$T$c(B")
    ("ppyu" . "$B$C$T$e(B")
    ("ppyo" . "$B$C$T$g(B")
    ("rrya" . "$B$C$j$c(B")
    ("rryu" . "$B$C$j$e(B")
    ("rryo" . "$B$C$j$g(B")
    ("ddyi" . "$B$C$G$#(B")
    ("ddhi" . "$B$C$G$#(B")
    ("xtsu" . "$B$C(B")
    ("ttya" . "$B$C$A$c(B")
    ("ttyi" . "$B$C$A(B")
    ("ttyu" . "$B$C$A$e(B")
    ("ttye" . "$B$C$A$'(B")
    ("ttyo" . "$B$C$A$g(B")
    ("kya" . "$B$-$c(B")
    ("kyu" . "$B$-$e(B")
    ("kyo" . "$B$-$g(B")
    ("gya" . "$B$.$c(B")
    ("gyu" . "$B$.$e(B")
    ("gyo" . "$B$.$g(B")
    ("shi" . "$B$7(B")
    ("sha" . "$B$7$c(B")
    ("shu" . "$B$7$e(B")
    ("she" . "$B$7$'(B")
    ("sho" . "$B$7$g(B")
    ("chi" . "$B$A(B")
    ("cha" . "$B$A$c(B")
    ("chu" . "$B$A$e(B")
    ("che" . "$B$A$'(B")
    ("cho" . "$B$A$g(B")
    ("dya" . "$B$B$c(B")
    ("dyu" . "$B$B$e(B")
    ("dye" . "$B$B$'(B")
    ("dyo" . "$B$B$g(B")
    ("vvu" . "$B$C$&!+(B")
    ("vva" . "$B$C$&!+$!(B")
    ("vvi" . "$B$C$&!+$#(B")
    ("vve" . "$B$C$&!+$'(B")
    ("vvo" . "$B$C$&!+$)(B")
    ("kka" . "$B$C$+(B")
    ("gga" . "$B$C$,(B")
    ("kki" . "$B$C$-(B")
    ("ggi" . "$B$C$.(B")
    ("kku" . "$B$C$/(B")
    ("ggu" . "$B$C$0(B")
    ("kke" . "$B$C$1(B")
    ("gge" . "$B$C$2(B")
    ("kko" . "$B$C$3(B")
    ("ggo" . "$B$C$4(B")
    ("ssa" . "$B$C$5(B")
    ("zza" . "$B$C$6(B")
    ("jji" . "$B$C$8(B")
    ("jja" . "$B$C$8$c(B")
    ("jju" . "$B$C$8$e(B")
    ("jje" . "$B$C$8$'(B")
    ("jjo" . "$B$C$8$g(B")
    ("ssu" . "$B$C$9(B")
    ("zzu" . "$B$C$:(B")
    ("sse" . "$B$C$;(B")
    ("zze" . "$B$C$<(B")
    ("sso" . "$B$C$=(B")
    ("zzo" . "$B$C$>(B")
    ("tta" . "$B$C$?(B")
    ("dda" . "$B$C$@(B")
    ("ddi" . "$B$C$B(B")
    ("ddu" . "$B$C$E(B")
    ("tte" . "$B$C$F(B")
    ("dde" . "$B$C$G(B")
    ("tto" . "$B$C$H(B")
    ("ddo" . "$B$C$I(B")
    ("hha" . "$B$C$O(B")
    ("bba" . "$B$C$P(B")
    ("ppa" . "$B$C$Q(B")
    ("hhi" . "$B$C$R(B")
    ("bbi" . "$B$C$S(B")
    ("ppi" . "$B$C$T(B")
    ("ffu" . "$B$C$U(B")
    ("ffa" . "$B$C$U$!(B")
    ("ffi" . "$B$C$U$#(B")
    ("ffe" . "$B$C$U$'(B")
    ("ffo" . "$B$C$U$)(B")
    ("bbu" . "$B$C$V(B")
    ("ppu" . "$B$C$W(B")
    ("hhe" . "$B$C$X(B")
    ("bbe" . "$B$C$Y(B")
    ("ppe" . "$B$C$Z(B")
    ("hho" . "$B$C$[(B")
    ("bbo" . "$B$C$\(B")
    ("ppo" . "$B$C$](B")
    ("yya" . "$B$C$d(B")
    ("yyu" . "$B$C$f(B")
    ("yyo" . "$B$C$h(B")
    ("rra" . "$B$C$i(B")
    ("rri" . "$B$C$j(B")
    ("rru" . "$B$C$k(B")
    ("rre" . "$B$C$l(B")
    ("rro" . "$B$C$m(B")
    ("tsu" . "$B$D(B")
    ("nya" . "$B$K$c(B")
    ("nyu" . "$B$K$e(B")
    ("nyo" . "$B$K$g(B")
    ("hya" . "$B$R$c(B")
    ("hyu" . "$B$R$e(B")
    ("hyo" . "$B$R$g(B")
    ("bya" . "$B$S$c(B")
    ("byu" . "$B$S$e(B")
    ("byo" . "$B$S$g(B")
    ("pya" . "$B$T$c(B")
    ("pyu" . "$B$T$e(B")
    ("pyo" . "$B$T$g(B")
    ("mya" . "$B$_$c(B")
    ("myu" . "$B$_$e(B")
    ("myo" . "$B$_$g(B")
    ("xya" . "$B$c(B")
    ("xyu" . "$B$e(B")
    ("xyo" . "$B$g(B")
    ("rya" . "$B$j$c(B")
    ("ryu" . "$B$j$e(B")
    ("ryo" . "$B$j$g(B")
    ("xwa" . "$B$n(B")
    ("dyi" . "$B$G$#(B")
    ("thi" . "$B$F$#(B")
    ("hhu" . "$B$C$U(B")
    ("shu" . "$B$7$e(B")
    ("chu" . "$B$A$e(B")
    ("sya" . "$B$7$c(B")
    ("syu" . "$B$7$e(B")
    ("sye" . "$B$7$'(B")
    ("syo" . "$B$7$g(B")
    ("jya" . "$B$8$c(B")
    ("jyu" . "$B$8$e(B")
    ("jye" . "$B$8$'(B")
    ("jyo" . "$B$8$g(B")
    ("zya" . "$B$8$c(B")
    ("zyu" . "$B$8$e(B")
    ("zye" . "$B$8$'(B")
    ("zyo" . "$B$8$g(B")
    ("tya" . "$B$A$c(B")
    ("tyi" . "$B$A(B")
    ("tyu" . "$B$A$e(B")
    ("tye" . "$B$A$'(B")
    ("tyo" . "$B$A$g(B")
    ("dhi" . "$B$G$#(B")
    ("xtu" . "$B$C(B")
    ("xa" . "$B$!(B")
    ("xi" . "$B$#(B")
    ("xu" . "$B$%(B")
    ("vu" . "$B$&!+(B")
    ("va" . "$B$&!+$!(B")
    ("vi" . "$B$&!+$#(B")
    ("ve" . "$B$&!+$'(B")
    ("vo" . "$B$&!+$)(B")
    ("xe" . "$B$'(B")
    ("xo" . "$B$)(B")
    ("ka" . "$B$+(B")
    ("ga" . "$B$,(B")
    ("ki" . "$B$-(B")
    ("gi" . "$B$.(B")
    ("ku" . "$B$/(B")
    ("gu" . "$B$0(B")
    ("ke" . "$B$1(B")
    ("ge" . "$B$2(B")
    ("ko" . "$B$3(B")
    ("go" . "$B$4(B")
    ("sa" . "$B$5(B")
    ("za" . "$B$6(B")
    ("ji" . "$B$8(B")
    ("ja" . "$B$8$c(B")
    ("ju" . "$B$8$e(B")
    ("je" . "$B$8$'(B")
    ("jo" . "$B$8$g(B")
    ("su" . "$B$9(B")
    ("zu" . "$B$:(B")
    ("se" . "$B$;(B")
    ("ze" . "$B$<(B")
    ("so" . "$B$=(B")
    ("zo" . "$B$>(B")
    ("ta" . "$B$?(B")
    ("da" . "$B$@(B")
    ("di" . "$B$B(B")
    ("tt" . "$B$C(B")
    ("du" . "$B$E(B")
    ("te" . "$B$F(B")
    ("de" . "$B$G(B")
    ("to" . "$B$H(B")
    ("do" . "$B$I(B")
    ("na" . "$B$J(B")
    ("ni" . "$B$K(B")
    ("nu" . "$B$L(B")
    ("ne" . "$B$M(B")
    ("no" . "$B$N(B")
    ("ha" . "$B$O(B")
    ("ba" . "$B$P(B")
    ("pa" . "$B$Q(B")
    ("hi" . "$B$R(B")
    ("bi" . "$B$S(B")
    ("pi" . "$B$T(B")
    ("fu" . "$B$U(B")
    ("fa" . "$B$U$!(B")
    ("fi" . "$B$U$#(B")
    ("fe" . "$B$U$'(B")
    ("fo" . "$B$U$)(B")
    ("bu" . "$B$V(B")
    ("pu" . "$B$W(B")
    ("he" . "$B$X(B")
    ("be" . "$B$Y(B")
    ("pe" . "$B$Z(B")
    ("ho" . "$B$[(B")
    ("bo" . "$B$\(B")
    ("po" . "$B$](B")
    ("ma" . "$B$^(B")
    ("mi" . "$B$_(B")
    ("mu" . "$B$`(B")
    ("me" . "$B$a(B")
    ("mo" . "$B$b(B")
    ("ya" . "$B$d(B")
    ("yu" . "$B$f(B")
    ("yo" . "$B$h(B")
    ("ra" . "$B$i(B")
    ("ri" . "$B$j(B")
    ("ru" . "$B$k(B")
    ("re" . "$B$l(B")
    ("ro" . "$B$m(B")
    ("wa" . "$B$o(B")
    ("wi" . "$B$p(B")
    ("we" . "$B$q(B")
    ("wo" . "$B$r(B")
    ("n'" . "$B$s(B")
    ("nn" . "$B$s(B")
    ("ca" . "$B$+(B")
    ("ci" . "$B$-(B")
    ("cu" . "$B$/(B")
    ("ce" . "$B$1(B")
    ("co" . "$B$3(B")
    ("si" . "$B$7(B")
    ("ti" . "$B$A(B")
    ("hu" . "$B$U(B")
    ("tu" . "$B$D(B")
    ("zi" . "$B$8(B")
    ("la" . "$B$!(B")
    ("li" . "$B$#(B")
    ("lu" . "$B$%(B")
    ("le" . "$B$'(B")
    ("lo" . "$B$)(B")
    ("a" . "$B$"(B")
    ("i" . "$B$$(B")
    ("u" . "$B$&(B")
    ("e" . "$B$((B")
    ("o" . "$B$*(B")
    ("n" . "$B$s(B")
    ("-" . "$B!<(B")
    ("^" . "$B!<(B")))


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
(defvar sekka-fence-start nil)		; fence $B;OC<0LCV(B
(defvar sekka-fence-end nil)		; fence $B=*C<0LCV(B
(defvar sekka-henkan-separeter " ")	; fence mode separeter
(defvar sekka-henkan-buffer nil)	; $BI=<(MQ%P%C%U%!(B
(defvar sekka-henkan-length nil)	; $BI=<(MQ%P%C%U%!D9(B
(defvar sekka-henkan-revpos nil)	; $BJ8@a;OC<0LCV(B
(defvar sekka-henkan-revlen nil)	; $BJ8@aD9(B

;;; sekka basic local
(defvar sekka-cand     nil)		; $B%+%l%s%HJ8@aHV9f(B
(defvar sekka-cand-n   nil)		; $BJ8@a8uJdHV9f(B
(defvar sekka-cand-n-backup   nil)	; $BJ8@a8uJdHV9f(B ( $B8uJdA*Br%-%c%s%;%kMQ(B )
(defvar sekka-cand-max nil)		; $BJ8@a8uJd?t(B
(defvar sekka-last-fix "")		; $B:G8e$K3NDj$7$?J8;zNs(B
(defvar sekka-henkan-list nil)		; $BJ8@a%j%9%H(B
(defvar sekka-repeat 0)		; $B7+$jJV$72s?t(B
(defvar sekka-marker-list '())		; $BJ8@a3+;O!"=*N;0LCV%j%9%H(B: $B<!$N$h$&$J7A<0(B ( ( 1 . 2 ) ( 5 . 7 ) ... ) 
(defvar sekka-timer    nil)            ; $B%$%s%?!<%P%k%?%$%^!<7?JQ?t(B
(defvar sekka-timer-rest  0)           ; $B$"$H2?2s8F=P$5$l$?$i!"%$%s%?!<%P%k%?%$%^$N8F=P$r;_$a$k$+(B
(defvar sekka-guide-overlay   nil)     ; $B%j%"%k%?%$%`%,%$%I$K;HMQ$9$k%*!<%P!<%l%$(B
(defvar sekka-last-request-time 0)     ; Sekka$B%5!<%P!<$K%j%/%(%9%H$7$?:G8e$N;~9o(B($BC10L$OIC(B)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $BI=<(7O4X?t72(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar sekka-use-fence t)
(defvar sekka-use-color nil)

(defvar sekka-init nil)
(defvar sekka-server-cert-file nil)

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

  ;; $B%R%9%H%j%U%!%$%k$H%a%b%jCf$N%R%9%H%j%G!<%?$r%^!<%8$9$k(B
  (defun sekka-merge-kakutei-history (base-list new-list)
    (let ((merged-num  '())
	  (merged-list '()))
      (mapcar
       (lambda (x)
	 (when (not (member (car x) merged-num))
	   (progn
	     (push (car x) merged-num)
	     (push      x  merged-list))))
       (append
	base-list
	new-list))
      merged-list))

  ;; $B%F%s%]%i%j%U%!%$%k$r:n@.$9$k!#(B
  (defun sekka-make-temp-file (base)
    (if	(functionp 'make-temp-file)
	(make-temp-file base)
      (concat "/tmp/" (make-temp-name base))))

  (when (not sekka-init)
    ;; SSL$B>ZL@=q%U%!%$%k$r%F%s%]%i%j%U%!%$%k$H$7$F:n@.$9$k!#(B
    (setq sekka-server-cert-file 
	  (sekka-make-temp-file
	   "sekka.certfile"))
    (sekka-debug-print (format "cert-file :[%s]\n" sekka-server-cert-file))
    (with-temp-buffer
      (insert sekka-server-cert-data)
      (write-region (point-min) (point-max) sekka-server-cert-file  nil nil))

    (when (and
	   sekka-history-feature
	   (file-exists-p sekka-history-filename))
      (progn
	(load-file sekka-history-filename)
	(setq sekka-kakutei-history sekka-kakutei-history-saved)))

    ;; Emacs$B=*N;;~(BSSL$B>ZL@=q%U%!%$%k$r:o=|$9$k!#(B
    (add-hook 'kill-emacs-hook
	      (lambda ()
		;; $B%f!<%6!<JQ49MzNr$r%^!<%8$7$FJ]B8$9$k(B
		(when sekka-history-feature
		  (progn
		    ;; $B8=:_$N%U%!%$%k$r:FEYFI$_$3$`(B($BJL$N(BEmacs$B%W%m%;%9$,99?7$7$F$$$k$+$bCN$l$J$$0Y(B)
		    (when (file-exists-p sekka-history-filename)
		      (load-file sekka-history-filename))
		    (with-temp-file
			sekka-history-filename
		      (insert (format "(setq sekka-kakutei-history-saved '%s)" 
				      (let ((lst
					     (sekka-take 
					      (sekka-merge-kakutei-history
					       sekka-kakutei-history-saved
					       sekka-kakutei-history)
					      sekka-history-max)))
					(if (functionp 'pp-to-string)
					    (pp-to-string lst)
					  (prin1-to-string lst))))))))
		;; SSL$B>ZL@=q$N%F%s%]%i%j%U%!%$%k$r:o=|$9$k(B
		(when (file-exists-p sekka-server-cert-file)
		  (delete-file sekka-server-cert-file))))
    
    ;; $B=i4|2=40N;(B
    (setq sekka-init t)))


;;
;; $B%m!<%^;z$G=q$+$l$?J8>O$r(BSekka$B%5!<%P!<$r;H$C$FJQ49$9$k(B
;;
(defun sekka-soap-request (func-name arg-list)
  (let (
	(command
	 (concat
	  sekka-curl " --silent --show-error "
	  (format " --max-time %d " sekka-server-timeout)
	  (if sekka-server-use-cert
	    (if (not sekka-server-cert-file)
		(error "Error : cert file create miss!")
	      (format "--cacert '%s' " sekka-server-cert-file))
	    " --insecure ")
	  (format " --header 'Content-Type: text/xml' ")
	  (format " --header 'SOAPAction:urn:SekkaConvert#%s' " func-name)
	  sekka-server-url " "
	  (format (concat "--data '"
			  "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
			  "  <SOAP-ENV:Envelope xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\""
			  "   SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\""
			  "   xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\""
			  "   xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\""
			  "   xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\">"
			  "  <SOAP-ENV:Body>"
			  "    <namesp1:%s xmlns:namesp1=\"urn:SekkaConvert\">"
			  (mapconcat
			   (lambda (x)
			     (format "    <in xsi:type=\"xsd:string\">%s</in>" x))
			   arg-list
			   " ")
			  "    </namesp1:%s>"
			  "  </SOAP-ENV:Body>"
			  "</SOAP-ENV:Envelope>"
			  "' ")
		  func-name
		  func-name
		  func-name
		  func-name
		  ))))

    (sekka-debug-print (format "curl-command :%s\n" command))

    (let* (
	   (_xml
	    (shell-command-to-string
	     command))
	   (_match
	    (string-match "<s-gensym3[^>]+>\\(.+\\)</s-gensym3>" _xml)))
	   
      (sekka-debug-print (format "curl-result-xml :%s\n" _xml))

      (if _match 
	  (decode-coding-string
	   (base64-decode-string 
	    (match-string 1 _xml))
	   'euc-jp)
	_xml))))

      
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
(defun sekka-henkan-request (yomi)
  (sekka-debug-print (format "henkan-input :[%s]\n"  yomi))

  (message "Requesting to sekka server...")
  
  (let* (
	 (result (sekka-soap-request "doSekkaConvertSexp" (list yomi
								  ""
								  (sekka-get-history-string
								   sekka-kakutei-history)))))
    (sekka-debug-print (format "henkan-result:%S\n" result))
    (if (eq (string-to-char result) ?\( )
	(progn
	  (sekka-next-history)
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


;; $B%]!<%?%V%kJ8;zNsCV49(B( Emacs$B$H(BXEmacs$B$NN>J}$GF0$/(B )
(defun sekka-replace-regexp-in-string (regexp replace str)
  (cond ((featurep 'xemacs)
	 (replace-in-string str regexp replace))
	(t
	 (replace-regexp-in-string regexp replace str))))
	

;; $BCV49%-!<%o!<%I$r2r7h$9$k(B
(defun sekka-replace-keyword (str)
  (let (
	;; $B2~9T$r0l$D$N%9%Z!<%9$KCV49$7$F!"(B
	;; $B%-!<%o!<%ICV49=hM}$NA0=hM}$H$7$F9TF,$H9TKv$K%9%Z!<%9$rDI2C$9$k!#(B
	(replaced 
	 (concat " " 
		 (sekka-replace-regexp-in-string 
		  "[\n]"
		  " "
		  str)
		 " ")))

    (mapcar
     (lambda (x)
       (setq replaced 
	     (sekka-replace-regexp-in-string 
	      (concat " " (car x) " ")
	      (concat " " (cdr x) " ")
	      replaced)))
     sekka-replace-keyword-list)
    replaced))

;; $B%j!<%8%g%s$r%m!<%^;z4A;zJQ49$9$k4X?t(B
(defun sekka-henkan-region (b e)
  "$B;XDj$5$l$?(B region $B$r4A;zJQ49$9$k(B"
  (sekka-init)
  (when (/= b e)
    (let* (
	   (yomi (buffer-substring-no-properties b e))
	   (henkan-list (sekka-henkan-request (sekka-replace-keyword yomi))))
      
      (if henkan-list
	  (condition-case err
	      (progn
		(setq
		 ;; $BJQ497k2L$NJ];}(B
		 sekka-henkan-list henkan-list
		 ;; $BJ8@aA*Br=i4|2=(B
		 sekka-cand-n   (make-list (length henkan-list) 0)
		 ;; 
		 sekka-cand-max (mapcar
				  (lambda (x)
				    (length x))
				  henkan-list))
		
		(sekka-debug-print (format "sekka-henkan-list:%s \n" sekka-henkan-list))
		(sekka-debug-print (format "sekka-cand-n:%s \n" sekka-cand-n))
		(sekka-debug-print (format "sekka-cand-max:%s \n" sekka-cand-max))
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
  (let ((cnt 0))
    (mapconcat
     (lambda (x)
       ;; $BJQ497k2LJ8;zNs$rJV$9!#(B
       (let ((word (nth (nth cnt sekka-cand-n) x)))
	 (sekka-debug-print (format "word:[%d] %s\n" cnt word))
	 (setq cnt (+ 1 cnt))
	 (nth sekka-tango-index word)))
     sekka-henkan-list
     "")))


(defun sekka-display-function (b e select-mode)
  (setq sekka-henkan-separeter (if sekka-use-fence " " ""))
  (when sekka-henkan-list
    ;; UNDO$BM^@)3+;O(B
    (sekka-disable-undo)

    (delete-region b e)

    ;; $B%j%9%H=i4|2=(B
    (setq sekka-marker-list '())

    (let (
	   (cnt 0))

      (setq sekka-last-fix "")

      ;; $BJQ49$7$?(Bpoint$B$NJ];}(B
      (setq sekka-fence-start (point-marker))
      (when select-mode (insert "|"))

      (mapcar
       (lambda (x)
	 (if (and
	      (not (eq (preceding-char) ?\ ))
	      (not (eq (point-at-bol) (point)))
	      (eq (sekka-char-charset (preceding-char)) 'ascii)
	      (and
	       (< 0 (length (cadar x)))
	       (eq (sekka-char-charset (string-to-char (cadar x))) 'ascii)))
	     (insert " "))

	 (let* (
		(start       (point-marker))
		(_n          (nth cnt sekka-cand-n))
		(_max        (nth cnt sekka-cand-max))
		(spaces      (nth sekka-spaces-index (nth _n x)))
		(insert-word (nth sekka-tango-index  (nth _n x)))
		(_insert-word
		 ;; $B%9%Z!<%9$,(B2$B8D0J>eF~$l$i$l$?$i!"(B1$B8D$N%9%Z!<%9$rF~$l$k!#(B($BC"$7!"(Bauto-fill-mode$B$,L58z$N>l9g$N$_(B)
		 (if (and (< 1 spaces) (not auto-fill-function))
		     (concat " " insert-word)
		   insert-word))
		(ank-word    (cadr (assoc 'l x)))
		(_     
		 (if (eq cnt sekka-cand)
		     (progn
		       (insert _insert-word)
		       (message (format "[%s] candidate (%d/%d)" insert-word (+ _n 1) _max)))
		   (insert _insert-word)))
		(end         (point-marker))
		(ov          (make-overlay start end)))

	   ;; $B3NDjJ8;zNs$N:n@.(B
	   (setq sekka-last-fix (concat sekka-last-fix _insert-word))
	   
	   ;; $BA*BrCf$N>l=j$rAu>~$9$k!#(B
	   (overlay-put ov 'face 'default)
	   (when (and select-mode
		      (eq cnt sekka-cand))
	     (overlay-put ov 'face 'highlight))

	   (push `(,start . ,end) sekka-marker-list)
	   (sekka-debug-print (format "insert:[%s] point:%d-%d\n" insert-word (marker-position start) (marker-position end))))
	 (setq cnt (+ cnt 1)))

       sekka-henkan-list))

    ;; $B%j%9%H$r5U=g$K$9$k!#(B
    (setq sekka-marker-list (reverse sekka-marker-list))

    ;; fence$B$NHO0O$r@_Dj$9$k(B
    (when select-mode (insert "|"))
    (setq sekka-fence-end   (point-marker))

    (sekka-debug-print (format "total-point:%d-%d\n"
				(marker-position sekka-fence-start)
				(marker-position sekka-fence-end)))
    ;; UNDO$B:F3+(B
    (sekka-enable-undo)
    ))



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
(define-key sekka-select-mode-map "b"                      'sekka-select-prev-word)
(define-key sekka-select-mode-map "f"                      'sekka-select-next-word)
(define-key sekka-select-mode-map "a"                      'sekka-select-first-word)
(define-key sekka-select-mode-map "e"                      'sekka-select-last-word)
(define-key sekka-select-mode-map "p"                      'sekka-select-prev)
(define-key sekka-select-mode-map "n"                      'sekka-select-next)
(define-key sekka-select-mode-map sekka-rK-trans-key      'sekka-select-next)
(define-key sekka-select-mode-map " "                      'sekka-select-next)
(define-key sekka-select-mode-map "j"                      'sekka-select-kanji)
(define-key sekka-select-mode-map "h"                      'sekka-select-hiragana)
(define-key sekka-select-mode-map "k"                      'sekka-select-katakana)
(define-key sekka-select-mode-map "u"                      'sekka-select-hiragana)
(define-key sekka-select-mode-map "i"                      'sekka-select-katakana)
(define-key sekka-select-mode-map "\C-u"                   'sekka-select-hiragana)
(define-key sekka-select-mode-map "\C-i"                   'sekka-select-katakana)
(define-key sekka-select-mode-map "l"                      'sekka-select-alphabet)


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


;; $B3NDj$7$?(BID$B%j%9%H$rJQ49MzNr$KDI2C$9$k(B
(defun sekka-next-history ( )
  (if sekka-history-feature
      (progn
	(push
	 (cons 
	  (sekka-current-unixtime)
	  '())
	 sekka-kakutei-history)
	(sekka-debug-print (format "init:kakutei-history:%S\n" sekka-kakutei-history))
	sekka-kakutei-history)
    '()))


;; Sekka$B%5!<%P!<$K(B $BAw$k%R%9%H%j%j%9%H$r=P$9(B
(defun sekka-get-history-string (kakutei-history)
  (mapconcat
   (lambda (entry)
     (mapconcat
      (lambda (x) (number-to-string x))
      (cdr entry)
      " "))
   kakutei-history
   ";"))

;;(sekka-get-history-string
;; '(
;;   (1 2 3 4 5 6)
;;   (10 20 30 40 50 60)))

;; $B3NDj$7$?(BID$B%j%9%H$r99?7$9$k(B
(defun sekka-update-history( cand-n )
  (let* ((cnt 0)
	 (result 
	  (mapcar
	   (lambda (x)
	     ;; $BJQ497k2LJ8;zNs$rJV$9!#(B
	     (let ((word (nth (nth cnt cand-n) x)))
	       (sekka-debug-print (format "history-word:[%d] %s\n" cnt word))
	       (setq cnt (+ 1 cnt))
	       (nth sekka-id-index word)))
	   sekka-henkan-list)))
    ;; $B%R%9%H%j%G!<%?$r:n$jD>$9(B
    (when sekka-history-feature
      (setq sekka-kakutei-history
	    (cons
	     (cons
	      (caar sekka-kakutei-history)
	      result)
	     (if (< 1 (length sekka-kakutei-history))
		 (cdr sekka-kakutei-history)
	       '())))
      (sekka-debug-print (format "kakutei-history:%S\n" sekka-kakutei-history)))))
  


;; $B8uJdA*Br$r3NDj$9$k(B
(defun sekka-select-kakutei ()
  "$B8uJdA*Br$r3NDj$9$k(B"
  (interactive)
  ;; $B8uJdHV9f%j%9%H$r%P%C%/%"%C%W$9$k!#(B
  (setq sekka-cand-n-backup (copy-list sekka-cand-n))
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display)
  (sekka-update-history sekka-cand-n))


;; $B8uJdA*Br$r%-%c%s%;%k$9$k(B
(defun sekka-select-cancel ()
  "$B8uJdA*Br$r%-%c%s%;%k$9$k(B"
  (interactive)
  ;; $B%+%l%s%H8uJdHV9f$r%P%C%/%"%C%W$7$F$$$?8uJdHV9f$GI|85$9$k!#(B
  (setq sekka-cand-n (copy-list sekka-cand-n-backup))
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))

;; $BA0$N8uJd$K?J$a$k(B
(defun sekka-select-prev ()
  "$BA0$N8uJd$K?J$a$k(B"
  (interactive)
  (let (
	(n sekka-cand))

    ;; $BA0$N8uJd$K@Z$j$+$($k(B
    (setcar (nthcdr n sekka-cand-n) (- (nth n sekka-cand-n) 1))
    (when (> 0 (nth n sekka-cand-n))
      (setcar (nthcdr n sekka-cand-n) (- (nth n sekka-cand-max) 1)))
    (sekka-select-update-display)))

;; $B<!$N8uJd$K?J$a$k(B
(defun sekka-select-next ()
  "$B<!$N8uJd$K?J$a$k(B"
  (interactive)
  (let (
	(n sekka-cand))

    ;; $B<!$N8uJd$K@Z$j$+$($k(B
    (setcar (nthcdr n sekka-cand-n) (+ 1 (nth n sekka-cand-n)))
    (when (>= (nth n sekka-cand-n) (nth n sekka-cand-max))
      (setcar (nthcdr n sekka-cand-n) 0))

    (sekka-select-update-display)))

;; $BA0$NJ8@a$K0\F0$9$k(B
(defun sekka-select-prev-word ()
  "$BA0$NJ8@a$K0\F0$9$k(B"
  (interactive)
  (when (< 0 sekka-cand)
    (setq sekka-cand (- sekka-cand 1)))
  (sekka-select-update-display))

;; $B<!$NJ8@a$K0\F0$9$k(B
(defun sekka-select-next-word ()
  "$B<!$NJ8@a$K0\F0$9$k(B"
  (interactive)
  (when (< sekka-cand (- (length sekka-cand-n) 1))
    (setq sekka-cand (+ 1 sekka-cand)))
  (sekka-select-update-display))

;; $B:G=i$NJ8@a$K0\F0$9$k(B
(defun sekka-select-first-word ()
  "$B:G=i$NJ8@a$K0\F0$9$k(B"
  (interactive)
  (setq sekka-cand 0)
  (sekka-select-update-display))

;; $B:G8e$NJ8@a$K0\F0$9$k(B
(defun sekka-select-last-word ()
  "$B:G8e$NJ8@a$K0\F0$9$k(B"
  (interactive)
  (setq sekka-cand (- (length sekka-cand-n) 1))
  (sekka-select-update-display))


;; $B;XDj$5$l$?(B type $B$N8uJd$K6/@)E*$K@Z$j$+$($k(B
(defun sekka-select-by-type ( _type )
  (let* (
	 (n sekka-cand)
	 (kouho (nth n sekka-henkan-list))
	 (_element (assoc _type kouho)))

    ;; $BO"A[%j%9%H$+$i(B _type $B$G0z$$$?(B index $BHV9f$r@_Dj$9$k$@$1$GNI$$!#(B
    (when _element
      (setcar (nthcdr n sekka-cand-n) (nth sekka-candno-index _element))
      (sekka-select-update-display))))

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

(defun sekka-select-alphabet ()
  "$B%"%k%U%!%Y%C%H8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B%m!<%^;z4A;zJQ494X?t(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-rK-trans ()
  "$B%m!<%^;z4A;zJQ49$r$9$k!#(B
$B!&%+!<%=%k$+$i9TF,J}8~$K%m!<%^;zNs$,B3$/HO0O$G%m!<%^;z4A;zJQ49$r9T$&!#(B"
  (interactive)
;  (print last-command)			; DEBUG

  ;; $BHs(BSSL$B$N7Y9p$r=P$9(B
  (when (and (string-match "^[ ]*http:" sekka-server-url)
	     (> 1 sekka-timer-rest))
    (progn
      ;; $B7Y9p$r=P$7$F%]!<%:$9$k(B
      (message "sekka.el: !! $BHs(BSSL$B$GDL?.$9$k@_Dj$K$J$C$F$$$^$9!#(B !!")
      (sleep-for 2)))

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
	      (sekka-select-kakutei))))))

     
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
	(let
	    ((cnt 0))
	  (setq sekka-select-mode t)
	  (run-hooks 'sekka-select-mode-hook)
	  (setq sekka-cand 0)		; $BJ8@aHV9f=i4|2=(B
	  
	  (sekka-debug-print "henkan mode ON\n")
	  
	  ;; $B%+!<%=%k0LCV$,$I$NJ8@a$K>h$C$F$$$k$+$rD4$Y$k!#(B
	  (mapcar
	   (lambda (x)
	     (let (
		   (start (marker-position (car x)))
		   (end   (marker-position (cdr x))))
	       
	       (when (and
		      (< start (point))
		      (<= (point) end))
		 (setq sekka-cand cnt))
	       (setq cnt (+ cnt 1))))
	   sekka-marker-list)

	  (sekka-debug-print (format "sekka-cand = %d\n" sekka-cand))

	  ;; $BI=<(>uBV$r8uJdA*Br%b!<%I$K@ZBX$($k!#(B
	  (sekka-display-function
	   (marker-position sekka-fence-start)
	   (marker-position sekka-fence-end)
	   t))))
     ))))



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
;;; $B%m!<%+%k$N(BEmacsLisp$B$@$1$GJQ49$9$k=hM}(B
;;;
;; a-list $B$r;H$C$F(B str $B$N@hF,$K3:Ev$9$kJ8;zNs$,$"$k$+D4$Y$k(B
(defun romkan-scan-token (a-list str)
  (let 
      ((result     (substring str 0 1))
       (rest       (substring str 1 (length str)))
       (done       nil))

    (mapcar
     (lambda (x)
       (if (and 
	    (string-match (concat "^" (car x)) str)
	    (not done))
	   (progn
	     (setq done t)
	     (setq result (cdr x))
	     (setq rest   (substring str (length (car x)))))))
     a-list)
    (cons result rest)))


;; $B$+$J(B<->$B%m!<%^;zJQ49$9$k(B
(defun romkan-convert (a-list str)
  (cond ((= 0 (length str))
	 "")
	(t
	 (let ((ret (romkan-scan-token a-list str)))
	   (concat
	    (car ret)
	    (romkan-convert a-list (cdr ret)))))))


  
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



(defun sekka-realtime-guide ()
  "$B%j%"%k%?%$%`$GJQ49Cf$N%,%$%I$r=P$9(B
sekka-mode$B$,(BON$B$N4VCf8F$S=P$5$l$k2DG=@-$,$"$k!&(B"
  (cond
   ((or (null sekka-mode)
	(> 1 sekka-timer-rest))
    (cancel-timer sekka-timer)
    (setq sekka-timer nil)
    (delete-overlay sekka-guide-overlay))
   (sekka-guide-overlay
    ;; $B;D$j2s?t$N%G%/%j%a%s%H(B
    (setq sekka-timer-rest (- sekka-timer-rest 1))

    (let* (
	   (end (point))
	   (gap (sekka-skip-chars-backward))
	   (prev-line-existp
	    (not (= (point-at-bol) (point-min))))
	   (next-line-existp
	    (not (= (point-at-eol) (point-max))))
	   (prev-line-point
	    (when prev-line-existp
	      (save-excursion
		(forward-line -1)
		(point))))
	   (next-line-point
	    (when next-line-existp
	      (save-excursion
		(forward-line 1)
		(point))))
	   (disp-point
	    (or next-line-point prev-line-point)))

      (if 
	  (or 
	   (when (fboundp 'minibufferp)
	     (minibufferp))
	   (and
	    (not next-line-point)
	    (not prev-line-point))
	   (= gap 0))
	  ;; $B>e2<%9%Z!<%9$,L5$$(B $B$^$?$O(B $BJQ49BP>]$,L5$7$J$i%,%$%I$OI=<($7$J$$!#(B
	  (overlay-put sekka-guide-overlay 'before-string "")
	;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$G%,%$%I$rI=<($9$k!#(B
	(let* (
	       (b (+ end gap))
	       (e end)
	       (str (buffer-substring b e))
	       (l (split-string str))
	       (mess
		(mapconcat
		 (lambda (x)
		   (let* ((l (split-string x "\\."))
			  (method
			   (when (< 1 (length l))
			     (cadr l)))
			  (hira
			   (romkan-convert sekka-roman->kana-table
					   (car l))))
		     (cond
		      ((string-match "[a-z]+" hira)
		       x)
		      ((not method)
		       hira)
		      ((or (string-equal "j" method) (string-equal "h" method))
		       hira)
		      ((or (string-equal "e" method) (string-equal "l" method))
		       (car l))
		      ((string-equal "k" method)
		       (romkan-convert sekka-hiragana->katakana-table
				       hira))
		      (t
		       x))))
		 l
		 " ")))
	  (move-overlay sekka-guide-overlay 
			disp-point (min (point-max) (+ disp-point 1)) (current-buffer))
	  (overlay-put sekka-guide-overlay 'before-string mess))))
    (overlay-put sekka-guide-overlay 'face 'sekka-guide-face))))


;;;
;;; human interface
;;;
(define-key sekka-mode-map sekka-rK-trans-key 'sekka-rK-trans)
(define-key sekka-mode-map "\M-j" 'sekka-rHkA-trans)
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
