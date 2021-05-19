
(defun custom/python-config ()

  (defun python-insert-assign ()
    "Insert an assignment ="
    (interactive)
    (insert " = "))

  (define-key python-mode-map (kbd "C-<") 'python-insert-assign)
  (define-key inferior-python-mode-map (kbd "C-<") 'python-insert-assign)
  (spacemacs/declare-prefix-for-mode 'python-mode "E" "Extra")
  (spacemacs/set-leader-keys-for-major-mode 'python-mode "Er" 'pyvenv-restart-python)

  )
