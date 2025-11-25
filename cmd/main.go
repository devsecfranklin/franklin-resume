/*
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT
*/

package main

import (
	"html/template"
	"net/http"
	"internal/logging"
)

var (
	err error

	LayoutDir string = "template/"
	tmpls     *template.Template
)

func main() {
	fs := http.FileServer(http.Dir("./static/www"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	tmpls, err = template.ParseGlob(LayoutDir + "/*.tmpl")
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/", handler)

}

func handler(w http.ResponseWriter, r *http.Request) { // handler for the root path
	log.Println("Serving index page")

	w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
	w.Header().Set("Pragma", "no-cache")
	w.Header().Set("Expires", "0")

	page := Page{"www.bitsmasher.net"}

	err := tmpls.ExecuteTemplate(w, "indexPage", page) // Assuming you have an "indexPage" template
	if err != nil {
		log.Println(err)
		http.Error(w, "Internal server error: Could not render index page.", http.StatusInternalServerError)
	}
}
