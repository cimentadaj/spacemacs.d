
(defun custom/python-config ()
  (with-eval-after-load 'python-mode
    (spacemacs/declare-prefix-for-mode 'python-mode fed "E" "Extra")
    (spacemacs/set-leader-keys-for-major-mode 'python-mode "Er" 'pyvenv-restart-python))
  )
