------------------------------------------------------------------------
-- The Agda standard library
--
-- Properties satisfied by lattices
------------------------------------------------------------------------

{-# OPTIONS --without-K #-}

open import Relation.Binary.Lattice

module Relation.Binary.Properties.Lattice
  {c ℓ₁ ℓ₂} (L : Lattice c ℓ₁ ℓ₂) where

open Lattice L

import Algebra as Alg
import Algebra.Structures as Alg
open import Algebra.FunctionProperties _≈_
open import Data.Product using (_,_)
open import Function using (flip)
open import Relation.Binary
open import Relation.Binary.Properties.Poset poset
import Relation.Binary.Properties.JoinSemilattice joinSemilattice as J
import Relation.Binary.Properties.MeetSemilattice meetSemilattice as M
import Relation.Binary.EqReasoning as EqReasoning
import Relation.Binary.PartialOrderReasoning as POR

∨-absorbs-∧ : _∨_ Absorbs _∧_
∨-absorbs-∧ x y =
  let x≤x∨[x∧y] , _ , least = supremum  x (x ∧ y)
      x∧y≤x     , _ , _     = infimum x y
  in antisym (least x refl x∧y≤x) x≤x∨[x∧y]

∧-absorbs-∨ : _∧_ Absorbs _∨_
∧-absorbs-∨ x y =
  let x∧[x∨y]≤x , _ , greatest = infimum  x (x ∨ y)
      x≤x∨y     , _ , _        = supremum x y
  in antisym x∧[x∨y]≤x (greatest x refl x≤x∨y)

absorptive : Absorptive _∨_ _∧_
absorptive = ∨-absorbs-∧ , ∧-absorbs-∨

∧≤∨ : ∀ {x y} → x ∧ y ≤ x ∨ y
∧≤∨ {x} {y} = begin
  x ∧ y ≤⟨ x∧y≤x x y ⟩
  x     ≤⟨ x≤x∨y x y ⟩
  x ∨ y ∎
  where open POR poset

-- two quadrilateral arguments

quadrilateral₁ : ∀ {x y} → x ∨ y ≈ x → x ∧ y ≈ y
quadrilateral₁ {x} {y} x∨y≈x = begin
  x ∧ y       ≈⟨ M.∧-cong (Eq.sym x∨y≈x) Eq.refl ⟩
  (x ∨ y) ∧ y ≈⟨ M.∧-comm _ _ ⟩
  y ∧ (x ∨ y) ≈⟨ M.∧-cong Eq.refl (J.∨-comm _ _) ⟩
  y ∧ (y ∨ x) ≈⟨ ∧-absorbs-∨ _ _ ⟩
  y           ∎
  where open EqReasoning setoid

quadrilateral₂ : ∀ {x y} → x ∧ y ≈ y → x ∨ y ≈ x
quadrilateral₂ {x} {y} x∧y≈y = begin
  x ∨ y       ≈⟨ J.∨-cong Eq.refl (Eq.sym x∧y≈y) ⟩
  x ∨ (x ∧ y) ≈⟨ ∨-absorbs-∧ _ _ ⟩
  x           ∎
  where open EqReasoning setoid

-- collapsing sublattice

collapse₁ : ∀ {x y} → x ≈ y → x ∧ y ≈ x ∨ y
collapse₁ {x} {y} x≈y = begin
  x ∧ y ≈⟨ M.y≤x⇒x∧y≈y y≤x ⟩
  y     ≈⟨ Eq.sym x≈y ⟩
  x     ≈⟨ Eq.sym (J.x≤y⇒x∨y≈y y≤x) ⟩
  y ∨ x ≈⟨ J.∨-comm _ _ ⟩
  x ∨ y ∎
  where
  y≤x = reflexive (Eq.sym x≈y)
  open EqReasoning setoid

-- this can also be proved by quadrilateral argument, but it's much less symmetric.
collapse₂ : ∀ {x y} → x ∨ y ≤ x ∧ y → x ≈ y
collapse₂ {x} {y} ∨≤∧ = antisym
  (begin x     ≤⟨ x≤x∨y _ _ ⟩
         x ∨ y ≤⟨ ∨≤∧ ⟩
         x ∧ y ≤⟨ x∧y≤y _ _ ⟩
         y     ∎)
  (begin y     ≤⟨ y≤x∨y _ _ ⟩
         x ∨ y ≤⟨ ∨≤∧ ⟩
         x ∧ y ≤⟨ x∧y≤x _ _ ⟩
         x     ∎)
  where open POR poset

------------------------------------------------------------------------
-- The dual construction is also a lattice.

∧-∨-isLattice : IsLattice _≈_ (flip _≤_) _∧_ _∨_
∧-∨-isLattice = record
  { isPartialOrder = invIsPartialOrder
  ; supremum       = infimum
  ; infimum        = supremum
  }

∧-∨-lattice : Lattice c ℓ₁ ℓ₂
∧-∨-lattice = record
  { _∧_       = _∨_
  ; _∨_       = _∧_
  ; isLattice = ∧-∨-isLattice
  }

------------------------------------------------------------------------
-- Every order-theoretic lattice can be turned into an algebraic one.

isAlgLattice : Alg.IsLattice _≈_ _∨_ _∧_
isAlgLattice = record
  { ∨-isSemilattice = record
    { isBand = record
      { isSemigroup = record
        { isMagma = record
          { isEquivalence = isEquivalence
          ; ∙-cong        = J.∨-cong
          }
        ; assoc = J.∨-assoc
        }
      ; idem = J.∨-idempotent
      }
    ; comm = J.∨-comm
    }
  ; ∧-isSemilattice = record
    { isBand = record
      { isSemigroup = record
        { isMagma = record
          { isEquivalence = isEquivalence
          ; ∙-cong        = M.∧-cong
          }
        ; assoc = M.∧-assoc
        }
      ; idem = M.∧-idempotent
      }
    ; comm = M.∧-comm
    }
  ; absorptive    = absorptive
  }

algLattice : Alg.Lattice c ℓ₁
algLattice = record
  { isLattice = isAlgLattice
  }
