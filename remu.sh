#!/bin/bash
password=$(gpg --decrypt --interactive --verbose remu.gpg) > repo_key
