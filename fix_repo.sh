#!/usr/bin/env bash
# Pulizia della repo MachineLearningProject.
# ESEGUIRE DALLA ROOT DELLA REPO, dopo aver copiato qui:
#   README.md, .gitignore, LICENSE (sovrascrivi il vecchio .gitignore)
set -e

echo "== 1. Rinomino i notebook senza estensione =="
# git mv "notebooks/01 - EDA"       "notebooks/01_EDA.ipynb"
# git mv "notebooks/02 - MakeSplit" "notebooks/02_MakeSplit.ipynb"

echo "== 2. Rinomino il test script =="
# git mv test_Computer_Engineering.ipynb inference.ipynb

echo "== 3. Rimuovo i duplicati in results/ =="
# git rm "results/realwaste_confusion_aug_light(1).png"
# git rm "results/realwaste_per_class_tpr_aug_light(1).csv"

echo "== 4. Tolgo dataset e pesi dal versionamento (restano su disco) =="
# git rm -r --cached dataset
# git rm --cached regnety16gf_acq_mild.pth

git config --global user.email "erri.gioia@gmail.com"
git config --global user.name "Errico Gioia"

echo "== 5. Aggiungo README, .gitignore, LICENSE =="
git add README.md .gitignore LICENSE
git add -A

echo "== 6. Riscrivo la history con un unico commit pulito =="
# Indispensabile: il dataset resterebbe altrimenti nella history (~550 MB)
git checkout --orphan clean-main
git add -A
git commit -m "Waste type identification - ML project (UNISA 2026)"
git branch -D main
git branch -m main

echo ""
echo "Fatto! Ora esegui manualmente:"
echo ""
echo "  1) git push -f origin main"
echo ""
echo "  2) (opzionale) per liberare i ~280 MB della vecchia history in locale:"
echo "     git update-ref -d refs/remotes/origin/HEAD 2>/dev/null"
echo "     git reflog expire --expire=now --all && git gc --prune=now"
echo ""
echo "  3) Pubblica i pesi come Release:"
echo "     GitHub -> Releases -> 'Draft a new release' -> tag v1.0"
echo "     e trascina regnety16gf_acq_mild.pth tra gli asset."
