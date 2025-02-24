# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#
# {{ ansible_managed }}
#

check: ANSIBLE-exists

setup:
	sudo cp ansible.cfg hosts /etc/ansible
	sudo ln -s $PWD/roles /etc/ansible/roles
	sudo ln -s $PWD/group_vars /etc/ansible/group_vars
