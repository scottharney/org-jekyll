org-jekyll
==========

Set up for the combo Emacs Org-mode & Jekyll.

This was forked from
[from](http://www.gorgnegre.com/linux/using-emacs-orgmode-to-blog-with-jekyll.html)
. The original author may have abandoned this as the source repo doesn't have
the `org-jekyll.el` file referenced in the post.  I copied the file contents
form the post and made several changes.

  * I use [spacemacs](http://spacemacs.org) so I updated the key mappings to
  suit me.
  * I fixed `:publishing-function org-html-publish-to-html` in the publish list
    since that has changed
  * fixed some default template items to suit me
  * refactored functin names and vars to `org-jekyll`
  * added functions for the list drafts/posts items so they would show up right
    with helm in spacemacs
