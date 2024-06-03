(TeX-add-style-hook
 "pyramid"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("standalone" "margin=10pt")))
   (TeX-run-style-hooks
    "latex2e"
    "standalone"
    "standalone10"
    "tikz")
   (TeX-add-symbols
    "colorlist"))
 :latex)

