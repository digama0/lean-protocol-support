import galois.tactic
       galois.list.take_drop_lemmas

namespace nat

lemma lt_succ_ne_lt (a b : ℕ) :
  a < nat.succ b →  a ≠ b → a < b :=
begin
intros lt ne,
cases lt with x succ_lt,
{ contradiction, },
{ exact succ_lt, }
end

lemma pos_subtract (n k : ℕ)
  (Hn : 0 < n) (Hk : 0 < k)
  : (n - k) < n
:= begin
cases n, exfalso, apply (@@lt_irrefl _ _), apply Hn,
cases k, exfalso, apply (@@lt_irrefl _ _), apply Hk,
rename a n, rename a_1 k, clear Hn Hk,
rw nat.succ_sub_succ,
apply lt_of_le_of_lt, apply nat.sub_le_sub_left,
apply nat.zero_le, rw nat.sub_zero,
apply nat.lt_succ_self
end

lemma le_of_div_succ
  {n k p : ℕ}
  (H : n / k = nat.succ p)
 : k ≤ n
:=
begin
rw nat.div_def at H,
by_cases ((0 < k ∧ k ≤ n)) with h; simp [h] at H,
{ cases h,
  assumption,
},
{
  contradiction,
}
end

lemma drop_drops_one : forall index drop_size,
drop_size ≠ 0 →
drop_size ≤ index ->
index / drop_size = ((index - drop_size) / drop_size) + 1 :=
begin
intros, rw nat.div_def,
by_cases (0 < drop_size ∧ drop_size ≤ index) with h;
simp [h],
{
  exfalso, apply h,
  split,
  { destruct drop_size; intros; subst drop_size,
    {
      contradiction,
    },
    {
      simp [nat.lt_is_succ_le], have e : (nat.succ a_2) = 1 + a_2, simp,
        rw e, apply nat.le_add_right
    }
  },
  {
   assumption,
  }
}
end

lemma drops_decreases : forall drop_size index,
drop_size ≠ 0 →
drop_size ≤ index ->
((index - drop_size) / drop_size) < index /drop_size :=
begin
intros,
rw (drop_drops_one index); try {assumption},
apply nat.lt.base,
end

lemma lt_of_div_succ_2
  {n k p : ℕ}
  (H : n / k = p.succ)
 : (n - k) / k = p
:=
begin
cases k with k, simp at *, contradiction,
have dps := drop_drops_one n (nat.succ k),
have neO : nat.succ k ≠ 0, {contradiction},
specialize dps neO,
clear neO,
specialize dps (nat.le_of_div_succ H),
rw dps at H, rw <- nat.succ_eq_add_one at H,
injection H
end

lemma sub_le_le (m n k : ℕ)
 (Hmn : m ≤ n)
 (H : m ≤ k)
 : m + (n - k) ≤ n
:= begin
induction H,
apply le_of_eq,
apply nat.add_sub_of_le, assumption,
rw nat.sub_succ, apply le_trans,
tactic.swap, apply ih_1,
apply nat.add_le_add_left,
apply nat.pred_le,
end


lemma sub_pos_le (n k : ℕ) (Hk : 0 < k) (Hn : 0 < n)
  : n - k + 1 ≤ n
:= begin
cases k, exfalso, apply nat.lt_irrefl, assumption,
rw nat.sub_succ,
rw nat.add_comm,
rw nat.one_add,
cases n, exfalso, apply nat.lt_irrefl, assumption,
rename a k, rename a_1 n,
apply nat.succ_le_succ,
clear Hk Hn,
apply le_trans,
apply nat.pred_le_pred,
apply nat.sub_le,
apply le_refl,
end

lemma sub_1_succ : forall (n b : ℕ),
n - 1 - b = n - nat.succ b :=
begin
intros n,
induction n; intros,
{ dsimp, cases b,
  {refl},
  { simp }
},
{
  simp,
}
end

lemma lt_succ_both : forall a b, nat.succ a < nat.succ b -> a < b :=
begin
intros,  simp [nat.lt_is_succ_le, nat.succ_le_succ_iff] at *, apply a_1,
end

lemma max_subtract : forall (a b : nat),
(max a b) - b = a - b :=
begin
intros a b, unfold max,
apply (if H : a ≤ b then _ else _),
{ rw (if_pos H), rw nat.sub_eq_zero_of_le,
  rw nat.sub_eq_zero_of_le, assumption,
  apply le_refl,
 },
{ rw (if_neg H), }
end

lemma mul_2_add {n : nat} : n * 2 = n + n
:= begin
induction n, simp,
dsimp [has_mul.mul, nat.mul],
simp,
end

lemma le_add_r {x y : nat} : x ≤ x + y
:= begin
induction y, simp,
apply le_trans, assumption,
apply nat.add_le_add_left, constructor,
constructor,
end

lemma le_add_compat {x y x' y' : nat}
  (Hx : x ≤ x') (Hy : y ≤ y') : x + y ≤ x' + y'
:= begin
induction Hx, apply nat.add_le_add_left, assumption,
apply le_trans, apply ih_1,
simp, apply nat.add_le_add_left, constructor,
constructor,
end

lemma max_same (n : ℕ) : max n n = n
:= begin
unfold max, rw (if_pos (le_refl n)),
end

lemma max_add {m n k : ℕ} : max (m + k) (n + k) = max m n + k
:= begin
unfold max,
apply (if H : m ≤ n then _ else _),
rw (if_pos H), rw if_pos,
apply nat.add_le_add_right, assumption,
rw (if_neg H), rw if_neg,
intros contra, apply H, rw ← nat.add_le_add_iff_le_right,
assumption,
end

lemma neg_le_le (x y : ℕ) (H : ¬ x ≤ y)
  : y ≤ x
:= begin
apply (if H' : y ≤ x then _ else _),
assumption, exfalso,
have H1 := @nat.le_total x y,
induction H1; contradiction,
end

lemma max_mono {x y x' y' : ℕ} (Hx : x ≤ x') (Hy : y ≤ y')
  : max x y ≤ max x' y'
:= begin
unfold max,
apply (if H : x ≤ y then _ else _),
{ rw (if_pos H),
  apply (if H' : x' ≤ y' then _ else _),
  rw (if_pos H'), assumption,
  rw (if_neg H'), apply le_trans, assumption,
  apply nat.neg_le_le, assumption,
},
{ rw (if_neg H),
  apply (if H' : x' ≤ y' then _ else _),
  rw (if_pos H'), apply le_trans; assumption,
  rw (if_neg H'), assumption,
}
end

lemma max_0_r (x : ℕ) : max x 0 = x
:= begin
unfold max,
apply (if H : x ≤ 0 then _ else _),
rw (if_pos H), symmetry, rw ← nat.le_zero_iff,
assumption, rw if_neg, assumption,
end

end nat