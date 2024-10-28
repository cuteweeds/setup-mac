password=$(gpg --decrypt --interactive --verbose setup-mac/remu.gpg)
echo $password