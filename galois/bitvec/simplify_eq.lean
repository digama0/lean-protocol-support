/- This module defines lemmas to simplify equalities between literals. -/
import data.bitvec
import ..vector

namespace bitvec

open vector

local infix `++`:65 := vector.append

section adc_lemmas

@[simp]
theorem adc_match_def {n : ℕ} (r : bool × bitvec n) : adc._match_1 r = r^.fst :: r^.snd :=
begin
  cases r,
  simp [adc._match_1]
end

@[simp]
theorem adc_empty (x y : bitvec 0) (c : bool)
: adc x y c = cons c nil :=
begin
  simp [adc, map_accumr₂_nil, adc_match_def],
end

theorem adc_append1 {n : ℕ} (x : bitvec n) (a : bool) (y : bitvec n) (b : bool) (c : bool)
: adc (x ++ cons a nil) (y ++ cons b nil) c
  = adc x y (bitvec.carry a b c) ++ cons (bitvec.xor3 a b c) nil :=
begin
  apply vector.eq,
  simp [adc, map_accumr₂_append1, adc_match_def]
end

@[simp]
theorem carry_eq (a b : bool) : bitvec.carry a a b = a :=
begin
  unfold bitvec.carry,
  cases a, all_goals { simp }
end

@[simp]
theorem xor3_eq (a b : bool) : bitvec.xor3 a a b = b :=
begin
  unfold bitvec.xor3,
  cases a, all_goals { simp }
end

theorem adc_zero {n : ℕ} (x : bitvec n) : adc x (repeat ff n) ff = (ff :: x) :=
begin
  induction n with n ind,
  { apply vector.eq,
    simp [adc_empty],
  },
  { apply (eq.subst (init_append_last_self x)),
    apply vector.eq,
    simp [repeat_succ_to_append, adc_append1, bitvec.carry, bitvec.xor3, ind (init x)]
  }
end

theorem adc_eq {n : ℕ} (x : bitvec n) (b : bool) : adc x x b = x ++ cons b nil :=
begin
  revert b,
  induction n with n ind,
  { intro b,
    apply vector.eq,
    simp [adc_empty],
  },
  { intro b,
    apply (eq.subst (init_append_last_self x)),
    simp [adc_append1, ind (init x)],
  }
end

end adc_lemmas

section literal_definition_lemmas

open nat

-- Definition of 0
theorem zero_to_repeat (n : ℕ) : (0 : bitvec n) = repeat ff n :=
begin
  refl
end

theorem one_to_repeat (n : ℕ)
: (1 : bitvec (succ n)) = repeat ff n ++ cons tt nil :=
begin
  trivial,
end

theorem bit0_to_repeat {n : ℕ} (x : bitvec (succ n))
: bit0 x = vector.total_tail x ++ cons ff nil :=
begin
  unfold bit0,
  unfold has_add.add bitvec.add,
  apply vector.eq,
  simp [adc_eq, list.tail_append],
end

theorem bit1_to_repeat {n : ℕ} (x : bitvec (succ n))
: bit1 x = vector.total_tail x ++ cons tt nil :=
begin
  unfold bit1,
  unfold has_add.add bitvec.add,
  apply vector.eq,
  simp [one_to_repeat, bit0_to_repeat, adc_append1, bitvec.carry, bitvec.xor3],
  dsimp [nat.succ_sub_one],
  simp [@adc_zero n (total_tail x)]
end

end literal_definition_lemmas

-- Lemmas about total tail of the natural number literal primitives
section total_tail_literal_lemmas

@[simp]
theorem total_tail_zero (n : ℕ)
: vector.total_tail (0 : bitvec n) = 0 :=
begin
  apply vector.eq,
  simp [zero_to_repeat, vector.to_list_total_tail, list.tail_repeat],
end

@[simp]
theorem total_tail_one (n : ℕ)
: vector.total_tail (1 : bitvec n) = 1 :=
begin
  -- Case for n = 0
  cases n with n, simp,
  -- Case for n = 1
  cases n with n, simp,
  -- Case for n ≥ 2
  { apply vector.eq,
    unfold has_one.one,
    trivial,
  }
end

