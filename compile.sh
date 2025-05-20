# Ассемблируем загрузчик и ядро
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

# Создаем образ дискеты (1.44 MB)
dd if=/dev/zero of=floppy.img bs=512 count=2880

# Записываем загрузчик в первый сектор (с сигнатурой 0xAA55)
dd if=boot.bin of=floppy.img conv=notrunc bs=512 count=1

# Записываем ядро, начиная со второго сектора (offset 0x200)
dd if=kernel.bin of=floppy.img conv=notrunc bs=512 seek=1

qemu-system-i386 --full-screen -fda floppy.img
