;;; blackify.el --- format python buffers using black.  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Yusuke Kitamura

;; Author: Yusuke Kitamura <ymyk6602@gmail.com>
;; Keywords: languages
;; Version: 1.0.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Blackify uses black to format Python buffer.
;; Blackify is based on yapfify (https://github.com/JorisE/yapfify) and
;; has similar (analogous) functions and variables to it.

;;; Code:
(require 'cl-lib)
(require 'dash)

(defcustom blackify-executable "black"
  "Executable used to start yapf."
  :type 'string
  :group 'blackify)

(defcustom blackfiy-lighter " black"
  "Lighter of blackify-mode."
  :type 'string
  :group 'blackify)

(defun blackify-call-bin (input-buffer output-buffer start-pos end-pos)
  "Call process black on INPUT-BUFFER saving the output to OUTPUT-BUFFER.
Return the exit code.  START-LINE and END-LINE specify region to
format."
  (with-current-buffer input-buffer
    (call-process-region start-pos end-pos blackify-executable nil output-buffer nil "-" "-q")))

;;;###autoload
(defun blackify-region (beginning end)
  "Try to apply black to the current region.
If black exits with an error, the output will be shown in a help-window."
  (interactive "r")
  (-if-let (tmp-buffer (get-buffer "*blackify*"))   ;; Make sure to delete old window
      (kill-buffer tmp-buffer))
  (let* ((original-buffer (current-buffer))
         (original-point (point))  ; Because we are replacing text, save-excursion does not always work.
         (buffer-windows (get-buffer-window-list original-buffer nil t))
         (original-window-pos (mapcar 'window-start buffer-windows))
         (tmpbuf (get-buffer-create "*blackify*"))
         (exit-code (blackify-call-bin original-buffer tmpbuf beginning end)))
    (deactivate-mark)
    ;; There are three exit-codes defined for YAPF:
    ;; 0: Exit with success (change or no change on yapf >=0.11)
    ;; 123: Exit with error
    ;; anything else would be very unexpected.
    (cond ((eq exit-code 0)
           (with-current-buffer tmpbuf
             (copy-to-buffer original-buffer (point-min) (point-max))))
          ((eq exit-code 123)
           (error "Black failed, see %s buffer for details" (buffer-name tmpbuf))))
    ;; Clean up tmpbuf
    (kill-buffer tmpbuf)
    ;; restore window to similar state
    (goto-char original-point)
    (cl-mapcar 'set-window-start buffer-windows original-window-pos)))


;;;###autoload
(defun blackify-buffer ()
  "Blackify whole buffer."
  (interactive)
  (blackify-region (point-min) (point-max)))


;;;###autoload
(defun blackify-region-or-buffer ()
  "Blackify the region if it is active. Otherwise, blackify the buffer"
  (interactive)
  (if (region-active-p)
      (blackify-region (region-beginning) (region-end))
    (blackify-buffer)))

;;;###autoload
(define-minor-mode blackify-mode
  "Automatically run black before saving."
  :lighter blackify-lighter
  (if blackify-mode
      (add-hook 'before-save-hook 'blackify-buffer nil t)
    (remove-hook 'before-save-hook 'blackify-buffer t)))

(provide 'blackify)
;;; blackify.el ends here
