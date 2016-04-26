;;; defuns-ui.el
;; for ../core-ui.el

;;;###autoload (autoload 'narf:toggle-fullscreen "defuns-ui" nil t)
;;;###autoload (autoload 'narf:set-columns "defuns-ui" nil t)
(after! evil
  (evil-define-command narf:set-columns (&optional bang columns)
    "Adjusts visual-fill-column-width on the fly."
    (interactive "<!><a>")
    (if (or (= (length columns) 0) bang)
        (progn
          (setq visual-fill-column-width 80)
          (when visual-fill-column-mode
            (visual-fill-column-mode -1)))
      (setq columns (string-to-number columns))
      (when (> columns 30)
        (setq visual-fill-column-width columns)))
    (if visual-fill-column-mode
        (visual-fill-column--adjust-window)
      (visual-fill-column-mode 1)))

  (evil-define-command narf:toggle-fullscreen ()
    (interactive)
    (set-frame-parameter nil 'fullscreen (if (not (frame-parameter nil 'fullscreen)) 'fullboth))))

;;;###autoload
(defun narf/reset-theme ()
  (interactive)
  (narf/load-theme (or narf-current-theme narf-default-theme)))

;;;###autoload
(defun narf/load-font (font)
  (interactive)
  (set-frame-font font t)
  (setq narf-current-font font))

;;;###autoload
(defun narf/load-theme (theme &optional suppress-font)
  (interactive)
  (when narf-current-theme
    (disable-theme narf-current-theme))
  (load-theme theme t)
  (unless suppress-font
    (narf/load-font narf-current-font))
  (setq narf-current-theme theme))

;;;###autoload
(defun narf/show-as (how &optional pred)
  (let* ((beg (match-beginning 1))
         (end (match-end 1))
         (ok (or (not pred) (funcall pred beg end))))
    (when ok
      (compose-region beg end how 'decompose-region))
    nil))

;;;###autoload
(defun narf/add-whitespace (&optional start end)
  "Maintain indentation whitespace in buffer. Used so that highlight-indentation will
display consistent guides. Whitespace is stripped out on save, so this doesn't affect the
end file."
  (interactive (progn (barf-if-buffer-read-only)
                      (if (use-region-p)
                          (list (region-beginning) (region-end))
                        (list nil nil))))
  (unless indent-tabs-mode
    (save-match-data
      (save-excursion
        (let ((end-marker (copy-marker (or end (point-max))))
              (start (or start (point-min))))
          (goto-char start)
          (while (and (re-search-forward "^$" end-marker t) (not (>= (point) end-marker)))
            (let (line-start line-end next-start next-end)
              (save-excursion
                ;; Check previous line indent
                (forward-line -1)
                (setq line-start (point)
                      line-end (save-excursion (back-to-indentation) (point)))
                ;; Check next line indent
                (forward-line 2)
                (setq next-start (point)
                      next-end (save-excursion (back-to-indentation) (point)))
                ;; Back to origin
                (forward-line -1)
                ;; Adjust indent
                (let* ((line-indent (- line-end line-start))
                       (next-indent (- next-end next-start))
                       (indent (min line-indent next-indent)))
                  (insert (make-string (if (zerop indent) 0 (1+ indent)) ? )))))
            (forward-line 1)))))
    (set-buffer-modified-p nil))
  nil)

;;;###autoload
(defun narf/imenu-list-quit ()
  (interactive)
  (quit-window)
  (mapc (lambda (b) (with-current-buffer b
                 (when imenu-list-minor-mode
                   (imenu-list-minor-mode -1))))
        (narf/get-visible-buffers (narf/get-real-buffers))))

;;;###autoload
(defun narf|hide-mode-line (&rest _)
  (setq mode-line-format nil))

(provide 'defuns-ui)
;;; defuns-ui.el ends here
