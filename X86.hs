{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE TypeFamilies #-}
module X86 where

import Data.Bits
import Data.Char
import Data.Int
import Data.Word

--------------------------------------------------------------------------------
-- Instructions
--------------------------------------------------------------------------------

data Immediate =
    Literal Int64
  | Label String
  deriving (Eq, Show)

data Register =
    RAX | RBX | RCX | RDX
  | RSI | RDI | RBP | RSP
  | R08 | R09 | R10 | R11 | R12 | R13 | R14 | R15
  deriving (Eq, Ord, Show)

data Operand =
    Imm Immediate           -- $5
  | Reg Register            -- %rax
  | IndImm Immediate        -- (label)
  | IndReg Register         -- (%rax)
  | IndBoth Int64 Register  -- -4(%rax)
  deriving (Eq, Show)

data Condition = Eq | Neq | Gt | Ge | Lt | Le
  deriving (Eq, Show)

data Operation =
    Movq | Pushq | Popq
  | Leaq
  | Incq | Decq | Negq | Notq
  | Addq | Subq | Imulq | Xorq | Orq | Andq
  | Shlq | Sarq | Shrq
  | Jmp | J Condition
  | Cmpq | Set Condition
  | Callq | Retq
  deriving (Eq, Show)

type Instruction = (Operation, [Operand])

--------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------

-- Subject to change
data Data = String [Char] | Word Immediate
  deriving (Eq, Show)

data Asm = Text [Instruction] | Data [Data]
  deriving (Eq, Show)

type Prog = [(String, Bool, Asm)]

--------------------------------------------------------------------------------
-- Convenience functions
--------------------------------------------------------------------------------


(~~) :: Instruction -> Operand -> Instruction
(~$) :: Instruction -> Int64 -> Instruction
(~$$) :: Instruction -> String -> Instruction
(~%) :: Instruction -> Register -> Instruction

(op, operands) ~~ operand = (op, operands ++ [operand])
instr ~$ i = instr ~~ Imm (Literal i)
instr ~$$ l = instr ~~ Imm (Label l)
instr ~% r = instr ~~ Reg r

class IndirectReference r
    where (~#) :: Instruction -> r -> Instruction

instance IndirectReference String
    where instr ~# l = instr ~~ IndImm (Label l)

instance IndirectReference Register
    where instr ~# r = instr ~~ IndReg r

instance a ~ Int64 => IndirectReference (a, Register)
    where instr ~# (i, r) = instr ~~ IndBoth i r

(~#$) :: Instruction -> Int64 -> Instruction
instr ~#$ i = instr ~~ IndImm (Literal i)

global, text :: String -> [Instruction] -> (String, Bool, Asm)
global l ops = (l, True, Text ops)
text l ops = (l, False, Text ops)

movq, pushq, popq, leaq, incq, decq, negq, notq, addq, subq, imulq, xorq, orq, andq,
   shlq, sarq, shrq, jmp, cmpq, callq, retq :: Instruction

makeInstr :: Operation -> Instruction
makeInstr op = (op, [])

movq  = makeInstr Movq
pushq = makeInstr Pushq
popq  = makeInstr Popq
leaq  = makeInstr Leaq
incq  = makeInstr Incq
decq  = makeInstr Decq
negq  = makeInstr Negq
notq  = makeInstr Notq
addq  = makeInstr Addq
subq  = makeInstr Subq
imulq = makeInstr Imulq
xorq  = makeInstr Xorq
orq   = makeInstr Orq
andq  = makeInstr Andq
shlq  = makeInstr Shlq
sarq  = makeInstr Sarq
shrq  = makeInstr Shrq
jmp   = makeInstr Jmp
cmpq  = makeInstr Cmpq
callq = makeInstr Callq
retq  = makeInstr Retq

j, set :: Condition -> Instruction
j   = makeInstr . J
set = makeInstr . Set
