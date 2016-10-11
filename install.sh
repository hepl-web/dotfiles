#!/bin/sh
# hepl-web/dotfiles - system install

# VARS
START_TIME=$SECONDS
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "---------- .dotfiles --------"
echo ""
echo "This will install & setup all the system."
read -n 1 -r -p "Ready? [y/N]" response
case $response in
    [yY]) echo "";;
    *) exit 1;;
esac

echo ""
echo "----- link dotfiles -----"

ln -sfv "$DOTFILES_DIR/../etc/gitconfig" ~/.gitconfig
ln -sfv "$DOTFILES_DIR/../etc/gitignore_global" ~/.gitignore_global
ln -sfv "$DOTFILES_DIR/../etc/curlrc" ~/.curlrc
ln -sfv "$DOTFILES_DIR/../etc/wgetrc" ~/.wgetrc
ln -sfv "$DOTFILES_DIR/../etc/editorconfig" ~/.editorconfig

echo ""
echo "----- install tools for XCode -----"
if [[ ! -d "$('xcode-select' -print-path 2>/dev/null)" ]]; then
    sudo xcode-select -switch /usr/bin
fi

echo ""
echo "----- install homebrew -----"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update
brew upgrade
brew tap homebrew/dupes
brew install homebrew/dupes/grep

echo "----- brew: install formulas -----"
xargs brew install < "$DOTFILES_DIR/packages/brew"
brew cleanup

echo ""
echo "----- brew: cask -----"
brew tap caskroom/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
xargs brew cask install < "$DOTFILES_DIR/packages/cask"

echo ""
echo "----- brew: quicklook -----"
xargs brew cask install < "$DOTFILES_DIR/packages/quicklook"

echo ""
echo "----- brew: fonts -----"
brew tap caskroom/fonts
xargs brew cask install < "$DOTFILES_DIR/packages/fonts"

echo ""
echo "----- setup: htop -----"
if [[ "$(type -P $binroot/htop)" ]] && [[ "$(stat -L -f "%Su:%Sg" "$binroot/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "$binroot/htop") & 4))" ]]; then
    echo "- Updating htop permissions"
    sudo chown root:wheel "$binroot/htop"
    sudo chmod u+s "$binroot/htop"
fi

echo ""
echo "----- install npm packages -----"
xargs npm install -g < "$DOTFILES_DIR/packages/npm"

echo ""
echo "----- install atom packages -----"
xargs apm install -g < "$DOTFILES_DIR/packages/apm"

echo ""
echo "----- install vagrant boxes -----"
vagrant box add laravel/homestead
vagrant box add --name leny/etab http://vagrant.flatland.be/etab-2016-10-04.box

echo ""
echo "----- generate directory structure -----"

mkdir -p ~/Students

echo ""
echo "----- setup mac system -----"

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################

########## General UI/UX

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "fr" "en"
defaults write NSGlobalDomain AppleLocale -string "fr_BE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Brussels" > /dev/null

######### Terminal & iTerm 2

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

########## Trackpad, mouse, keyboard, Bluetooth accessories, and input

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Enable access for assistive devices
echo -n 'a' | sudo tee /private/var/db/.AccessibilityAPIEnabled > /dev/null 2>&1
sudo chmod 444 /private/var/db/.AccessibilityAPIEnabled

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

########## Screen

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

########## Finder

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Use AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view.
# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

########## Dock, Dashboard, and hot corners

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

########## Safari & WebKit

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Set up Safari for development.
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

######### Chrome

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# Disable the all too sensitive backswipe on Magic Mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

######## Time Machine

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Menu bar: hide the useless Time Machine and Volume icons
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/AirPort.menu" "/System/Library/CoreServices/Menu Extras/Battery.menu" "/System/Library/CoreServices/Menu Extras/Clock.menu"

# Disable local Time Machine backups
hash tmutil &> /dev/null && sudo tmutil disablelocal

########## Activity Monitor

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

########## TextEdit and Disk Utility

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

###############################################################################

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo ""
echo ""
echo ""
echo "-----------------------------"
echo "----- dotfiles ended -----"
echo "-----------------------------"
echo "Duration : $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "-------------------------"
echo "Done. All these changes require a logout/restart to take effect."
echo "-------------------------"

read -n 1 -r -p "Ready? [y/N]" response
case $response in
    [yY]) echo ""; osascript -e 'tell app "System Events" to restart';;
    *) echo "ok."; exit 0;;
esac
