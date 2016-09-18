format PE console
entry _start         ; we let fasm know that it should start at this label

include 'win32a.inc' ; we'll need certain functions from Win32

; Constants
str_fmt:  db  "The result is %d",0

; here we define the layout of the future PE/COFF binary
section '.text' code readable executable

; a simple function that does ECX+1 and then moves the new value to EAX
; the value in EAX later serves as the `return value` of `_incr` 
_incr:         
       push ebp
       mov ebp, esp
       
       mov ecx,[ebp+8]
       inc ecx
       mov eax, ecx
       
       mov esp, ebp
       pop ebp
       retn
; our program starts here
_start:
        push ebp      ; save old stack pointer and create new stack frame
        mov  ebp, esp
                    
        mov  eax, 10  ; prepare argument for function `_incr`
        push eax      ; and put them on the stack so `_incr` can grab them

        call _incr    ; Go to `_incr` label and continue execution there
                      ; Notice: 
                      ; Every `call` comprises of two _implicit_ tasks: 
                      ; First, save the NEXT ADDRESS after `call` to EIP 
                      ; Sencond: JUMP to the given label. 
                      ; The address that's being saved into EIP-register will
                      ; later be used to find the point in memory where
                      ; the program should continue its execution after the
                      ; called procedure has completed. In our case
                      ; the address will belong to the `add esp, 4` mnemonic
                      ; below the `call _incr`. Every `call` is actuall a 
                      ; MOV EIP, some-address and JUMP some-label but because
                      ; there's no possibility to manipulate EIP directly 
                      ; the values in EIP can only be changed by special 
                      ; menonics like `call`.
                      
        add  esp, 4   ; We came back from `_incr` and will reclaim the previously 
                      ; used 4-bytes by _incr's argument
        
        push eax      ; The `return value` of _incr is stored in EAX. So let's 
                      ; pass it to `printf` as its first argument.
        push str_fmt  ; The second argument for `printf` is the string-format
                      ; whose definition is located at the very beginning of 
                      ; this code.
        call [printf] ; Now let's print out the value stored in EAX.

        add esp, 8    ; And again, reclaim the space being used by the arguments
        
        push 0        ; Be nice and let the system know that everything  
                      ; completed without any errors (like `return 0` in C/C++).
        
        mov  esp, ebp ; Now restore the previous stack pointer 
        pop  ebp

        call [ExitProcess] ; Go back to the calling procedure (system, whatever)

; Import section 
section '.idata' import data readable
 
library kernel32, 'kernel32.dll', \
        msvcrt,'msvcrt.dll'

import kernel32, \
       ExitProcess,'ExitProcess'
 
import  msvcrt, \
        printf, 'printf'