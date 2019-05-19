.model small
.stack 100h
 
.data
    input_str db 256 dup ('$')
    
    msg0 db "choice type of working:",0,0dh,0ah
         db "1. Console input",0,0dh,0ah
         db "2. File input",0,0dh,0ah,'$'
    
    msg1 db 'enter your string for encryption', '$'
    msg2 db 'enter your key string', '$'
    msg3 db 'encrypted string', '$'
    msg4 db 'do you want to continue?(y/n)', '$'
    
    Error   db "Error! Try again",0,0dh,0ah,'$'
    outfile db "output_fl.txt",0    
    infile  db "input_fl.txt",0    
    handle  dw ?    
    act     db ?    
    choice  db 0
    
    str_len dw 0
    key_len dw 0
    counter dw 0
    temp dw 0
    temp_value dw 0
 
 
.code
.386
start:
    mov ax,@data
    mov ds,ax
    mov es, ax
    
    call NewLine            
    lea dx, msg0
    mov ah, 9
    int 21h
    call NewLine
    
    mov ah, 1
    int 21h
    cmp al, 49
    mov choice, al    ;if choice == 1
    je Choice1
    cmp al, 50  
    mov choice, al     ;if choice == 2
    je Choice2
    
Choice1:  
    call NewLine            
    lea dx, msg1
    mov ah, 9
    int 21h
    call NewLine
 
    lea si, input_str
 
GetInputStr:
    mov ah, 1
    int 21h
    mov [si], al
    cmp al, 13      ;if button == enter
    je PrintMsg2
    inc si
    inc str_len
    jmp GetInputStr
 
PrintMsg2:
    call NewLine
    lea dx, msg2
    mov ah, 9
    int 21h
    call newLine
    
GetInputKey:    
    mov ah, 1
    int 21h
    mov [si], al
    cmp al, 13
    je StartEncryption
    inc si
    inc key_len
    jmp GetInputKey

Choice2:
    mov ah, 3Dh             
    xor al, al      
    lea dx, infile        
    xor cx, cx           
    int 21h
    jnc f1                  
    lea dx, Error
    mov ah, 09h
    int 21h
    jmp Exit                
f1:
    mov handle, ax
    mov bx, ax               
    mov ah, 3Fh              
    lea dx, input_str         
    mov cx, 1021             
                                                                                             
    int 21h
    jnc f2             
    lea dx, Error
    mov ah, 09h
    int 21h
    jmp Exit            
f2:
    mov bx, ax
    mov act, al
    mov input_str[bx], 0dh    
    mov input_str[bx+1], 0ah
    mov input_str[bx+2], '$'
    mov ah, 3Eh              
    mov bx, handle          
    int 21h                 
    jnc f3                  
    lea dx,Error
    mov ah,09h
    int 21h
    jmp Exit
f3:
    call NewLine            
    lea dx, msg1
    mov ah, 9
    int 21h
    call NewLine
    
    lea di, input_str
    lea si, input_str
    
FileGetInputStr:
    mov dl, [si]
    cmp dl, 13      ;if button == enter
    je FilePrintMsg2
    mov ah, 2
    int 21h
    inc si
    inc str_len
    jmp FileGetInputStr
 
FilePrintMsg2:
    call NewLine
    call NewLine
    lea dx, msg2
    mov ah, 9
    int 21h
    
    inc si
FileGetInputKey:    
    mov dl, [si]
    cmp dl, 13
    je FileStartEncryption
    mov ah, 2
    int 21h
    inc si
    inc key_len
    jmp FileGetInputKey
    
FileStartEncryption:
    call NewLine
    jmp StartEncryption
    
    
NewLine:
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    int 21h
    ret
 
;================================  
 
StartEncryption:
   lea si, input_str    
   mov cx, str_len
    
Encryption:    
    mov temp, si      ;Save current index
    call GetKeyLetter
    mov si, temp    
    xor [si], al    
    inc si
loop Encryption    

    call NewLine
    lea dx, msg3
    mov ah, 9
    int 21h
    
    mov si, str_len
    mov input_str[si], 36   ;change symbol after input_str to $
    mov cx, key_len
    
DeleteKey:
    inc si   
    mov input_str[si], 0 
loop DeleteKey

    call NewLine
    lea dx, input_str   ;write encrypted string
    mov ah, 9
    int 21h
    
    mov dl, choice
    cmp dl, 49      ;if choice == 1
    je PrintMsg4
    mov ah, 3Ch             
    xor al, al               
    lea dx, outfile         
    xor cx, cx               
    int 21h
    jnc f4                  
    lea dx, Error
    mov ah, 09h
    int 21h
    jmp Exit                
f4:
    mov handle, ax
    mov bx, ax
    mov ah, 40h               
    lea dx, input_str
    xor cx, cx
    mov cl, act
    int 21h
    mov ah, 3eh
    mov bx, handle
    int 21h
    ;mov act, 0                 
    ;mov string,'$'           
    
PrintMsg4:    
    call NewLine
    call NewLine
    lea dx, msg4
    mov ah, 9
    int 21h
    
    call NewLine
    mov ah, 1
    int 21h
    cmp al, 121     ;if choice == y
    je ChoiceY
Exit:
    mov ax, 4c00h       ;end of the program
    int 21h
    
ChoiceY:
    mov str_len, 0
    mov key_len, 0
    mov counter, 0
    mov temp, 0
    mov temp_value, 0
    call NewLine
    call start
    
GetKeyLetter proc
    add si, cx
    add si, counter
    mov al, [si]        ;current key letter
    inc counter
    mov dx, counter
    cmp dx, key_len    ;if counter == key_len
    je Lastletter
    ret
    
    Lastletter:
    mov counter, 0
    ret
GetkeyLetter endp

    end start
    