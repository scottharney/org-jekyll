;;; Emacs org-mode support for blogging with Jekyll.
;;;
;;; To use, just put this file somewhere in your emacs load path and
;;; (require 'org-jekyll)
;;;
;;; An article showing its use can be found at:
;;;    - http://www.gorgnegre.com/linux/using-emacs-orgmode-to-blog-with-jekyll.html
;;;
;;; Adapted from
;;;    - http://orgmode.org/worg/org-tutorials/org-jekyll.html
;;;    - https://github.com/metajack/jekyll/blob/master/emacs/jekyll.el
;;;
;;;    - http://www.gorgnegre.com/linux/using-emacs-orgmode-to-blog-with-jekyll.html
;;; Gorg Negre 2012-07-05

(provide 'org-jekyll)

;; Define our org project to be exported. Run "M-x org-export X scott" to
;; export.
(setq org-publish-project-alist
      '(

   ("org-scottharney"
          :base-directory "/home/sharney/scottharney.com/org/" ;; Path to your org files.
          :base-extension "org"
          :publishing-directory "/home/sharney/scottharney.com/jekyll/" ;; Path to your Jekyll project.
          :recursive t
          :publishing-function org-html-publish-to-html
          :headline-levels 6
          :html-extension "html"
          :body-only t ;; Only export section between &lt;body&gt; &lt;/body&gt; tags
          :section-numbers nil
          :table-of-contents nil

          :author "Scott Harney"
          :email "scotth@scottharney.com"
    )

    ("org-static-scottharney"
          :base-directory "/home/sharney/scottharney.com/org/"
          :base-extension "css\\|js\\|png\\|jpg\\|ico\\|gif\\|pdf\\|mp3\\|flac\\|ogg\\|swf\\|php\\|markdown\\|md\\|html\\|htm\\|sh\\|xml\\|gz\\|bz2\\|vcf\\|zip\\|txt\\|tex\\|otf\\|ttf\\|eot\\|rb\\|yml\\|htaccess\\|gitignore"
          :publishing-directory "/home/sharney/scottharney.com/jekyll/"
          :recursive t
          :publishing-function org-publish-attachment)

    ("scott" :components ("org-scottharney" "org-static-scottharney"))

))

;; Improve our blogging experience with Org-Jekyll. This code sets four
;; functions with corresponding key bindings:
;;
;; leader/o j n - Create new draft
;; leader/o j P - Post current draft
;; leader/o j d - Show all drafts
;; leader/o j p - Show all posts
;;
;; Once a draft has been posted (i.e., moved from the _drafts
;; directory to _post with the required date prefix in the filename), we
;; then need to html-export it to the jekyll rootdir (with org-publish).

 (spacemacs/set-leader-keys "ojn" 'org-jekyll-draft-post)
 (spacemacs/set-leader-keys "ojP" 'org-jekyll-publish-post)
 (spacemacs/set-leader-keys "ojp" 'org-jekyll-list-posts)
 (spacemacs/set-leader-keys "ojd" 'org-jekyll-list-drafts)

(defvar org-jekyll-directory "/home/sharney/scottharney.com/org/"
  "Path to Jekyll blog.")
(defvar org-jekyll-drafts-dir "_drafts/"
  "Relative path to drafts directory.")
(defvar org-jekyll-posts-dir "_posts/"
  "Relative path to posts directory.")
(defvar org-jekyll-post-ext ".org"
  "File extension of Jekyll posts.")
(defvar org-jekyll-post-template
  "#+OPTIONS: H:2 num:nil tags:nil toc:nil timestamps:t\n#+BEGIN_HTML\n---\nlayout: post\ntitle: %s\nexcerpt: \ncategories:\n  -  \ntags:\n  -  \ncomments: true\npublished: false\n---\n#+END_HTML\n\n** "
  "Default template for Jekyll posts. %s will be replace by the post title.")

(defun org-org-jekyll-list-drafts ()
    "list org drafts"
    (interactive)
    (find-file (concat org-jekyll-directory org-jekyll-drafts-dir)))

(defun org-org-jekyll-list-posts ()
  "list org posts"
  (interactive)
  (find-file (concat org-jekyll-directory org-jekyll-posts-dir)))

(defun org-jekyll-make-slug (s)
  "Turn a string into a slug."
  (replace-regexp-in-string
   " " "-" (downcase
            (replace-regexp-in-string
             "[^A-Za-z0-9 ]" "" s))))

(defun org-jekyll-yaml-escape (s)
  "Escape a string for YAML."
  (if (or (string-match ":" s)
          (string-match "\"" s))
      (concat "\"" (replace-regexp-in-string "\"" "\\\\\"" s) "\"")
    s))

(defun org-jekyll-draft-post (title)
  "Create a new Jekyll blog post."
  (interactive "sPost Title: ")
  (let ((draft-file (concat org-jekyll-directory org-jekyll-drafts-dir
                            (org-jekyll-make-slug title)
                            org-jekyll-post-ext)))
     (if (file-exists-p draft-file)
         (find-file draft-file)
       (find-file draft-file)
       (insert (format org-jekyll-post-template (org-jekyll-yaml-escape title))))))
 
 (defun org-jekyll-publish-post ()
   "Move a draft post to the posts directory, and rename it so that it
 contains the date."
   (interactive)
   (cond
    ((not (equal
           (file-name-directory (buffer-file-name (current-buffer)))
           (concat org-jekyll-directory org-jekyll-drafts-dir)))
     (message "This is not a draft post.")
     (insert (file-name-directory (buffer-file-name (current-buffer))) "\n"
             (concat org-jekyll-directory org-jekyll-drafts-dir)))
    ((buffer-modified-p)
     (message "Can't publish post; buffer has modifications."))
    (t
     (let ((filename
            (concat org-jekyll-directory org-jekyll-posts-dir
                    (format-time-string "%Y-%m-%d-")
                    (file-name-nondirectory
                     (buffer-file-name (current-buffer)))))
           (old-point (point)))
       (rename-file (buffer-file-name (current-buffer))
                    filename)
       (kill-buffer nil)
       (find-file filename)
       (set-window-point (selected-window) old-point)))))
