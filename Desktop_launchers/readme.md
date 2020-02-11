# This file is part of eRCaGuy_dotfiles: https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles

# Manual Install of Desktop Files:

INSTRUCTIONS:
- See here for detailed instructions:  
  https://askubuntu.com/questions/64222/how-can-i-create-launchers-on-my-desktop/1014261#1014261  
  
In short:  
1. Ensure the "~/Desktop_launchers" directory exists:
          mkdir -p ~/Desktop_launchers
2. Copy this file to "~/Desktop_launchers" & ensure it is executable.
          cd /path/to/here
          cp -i new_launcher.desktop ~/Desktop_launchers
          chmod +x ~/Desktop_launchers/new_launcher.desktop
3. Manually edit the file to update the Name, Exec path, and Icon below.
4.        gedit ~/Desktop_launchers/new_launcher.desktop  # open in gedit GUI editor, then edit & save
5. Make a symbolic link to your .desktop launcher on the Desktop so you can launch it from there:
   Command Format: "ln -s /path/to/file /path/to/symlink_to_make"
          ln -s ~/Desktop_launchers/new_launcher.desktop ~/Desktop/new_launcher.desktop
6. Make a symbolic link to it on the Application menu so you can launch it from the Application Menu or Ubuntu
   Dock too. 
   Notes:
   - Application .desktop files are stored in: "/usr/share/applications"
   - The .desktop files in the applications directory, unlike on the Desktop, don't need to be marked executable 
     to work.
          sudo ln -s ~/Desktop_launchers/new_launcher.desktop /usr/share/applications/new_launcher.desktop
5. Done!
   Now if you ever need to update the desktop file, update it directly in only one place: 
   "~/Desktop_launchers/new_launcher.desktop", and the changes will automatically be recognized by the 
   symlinks on the Desktop and in "/usr/share/applications". If the Desktop icon doesn't update after 
   changing it, click on the Desktop then hit either 'F5' or 'Ctrl + R' to refresh the Desktop icons.
6. To remove the shortcuts simply delete the symlinks from the Desktop and from "/usr/share/applications" as follows:
          rm ~/Desktop/new_launcher.desktop
          sudo rm /usr/share/applications/new_launcher.desktop