#!/bin/bash
password=$(gpg --decrypt --interactive --verbose setup-mac/remu.gpg) > repo_key
