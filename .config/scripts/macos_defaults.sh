defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
