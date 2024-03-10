# LUKSKey
The program is designed to make it easy to change passwords for encrypted LUKS partitions.  
  
**Dependencies:** gtk2 cryptsetup coreutils polkit
  
![](https://github.com/AKotov-dev/LUKSKey/blob/main/Screenshot1.png)  
  
Intermediate password files are destroyed after use (`shred`, 3 cycles of rewriting with zeros). The interface is intuitive and does not require additional explanation.

### Keyboard layout when entering password
To avoid problems with `passwords`, it is strongly recommended to use `English`!
