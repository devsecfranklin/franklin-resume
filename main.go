/*
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT
*/

package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"

	"internal/logging"
)

type (
	Page struct { // Page data structure for a generic page
			Title string
	}
)

var (
	err error
	LayoutDir string = "template/www"
	tmpls     *template.Template
)

func main() {
	fs := http.FileServer(http.Dir("./static/"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))
	tmpls, err = template.ParseGlob(LayoutDir + "/*.tmpl")
	if err != nil {
			panic(err)
	}

	http.HandleFunc("/", handler)
	http.HandleFunc("/bio", bioHandler)
	logging.Log_header("Server listening on :8080")
	err = http.ListenAndServe(":8080", nil)
	if err != nil {
			logging.Log_fatal(fmt.Sprintf("Server failed to start: %v", err))
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
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

func bioHandler(w http.ResponseWriter, r *http.Request) {
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
