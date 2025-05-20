;; KERNEL

bits 16
org 0x200
    
start:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    mov si, MSG_WELCOME
    call puts

huesos.exec:
    mov si, MSG_GREET
    call puts
    
    mov bx, input
    call get_input

    mov si, EXEC_SHUT
    mov di, input
    call cmp_str
    cmp bx, 1
    je DO_SHUT

    mov si, EXEC_MSG
    mov di, input
    call cmp_str
    cmp bx, 1
    je DO_MSG
    
    mov si, EXEC_CLS
    mov di, input
    call cmp_str
    cmp bx, 1
    je DO_CLS

    mov si, EXEC_HELP
    mov di, input
    call cmp_str
    cmp bx, 1
    je DO_HELP
    
    mov si, unknown_cmd
    call puts
    mov si, input
    call puts

    mov si, newline
    call puts
    
    jmp huesos.exec
    
puts:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp puts
done:
    ret

get_input:
    mov bx, 0
clean_input_loop:
    mov byte [input+bx], 0      ; очищаем буффер
    inc bx
    cmp bx, 64
    jne clean_input_loop
    mov bx, 0                 ; инициализируем bx как индекс для хранения ввода
input_processing:
    mov ah, 0x0               ; параметр для вызова 0x16
    int 0x16                  ; получаем ASCII код

    mov ah, 0x0E
    int 0x10

    cmp al, 0x0D
    je endinput
    cmp al, 0x08
    je backspace_pressed
    
    mov [input+bx], al        ; и сохраняем его в буффер ввода
    inc bx                    ; увеличиваем индекс
    jmp input_processing      ; и идем заново
backspace_pressed:
    cmp bx, 0
    je input_processing

    mov ah, 0x0E
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    
    mov byte [input+bx], 0
    dec bx
    
    jmp input_processing
endinput:
    mov si, newline
    call puts
    ret

cmp_str:
    xor bx, bx
.loop:
    mov cl, [si]
    mov ch, [di]
    cmp cl, ch
    jne .not_equ
    test cl, cl
    jz .equ
    inc si
    inc di
    jmp .loop
.equ:
    mov bx, 1
.not_equ:
       ret

    
DO_SHUT:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

DO_MSG:
    mov si, MSG_WELCOME
    call puts
    jmp huesos.exec

DO_CLS:
    mov ah, 0x00
    mov al, 0x03
    int 0x10    
    jmp huesos.exec

DO_HELP
    mov si, MSG_HELP
    call puts
    jmp huesos.exec

    
MSG_WELCOME db "Welcome to HuesOS!", 0x0A, 0x0A, 0x0D, "Type HELP to show help message", 0x0A, 0x0A, 0x0D, 0
MSG_GREET db "-#", 0
unknown_cmd db "Unknown command ", 0

EXEC_SHUT   db "SHUT", 0
EXEC_MSG    db "MSG", 0
EXEC_CLS    db "CLS", 0
EXEC_HELP   db "HELP", 0
    
MSG_HELP db "Commands:", 0x0A, 0x0D
         db "SHUT - Shutdown PC", 0x0A, 0x0D
         db "MSG - Show greet message", 0x0A, 0x0D
         db "CLS - Clear screen", 0x0A, 0x0D
    
    
newline db 0x0A, 0x0D, 0    
input:  times 64 db 0
