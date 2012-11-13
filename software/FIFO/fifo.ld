SECTIONS
{
    . = 0x1ffff000;
    .text : {
        * (.start);
        * (.text);
    }
}
