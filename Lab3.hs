module Lab3 where

import X86
import Text
import RunAsm

{-

LAB 3: Assembly programming

DUE: Thursday, February 15, 11:59 PM

This laboratory will allow you to demonstrate facility with simple programming
in x86 assembly.  You will be asked to write a series of assembly functions
manipulating 0-terminated arrays of (64-bit signed) integers.  There are many
ways to write each of these functions; you should not worry about either
runtime, instruction, or register efficiency.

The runtime harness is similar to the in-class examples.  Each of your solutions
should provide a global label "function"; this will be called passing (a pointer
to) an array as its only argument.  The final element of the array will be a
'0'; there will not be any other '0's in the array, but you should not make any
other assumptions about array elements.

We have provided two ways of running your solutions.  `runAsmResult` will call
the provided assembly with several examples arrays, printing the returned value
in each case.  Use this function to run examples 1-3.  `runAsmArray` will call
the provided assembly with several example arrays, printing the arrays after the
function returns.  Use this function to run examples 4-5.  These are implemented
in runtimer.c and runtimea.c respectively, if you want to add your own test
cases.

These problems will be made significantly easier with the use of indirect
addressing.  As with the other features of x86 assembly, we have provided syntax
to help construct indirect references.  However, it is not quite as close the
the underlying assembly:

    movq ~#RDI ~%RAX          -- movq (%rdi), %rax
    movq ~#(4, RDI) ~%RAX     -- movq 4(%rdi), %rax

Also, these problems may bring you up against a limitation of the x86
instruction set we have not previously discussed: an individual x86 instruction
can operate on one indirect reference, but not two.  So, while you can do

    cmpq ~#RDI ~%RAX            -- cmpq %(rdi), %rax

or

    cmpq ~%RAX ~#RDI            -- cmpq %rax, %(rdi)

you cannot do

    cmpq ~#RSI ~#RDI            -- cmpq %(rsi), %(rdi)

Use temporary registers as necessary.

-}

--------------------------------------------------------------------------------
-- Win64 calling convention nonsense                                          --
-- Your solutions will NOT be tested on Win64, so you only need to include    --
-- this shim if you are using Windows yourself.                               --
import System.Info (os)
firstArgToRDI
    | os == "mingw32" = [movq ~%RCX ~%RDI]
    | otherwise = []
--------------------------------------------------------------------------------

-- Regsiters that can be used
-- RAX, RCX, RDX, RDI, RSI

-- Write a function which returns (in RAX) the length of the input array
problem1 =
  [ global "function"
    [ movq ~%r_array ~%r_start
    ]
  , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , addq ~$8 ~%r_array
    , jmp ~$$"test"
    ]
  , text "ret"
    [ subq ~%r_start ~%r_array
    , movq ~%r_array ~%RAX
    , shrq ~$3 ~%RAX
    , retq
    ]
  ]
    where r_start = RSI
          r_array = RDI

-- Write a function which returns (in RAX) the largest number appearing in the
-- input array.

problem2 = 
  [ global "function"
    [ movq ~$0 ~%m_largest 
    ]
  , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , cmpq ~#r_array  ~%m_largest
    , j Lt ~$$"numax"
    , addq ~$8 ~%r_array
    , jmp ~$$"test"
    ]
  , text "numax"
    [ movq ~#r_array ~%m_largest
    , jmp ~$$"test"
    ]
  , text "ret"
    [ movq ~%m_largest ~%RAX
    , retq
    ]
  ]
    where m_largest = RSI
          r_array = RDI

-- Write a function which returns the sum of the  values in the input array
problem3 =
  [ global "function"
    [ movq ~$0 ~%m_accumulator
    ]
  , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , addq ~#r_array ~%m_accumulator
    , addq ~$8 ~%r_array
    , jmp ~$$"test"
    ]
  , text "ret"
    [ movq ~%m_accumulator ~%RAX
    , retq
    ]
  ]
    where m_accumulator = RSI
          r_array = RDI

