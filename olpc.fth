\ OLPC boot script

visible

: xo-version  ( -- n )  fw-version$ drop 1+ c@ [char] 0 -  ;

: xo-1?  ( -- flag )  xo-version 2 =  ;

: xo-1.5?  ( -- flag )  xo-version 3 =  ;

: desired-ofw-version$  ( -- adr len )
   xo-version case
      2 of  " q2f20 "  endof   \ XO-1
      3 of  " q3c17 "  endof   \ XO-1.5
      ( default )
         ." UNKNOWN XO VERSION" cr
      " q0000 "  rot
   endcase
;

: $ofw-version-num  ( adr len -- n )  drop h# fffc6 -  (fw-version)  ;

: this-ofw-version-num  ( -- n )  rom-pa (fw-version)  ;

: check-ofw  ( -- )
   desired-ofw-version$ $ofw-version-num  this-ofw-version-num u>  if
      ." You need to update the firmware to "  desired-ofw-version$ type  cr
   then
;

: set-path-macros  ( -- )
   \ "O" game button forces boot from internal FLASH
   button-o game-key?  if
      " \boot"  pn-buf place
      " int:"   dn-buf place
      exit
   then

   \ Set DN to the device that was used to boot this script
   " /chosen" find-package  if                       ( phandle )
      " bootpath" rot  get-package-property  0=  if  ( propval$ )
         get-encoded-string                          ( bootpath$ )
         [char] \ left-parse-string  2nip            ( dn$ )
         dn-buf place                                ( )
      then
   then

   \ Set PN according to the XO version
   xo-version  case
      2 of  " \boot10"  endof
      3 of  " \boot"  endof
      ( default )  " \" rot
   endcase  ( adr len )
   pn-buf place
;


: dn-contains?  ( $ -- flag )  " ${DN}" expand$  sindex 0>=  ;
: usb?    ( -- flag )  " /usb"     dn-contains?  ;
: sd?     ( -- flag )  " /sd"      dn-contains?  ;
: slot1?  ( -- flag )  " /disk@1"  dn-contains?  ;

: olpc-fth-boot-me  ( -- )
   set-path-macros

   usb?  if
      " PDEV1=sda1"
   else
      sd?  if
         slot1?  if
            " PDEV1=mmcblk0p1"  \ External SD card
         else
            " PDEV1=mmcblk1p1"  \ Internal SD card
         then
      else
         " "   \ Internal raw NAND
      then
   then
   " PD" $set-macro

   check-ofw

   " ro root=LABEL=ARCHroot rootdelay=10 ${PD}" expand$ to boot-file

\ Uncomment the next 2 lines to see the command line
\   ." cmdline is " boot-file type cr
\   d# 4000 ms

   " ${DN}${PN}\vmlinuz-linux-via-olpc"    expand$ to boot-device
   " ${DN}${PN}\initramfs-linux-via-olpc.img" expand$ to ramdisk
   boot
;
olpc-fth-boot-me