@[simp]
theorem total_tail_bit0 {n : ℕ} (x : bitvec n)
: vector.total_tail (bit0 x) = bit0 (vector.total_tail x) :=
begin
  -- Case for n = 0
  cases n with n, { simp },
  -- Case for n = 1
  cases n with n, { simp },
  -- Case for n ≥ 2
  { apply vector.eq,
    simp [bit0_to_repeat, list.tail_append, vector.length_to_list]
  }
end

@[simp]
theorem total_tail_bit1 {n : ℕ} (x : bitvec n)
: vector.total_tail (bit1 x : bitvec n) = bit1 (vector.total_tail x) :=
begin
  -- Case for n = 0
  cases n with n, { simp },
  -- Case for n = 1
  cases n with n, { simp },
  -- Case for n ≥ 2
  { apply vector.eq,
    simp [bit1_to_repeat, list.tail_append, vector.length_to_list],
  }
end

end total_tail_literal_lemmas

-- Simplification lemmas for bitvector literals
section literal_simplification_literals

-- This tactic simplifies the bitvector equalitiy lemmas
private
meta def simp_bvlit_rule : tactic unit := do
    let lemmas : list expr :=
      [ -- Core lemmas
        expr.const `and_true []
      , expr.const `true_and []
      , expr.const `and_false []
      , expr.const `false_and []
      , expr.const `eq_self_iff_true [level.of_nat 1]
      , expr.const `tt_eq_ff_eq_false []
      , expr.const `ff_eq_tt_eq_false []
        -- Natural number lemmas
      , expr.const `nat.not_succ_eq_zero []
      , expr.const `nat.not_zero_eq_succ []
      , expr.const `nat.succ_sub_succ []
        -- Vector lemmas
      , expr.const `vector.repeat_succ_to_append []
      , expr.const `vector.zero_vec_always_eq [level.of_nat 0]
      , expr.const `vector.cons_eq_cons [level.of_nat 0]
      , expr.const `vector.append_eq_append [level.of_nat 0]
      , expr.const `bitvec.zero_to_repeat []
      , expr.const `bitvec.one_to_repeat []
      , expr.const `bitvec.bit0_to_repeat []
      , expr.const `bitvec.bit1_to_repeat []
      ] in do
    s ← simp_lemmas.mk.append lemmas,
    tactic.simp_target s,
    tactic.try (tactic.reflexivity)

@[simp]
theorem zero_eq_one  (n : ℕ) : (0 : bitvec n) = 1 ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem zero_eq_bit0 {n : ℕ} (y : bitvec n) : (0 : bitvec n) = bit0 y ↔ 0 = vector.total_tail y :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem zero_eq_bit1 {n : ℕ} (y : bitvec n) : (0 : bitvec n) = bit1 y ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem one_eq_zero (n : ℕ)                 : (1 : bitvec n) = 0      ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem one_eq_bit0 {n : ℕ} (y : bitvec n)  : (1 : bitvec n) = bit0 y ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem one_eq_bit1 {n : ℕ} (y : bitvec n)  : (1 : bitvec n) = bit1 y ↔ 0 = vector.total_tail y :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit0_eq_zero {n : ℕ} (x   : bitvec n) : bit0 x = 0      ↔ vector.total_tail x = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit0_eq_one  {n : ℕ} (x   : bitvec n) : bit0 x = 1      ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit0_eq_bit0 {n : ℕ} (x y : bitvec n) : bit0 x = bit0 y ↔ vector.total_tail x = vector.total_tail y :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit0_eq_bit1 {n : ℕ} (x y : bitvec n) : bit0 x = bit1 y ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit1_eq_zero {n : ℕ} (x : bitvec n)   : bit1 x = 0      ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit1_eq_one  {n : ℕ} (x : bitvec n)   : bit1 x = 1      ↔ vector.total_tail x = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit1_eq_bit0 {n : ℕ} (x y : bitvec n) : bit1 x = bit0 y ↔ n = 0 :=
begin cases n, all_goals { simp_bvlit_rule } end

@[simp]
theorem bit1_eq_bit1 {n : ℕ} (x y : bitvec n) : bit1 x = bit1 y ↔ vector.total_tail x = vector.total_tail y :=
begin cases n, all_goals { simp_bvlit_rule } end

end literal_simplification_literals

end bitvec
