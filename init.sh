#!/usr/bin/env bash

# Initialize the codebase.

# Attempt to generate android keystore.
android_key_properties_file='android/key.properties'

if [[ ! -f ${android_key_properties_file} ]]; then
    read -s -p "Keystore Password: " STORE_PASS
    echo
    read -p "Key Alias: " KEY_ALIAS
    read -s -p "Key Password: " KEY_PASS
    echo

    # Generate the keystore file.
    keytool -genkey -v -keystore "android/app/release.keystore" -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -storepass "$STORE_PASS" -keypass "$KEY_PASS"
    # keytool -importkeystore -srckeystore android/app/release.keystore -destkeystore android/release.keystore -deststoretype pkcs12

    # Store the environment properties.
    echo "storeFile=release.keystore
storePassword=$STORE_PASS
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASS" > ${android_key_properties_file}

fi
