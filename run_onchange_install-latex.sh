#!/bin/bash
# Install a LaTeX (TeX Live) toolchain for compiling LaTeX documents to PDF.
#
# Full-but-not-everything TeX Live set (pdf/xe/lua-latex, latexmk, latexindent,
# chktex). Skips the multi-GB texlive-meta "everything" group.
#
# Large download (~2-4 GB). Idempotent.
set -e

omarchy pkg add \
    texlive-basic \
    texlive-latex \
    texlive-latexrecommended \
    texlive-latexextra \
    texlive-fontsrecommended \
    texlive-fontsextra \
    texlive-langenglish \
    texlive-binextra
