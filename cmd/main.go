/*
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT
*/

package main

import (
	"html/template"
	"net/http"
)

var (
	err error

	LayoutDir string = "template/www"
	tmpls     *template.Template
)

func main() {
	fs := http.FileServer(http.Dir("./static/www"))
	http.Handle("/static/www/", http.StripPrefix("/static/www/", fs))

	tmpls, err = template.ParseGlob(LayoutDir + "/*.tmpl")
	if err != nil {
		panic(err)
	}
}