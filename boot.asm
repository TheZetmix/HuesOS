;; BOOT

bits 16
org 0x7C00

KERNEL_OFFSET equ 0x200
KERNEL_SECTORS equ 1
    
start:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, BOOT_MSG
    call puts

    mov bx, KERNEL_OFFSET
    mov dh, KERNEL_SECTORS
    call load_disk

    mov si, BOOT_MSG_SUCCESFUL
    call puts
    mov si, BOOT_MSG_LOAD
    call puts
    
    mov ah, 0x0               ; параметр для вызова 0x16
    int 0x16                  ; получаем ASCII код
    
    jmp KERNEL_OFFSET

load_disk:
    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    int 0x13
    jc disk_error
    ret

disk_error:
    mov si, DISK_ERR
    call puts
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
puts:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp puts
done:
    ret

BOOT_MSG db "Loading kernel...", 0x0A, 0x0D, 0
BOOT_MSG_SUCCESFUL db "HuesOS Loaded!", 0x0A, 0x0D, 0
BOOT_MSG_LOAD db "Press enter to load...", 0
    
DISK_ERR db "disk error", 0x0A, 0x0D, 0
    
times 510-($-$$) db 0
dw 0xAA55
