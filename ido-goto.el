;;; ido-goto.el --- select Imenu tags for a buffer using IDO completion
;;
;; Copyright (c) 2014 Kevin Birch
;; Author: kevin birch <kmb@pobox.com>
;; Created: Thu Jan  9 18:33:06 2014 (-0500)
;; Version: 1.0
;; Keywords: ido, imenu, tags
;;
;; This file is NOT part of GNU Emacs.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; `ido-goto` shows an ido selection list in the minibuffer of the
;; imenu tags of the current buffer.  Selecting one will jump to that
;; symbol.
;;
;; To use, just bind ido-goto to a convenient key:
;;
;;    (global-set-key (kbd "C-c g") 'ido-goto)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change Log:
;;
;; 2014/01/09 kmb
;;     First version
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of
;; this software and associated documentation files (the "Software"), to deal with
;; the Software without restriction, including without limitation the rights to
;; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
;; the Software, and to permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:

;; - Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimers.
;; - Redistributions in binary form must reproduce the above copyright notice, this
;;   list of conditions and the following disclaimers in the documentation and/or
;;   other materials provided with the distribution.
;; - Neither the names of the copyright holders, nor the names of the authors, nor
;;   the names of other contributors may be used to endorse or promote products
;;   derived from this Software without specific prior written permission.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
;; FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE CONTRIBUTORS
;; OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE SOFTWARE.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'ido nil t)
(require 'imenu)

;;;###autoload
(defun ido-goto ()
  "Refresh imenu and jump to a place in the buffer using Ido."
  (interactive)
  (imenu--cleanup)
  (setq imenu--index-alist nil)
  (let* ((index-alist (imenu--make-index-alist))
         (symbol-alist (ido-goto/expand-symbol-names index-alist))
         (symbol-names (mapcar #'car symbol-alist))
         selected-symbol
         position)
    (setq selected-symbol (ido-completing-read "Symbol? " symbol-names))
    (setq position (cdr (assoc selected-symbol symbol-alist)))
    (unless (and (boundp 'mark-active) mark-active)
      (push-mark nil t nil))
    (if (overlayp position)
        (goto-char (overlay-start position))
      (goto-char position))))

(defun ido-goto/expand-symbol-names (symbol-alist &optional prefix)
  (let (result)
    (dolist (each symbol-alist result)
      (cond
       ((and (listp each) (imenu--subalist-p each))
        ;; recursively expand sublist
        (let* ((context (ido-goto/clean-symbol-name (car each)))
               (context-alist (cdr each))
               (cleaned-alist (ido-goto/expand-symbol-names context-alist context)))
          (setq result (append result cleaned-alist))))
       ((and (not (stringp each))
             (not (equal imenu--rescan-item each)))
        ;; add cleaned up symbol name cons to result list
        (setq result (append result (list (ido-goto/clean-symbol each prefix)))))))))

(defun ido-goto/clean-symbol (symbol &optional prefix)
  (cons (ido-goto/make-symbol-name symbol prefix)
        (cdr symbol)))

(defun ido-goto/make-symbol-name (symbol &optional prefix)
  (let ((cleaned-name (ido-goto/clean-symbol-name (car symbol))))
    (cond
     ((string-match-p "[*][^*]*[*]" (car symbol))
      prefix)
     (prefix
      (concat prefix "." cleaned-name))
     (t
      cleaned-name))))

(defun ido-goto/clean-symbol-name (symbol-name)
  (substring symbol-name 0 (string-match " (.*)" symbol-name)))

(provide 'ido-goto)

;;; ido-goto.el ends here
