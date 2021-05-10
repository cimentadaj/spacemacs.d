
(defun custom/python-config ()
  (spacemacs/declare-prefix-for-mode 'python-mode "E" "Extra")
  (spacemacs/set-leader-keys-for-major-mode 'python-mode "Er" 'pyvenv-restart-python)
  )
