#!/bin/bash
# Install a LaTeX (TeX Live) toolchain for compiling LaTeX documents to PDF.
#
# Package set mirrors a typical full-but-not-everything install: the base
# engine and latex format, the recommended + extra latex packages, the
# recommended + extra fonts, English language support, and the binextra
# scripts collection (latexmk, latexindent, texcount, chktex, ...). Pulls in
# pdflatex/xelatex/lualatex, latexmk, and the bulk of CTAN packages most
# documents need (skips the multi-GB texlive-meta "everything" group).
#
# Large download (~2-4 GB). Idempotent: omarchy pkg add uses pacman --needed
# and is a no-op once the packages are present.
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
