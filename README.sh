#!/bin/bash
# Reset JetBrains IDE evaluations
OS_NAME=$(uname -s)

JB_PRODUCTS="IntelliJIdea CLion PhpStorm GoLand PyCharm WebStorm Rider DataGrip RubyMine AppCode"

remove_evals_mac_linux() {
  for PRD in $JB_PRODUCTS; do
    rm -rf $1/"${PRD}"*/eval
    sed -i'' '/<property name="evlsprt.*" value="[^"]*"/d' $1/"${PRD}"*/options/other.xml >/dev/null 2>&1
  done
}

if [ "$OS_NAME" = "Darwin" ]; then
  echo 'macOS:'
  CONFIG_PATH=~/Library/Preferences
  SUPPORT_PATH=~/Library/Application\ Support/JetBrains

  remove_evals_mac_linux "${CONFIG_PATH}"
  remove_evals_mac_linux "${SUPPORT_PATH}"

  # Remove JetBrains specific UUIDs from macOS preferences
  plutil -remove "/.JetBrains.UserIdOnMachine" ~/Library/Preferences/com.apple.java.util.prefs.plist >/dev/null
  plutil -remove "/.jetbrains/.user_id_on_machine" ~/Library/Preferences/com.apple.java.util.prefs.plist >/dev/null
  plutil -remove "/.jetbrains/.device_id" ~/Library/Preferences/com.apple.java.util.prefs.plist >/dev/null
elif [ "$OS_NAME" = "Linux" ]; then
  echo 'Linux:'
  CONFIG_PATH=~/.config/JetBrains
  SUPPORT_PATH=~/."${PRD}"*/config

  remove_evals_mac_linux "${SUPPORT_PATH}"
  remove_evals_mac_linux "${CONFIG_PATH}"

  # Remove JetBrains specific UUIDs from Linux java preferences
  sed -i '/<entry key="JetBrains.UserIdOnMachine" value="[^"]*"/d' ~/.java/.userPrefs/prefs.xml
  sed -i '/<entry key="device_id" value="[^"]*"/d' ~/.java/.userPrefs/jetbrains/prefs.xml
  sed -i '/<entry key="user_id_on_machine" value="[^"]*"/d' ~/.java/.userPrefs/jetbrains/prefs.xml
elif [ "$OS_NAME" = "CYGWIN_NT" ] || [ "$OS_NAME" = "MINGW32_NT" ] || [ "$OS_NAME" = "MSYS_NT" ]; then
  echo 'Windows:'
  CONFIG_PATH=~/AppData/Roaming/JetBrains
  SUPPORT_PATH=~/AppData/Local/JetBrains

  # Assuming Git Bash or similar is being used
  for PRD in $JB_PRODUCTS; do
    rm -rf $CONFIG_PATH/"${PRD}"*/eval
    sed -i 's/<property name="evlsprt.*" value="[^"]*"\/>//g' $CONFIG_PATH/"${PRD}"*/options/other.xml
    rm -rf $SUPPORT_PATH/"${PRD}"*/eval
    sed -i 's/<property name="evlsprt.*" value="[^"]*"\/>//g' $SUPPORT_PATH/"${PRD}"*/options/other.xml
  done

  # Remove JetBrains specific UUIDs from Windows registry (not supported by shell script, needs PowerShell or regedit)
  echo 'Registry clean up is not supported by this script. Please use Windows tools like regedit or PowerShell.'
else
  echo 'Unsupported OS'
  exit 1
fi

echo 'done.'
