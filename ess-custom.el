
(defun custom/ess-config ()

  ;; Functions to run partial pipe
  (defun pos-paragraph ()
    (backward-paragraph)
    (next-line 1)
    (beginning-of-line)
    (point))

  (defun highlight-piped-region ()
    (let ((end (point))
          (beg (pos-paragraph)))
      (set-mark beg)
      (goto-char end)
      (end-of-line)
      (deactivate-mark)
      (setq last-point (point))
      (goto-char end)
      (buffer-substring-no-properties beg last-point)))

  (defun run-partial-pipe ()
    (interactive)
    (let ((string-to-execute (highlight-piped-region)))
      ;; https://stackoverflow.com/questions/65882345/replace-last-occurence-of-regexp-in-a-string-which-has-new-lines-replace-regexp/65882683#65882683
      (ess-eval-linewise
       (replace-regexp-in-string
        ".+<-" "" (replace-regexp-in-string
                   "\\(\\(.\\|\n\\)*\\)\\(%>%\\|\+\\) *\\'" "\\1" string-to-execute)))))

  (defun tide-insert-pipe ()
    "Insert a %>% and newline"
    (interactive)
    (insert " %>% "))

  (defun tide-insert-assign ()
    "Insert an assignment <-"
    (interactive)
    (insert " <- "))

  (defun ess-comint-clean-buffer ()
    "Applies comint-clear-buffer to the inferior process
       associated with a buffer. If you're in buffer '*a*' and run this,
       it will switch to the associated inferior buffer apply
       comint-clear-buffer and switch back to *a*"
    (interactive)
    (let ((first-buffer (current-buffer)))
      (ess-switch-to-inferior-or-script-buffer t)
      (comint-clear-buffer)
      (switch-to-buffer-other-window first-buffer)))


  (defun save-lintr (lintr-path)
    ;; create new buffer, do things, then write to file at fpath
    (with-temp-file lintr-path
      (insert "
linters:with_defaults(
  line_length_linter = NULL, # Make sure you don't change any parenthesis nor trailing blank lines, lintr needs this EXACT format for linting. Don't even move this comment line
  object_name_linter = NULL,
  object_usage_linter = NULL,
  camel_case_linter = NULL,
  object_snake_case_linter = NULL,
  object_name_linter = NULL,
  commented_code_linter = NULL)
exclusions:list(
  'inst/',
  'man/')

"
              )
      )
    )

  (save-lintr "~/.lintr")


  (defun R-scratch ()
    (interactive)
    (progn
      (delete-other-windows)
      (setq new-buf (get-buffer-create "scratch.R"))
      (switch-to-buffer new-buf)
      (R-mode)
      (setq w1 (selected-window))
      (setq w1name (buffer-name))
      (setq w2 (split-window w1 nil t))
      (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
          (R))
      (set-window-buffer w2 "*R*")
      (set-window-buffer w1 w1name)))

  (defun tide-shiny-eval-app()
    "Run a shiny app in the current working directory"
    (interactive)
    (ess-eval-linewise "shiny::runApp()"))

  (with-eval-after-load 'ess-r-mode
    (define-key ess-r-mode-map (kbd "C->") 'tide-insert-pipe)
    (define-key ess-r-mode-map (kbd "C-<") 'tide-insert-assign)
    (define-key inferior-ess-r-mode-map (kbd "C->") 'tide-insert-pipe)
    (define-key inferior-ess-r-mode-map (kbd "C-<") 'tide-insert-assign)
    (spacemacs/set-leader-keys-for-major-mode 'ess-r-mode "Ec" 'ess-comint-clean-buffer)
    (spacemacs/set-leader-keys-for-major-mode 'ess-r-mode "sp" 'run-partial-pipe)
    (spacemacs/declare-prefix-for-mode 'ess-r-mode "S" "Shiny")
    (spacemacs/set-leader-keys-for-major-mode 'ess-r-mode "Se" 'tide-shiny-eval-app)
    (spacemacs/set-leader-keys-for-major-mode 'ess-r-mode "sh" 'ess-eval-buffer-from-beg-to-here)
    (spacemacs/set-leader-keys-for-major-mode 'ess-r-mode "su" 'ess-eval-buffer-from-here-to-end)
    (global-set-key (kbd "C-x 9") 'R-scratch))

  )
