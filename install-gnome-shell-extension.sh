#!/bin/bash

set -e

extensionUrl=$1
if [[ "$extensionUrl" == "" ]]
then
	echo "Missing argument"
	exit 1
fi

echo "> setting up gnome extensions"
set -x
sudo apt-get install gnome-shell-extensions gnome-shell-extension-manager jq
set +x

echo "> installing gnome shell extension $extensionUrl"

tmpExtension="$(mktemp)"
tmpExtensionDir="$(mktemp --directory)"
extensionsDir="$HOME/.local/share/gnome-shell/extensions"
curl "$extensionUrl" > "$tmpExtension"
unzip "$tmpExtension" -d "$tmpExtensionDir"
rm "$tmpExtension"
extensionId="$(jq -r .uuid $tmpExtensionDir/metadata.json)"
extensionDir="$HOME/.local/share/gnome-shell/extensions/$extensionId"

if [[ -e "$extensionDir" ]]
then
	echo "The extension is already installed."
	rm -rf "$tmpExtensionDir"
	exit
fi

mv "$tmpExtensionDir" "$extensionDir"

echo "Installed gnome shell extension $extensionUrl"
