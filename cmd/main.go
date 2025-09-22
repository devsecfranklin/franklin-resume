/*
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT
*/

package main

import (
	"github.com/go-git/go-git/v5"
	"internal/logging"
	"os"
)

var (
	err error
)

func main() {

	// create the dir structure in /home/user/workspace
	logging.Log_info("Create the dir structure") //

	// clone the lab repo
	_, err := git.PlainClone("/home/franklin/workspace", false, &git.CloneOptions{
		URL:      "https://github.com/go-git/go-git",
		Progress: os.Stdout,
	})
	if err != nil {
		logging.Log_error(err)
	}

}
