(defun custom/blog-config()

  (defun blog-timestamp ()
    "Return date and timestamp as string."
    (setq system-time-locale "C")
    (format-time-string "%d of %B, %Y - %H:%M"))

  (defun indent-buffer ()
    "Indent entire buffer."
    (save-excursion
      (indent-region (point-min) (point-max) nil)))

;;; Blogdown functions

  (defun find-blog-blogdown ()
    "Return the regexp found in the known list of projectile projects."
    ;; regexp are a bit different in emacs so I struggled
    ;; a bit to find a way to build this function. The idea
    ;; is to make this function search the (projectile-relevant-known-projects)
    ;; and extract the regexp of the directory. This way you can
    ;; filter both the stats blog as your private blog.
    "~/repositories/cimentadaj.github.io")

  (defun new-blog-post-R ()
    "Skeleton of R function to create new blogpost using blogdown."
    "
  my_new_post <- function(title, ...) {

  title_change <- trimws(gsub('[[:punct:]]', '', title))
  slug <- stringr::str_to_lower(gsub(' +','-', title_change))

  dir <- paste0(lubridate::today(), '-', slug)

  blogdown::new_post(title = title,
                     author = 'Jorge Cimentada',
                     subdir = file.path('./blog', dir),
                     ext = '.Rmd',
                     ...)
  }")

  (defun blog/new-blog-post-blogdown ()
    "Run cimentadaj::my_new_post() on an argument read from the mini buffer.
This effectively creates the Rmd file on the result of (find-blog-blogdown) creating
all the necessary folders in between. Finally, it opens the file as a new buffer."
    (interactive)
    (let* ((name-blog-post (read-from-minibuffer "Name of the blogpost: "))
           (setwd-dir (concat "setwd('" (find-blog-blogdown) "')"))
           (new-post-expression (concat "my_new_post('" name-blog-post "')"))
           (incomplete-expression (concat setwd-dir ";" (new-blog-post-R) ";" new-post-expression))
           (entire-expression (concat "Rscript -e " (prin1-to-string incomplete-expression))))
      ;; Run rscript expression and save to log.txt
      (shell-command (concat entire-expression "> /tmp/log.txt"))
      (with-temp-buffer
        (insert-file-contents "/tmp/log.txt")
        (shell-command "rm -rf /tmp/log.txt")
        (forward-line 2)
        (delete-char 5)
        (end-of-line 1)
        (backward-delete-char-untabify 1)
        (beginning-of-line 1)
        (kill-line))
      (find-file (concat (find-blog-blogdown) "/" (car kill-ring)))))

  (defun blog/preview-blog-post-blogdown ()
    "Run blogdown::server_site on an R buffer in the directory of the blog."
    (interactive)
    ;; Even though default-directory is not directly
    ;; used, it sets the dir for opening the R session
    (let* ((default-directory (find-blog-blogdown))
           (selected-buffer (current-buffer))
           (ess-dialect "R"))
      (ess-eval-linewise "blogdown::serve_site()")))

  (defun blog/publish-blog-post-blogdown ()
    "Publishes the website using the script public_update.sh."
    (interactive)
    (let ((default-directory (find-blog-blogdown)))
      (compile "bash public_update.sh")))

  (defun blog/open-blog-blogdown ()
    "Open up personal blogdown"
    (interactive)
    (browse-url "https://cimentadaj.github.io/"))

;;; Personal blog functions

  (defun find-blog-personal ()
    "Return the local directory of the personal blog.
See find-blog-blogdown comments inside the function for greater details."
    "~/repositories/personal_blog")

  (defun new-blog-post-html (blog-title)
    "HTML skeleton to create new blogpost with name BLOG-TITLE for personal website."
    (concat
     "<!DOCTYPE html>
<html>
    <center>
        <head>
            <meta charset='utf-8' />
            <style>
             body {
                 width: 55em;
                 margin: 0 auto;
                 font-family: Tahoma, Verdana, Arial, sans-serif;
             }
            </style>
            <title>" (capitalize blog-title) "</title>
        </head>
        <body>
            <h1 class='title'>" (capitalize blog-title) "</h1>
            <p>" (blog-timestamp) "</p>
            <hr>
            <p style='text-align:left'>
               <span style='white-space: pre-line'>

               </span>
            </p>
        </body>
    </center>
</html>"
     ))

  (defun new-blog-post-index-html (new-post-relative-path blog-title timestamp)
    "Return the HTML string of the index portion to be appended with the NEW-POST-RELATIVE-PATH inside the <a> tag with the BLOG-TITLE and TIMESTAMP."
    (concat
     "<li>
  <a href='" new-post-relative-path "'>" blog-title "</a> - " timestamp "
  </li>")
    )

  (defun blog/new-blog-post-personal ()
    "Asks the user for a blog name and create the directory/index HTML based on the directory of the personal blog. Opens up the file with httpd-start and impatient mode for easy previewing. For easy previewing see preview-blog-post-personal."
    (interactive)
    (let* (
           (name-blog-post (read-from-minibuffer "Name of the blogpost: "))
           (name-blog-post-lower (downcase name-blog-post))
           (name-blog-post-dir (replace-regexp-in-string " +" "-" name-blog-post-lower))
           (full-dir (concat (find-blog-personal) "/" name-blog-post-dir))
           (full-path (concat full-dir "/index.html"))
           )
      (shell-command (concat "mkdir -p " full-dir " && touch " full-path))
      (write-region (new-blog-post-html name-blog-post) nil full-path 'append)

      (with-temp-file (concat (find-blog-personal) "/index.html")
        (insert-file-contents (concat (find-blog-personal) "/index.html"))
        (search-forward "<ul>")
        (open-line 2)
        (forward-line 2)
        (insert (new-blog-post-index-html (concat name-blog-post-dir "/index.html") (capitalize name-blog-post) (blog-timestamp)))
        (web-mode)
        (indent-buffer)
        )
      (find-file full-path)
      (httpd-start)
      (impatient-mode)
      ))

  (defun blog/preview-blog-post-personal ()
    "Open browser with the rendered version of new blog post."
    (interactive)
    (browse-url "http://localhost:8080/imp/live/index.html/"))

  (defun blog/publish-blog-post-personal ()
    "Publishes the website by pushing the blog post to GH and then pulling from the remote."
    (interactive)
    (let ((default-directory (find-blog-personal)))
      (compile "git add .; git commit -m 'New blog post'; git push; ssh root@personal_server 'cd /var/www/blog.cimentada.org/html; git pull'")))

  (defun blog/open-blog-personal ()
    "Open up personal blog"
    (interactive)
    (browse-url "https://blog.cimentada.org/"))

  (spacemacs/declare-prefix "P" "blog")
  (spacemacs/declare-prefix "Ps" "stats")
  (spacemacs/declare-prefix "Pp" "personal")

  (define-key global-map (kbd "M-m P s n ") 'blog/new-blog-post-blogdown)
  (define-key global-map (kbd "M-m P s p ") 'blog/preview-blog-post-blogdown)
  (define-key global-map (kbd "M-m P s P ") 'blog/publish-blog-post-blogdown)
  (define-key global-map (kbd "M-m P s b ") 'blog/open-blog-blogdown)

  (define-key global-map (kbd "M-m P p n ") 'blog/new-blog-post-personal)
  (define-key global-map (kbd "M-m P p p ") 'blog/preview-blog-post-personal)
  (define-key global-map (kbd "M-m P p P ") 'blog/publish-blog-post-personal)
  (define-key global-map (kbd "M-m P p b ") 'blog/open-blog-personal)
  )
