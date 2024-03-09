# LUKSKey
The program is designed to make it easy to change passwords for encrypted LUKS partitions.  
  
**Dependencies:** gtk2 cryptsetup coreutils polkit
  
![](https://github.com/AKotov-dev/LUKSKey/blob/main/Screenshot1.png)  
  
Intermediate password files are destroyed after use (`shred`, 3 cycles of rewriting with zeros). The interface is intuitive and does not require additional explanation.

## Keyboard layout when entering password

If you used a different input language (non-English) to enter your password, then use the `Shift+Ctrl` or `Shift+Alt` keyboard shortcuts to change the layout during the system boot process. It is noted that in **Mageia** this is a combination that was assigned during the system installation stage, and in **ROSA** it is `Shift+Alt` (fixed). Additionally, there is an option to force the installation of the keyboard layout through the `GRUB` parameters: [rd.vconsole.keymap=xx](https://shivering-isles.com/2023/11/silverblue-luks-preboot-keyboard-layout) or `rd.luks.keymap=xx`.