-- Write a function which returns *the index of* the largest number appearing in
-- the input array.  For example, if the input array is 4 -2 3 6 1 0, then your
-- function should return 3.
problem4 =
  [ global "function"
    [ movq ~$0 ~%m_largest 
    , movq ~$0 ~%m_largest_ind
    , movq ~$0 ~%m_counter 
    ]
  , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , cmpq ~#r_array  ~%m_largest
    , j Lt ~$$"numax"
    , addq ~$8 ~%r_array
    , addq ~$1 ~%m_counter
    , jmp ~$$"test"
    ]
  , text "numax"
    [ movq ~#r_array ~%m_largest
    , movq ~%m_counter ~%m_largest_ind
    , jmp ~$$"test"
    ]
  , text "ret"
    [ movq ~%m_largest_ind ~%RAX
    , retq
    ]
  ]
    where m_largest = RSI
          r_array = RDI
          m_largest_ind = R12
          m_counter = R13


-- Write a function which reverses the elements in the input array.  Do not use
-- any additional storage (for example, on the stack).  This will require
-- somewhat more algorithmic sophistication than the previous examples.
problem5 =
  [ global "function"
    [ movq ~%r_array ~%r_start
    , movq ~%r_start ~%r_end
    ]
    , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , addq ~$8 ~%r_array
    , jmp ~$$"test"
    ]
    , text "ret"
    [ subq ~%r_start ~%r_array
    , movq ~%r_array ~%m_length
    , shrq ~$3 ~%m_length
    , jmp ~$$"rev"
    ]
  , text "rev"
    [ shlq ~$3 ~%m_length
    , subq ~$8 ~%m_length
    , addq ~%m_length ~%r_end
    , cmpq ~%r_start ~%r_end
    , j Eq ~$$"ret_rev"
    , jmp ~$$"move"
    ]
  , text "move"
    [ movq ~#r_start ~%r_temp1
    , movq ~#r_end ~%r_temp2
    , movq ~%r_temp2  ~#r_start
    , movq ~%r_temp1 ~#r_end
    , cmpq ~%r_start ~%r_end
    , j Eq ~$$"ret_rev"
    , addq ~$8 ~%r_start
    , subq ~$8 ~%r_end
    , jmp ~$$"move"
    ]
  , text "ret_rev"
    [
      retq
    ]
  ]
    where r_start = RSI
          m_length = RDX
          r_end = R14 
          r_temp1 = R12
          r_temp2 = R13
          r_array = RDI


-- Write a function which sorts the input array; use no additional storage
-- (either explicitly or implicitly).  Your sort should run in n^2 time or less,
-- but you do not need to demonstrate any sophistication in your sorting
-- algorithm.
problem6 =
  [ global "function"
    [ movq ~%r_array ~%r_start
    , movq ~%r_start ~%r_end
    ]
    , text "test"
    [ cmpq ~$0 ~#r_array
    , j Eq ~$$"ret"
    , addq ~$8 ~%r_array
    , jmp ~$$"test"
    ]
    , text "ret"
    [ subq ~%r_start ~%r_array
    , movq ~%r_array ~%m_length
    , shrq ~$3 ~%m_length
    , jmp ~$$"rev"
    ]
  , text "rev"
    [ shlq ~$3 ~%m_length
    , subq ~$8 ~%m_length
    , addq ~%m_length ~%r_end
    , jmp ~$$"inc"
    ]
  , text "inc"
    [ cmpq ~%r_start ~%r_end
    , j Eq ~$$"ret_rev"
    , cmpq ~#r_start ~#r_end
    , j Lt ~$$"swap"
    , addq ~$8 ~%r_start
    , subq ~$8 ~%r_end
    , jmp ~$$"inc"
    ]  
  , text "swap"
    [ movq ~#r_start ~%r_temp1
    , movq ~#r_end ~%r_temp2
    , movq ~%r_temp2  ~#r_start
    , movq ~%r_temp1 ~#r_end
    , cmpq ~%r_start ~%r_end
    , j Eq ~$$"ret_rev"
    , jmp ~$$"inc"
    ]
  , text "ret_rev"
    [
      retq
    ]
  ]
    where r_start = RSI
          m_length = RDX
          r_end = R14 
          r_temp1 = R12
          r_temp2 = R13
          r_array = RDI
