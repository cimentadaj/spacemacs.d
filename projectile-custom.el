(defun custom/projectile-config ()

  ;; Projectile
  (spacemacs/set-leader-keys "ps" 'counsel-projectile-ag)
  ;; (projectile-discover-projects-in-search-path '("~/repositories/"))
  (setq projectile-project-search-path '("~/repositories/"))

  )
