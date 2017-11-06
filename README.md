# ido-goto.el
Select Imenu tags for a buffer using IDO completion.

The `ido-goto` function shows an ido selection list in the minibuffer of the imenu tags of the current buffer.  Selecting one will jump to that symbol.

To use, just bind ido-goto to a convenient key:

    (global-set-key (kbd "C-c g") 'ido-goto)
