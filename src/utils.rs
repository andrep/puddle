pub unsafe fn outb(port: u16, value: u8) {
    asm!("outb %al, %dx"
         :
         : "{dx}" (port), "{al}" (value)
         :
         : "volatile" );
}

pub unsafe fn inb(port: u16) -> u8 {
    let ret: u8;
    asm!("inb %dx, %al"
         : "={al}"(ret)
         : "{dx}"(port)
         :
         : "volatile" );
    return ret;
}
