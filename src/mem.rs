use core::mem::size_of;

static mut base: uint = 0x200000;

// Naive malloc
#[no_mangle]
pub extern "C" fn malloc(len: uint) -> *mut u8 {
    unsafe {
        let ret: uint = base;
        base += len + size_of::<uint>();

        // Align next allocation to 4-byte boundary.
        if base % 4 != 0 {
            base += 4 - (base % 4);
        }

        *(base as *mut uint) = len;

        return (ret + size_of::<uint>()) as *mut u8;
    }
}

// Even more naive free().
#[no_mangle]
pub extern "C" fn free(_ptr: *mut u8) {}

#[no_mangle]
pub extern "C" fn realloc(_ptr: *mut u8, _len: uint) {}

#[no_mangle]
pub extern "C" fn calloc(len: uint) -> *mut u8 {
    return malloc(len);
}

#[no_mangle]
pub extern "C" fn aligned_alloc(len: uint) -> *mut u8 {
    return malloc(len);
}


pub fn main() {}
