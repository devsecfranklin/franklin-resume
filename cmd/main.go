/*
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT
*/

package main

import (
	"fmt"
	"html/template"
	"internal/logging"
	"net/http"
)

var (
	err error

	LayoutDir string = "template/"
	tmpls     *template.Template
)

type (
	Page struct { // Page data structure for a generic page
		Title string
	}
)

func main() {
	fs := http.FileServer(http.Dir("./static/www"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	tmpls, err = template.ParseGlob(LayoutDir + "/*.tmpl")
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/", handler)

	logging.Log_header("Server listening on :8080")
	err = http.ListenAndServe(":8080", nil)
	if err != nil {
		logging.Log_fatal(fmt.Sprintf("Server failed to start: %v", err))
	}

}

func handler(w http.ResponseWriter, r *http.Request) { // handler for the root path
	logging.Log_header("Serving index page")

	w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
	w.Header().Set("Pragma", "no-cache")
	w.Header().Set("Expires", "0")

	page := Page{"www.bitsmasher.net"}

	err := tmpls.ExecuteTemplate(w, "indexPage", page) // Assuming you have an "indexPage" template
	if err != nil {
		logging.Log_error(err.Error())
		http.Error(w, "Internal server error: Could not render index page.", http.StatusInternalServerError)
	}
}
